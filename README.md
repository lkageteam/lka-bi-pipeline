# lka-bi-pipeline

Pipeline ETL MongoDB -> MySQL pour Power Process BI, execute via GitHub Actions.

## Statut actuel (2026-07-01)

✅ Pipeline valide en local (tunnel WireGuard) **et** depuis GitHub Actions en **connexion directe** (sans tunnel). Un diagnostic reseau initial avait mesure ~30% d'echecs TCP directs et laisse penser que les runners GitHub Actions (Azure) etaient specifiquement bloques par Contabo (2 runs sur 3 avec echec du handshake WireGuard). Ce constat s'est revele trompeur : le repo `AUTOMATIONS-BI` (meme infra MySQL/Mongo) tourne en connexion directe depuis GitHub Actions avec 15+ runs recents en succes, et un test direct sur ce repo a egalement reussi du premier coup. La cause exacte des echecs precedents reste incertaine (fenetre de test malchanceuse ou instabilite reellement transitoire), mais la connexion directe est desormais le mode par defaut du workflow (`use_tunnel=false`).

Le tunnel WireGuard reste en place et disponible (`use_tunnel=true` dans le workflow, ou `MYSQL_HOST=10.66.66.1` en local) comme filet de secours si la connexion directe redevient instable.

## Architecture

- `config/flows.yaml` : declare chaque flux (collection source, filtre, projection, table cible, regles de transformation). Ajouter un flux = ajouter une entree ici, pas de code Python a toucher.
- `src/etl/extractor.py` : extraction Mongo par batch, avec filtre/projection arbitraires (`extract_with_query`). Le filtre temporel utilise une borne sur `_id` (ObjectId, timestamp integre) plutot que sur le champ date lui-meme, car `_id` est indexe par defaut sur toute collection Mongo — pas besoin de droits admin pour creer un index dedie.
- `src/etl/transformer.py` : transformation pilotee par la config du flux (pas d'heuristique sur le nom de collection). Aplatissement des sous-documents en colonnes prefixees (`pd.json_normalize`), fusion des typos de colonnes badge, filtre/dedoublonnage.
- `src/etl/loader.py` : chargement MySQL, creation automatique de table ou upsert via staging (`INSERT ... ON DUPLICATE KEY UPDATE`), retry (tenacity) sur la connexion.
- `src/etl/pipeline.py` : orchestrateur, suivi via les tables `sync_runs` (audit des executions) / `sync_state` (checkpoint incremental par flux).

## Connectivite MySQL

Connexion directe a `75.119.154.255:3306` par defaut (fiable, cf. §Statut). Deux filets de secours disponibles si elle redevient instable :

- Tunnel WireGuard : local, importer le fichier de config recu separement puis `MYSQL_HOST=10.66.66.1` ; en CI, `connection_mode=wireguard`.
- Tunnel SSH : en CI, `connection_mode=ssh_tunnel` (`scripts/ssh_tunnel_up.sh`) - a utilise avec succes le 2026-07-02 quand direct et WireGuard etaient tous les deux bloques depuis les runners GitHub Actions.

## Lancer en local

```bash
cp .env.example .env   # completer MONGO_URI, MYSQL_PASSWORD, etc.
pip install -r requirements.txt
python -m src.etl.pipeline --dry-run                      # tous les flux, sans ecrire en MySQL
python -m src.etl.pipeline --flows vente_sim --dry-run     # un seul flux
python -m src.etl.pipeline                                 # execution reelle
```

## Flux actuellement implementes

Base cible : **`tsa_activities`** (meme nom que la base legacy de reference, organisation par projet - cf. `tsa_activities_structure.sql` fourni par l'utilisateur). Schema (noms de table/colonnes) valide colonne-par-colonne contre ce dump le 2026-07-03.

| Flux | Source Mongo | Table cible |
|---|---|---|
| `tsa_reports` | `reports` (export complet) | `tsa_activities.tsa_reports` |
| `tsa_deployments` | `pos` (export complet - **pas** `activities`, corrige le 2026-07-02) | `tsa_activities.tsa_deployments` |
| `vente_sim` | `bareports` (`type=bs-vente-sim`) | `tsa_activities.VENTE_SIM` |
| `dtc_activation` | `bareports` (`type=bs-dtc-activation`) | `tsa_activities.DTC_EXISITING` |
| `zotcheze` | `bareports` (`type=bs-zotcheze`) | `tsa_activities.ZOTCHEZE` (nouvelle table, aucun equivalent legacy) |

`tsa_reports`/`tsa_deployments`/`vente_sim`/`dtc_activation` ajoutent automatiquement toute colonne nouvelle rencontree dans un batch ulterieur (schema drift, cf. `SQLLoader._sync_columns`) et forcent le type TEXT pour les colonnes texte/ambigues (`SQLLoader._text_dtype_map`) afin d'eviter les erreurs de troncature MySQL.

D'autres flux (voir le fichier de collecte `analyses/handoff_gerrish_template.xlsx` du repo `bi-gerrish`) pourront etre ajoutes a `config/flows.yaml` une fois confirmes. Les tables Excel (`tsa_numenclature`, `tsa_date`, etc.) sont gerees separement via `config/excel_flows.yaml` / `.github/workflows/excel-sync.yml` (source : Google Drive).

## Tests

```bash
python -m pytest tests/ -v
```
