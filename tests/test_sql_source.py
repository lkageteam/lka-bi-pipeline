import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from src.etl.sql_source import (
    _username_key,
    _valid_id,
    _generate_unique_id,
    USERNAME_CORRECTIONS,
    REGION_LABEL_AND_ID,
    BUS_STATUS_MAP,
)


def test_username_key_strips_accents():
    assert _username_key("Fréjus.Koubia") == _username_key("Frejus.Koubia")


def test_username_key_applies_known_corrections():
    # 'Chianvo.Shovo' est une typo connue -> doit matcher la forme corrigee.
    assert _username_key("Chianvo.Shovo") == _username_key("Chianvo.Shobo")


def test_username_key_case_insensitive():
    assert _username_key("Kévin.Nana") == _username_key("kevin.nana")


def test_username_key_empty_for_missing_value():
    assert _username_key(None) == ""
    assert _username_key("") == ""
    assert _username_key("   ") == ""


def test_valid_id_requires_id_prefix_and_min_length():
    """
    Bug reel observe (2026-07-07) : des valeurs sentinelles ('not Found45',
    'run106', 'Kioks491', 'pos049', 'tsa67', 'check4', '8') existent dans les
    deux bases et ne doivent PAS etre traitees comme des ID_Unique valides -
    sinon elles provoquent de faux doublons une fois copiees telles quelles.
    """
    assert _valid_id("IDW9Ok9S1") is True
    assert _valid_id("IDmj9BtFD_") is True
    for junk in ["not Found45", "run106", "Kioks491", "pos049", "tsa67", "check4", "8", "0", "", None]:
        assert _valid_id(junk) is False, f"{junk!r} ne devrait pas etre valide"


def test_generate_unique_id_avoids_collisions():
    existing = {"IDaaaaaaa"}
    generated = _generate_unique_id(existing)
    assert generated.startswith("ID")
    assert len(generated) == 9
    assert generated in existing  # _generate_unique_id ajoute son propre resultat


def test_region_mapping_covers_all_six_canonical_regions():
    expected = {"COTONOU", "ATLANTIQUE", "SUD EST", "SUD OUEST", "NORD EST", "NORD OUEST"}
    assert set(REGION_LABEL_AND_ID.keys()) == expected
    # Region_Id doivent tous etre distincts (R1..R6).
    ids = [region_id for _, region_id in REGION_LABEL_AND_ID.values()]
    assert len(set(ids)) == 6


def test_bus_status_map_covers_known_values():
    assert BUS_STATUS_MAP["No Bus"] == "No"
    assert BUS_STATUS_MAP["Shared Bus"] == "Shared"
    assert BUS_STATUS_MAP["Bus"] == "yes"
