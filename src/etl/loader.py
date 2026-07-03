import os
import logging
from typing import Optional
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.engine import Engine
from sqlalchemy.exc import OperationalError, DBAPIError
from sqlalchemy.types import Text
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

logger = logging.getLogger(__name__)


class SQLLoader:
    """
    Chargement des donnees dans MySQL : creation automatique de table si
    absente, sinon UPSERT via table de staging (INSERT ... ON DUPLICATE
    KEY UPDATE). Repris de bi-gerrish/src/etl/loader.py (design deja
    production-capable, pas de raison de le reecrire).
    """

    def __init__(self, connection_string: Optional[str] = None):
        db_name = os.getenv("MYSQL_DATABASE", "tsa_activities")
        server = os.getenv("MYSQL_HOST", "10.66.66.1")
        port = os.getenv("MYSQL_PORT", "3306")
        user = os.getenv("MYSQL_USER", "root")
        password = os.getenv("MYSQL_PASSWORD", "")
        password_encoded = quote_plus(password)

        default_uri = f"mysql+pymysql://{user}:{password_encoded}@{server}:{port}/{db_name}"
        self.connection_string = connection_string or os.getenv("MYSQL_URI", default_uri)
        self.engine: Optional[Engine] = None

    @retry(
        stop=stop_after_attempt(8),
        wait=wait_exponential(multiplier=1, min=3, max=30),
        retry=retry_if_exception_type((OperationalError, DBAPIError)),
        reraise=True,
    )
    def connect(self) -> None:
        """
        Retry genereux (8 tentatives, backoff exponentiel jusqu'a 30s) :
        meme via le tunnel WireGuard, la perte de paquets residuelle sur le
        lien reseau peut faire echouer une tentative de connexion isolee
        (cf. diagnostic reseau documente sur le serveur MySQL cible).
        """
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

    def _text_dtype_map(self, df: pd.DataFrame) -> dict:
        """
        Force TEXT (pas de limite de longueur) pour :
        - toutes les colonnes de type 'object' (texte) - sans ca, SQLAlchemy/
          pandas peut inferer un VARCHAR(N) base sur les longueurs observees
          dans le SEUL premier batch, et un batch ulterieur avec une valeur
          plus longue declenche une erreur MySQL 1265 'Data truncated'.
        - toutes les colonnes ENTIEREMENT vides (NaN) dans ce batch : pandas
          leur assigne le dtype float64 par defaut (aucune valeur pour
          deviner le vrai type), ce qui cree une colonne DOUBLE/FLOAT si
          c'est le premier batch qui sert a creer la table. Si un batch
          ulterieur y met une vraie valeur texte (ex: agentInfo_idUnique,
          vide dans le premier batch de tsa_deployments mais alphanumerique
          ensuite), la meme erreur 1265 se produit - deja observe 2 fois en
          prod avant ce correctif.
        """
        return {
            col: Text
            for col in df.columns
            if pd.api.types.is_string_dtype(df[col]) or df[col].isna().all()
        }

    def _sync_columns(self, conn, inspector, table_name: str, df: pd.DataFrame) -> None:
        """
        Ajoute a la table les colonnes presentes dans ce batch mais absentes
        de la table (schema drift). Necessaire pour les flux en export
        complet (ex: `pos` -> tsa_deployments) : selon la date de creation
        du document, des sous-documents optionnels differents sont peuples
        (ex: `createdBy` avec ses propres champs imbriques), donc des
        colonnes nouvelles peuvent apparaitre dans un batch ulterieur au
        premier (qui a defini le schema initial de la table).
        """
        existing_cols = {c["name"] for c in inspector.get_columns(table_name)}
        new_cols = [c for c in df.columns if c not in existing_cols]
        for col in new_cols:
            try:
                conn.execute(text(f"ALTER TABLE `{table_name}` ADD COLUMN `{col}` TEXT NULL"))
                logger.info(f"Colonne `{col}` ajoutee sur `{table_name}` (schema drift).")
            except Exception as e:
                if "1060" in str(e) or "Duplicate column" in str(e):
                    pass
                else:
                    raise

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

        self._load_data_with_retry(df, table_name, primary_key)

    def replace_table(self, df: pd.DataFrame, table_name: str) -> None:
        """
        Remplacement complet d'une table (DROP+CREATE), pour les
        referentiels statiques (Excel) ou l'historique n'a pas de sens a
        preserver - convention deja utilisee par les scripts R legacy
        (dbWriteTable(..., overwrite = TRUE)).
        """
        if df.empty:
            logger.warning(f"Aucune donnee a charger pour '{table_name}' (replace).")
            return
        if not self.engine:
            self.connect()
        df.columns = [str(c).replace(".", "_").replace(" ", "_").replace("-", "_") for c in df.columns]
        df = self._prepare_dataframe_for_sql(df)
        self._replace_table_with_retry(df, table_name)

    @retry(
        stop=stop_after_attempt(8),
        wait=wait_exponential(multiplier=1, min=3, max=30),
        retry=retry_if_exception_type((OperationalError, DBAPIError)),
        reraise=True,
    )
    def _replace_table_with_retry(self, df: pd.DataFrame, table_name: str) -> None:
        with self.engine.begin() as conn:
            df.to_sql(table_name, conn, if_exists="replace", index=False, chunksize=5000, method="multi", dtype=self._text_dtype_map(df))
        logger.info(f"Table '{table_name}' remplacee ({len(df)} lignes).")

    @retry(
        stop=stop_after_attempt(8),
        wait=wait_exponential(multiplier=1, min=3, max=30),
        retry=retry_if_exception_type((OperationalError, DBAPIError)),
        reraise=True,
    )
    def _load_data_with_retry(self, df: pd.DataFrame, table_name: str, primary_key: str) -> None:
        """
        Chaque appel de load_data() ouvre potentiellement une NOUVELLE
        connexion TCP (le pool peut etre vide/recycle) - le retry sur
        SQLLoader.connect() seul ne protege donc pas cette etape. Meme
        logique de retry ici, reproductible independamment par flux/batch.
        """
        with self.engine.begin() as conn:
            inspector = inspect(self.engine)
            table_exists = inspector.has_table(table_name)

            if not table_exists:
                logger.info(f"Table '{table_name}' inexistante. Creation automatique...")
                df.to_sql(table_name, conn, if_exists="append", index=False, chunksize=5000, method="multi", dtype=self._text_dtype_map(df))
                if primary_key in df.columns:
                    self._ensure_primary_key(conn, table_name, primary_key)
                logger.info(f"Table '{table_name}' creee ({len(df)} lignes).")
            else:
                self._sync_columns(conn, inspector, table_name, df)

                staging_table = f"_stg_{table_name}"
                df.to_sql(staging_table, conn, if_exists="replace", index=False, chunksize=5000, method="multi", dtype=self._text_dtype_map(df))

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
