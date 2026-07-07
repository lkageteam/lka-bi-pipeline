"""
Configuration declarative des flux ETL (source Mongo -> table MySQL).

Chaque flux est defini dans config/flows.yaml plutot que code en dur,
pour pouvoir ajouter/retirer des flux sans toucher au code Python.
"""
import yaml
from bson import ObjectId
from dataclasses import dataclass, field
from datetime import datetime
from typing import Dict, List, Optional


@dataclass
class FlowConfig:
    name: str
    source_collection: str
    target_table: str
    target_database: str = "tsa_activities"
    primary_key: str = "_id"
    type_field: Optional[str] = None
    type_filter: Optional[str] = None
    projection: Optional[Dict[str, int]] = None
    date_field: str = "createdAt"
    bootstrap_start_date: Optional[str] = None
    badge_merge: bool = False
    dedup_key: Optional[str] = None
    phone_min_length: Optional[int] = None
    rename_id_to: Optional[str] = None
    add_date_time_split: bool = False
    # Renommage de champs post-aplatissement (cle = nom Mongo aplati, ex.
    # 'userInfo_numeroBadge' ; valeur = nom de colonne cible). Necessaire
    # quand le nom de colonne legacy ne correspond PAS au nom de champ Mongo
    # (ex. flux 'maj' : le champ Mongo 'numClient' doit devenir la colonne
    # legacy 'Contact_abonné') - contrairement aux autres flux BA ou les
    # noms Mongo aplatis coincident deja avec les noms de colonnes cibles.
    rename_fields: Optional[Dict[str, str]] = None

    def mongo_query(self, since: Optional[datetime] = None) -> Dict:
        """
        Construit le filtre Mongo. Le filtre temporel utilise une borne sur
        `_id` (ObjectId, qui embarque un timestamp) plutot que sur le champ
        date_field lui-meme : `_id` est indexe par defaut sur TOUTE collection
        MongoDB, donc ce filtre est rapide sans avoir a creer un index dedie
        sur `createdAt` (droits admin non disponibles avec l'utilisateur
        applicatif actuel). Le filtre par `type` (bareports) profite lui de
        l'index existant `(type, numSim)` deja present en base (confirme par
        `explain()` : IXSCAN sur ce prefixe).
        """
        query: Dict = {}
        if self.type_field and self.type_filter:
            query[self.type_field] = self.type_filter

        id_bound = None
        if since is not None:
            id_bound = ObjectId.from_datetime(since)
        elif self.bootstrap_start_date:
            id_bound = ObjectId.from_datetime(datetime.fromisoformat(self.bootstrap_start_date))

        if id_bound is not None:
            query["_id"] = {"$gte": id_bound}

        return query


def load_flows(path: str = "config/flows.yaml") -> List[FlowConfig]:
    with open(path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f)

    flows = []
    for entry in raw.get("flows", []):
        flows.append(FlowConfig(**entry))
    return flows
