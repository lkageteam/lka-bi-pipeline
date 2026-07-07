import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from src.etl.flows import FlowConfig
from src.etl.transformer import DataTransformer


def make_flow(**overrides):
    defaults = dict(
        name="test_flow",
        source_collection="bareports",
        target_table="TEST_TABLE",
    )
    defaults.update(overrides)
    return FlowConfig(**defaults)


def test_flattens_nested_fields_with_prefix():
    data = [{"_id": "1", "userInfo": {"firstName": "Ama", "lastName": "K"}, "createdAt": "2025-01-01T00:00:00Z"}]
    flow = make_flow()
    df = DataTransformer().transform_flow(data, flow)
    assert "userInfo_firstName" in df.columns
    assert "userInfo_lastName" in df.columns
    assert df.iloc[0]["userInfo_firstName"] == "Ama"


def test_single_badge_column_kept_as_is_not_renamed():
    """
    Bug reel : un flux Mongo n'a qu'une seule colonne badge propre
    (userInfo.numeroBadge, pas de typo a fusionner) - elle ne doit PAS
    etre renommee en 'badge_unifie' (le schema legacy attend
    'userInfo_numeroBadge' tel quel).
    """
    data = [{"_id": "1", "userInfo": {"numeroBadge": "B1"}, "createdAt": "2025-01-01T00:00:00Z"}]
    flow = make_flow(badge_merge=True)
    df = DataTransformer().transform_flow(data, flow)
    assert "userInfo_numeroBadge" in df.columns
    assert "badge_unifie" not in df.columns
    assert df.iloc[0]["userInfo_numeroBadge"] == "B1"


def test_badge_merge_consolidates_typo_columns():
    data = [
        {"_id": "1", "numeroBadge": "B1", "numeroBagde": None, "createdAt": "2025-01-01T00:00:00Z"},
        {"_id": "2", "numeroBadge": None, "numeroBagde": "B2", "createdAt": "2025-01-01T00:00:00Z"},
    ]
    flow = make_flow(badge_merge=True)
    df = DataTransformer().transform_flow(data, flow)
    assert "badge_unifie" in df.columns
    assert set(df["badge_unifie"]) == {"B1", "B2"}
    assert "numeroBadge" not in df.columns
    assert "numeroBagde" not in df.columns


def test_dedup_and_min_length_filter():
    data = [
        {"_id": "1", "numSim": "12345678", "createdAt": "2025-01-01T00:00:00Z"},
        {"_id": "2", "numSim": "12345678", "createdAt": "2025-01-01T00:00:00Z"},  # doublon
        {"_id": "3", "numSim": "123", "createdAt": "2025-01-01T00:00:00Z"},  # trop court
    ]
    flow = make_flow(dedup_key="numSim", phone_min_length=8)
    df = DataTransformer().transform_flow(data, flow)
    assert len(df) == 1
    assert df.iloc[0]["numSim"] == "12345678"


def test_rename_id_to_x_id():
    data = [{"_id": "abc123", "createdAt": "2025-01-01T10:30:00Z", "numSim": "12345678"}]
    flow = make_flow(rename_id_to="X_id")
    df = DataTransformer().transform_flow(data, flow)
    assert "X_id" in df.columns
    assert "_id" not in df.columns
    assert df.iloc[0]["X_id"] == "abc123"


def test_add_date_time_split():
    data = [{"_id": "1", "createdAt": "2025-03-15T14:22:05Z", "numSim": "12345678"}]
    flow = make_flow(add_date_time_split=True)
    df = DataTransformer().transform_flow(data, flow)
    assert df.iloc[0]["Date"] == "2025-03-15"
    assert df.iloc[0]["Time"] == "14:22:05"
    # createdAt original conserve (convention legacy : les deux coexistent)
    assert "createdAt" in df.columns


def test_malformed_createdAt_expression_object_is_neutralized():
    """
    Anomalie observee en production sur bareports : certains documents ont
    createdAt = {'$dateSubtract': {...}} (expression Mongo non evaluee)
    au lieu d'une vraie date. Doit etre neutralise en NULL, pas aplati en
    colonnes parasites (createdAt_$dateSubtract_*).
    """
    data = [
        {"_id": "1", "createdAt": "2025-01-01T00:00:00Z", "numSim": "12345678"},
        {"_id": "2", "createdAt": {"$dateSubtract": {"startDate": "$createdAt", "unit": "day", "amount": 1}}, "numSim": "87654321"},
    ]
    flow = make_flow()
    df = DataTransformer().transform_flow(data, flow)
    assert not any(c.startswith("createdAt_") for c in df.columns)
    assert "createdAt" in df.columns
    assert df["createdAt"].isna().sum() == 1


def test_rename_fields_maps_flattened_names_to_legacy_columns():
    """
    Cas reel : le flux 'maj' a des noms de colonnes legacy qui ne
    correspondent PAS aux noms de champs Mongo aplatis (ex. 'numClient' ->
    'Contact_abonné'), contrairement aux autres flux BA.
    """
    data = [{"_id": "1", "numClient": "12345678", "region": "Cotonou", "createdAt": "2025-01-01T10:00:00Z"}]
    flow = make_flow(rename_fields={"numClient": "Contact_abonné", "region": "Région", "Time": "Heure"}, add_date_time_split=True)
    df = DataTransformer().transform_flow(data, flow)
    assert "Contact_abonné" in df.columns
    assert "Région" in df.columns
    assert "Heure" in df.columns
    assert "numClient" not in df.columns
    assert "region" not in df.columns
    assert "Time" not in df.columns
    assert df.iloc[0]["Contact_abonné"] == "12345678"


def test_case_insensitive_duplicate_columns_removed():
    data = [{"_id": "1", "Date": "2025-01-01", "date": "2025-01-01"}]
    flow = make_flow()
    df = DataTransformer().transform_flow(data, flow)
    cols_lower = [c.lower() for c in df.columns]
    assert cols_lower.count("date") == 1
