"""
Synchronisation de tables qui ne viennent ni de MongoDB ni d'Excel/Drive,
mais d'une autre base MySQL du MEME serveur (75.119.154.255).

Cas confirmes par l'utilisateur (2026-07-03) : `newadd` et `ads`, dans
tsa_activities ET brand_soldier_activities, viennent respectivement de
`lka_perf_commissions`.`daily_gadd` et `.daily_ads` (alimentees par un
pipeline local distinct, D:\\LKA\\Perf_commissions). Chaque table cible est
en fait deux projections differentes de la meme donnee source :
  - tsa_activities.<table> : format long (Username, Date, <valeur>)
  - brand_soldier_activities.<table> : format pivote (Username + une
    colonne par date, cf. structure legacy confirmee par le dump reel
    pour newadd - meme convention appliquee a ads par symetrie)

Comme source et cibles sont sur le meme serveur/connexion, pas besoin
d'une deuxieme connexion MySQL - une simple lecture cross-database via le
meme engine SQLAlchemy que SQLLoader.
"""
import logging
from dataclasses import dataclass
from typing import Dict

import pandas as pd
from sqlalchemy import text

from .loader import SQLLoader

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

SOURCE_DATABASE = "lka_perf_commissions"


@dataclass
class PivotSourceFlow:
    name: str
    source_table: str
    value_column: str
    target_table: str


FLOWS = [
    PivotSourceFlow(name="newadd", source_table="daily_gadd", value_column="gadd", target_table="newadd"),
    PivotSourceFlow(name="ads", source_table="daily_ads", value_column="ads", target_table="ads"),
]


def sync_pivot_source(loader: SQLLoader, flow: PivotSourceFlow) -> Dict[str, int]:
    query = text(
        f"SELECT user_name, perf_date, {flow.value_column} "
        f"FROM `{SOURCE_DATABASE}`.`{flow.source_table}`"
    )
    with loader.engine.connect() as conn:
        df = pd.read_sql(query, conn)

    if df.empty:
        logger.warning(f"[{flow.name}] {SOURCE_DATABASE}.{flow.source_table} est vide, rien a synchroniser.")
        return {"tsa_rows": 0, "bs_rows": 0}

    # Format long, historique (tsa_activities.<table>)
    long_df = df.rename(columns={"user_name": "Username", "perf_date": "Date", flow.value_column: flow.target_table})
    long_df["Date"] = pd.to_datetime(long_df["Date"]).dt.strftime("%Y-%m-%d")
    loader.replace_table(long_df, flow.target_table, database="tsa_activities")

    # Format pivote par date, une colonne par jour (brand_soldier_activities.<table>)
    # - convention confirmee par le dump reel de newadd (colonnes '01/05/2025', ...).
    pivot_df = df.copy()
    pivot_df["perf_date"] = pd.to_datetime(pivot_df["perf_date"])
    wide_df = pivot_df.pivot_table(
        index="user_name", columns="perf_date", values=flow.value_column, aggfunc="sum"
    )
    # pivot_table trie les colonnes par la valeur datetime sous-jacente (ordre
    # chronologique correct) - on formate en DD/MM/YYYY seulement APRES ce tri.
    # Bug reel corrige (2026-07-03) : formater la date en string AVANT le pivot
    # faisait trier les colonnes alphabetiquement ('01/02/2026' avant
    # '01/05/2025'), pas chronologiquement.
    wide_df = wide_df.reindex(sorted(wide_df.columns), axis=1)
    wide_df.columns = [d.strftime("%d/%m/%Y") for d in wide_df.columns]
    wide_df = wide_df.reset_index().rename(columns={"user_name": "Username"})
    loader.replace_table(wide_df, flow.target_table, database="brand_soldier_activities")

    result = {"tsa_rows": len(long_df), "bs_rows": len(wide_df)}
    logger.info(f"[{flow.name}] termine: {result}")
    return result


if __name__ == "__main__":
    loader = SQLLoader()
    loader.connect()
    try:
        for flow in FLOWS:
            sync_pivot_source(loader, flow)
    finally:
        loader.close()
