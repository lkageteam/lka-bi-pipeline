import os
import logging
from typing import Optional
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.engine import Engine

logger = logging.getLogger(__name__)


class SQLLoader:
    """
    Chargement des donnees dans MySQL : creation automatique de table si
    absente, sinon UPSERT via table de staging (INSERT ... ON DUPLICATE
    KEY UPDATE). Repris de bi-gerrish/src/etl/loader.py (design deja
    production-capable, pas de raison de le reecrire).
    """

    def __init__(self, connection_string: Optional[str] = None):
        db_name = os.getenv("MYSQL_DATABASE", "lka_bi_dw")
        server = os.getenv("MYSQL_HOST", "10.66.66.1")
        port = os.getenv("MYSQL_PORT", "3306")
        user = os.getenv("MYSQL_USER", "root")
        password = os.getenv("MYSQL_PASSWORD", "")
        password_encoded = quote_plus(password)

        default_uri = f"mysql+pymysql://{user}:{password_encoded}@{server}:{port}/{db_name}"
        self.connection_string = connection_string or os.getenv("MYSQL_URI", default_uri)
        self.engine: Optional[Engine] = None

    def connect(self) -> None:
        logger.info("Connexion a MySQL...")
        self.engine = create_engine(
            self.connection_string,
            pool_size=5,
            max_overflow=10,
            pool_timeout=60,
            pool_recycle=1800,
            pool_pre_ping=True,
            connect_args={
                "connect_timeout": 30,
                "read_timeout": 600,
                "write_timeout": 600,
            },
        )
        with self.engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        logger.info("Connexion MySQL etablie (pool active).")

    def _prepare_dataframe_for_sql(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        for col in df.columns:
            if pd.api.types.is_datetime64_any_dtype(df[col]):
                if hasattr(df[col].dt, "tz") and df[col].dt.tz is not None:
                    df[col] = df[col].dt.tz_localize(None)
        return df

    def _ensure_primary_key(self, conn, table_name: str, primary_key: str):
        try:
            try:
                conn.execute(text(f"ALTER TABLE `{table_name}` MODIFY COLUMN `{primary_key}` VARCHAR(191)"))
            except Exception:
                pass
            conn.execute(text(f"ALTER TABLE `{table_name}` ADD PRIMARY KEY (`{primary_key}`)"))
            logger.info(f"Cle primaire ajoutee sur `{table_name}`.")
        except Exception as e:
            if "1068" in str(e) or "already exists" in str(e):
                pass
            else:
                logger.warning(f"Note sur la PK de `{table_name}`: {e}")

    def load_data(self, df: pd.DataFrame, table_name: str, primary_key: str = "_id") -> None:
        if df.empty:
            logger.warning(f"Aucune donnee a charger pour '{table_name}'.")
            return

        if not self.engine:
            self.connect()

        df.columns = [str(c).replace(".", "_").replace(" ", "_").replace("-", "_") for c in df.columns]
        df = self._prepare_dataframe_for_sql(df)

        if primary_key not in df.columns and "_id" in df.columns:
            primary_key = "_id"

        with self.engine.begin() as conn:
            inspector = inspect(self.engine)
            table_exists = inspector.has_table(table_name)

            if not table_exists:
                logger.info(f"Table '{table_name}' inexistante. Creation automatique...")
                df.to_sql(table_name, conn, if_exists="append", index=False, chunksize=5000, method="multi")
                if primary_key in df.columns:
                    self._ensure_primary_key(conn, table_name, primary_key)
                logger.info(f"Table '{table_name}' creee ({len(df)} lignes).")
            else:
                staging_table = f"_stg_{table_name}"
                df.to_sql(staging_table, conn, if_exists="replace", index=False, chunksize=5000, method="multi")

                columns = list(df.columns)
                col_list = ", ".join([f"`{col}`" for col in columns])
                update_assignments = [f"`{col}` = VALUES(`{col}`)" for col in columns if col != primary_key]
                update_clause = ", ".join(update_assignments)

                if update_clause and primary_key in df.columns:
                    conn.execute(text(f"""
                        INSERT INTO `{table_name}` ({col_list})
                        SELECT {col_list} FROM `{staging_table}`
                        ON DUPLICATE KEY UPDATE {update_clause}
                    """))
                else:
                    conn.execute(text(f"""
                        INSERT IGNORE INTO `{table_name}` ({col_list})
                        SELECT {col_list} FROM `{staging_table}`
                    """))

                conn.execute(text(f"DROP TABLE IF EXISTS `{staging_table}`"))

    def close(self) -> None:
        if self.engine:
            self.engine.dispose()
