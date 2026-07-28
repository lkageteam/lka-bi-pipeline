"""
Pipeline de synchronisation des tables Excel (referentiels statiques,
pas de MongoDB) depuis un dossier Google Drive partage.
"""
import logging
import os
import tempfile
from dataclasses import dataclass
from typing import List, Optional

import pandas as pd
import yaml
from sqlalchemy import text

from .drive_sync import DriveClient
from .loader import SQLLoader

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@dataclass
class ExcelFlowConfig:
    name: str
    match: str
    target_table: str
    target_database: str = "tsa_activities"
    sheet: object = 0


def load_excel_flows(path: str = "config/excel_flows.yaml") -> List[ExcelFlowConfig]:
    with open(path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f)
    return [ExcelFlowConfig(**entry) for entry in raw.get("excel_flows", [])]


class ExcelPipeline:
    def __init__(self, flows: Optional[List[ExcelFlowConfig]] = None, sql_uri: Optional[str] = None):
        self.flows = flows or load_excel_flows()
        self.drive = DriveClient()
        self.loader = SQLLoader(connection_string=sql_uri)

    # Table d'etat : memorise la date de modification Drive deja chargee
    # pour chaque flux, afin de ne recharger QUE ce qui a change. C'est ce
    # qui permet d'augmenter la frequence du cron (reaction rapide aux
    # depots manuels de l'equipe) sans recharger inutilement des fichiers
    # inchanges - demande du 2026-07-28 (le metier se plaignait du delai
    # jusqu'a 24h entre un depot Drive et sa visibilite en base).
    STATE_DATABASE = "tsa_activities"
    STATE_TABLE = "_excel_sync_state"

    def _ensure_state_table(self) -> None:
        with self.loader.engine.begin() as conn:
            conn.execute(text(f"CREATE DATABASE IF NOT EXISTS `{self.STATE_DATABASE}` CHARACTER SET utf8mb4"))
            conn.execute(text(f"""
                CREATE TABLE IF NOT EXISTS `{self.STATE_DATABASE}`.`{self.STATE_TABLE}` (
                    flow_name     VARCHAR(128) NOT NULL PRIMARY KEY,
                    file_id       VARCHAR(128),
                    file_name     VARCHAR(255),
                    modified_time VARCHAR(64),
                    rows_loaded   BIGINT,
                    synced_at     DATETIME
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
            """))

    def _read_state(self) -> dict:
        with self.loader.engine.begin() as conn:
            rows = conn.execute(text(
                f"SELECT flow_name, modified_time FROM `{self.STATE_DATABASE}`.`{self.STATE_TABLE}`"
            )).fetchall()
        return {r[0]: r[1] for r in rows}

    def _write_state(self, flow_name: str, match: dict, rows: int) -> None:
        with self.loader.engine.begin() as conn:
            conn.execute(text(f"""
                INSERT INTO `{self.STATE_DATABASE}`.`{self.STATE_TABLE}`
                    (flow_name, file_id, file_name, modified_time, rows_loaded, synced_at)
                VALUES (:fn, :fid, :name, :mt, :rows, NOW())
                ON DUPLICATE KEY UPDATE
                    file_id=VALUES(file_id), file_name=VALUES(file_name),
                    modified_time=VALUES(modified_time), rows_loaded=VALUES(rows_loaded),
                    synced_at=VALUES(synced_at)
            """), {"fn": flow_name, "fid": match.get("id"), "name": match.get("name"),
                   "mt": match.get("modifiedTime"), "rows": rows})

    def run(self, flow_names: Optional[List[str]] = None, dry_run: bool = False,
            force: bool = False) -> dict:
        access = self.drive.check_folder_access()
        if access["visible"]:
            logger.info(f"Dossier Drive visible : '{access['meta'].get('name')}' (id={self.drive.folder_id}).")
        else:
            logger.error(
                f"Dossier Drive INVISIBLE pour le compte de service (id={self.drive.folder_id}): "
                f"{access['error']}. Le dossier n'a probablement pas ete partage avec ce compte, "
                f"ou l'ID est incorrect."
            )

        target_flows = [f for f in self.flows if not flow_names or f.name in flow_names]
        available = {f["name"]: f for f in self.drive.list_files()}
        logger.info(f"{len(available)} fichier(s) dans le dossier Drive: {sorted(available.keys())}")

        state = {}
        if not dry_run:
            self.loader.connect()
            self._ensure_state_table()
            if not force:
                state = self._read_state()

        processed = 0
        skipped = []
        unchanged = []
        errors = []

        with tempfile.TemporaryDirectory() as tmpdir:
            for flow in target_flows:
                try:
                    match = self.drive.find_by_name(flow.match)
                    if not match:
                        logger.warning(f"[{flow.name}] aucun fichier Drive ne correspond au motif '{flow.match}'.")
                        skipped.append(flow.name)
                        continue

                    # Detection de changement : on ne recharge que si le
                    # fichier Drive a ete modifie depuis le dernier chargement
                    # reussi. --force ignore cette verification.
                    last_seen = state.get(flow.name)
                    if last_seen and last_seen == match.get("modifiedTime"):
                        logger.info(
                            f"[{flow.name}] inchange depuis le dernier chargement "
                            f"(modifie le {last_seen}) - ignore."
                        )
                        unchanged.append(flow.name)
                        continue

                    dest = os.path.join(tmpdir, match["name"])
                    self.drive.download_file(match["id"], match["mimeType"], dest)
                    df = pd.read_excel(dest, sheet_name=flow.sheet)

                    df.columns = [str(c).replace(".", "_").replace(" ", "_") for c in df.columns]

                    if dry_run:
                        logger.info(f"[DRY RUN][{flow.name}] fichier='{match['name']}' {len(df)} lignes | colonnes: {list(df.columns)}")
                    else:
                        self.loader.replace_table(df, flow.target_table, database=flow.target_database)
                        # Etat ecrit APRES le chargement reussi : un echec
                        # laisse l'etat inchange, donc le flux sera bien
                        # retente au run suivant.
                        self._write_state(flow.name, match, len(df))
                        logger.info(f"[{flow.name}] MIS A JOUR (fichier modifie le {match.get('modifiedTime')}).")

                    processed += 1
                except Exception as e:
                    logger.error(f"[{flow.name}] erreur: {e}")
                    errors.append(f"{flow.name}: {e}")

        if not dry_run:
            self.loader.close()

        result = {
            "status": "failed" if errors else "success",
            "processed": processed,
            "unchanged": unchanged,
            "skipped": skipped,
            "errors": errors,
        }
        logger.info(f"Excel sync termine: {result}")
        return result


if __name__ == "__main__":
    import argparse
    import sys

    parser = argparse.ArgumentParser()
    parser.add_argument("--flows", nargs="*", default=None)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument(
        "--force", action="store_true",
        help="Recharge meme si le fichier Drive n'a pas change depuis le dernier chargement.",
    )
    args = parser.parse_args()

    pipeline = ExcelPipeline()
    result = pipeline.run(flow_names=args.flows, dry_run=args.dry_run, force=args.force)
    if result["status"] != "success":
        sys.exit(1)
