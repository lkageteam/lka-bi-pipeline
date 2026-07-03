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

    def run(self, flow_names: Optional[List[str]] = None, dry_run: bool = False) -> dict:
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

        if not dry_run:
            self.loader.connect()

        processed = 0
        skipped = []
        errors = []

        with tempfile.TemporaryDirectory() as tmpdir:
            for flow in target_flows:
                try:
                    match = self.drive.find_by_name(flow.match)
                    if not match:
                        logger.warning(f"[{flow.name}] aucun fichier Drive ne correspond au motif '{flow.match}'.")
                        skipped.append(flow.name)
                        continue

                    dest = os.path.join(tmpdir, match["name"])
                    self.drive.download_file(match["id"], match["mimeType"], dest)
                    df = pd.read_excel(dest, sheet_name=flow.sheet)

                    df.columns = [str(c).replace(".", "_").replace(" ", "_") for c in df.columns]

                    if dry_run:
                        logger.info(f"[DRY RUN][{flow.name}] fichier='{match['name']}' {len(df)} lignes | colonnes: {list(df.columns)}")
                    else:
                        self.loader.replace_table(df, flow.target_table, database=flow.target_database)

                    processed += 1
                except Exception as e:
                    logger.error(f"[{flow.name}] erreur: {e}")
                    errors.append(f"{flow.name}: {e}")

        if not dry_run:
            self.loader.close()

        result = {
            "status": "failed" if errors else "success",
            "processed": processed,
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
    args = parser.parse_args()

    pipeline = ExcelPipeline()
    result = pipeline.run(flow_names=args.flows, dry_run=args.dry_run)
    if result["status"] != "success":
        sys.exit(1)
