import os
import logging
from typing import Dict, Optional, Any, Iterator, List
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

logger = logging.getLogger(__name__)


class MongoExtractor:
    """
    Module d'extraction de donnees depuis MongoDB.
    Gere la connexion (retry), l'extraction batchee, et le filtrage par
    requete/projection arbitraire (necessaire pour les collections
    polymorphes comme bareports, filtrees par un champ discriminant).
    """

    def __init__(self, uri: Optional[str] = None, db_name: Optional[str] = None):
        self.uri = uri or os.getenv("MONGO_URI")
        if not self.uri:
            raise ValueError("MONGO_URI environment variable is not set")
        self.db_name = db_name or os.getenv("MONGO_DB_NAME", "pulse_benin")
        self.client: Optional[MongoClient] = None
        self.db = None

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10),
        retry=retry_if_exception_type((ConnectionFailure, ServerSelectionTimeoutError)),
        reraise=True
    )
    def connect(self) -> None:
        logger.info(f"Tentative de connexion a MongoDB ({self.db_name})...")
        self.client = MongoClient(self.uri, serverSelectionTimeoutMS=8000)
        self.client.admin.command('ping')
        self.db = self.client[self.db_name]
        logger.info("Connexion MongoDB etablie.")

    def get_collection_count(self, collection_name: str, query: Optional[Dict] = None) -> int:
        if self.db is None:
            self.connect()
        if query:
            return self.db[collection_name].count_documents(query)
        return self.db[collection_name].estimated_document_count()

    def extract_with_query(
        self,
        collection_name: str,
        query: Optional[Dict[str, Any]] = None,
        projection: Optional[Dict[str, int]] = None,
        batch_size: int = 10000,
    ) -> Iterator[List[Dict[str, Any]]]:
        """
        Extrait par batch, avec filtre (query) et projection de champs
        (projection) arbitraires. Generateur : ne charge que batch_size
        documents en RAM a la fois.
        """
        if self.db is None:
            self.connect()

        cursor = self.db[collection_name].find(
            query or {}, projection, no_cursor_timeout=True
        ).batch_size(batch_size)

        try:
            batch = []
            for doc in cursor:
                batch.append(doc)
                if len(batch) >= batch_size:
                    yield batch
                    batch = []
            if batch:
                yield batch
        finally:
            cursor.close()

    def close(self) -> None:
        if self.client:
            self.client.close()
