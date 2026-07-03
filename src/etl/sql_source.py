"""
Synchronisation de tables qui ne viennent ni de MongoDB ni d'Excel/Drive,
mais d'une autre base MySQL du MEME serveur (75.119.154.255).

Cas confirme par l'utilisateur (2026-07-03) : `newadd`, dans
tsa_activities ET brand_soldier_activities, vient de
`lka_perf_commissions`.`daily_gadd` (alimentee par un pipeline local
distinct, D:\\LKA\\Perf_commissions). Les deux tables cibles sont deux
projections differentes de la meme donnee source :
  - tsa_activities.newadd : format long (Username, Date, newadd)
  - brand_soldier_activities.newadd : format pivote (Username + une
    colonne par date, cf. structure legacy confirmee par le dump reel)

Comme source et cibles sont sur le meme serveur/connexion, pas besoin
d'une deuxieme connexion MySQL - une simple lecture cross-database via le
meme engine SQLAlchemy que SQLLoader.
"""
import logging

import pandas as pd
from sqlalchemy import text

from .loader import SQLLoader

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

SOURCE_DATABASE = "lka_perf_commissions"
SOURCE_TABLE = "daily_gadd"


def sync_newadd(loader: SQLLoader) -> dict:
    query = text(f"SELECT user_name, perf_date, gadd FROM `{SOURCE_DATABASE}`.`{SOURCE_TABLE}`")
    with loader.engine.connect() as conn:
        df = pd.read_sql(query, conn)

    if df.empty:
        logger.warning(f"[newadd] {SOURCE_DATABASE}.{SOURCE_TABLE} est vide, rien a synchroniser.")
        return {"tsa_rows": 0, "bs_rows": 0}

    # Format long, historique (tsa_activities.newadd)
    long_df = df.rename(columns={"user_name": "Username", "perf_date": "Date", "gadd": "newadd"})
    long_df["Date"] = pd.to_datetime(long_df["Date"]).dt.strftime("%Y-%m-%d")
    loader.replace_table(long_df, "newadd", database="tsa_activities")

    # Format pivote par date, une colonne par jour (brand_soldier_activities.newadd)
    # - convention confirmee par le dump reel (colonnes '01/05/2025', '02/05/2025', ...).
    pivot_df = df.copy()
    pivot_df["perf_date"] = pd.to_datetime(pivot_df["perf_date"]).dt.strftime("%d/%m/%Y")
    wide_df = pivot_df.pivot_table(
        index="user_name", columns="perf_date", values="gadd", aggfunc="sum"
    ).reset_index()
    wide_df = wide_df.rename(columns={"user_name": "Username"})
    loader.replace_table(wide_df, "newadd", database="brand_soldier_activities")

    result = {"tsa_rows": len(long_df), "bs_rows": len(wide_df)}
    logger.info(f"[newadd] termine: {result}")
    return result


if __name__ == "__main__":
    loader = SQLLoader()
    loader.connect()
    try:
        sync_newadd(loader)
    finally:
        loader.close()
