"""
Orchestrateur ETL : Extract (Mongo, filtre par flux) -> Transform -> Load (MySQL upsert),
avec suivi via sync_runs / sync_state (incremental + audit).
"""
import os
import uuid
import logging
from datetime import datetime, timezone
from typing import List, Optional

import pandas as pd
from sqlalchemy import text

from .extractor import MongoExtractor
from .transformer import DataTransformer
from .loader import SQLLoader
from .flows import FlowConfig, load_flows

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class ETLPipeline:
    def __init__(
        self,
        flows: Optional[List[FlowConfig]] = None,
        mongo_uri: Optional[str] = None,
        mongo_db: Optional[str] = None,
        sql_uri: Optional[str] = None,
        flows_path: str = "config/flows.yaml",
    ):
        self.flows = flows or load_flows(flows_path)
        self.extractor = MongoExtractor(uri=mongo_uri, db_name=mongo_db)
        self.transformer = DataTransformer()
        self.loader = SQLLoader(connection_string=sql_uri)

    # --- sync_runs / sync_state bookkeeping -------------------------------

    def _get_last_synced_at(self, flow_name: str):
        with self.loader.engine.connect() as conn:
            row = conn.execute(
                text("SELECT last_synced_at FROM sync_state WHERE flow_name = :f"),
                {"f": flow_name},
            ).fetchone()
            return row[0] if row else None

    def _update_sync_state(self, flow_name: str, run_id: str, max_date):
        with self.loader.engine.begin() as conn:
            conn.execute(
                text(
                    """
                    INSERT INTO sync_state (flow_name, last_synced_at, last_success_run_id)
                    VALUES (:f, :d, :r)
                    ON DUPLICATE KEY UPDATE
                        last_synced_at = VALUES(last_synced_at),
                        last_success_run_id = VALUES(last_success_run_id)
                    """
                ),
                {"f": flow_name, "d": max_date, "r": run_id},
            )

    def _record_run_start(self, run_id: str, flows_scope: str):
        with self.loader.engine.begin() as conn:
            conn.execute(
                text(
                    """
                    INSERT INTO sync_runs (run_id, started_at, status, flows_scope)
                    VALUES (:r, :s, 'running', :fs)
                    """
                ),
                {"r": run_id, "s": datetime.now(timezone.utc), "fs": flows_scope},
            )

    def _record_run_end(self, run_id: str, status: str, docs_written: int, docs_failed: int, errors: List[str], duration: float):
        with self.loader.engine.begin() as conn:
            conn.execute(
                text(
                    """
                    UPDATE sync_runs
                    SET ended_at = :e, status = :st, docs_written = :dw,
                        docs_failed = :df, error_message = :em, duration_seconds = :d
                    WHERE run_id = :r
                    """
                ),
                {
                    "e": datetime.now(timezone.utc),
                    "st": status,
                    "dw": docs_written,
                    "df": docs_failed,
                    "em": "; ".join(errors) if errors else None,
                    "d": duration,
                    "r": run_id,
                },
            )

    # --- run ----------------------------------------------------------------

    def run(self, flow_names: Optional[List[str]] = None, dry_run: bool = False) -> dict:
        run_id = os.getenv("GITHUB_RUN_ID") or str(uuid.uuid4())
        started = datetime.now(timezone.utc)
        target_flows = [f for f in self.flows if not flow_names or f.name in flow_names]

        logger.info(f"Run {run_id} : {len(target_flows)} flux ({'DRY RUN' if dry_run else 'ecriture MySQL'}).")

        self.extractor.connect()
        if not dry_run:
            self.loader.connect()
            self._record_run_start(run_id, ",".join(f.name for f in target_flows))

        total_docs = 0
        docs_failed = 0
        errors: List[str] = []

        for flow in target_flows:
            try:
                since = None if dry_run else self._get_last_synced_at(flow.name)
                query = flow.mongo_query(since=since)
                max_date_seen = since
                flow_docs = 0

                logger.info(f"[{flow.name}] requete Mongo: {query}")

                for batch in self.extractor.extract_with_query(
                    flow.source_collection, query=query, projection=flow.projection
                ):
                    df = self.transformer.transform_flow(batch, flow)
                    if df.empty:
                        continue

                    # Le nom de la colonne _id peut avoir ete renomme par le
                    # transformer (convention legacy X_id) - convertir la
                    # colonne qui sert reellement de cle primaire pour ce flux.
                    id_col = flow.primary_key if flow.primary_key in df.columns else "_id"
                    if id_col in df.columns:
                        df[id_col] = df[id_col].astype(str)

                    if dry_run:
                        logger.info(f"[DRY RUN][{flow.name}] +{len(df)} lignes | colonnes: {list(df.columns)}")
                    else:
                        self.loader.load_data(df, flow.target_table, primary_key=flow.primary_key)

                    flow_docs += len(df)

                    if flow.date_field in df.columns:
                        batch_max = df[flow.date_field].max()
                        if pd.notna(batch_max):
                            # MySQL DATETIME (sync_state.last_synced_at) est naif ;
                            # transform_flow produit des Timestamp UTC tz-aware.
                            # Normaliser en naif partout pour rendre la comparaison
                            # et le stockage coherents (bug reel observe en prod :
                            # "can't compare offset-naive and offset-aware datetimes").
                            if batch_max.tzinfo is not None:
                                batch_max = batch_max.tz_localize(None)
                            if max_date_seen is None or batch_max > max_date_seen:
                                max_date_seen = batch_max

                total_docs += flow_docs
                logger.info(f"[{flow.name}] termine: {flow_docs} lignes.")

                if not dry_run and max_date_seen is not None:
                    self._update_sync_state(flow.name, run_id, max_date_seen)

            except Exception as e:
                logger.error(f"[{flow.name}] erreur: {e}")
                errors.append(f"{flow.name}: {e}")
                docs_failed += 1

        self.extractor.close()

        duration = (datetime.now(timezone.utc) - started).total_seconds()
        status = "failed" if errors else "success"

        if not dry_run:
            self._record_run_end(run_id, status, total_docs, docs_failed, errors, duration)
            self.loader.close()

        result = {
            "run_id": run_id,
            "status": status,
            "duration_seconds": duration,
            "flows_processed": len(target_flows) - docs_failed,
            "total_docs": total_docs,
            "errors": errors,
        }
        logger.info(f"Run {run_id} termine: {result}")
        return result


if __name__ == "__main__":
    import argparse
    import sys

    parser = argparse.ArgumentParser()
    parser.add_argument("--flows", nargs="*", default=None, help="Sous-ensemble de flux a executer (par nom)")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    pipeline = ETLPipeline()
    result = pipeline.run(flow_names=args.flows, dry_run=args.dry_run)

    # IMPORTANT: sans ceci, un run avec des flux en erreur (ex: connexion
    # MySQL refusee) se termine quand meme avec exit code 0 - GitHub Actions
    # rapporterait "success" a tort. Deja arrive en production (2026-07-01):
    # 4 flux sur 5 en erreur, workflow marque vert.
    if result["status"] != "success":
        sys.exit(1)
