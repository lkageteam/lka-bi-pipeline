import re
import json
import logging
from typing import Any, Dict, List, Optional

import pandas as pd

from .flows import FlowConfig

logger = logging.getLogger(__name__)

BADGE_PATTERN = re.compile(r"numeroB[ae]?[dg][deg]*", re.IGNORECASE)


class DataTransformer:
    """
    Transformation pilotee par la config du flux (FlowConfig), pas par
    heuristique sur le nom de collection. Chaque flux declare explicitement
    les regles qui s'appliquent (badge_merge, dedup_key, phone_min_length).
    """

    def transform_flow(self, data: List[Dict[str, Any]], flow: FlowConfig) -> pd.DataFrame:
        if not data:
            logger.warning(f"[{flow.name}] Aucune donnee a transformer.")
            return pd.DataFrame()

        # Aplatit les sous-documents (userInfo.firstName -> userInfo_firstName)
        # au lieu de les serialiser en JSON, pour matcher les projections
        # Mongo demandees (colonnes individuelles, pas de blob).
        df = pd.json_normalize(data, sep="_")
        logger.info(f"[{flow.name}] {len(df)} lignes extraites.")

        df = self._standardize_dates(df, flow.date_field)

        if flow.badge_merge:
            df = self._normalize_badges(df)

        if flow.dedup_key:
            df = self._filter_and_deduplicate(df, flow.dedup_key, flow.phone_min_length)

        # Securite : si des listes/dicts residuels subsistent (ex: tableaux),
        # les serialiser en JSON plutot que de faire echouer l'insertion SQL.
        df = self._flatten_remaining_objects(df)
        df = self._remove_duplicate_columns(df)

        logger.info(f"[{flow.name}] Transformation terminee ({len(df)} lignes, {len(df.columns)} colonnes).")
        return df

    def _standardize_dates(self, df: pd.DataFrame, date_field: str) -> pd.DataFrame:
        if date_field in df.columns:
            df[date_field] = pd.to_datetime(df[date_field], errors="coerce", utc=True)
        return df

    def _normalize_badges(self, df: pd.DataFrame) -> pd.DataFrame:
        """Fusionne les colonnes de badge mal orthographiees (numeroBadge/numeroBagde/...)."""
        badge_cols = [c for c in df.columns if BADGE_PATTERN.search(c)]
        if not badge_cols:
            return df

        logger.info(f"Colonnes de badge fusionnees: {badge_cols}")
        target_col = "badge_unifie"
        df[target_col] = None
        for col in badge_cols:
            df[target_col] = df[target_col].fillna(df[col])
        df = df.drop(columns=[c for c in badge_cols if c in df.columns])
        return df

    def _filter_and_deduplicate(
        self, df: pd.DataFrame, key: str, min_length: Optional[int]
    ) -> pd.DataFrame:
        if key not in df.columns:
            return df

        initial = len(df)
        if min_length:
            df = df[df[key].astype(str).str.len() >= min_length]
        df = df.drop_duplicates(subset=[key])

        if len(df) != initial:
            logger.info(f"Filtrage/dedup sur '{key}': {initial} -> {len(df)} lignes.")
        return df

    def _flatten_remaining_objects(self, df: pd.DataFrame) -> pd.DataFrame:
        for col in df.columns:
            sample = df[col].dropna().head(10)
            if len(sample) > 0 and any(isinstance(v, (dict, list)) for v in sample):
                df[col] = df[col].apply(
                    lambda x: json.dumps(x, default=str, ensure_ascii=False) if isinstance(x, (dict, list)) else x
                )
        return df

    def _remove_duplicate_columns(self, df: pd.DataFrame) -> pd.DataFrame:
        """MySQL est case-insensitive sur les noms de colonnes ('date' == 'Date')."""
        col_map: Dict[str, List[int]] = {}
        for i, col in enumerate(df.columns):
            col_map.setdefault(col.lower(), []).append(i)

        cols_to_keep = []
        for col_lower, indices in col_map.items():
            cols_to_keep.append(indices[0])
            if len(indices) > 1:
                logger.warning(
                    f"Colonnes dupliquees (case-insensitive): {[df.columns[i] for i in indices]}. "
                    f"Conservation de '{df.columns[indices[0]]}'."
                )

        return df.iloc[:, sorted(cols_to_keep)]
