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
import os
import random
import string
import unicodedata
from dataclasses import dataclass
from typing import Dict, Optional

import pandas as pd
from sqlalchemy import text

from .loader import SQLLoader

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

SOURCE_DATABASE = "lka_perf_commissions"
CLIENT_DATABASE = "lka_client_mtn"


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


def _canonicalize_usernames(df: pd.DataFrame) -> pd.DataFrame:
    """
    Fusionne les variantes de casse d'un meme user_name - bug reel observe
    (2026-07-08) dans lka_perf_commissions.daily_gadd/daily_ads : le meme
    agent apparait parfois sous 2 casses differentes (ex.
    'Charles.NOUMONVI' et 'Charles.Noumonvi', 7 cas confirmes). Sans ca, le
    pivot par utilisateur produit une ligne dupliquee (MySQL les compte
    comme UNE seule valeur DISTINCT via sa collation accent/casse-
    insensible, mais pandas les traite comme deux index differents).
    Normalise vers la premiere casse rencontree (deterministe, stable
    d'un run a l'autre car la requete SQL n'a pas d'ORDER BY explicite mais
    l'ordre de retour MySQL est stable pour une meme table non modifiee).
    """
    df = df.copy()
    key = df["user_name"].str.lower()
    df["user_name"] = df.groupby(key)["user_name"].transform("first")
    return df


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

    df = _canonicalize_usernames(df)

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


# ---------------------------------------------------------------------------
# numenclature (brand_soldier_activities) - reconstruction depuis le roster
# vivant lka_client_mtn.lka_usernames / .lka_supervisors (2026-07-07, demande
# utilisateur). Contrairement a newadd/ads, ce n'est pas un simple export : la
# table cible garde son schema legacy exact (colonnes issues de l'ancien
# fichier Excel BASE BA LKA.xlsx) pour rester compatible avec Power BI, mais
# le CONTENU est rafraichi pour tout username qui se retrouve dans le roster
# actuel. Les usernames absents du roster actuel restent inchanges tels
# quels (aucune source pour les rafraichir) - jamais supprimes.
# ---------------------------------------------------------------------------

# Portee depuis D:\LKA\lka_client_pipeline\connections\config.py (pas
# d'import cross-repo possible depuis GitHub Actions - ce module tourne dans
# un runner CI qui n'a pas acces au disque local de l'utilisateur).
USERNAME_CORRECTIONS = {
    "Chianvo.Shovo": "Chianvo.Shobo",
    "Garcia.Ahossi": "Gracia.Ahossi",
    "Therese.Djmade": "Therese.Djimade",
    "Fidele.Tandjikpon": "Fidele.Tandjiekpon",
    "Feix.Adegbola": "Felix.Adegbola",
    "Nathan.Adoukonon": "Nathan.Adoukonou",
    "Fréjus.Koubia": "Frejus.Koubia",
    "fréjus.koubia": "Frejus.Koubia",
    "Gbedole.Adoko": "Gbedolo.Adoko",
    "gbedole.adoko": "Gbedolo.Adoko",
    "Melanie.Tolo": "Melaine.Tolo",
    "melanie.tolo": "Melaine.Tolo",
    "Charles.NOUMONVI": "Charles.Noumonvi",
}

# Mapping region (nouvelle base, ALLCAPS) -> (libelle legacy, Region_Id
# legacy) - confirme par croisement exhaustif avec le dump reel de
# numenclature (2026-07-07) : les 6 regions sont un mapping propre 1:1 des
# deux cotes, aucune ambiguite.
REGION_LABEL_AND_ID = {
    "COTONOU": ("Cotonou", "R2"),
    "ATLANTIQUE": ("Atlantique", "R1"),
    "SUD EST": ("Sud Est", "R3"),
    "SUD OUEST": ("Sud Ouest", "R4"),
    "NORD EST": ("Nord Est", "R5"),
    "NORD OUEST": ("Nord Ouest", "R6"),
}

# lka_supervisors.bus_status -> vocabulaire legacy de l'ancienne colonne Bus.
BUS_STATUS_MAP = {"No Bus": "No", "Shared Bus": "Shared", "Bus": "yes"}


def _strip_accents(value):
    if not isinstance(value, str):
        return value
    normalized = unicodedata.normalize("NFKD", value)
    return "".join(c for c in normalized if not unicodedata.combining(c))


def _username_key(username) -> str:
    """
    Cle de correspondance entre l'ancien UsernameBS et le user_name actuel,
    insensible aux accents et aux typos deja recensees. Explique aussi les
    'faux doublons' vus dans l'ancienne table (Kévin.Nana / Kevin.Nana,
    etc.) - dus a la collation MySQL utf8mb4_0900_ai_ci (accent-insensible)
    utilisee par GROUP BY, pas de vrais doublons de donnees.
    """
    if not isinstance(username, str) or not username.strip():
        return ""
    corrected = USERNAME_CORRECTIONS.get(username, username)
    return _strip_accents(corrected).strip().lower()


def _valid_id(value) -> bool:
    """
    Un ID_Unique/id_pulse valide commence par 'ID' (convention confirmee sur
    les deux bases, ex. IDW9Ok9S1). Bug reel corrige (2026-07-07) : un
    simple check 'pas vide/pas 0' laissait passer des valeurs sentinelles
    manifestement invalides trouvees dans les deux bases ('not Found45',
    'run106', 'Kioks491', 'pos049', 'tsa67', 'check4', '8', ...), qui
    provoquaient de faux doublons d'ID_Unique une fois copiees telles
    quelles.
    """
    return isinstance(value, str) and value.strip().startswith("ID") and len(value.strip()) >= 9


def _generate_unique_id(existing_ids: set) -> str:
    """
    Format 'ID' + 7 caracteres alphanumeriques, identique au format observe
    sur id_pulse/ID_Unique des deux bases (ex. IDW9Ok9S1). Utilise seulement
    quand ni le nouveau (id_pulse) ni l'ancien (ID_Unique) ne sont valides -
    confirme par l'utilisateur (2026-07-07) : ID_Unique doit toujours etre
    rempli et unique, meme si l'ID pulse d'origine n'existe plus/pas.
    """
    alphabet = string.ascii_letters + string.digits
    while True:
        candidate = "ID" + "".join(random.choices(alphabet, k=7))
        if candidate not in existing_ids:
            existing_ids.add(candidate)
            return candidate


def sync_numenclature(loader: SQLLoader, inactive_months: int = 3) -> Dict[str, int]:
    with loader.engine.connect() as conn:
        old_df = pd.read_sql(text("SELECT * FROM `brand_soldier_activities`.`numenclature`"), conn)
        users_df = pd.read_sql(text(f"SELECT * FROM `{CLIENT_DATABASE}`.`lka_usernames`"), conn)
        sup_df = pd.read_sql(text(f"SELECT * FROM `{CLIENT_DATABASE}`.`lka_supervisors`"), conn)
        gadd_df = pd.read_sql(text(f"SELECT user_name, perf_date FROM `{SOURCE_DATABASE}`.`daily_gadd`"), conn)
        ads_df = pd.read_sql(text(f"SELECT user_name, perf_date FROM `{SOURCE_DATABASE}`.`daily_ads`"), conn)

    if users_df.empty:
        logger.warning("[numenclature] lka_usernames est vide, rien a synchroniser.")
        return {"rows": 0}

    target_columns = list(old_df.columns)

    # --- derniere activite connue par agent (union daily_gadd + daily_ads) ---
    activity = pd.concat([gadd_df[["user_name", "perf_date"]], ads_df[["user_name", "perf_date"]]])
    activity["perf_date"] = pd.to_datetime(activity["perf_date"])
    last_activity = activity.groupby("user_name")["perf_date"].max()
    threshold = pd.Timestamp.now() - pd.DateOffset(months=inactive_months)

    def is_active(user_name) -> bool:
        last = last_activity.get(user_name)
        return last is not None and pd.notna(last) and last >= threshold

    # --- lka_usernames -> lka_supervisors, jointure sur supervisor_first_name ---
    sup_df["_sup_key"] = sup_df["supervisor_first_name"].astype(str).str.upper().str.strip()
    sup_lookup = sup_df.set_index("_sup_key")[["supervisor_full_name", "pulse_id", "bus_status"]].to_dict("index")

    users_df["_key"] = users_df["user_name"].apply(_username_key)
    # Bug reel observe (2026-07-07) : lka_usernames contient parfois a la
    # fois l'ancienne orthographe fautive ET la version corrigee comme deux
    # lignes DISTINCTES (ex: 'Feix.Adegbola' et 'Felix.Adegbola' coexistent),
    # ce qui rend '_key' non-unique. Regle de departage deterministe : garder
    # la ligne dont le user_name n'est PAS une cle connue de
    # USERNAME_CORRECTIONS (donc la version canonique/corrigee).
    users_df["_is_known_typo"] = users_df["user_name"].isin(USERNAME_CORRECTIONS.keys())
    users_df = users_df.sort_values("_is_known_typo").drop_duplicates(subset="_key", keep="first")
    users_by_key = users_df.set_index("_key").to_dict("index")

    # --- IDs deja utilises, pour garantir l'unicite des IDs generes ---
    existing_ids = set(old_df["ID_Unique"].dropna().astype(str))
    existing_ids |= {v for v in users_df["id_pulse"].dropna().astype(str) if _valid_id(v)}
    # Suivi des IDs deja attribues PENDANT cette reconstruction : plusieurs
    # anciennes lignes UsernameBS distinctes (variantes orthographiques d'un
    # meme agent, ex. 'Côme.Koudebi' et 'Come.Koudebi') peuvent partager le
    # meme _key et donc le meme id_pulse legitime - sans ce suivi, les deux
    # lignes recevraient le MEME ID_Unique (doublon reel observe, 2026-07-07).
    # Seule la premiere occurrence garde l'id_pulse/ID_Unique d'origine, les
    # suivantes retombent sur un ID synthetique genere.
    assigned_ids: set = set()

    def resolve_supervisor(user_row: dict) -> dict:
        sup_key = str(user_row.get("supervisor_first_name") or "").upper().strip()
        sup = sup_lookup.get(sup_key)
        if sup:
            return {
                "Superviseur": sup["supervisor_full_name"],
                "Superviseur_Id": sup["pulse_id"],
                "Bus": BUS_STATUS_MAP.get(sup["bus_status"], sup["bus_status"]),
            }
        # Superviseur absent de lka_supervisors (6/44 cas connus) : repli sur
        # les champs deja presents dans lka_usernames, Bus reste inconnu.
        return {
            "Superviseur": user_row.get("supervisor_full_name"),
            "Superviseur_Id": user_row.get("id_superviseur"),
            "Bus": None,
        }

    def resolve_region(region_raw):
        key = str(region_raw or "").upper().strip()
        return REGION_LABEL_AND_ID.get(key, (region_raw, None))

    def merge_row(old_row: dict, user_row: dict) -> dict:
        merged = dict(old_row)

        sup_info = resolve_supervisor(user_row)
        merged["Superviseur"] = sup_info["Superviseur"]
        merged["Superviseur_Id"] = sup_info["Superviseur_Id"]
        if sup_info["Bus"] is not None:
            merged["Bus"] = sup_info["Bus"]

        region_label, region_id = resolve_region(user_row.get("region"))
        merged["Région"] = region_label
        merged["Region_Id"] = region_id
        if not merged.get("Région+_Mercen"):
            merged["Région+_Mercen"] = region_label
        merged["Ville"] = user_row.get("commune")
        merged["Departement"] = user_row.get("departement")

        new_id_pulse = user_row.get("id_pulse")
        old_id = old_row.get("ID_Unique")

        def _pick(candidate) -> bool:
            return _valid_id(candidate) and candidate not in assigned_ids

        if _pick(new_id_pulse):
            chosen_id = new_id_pulse
        elif _pick(old_id):
            chosen_id = old_id
        else:
            chosen_id = _generate_unique_id(existing_ids | assigned_ids)
        assigned_ids.add(chosen_id)
        merged["ID_Unique"] = chosen_id

        merged["Numéros_Pulse_du_BS"] = user_row.get("numero_pulse")
        merged["Numéros_MoMo_BS"] = user_row.get("momo_msisdn")
        merged["Noms&PrénomsBS"] = user_row.get("agent_name")
        # NOTE : UsernameBS n'est PAS ecrase par user_row["user_name"] - pour
        # les anciennes lignes matchees, on garde l'orthographe HISTORIQUE
        # telle quelle (c'est la cle deja utilisee ailleurs dans Power BI).
        # Seules les lignes vraiment nouvelles (old_row vide) recoivent
        # user_name comme UsernameBS, cf. bloc appelant plus bas.
        if not merged.get("UsernameBS"):
            merged["UsernameBS"] = user_row.get("user_name")
        merged["Type_BA"] = user_row.get("real_channel")

        active = is_active(user_row.get("user_name"))
        merged["Statut_Username"] = "Actif" if active else "Inactif"
        merged["Real_statu_actif"] = 1.0 if active else 0.0
        merged["Toujours_dans_la_team?"] = "Oui" if active else "Non"

        if not merged.get("Le_BS_a_t_il_un_username?"):
            merged["Le_BS_a_t_il_un_username?"] = "Oui"

        return {col: merged.get(col) for col in target_columns}

    old_records = old_df.to_dict("records")
    old_keys = [_username_key(r.get("UsernameBS")) for r in old_records]

    # Reserver a l'avance l'ID_Unique de toutes les anciennes lignes NON
    # appariees (elles restent figees, inchangees) - sinon une ligne
    # appariee pourrait recevoir par coincidence le meme id_pulse qu'une
    # ancienne ligne non touchee (bug reel observe, 2026-07-07 :
    # 'Emmanuel.Djivo', non apparie, avait deja ID_Unique='ID4EgC5Bc' dans
    # l'ancienne donnee - et 'Mouhamadou.Daouda', apparie separement,
    # recevait ce MEME id_pulse depuis lka_usernames sans que rien ne les
    # empeche d'entrer en collision).
    for key, old_row in zip(old_keys, old_records):
        if key not in users_by_key and _valid_id(old_row.get("ID_Unique")):
            assigned_ids.add(old_row["ID_Unique"])

    output_rows = []
    matched_new_keys = set()

    for key, old_row in zip(old_keys, old_records):
        user_row = users_by_key.get(key)
        if user_row is not None:
            matched_new_keys.add(key)
            output_rows.append(merge_row(old_row, user_row))
        else:
            output_rows.append(old_row)

    blank_old_row = {col: None for col in target_columns}
    new_only_count = 0
    for key, user_row in users_by_key.items():
        if key and key not in matched_new_keys:
            output_rows.append(merge_row(blank_old_row, user_row))
            new_only_count += 1

    result_df = pd.DataFrame(output_rows, columns=target_columns)
    loader.replace_table(result_df, "numenclature", database="brand_soldier_activities")

    result = {
        "total_rows": len(result_df),
        "old_rows": len(old_df),
        "matched_rows": len(matched_new_keys),
        "new_rows": new_only_count,
    }
    logger.info(f"[numenclature] termine: {result}")
    return result


if __name__ == "__main__":
    inactive_months = int(os.getenv("INACTIVE_MONTHS", "3"))

    loader = SQLLoader()
    loader.connect()
    try:
        for flow in FLOWS:
            sync_pivot_source(loader, flow)
        sync_numenclature(loader, inactive_months=inactive_months)
    finally:
        loader.close()
