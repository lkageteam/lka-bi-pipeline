# lka-bi-pipeline

Pipeline ETL MongoDB -> MySQL pour Power Process BI, execute via GitHub Actions.

## Architecture

- `config/flows.yaml` : declare chaque flux (collection source, filtre, projection, table cible, regles de transformation). Ajouter un flux = ajouter une entree ici, pas de code Python a toucher.
- `src/etl/extractor.py` : extraction Mongo par batch, avec filtre/projection arbitraires (`extract_with_query`). Le filtre temporel utilise une borne sur `_id` (ObjectId, timestamp integre) plutot que sur le champ date lui-meme, car `_id` est indexe par defaut sur toute collection Mongo — pas besoin de droits admin pour creer un index dedie.
- `src/etl/transformer.py` : transformation pilotee par la config du flux (pas d'heuristique sur le nom de collection). Aplatissement des sous-documents en colonnes prefixees (`pd.json_normalize`), fusion des typos de colonnes badge, filtre/dedoublonnage.
- `src/etl/loader.py` : chargement MySQL, creation automatique de table ou upsert via staging (`INSERT ... ON DUPLICATE KEY UPDATE`).
- `src/etl/pipeline.py` : orchestrateur, suivi via les tables `sync_runs` (audit des executions) / `sync_state` (checkpoint incremental par flux).

## Connectivite MySQL

Le serveur MySQL cible (`75.119.154.255`) a un taux d'echec de connexion TCP directe d'environ 30% (diagnostic reseau documente dans le repo `bi-gerrish`, `docs_ETL_MIGRATION_PLAN_V3.md` §2). Le pipeline (local et CI) passe donc par un tunnel WireGuard :

- Local : importer le fichier de config WireGuard recu separement, puis utiliser `MYSQL_HOST=10.66.66.1`.
- CI (GitHub Actions) : le workflow `.github/workflows/etl-sync.yml` monte automatiquement le tunnel via `scripts/wireguard_up.sh` (peer dedie, distinct du peer local) avant de lancer le pipeline.

## Lancer en local

```bash
cp .env.example .env   # completer MONGO_URI, MYSQL_PASSWORD, etc.
pip install -r requirements.txt
python -m src.etl.pipeline --dry-run                      # tous les flux, sans ecrire en MySQL
python -m src.etl.pipeline --flows vente_sim --dry-run     # un seul flux
python -m src.etl.pipeline                                 # execution reelle
```

## Flux actuellement implementes

5 flux en confiance forte (confirmes par requetes Compass reelles du referent metier, en attente de validation finale des noms de table par Gerrish) :

| Flux | Source | Table cible |
|---|---|---|
| `tsa_reports` | `reports` | `lka_bi_dw.TSA_Reports` |
| `tsa_activities` | `activities` | `lka_bi_dw.TSA_Deployments` (nom provisoire) |
| `vente_sim` | `bareports` (`type=bs-vente-sim`) | `lka_bi_dw.VENTE_SIM` |
| `dtc_activation` | `bareports` (`type=bs-dtc-activation`) | `lka_bi_dw.DTC_EXISITING` |
| `zotcheze` | `bareports` (`type=bs-zotcheze`) | `lka_bi_dw.ZOTCHEZE` (nouvelle table) |

D'autres flux (voir le fichier de collecte `analyses/handoff_gerrish_template.xlsx` du repo `bi-gerrish`) pourront etre ajoutes a `config/flows.yaml` une fois confirmes.

## Tests

```bash
python -m pytest tests/ -v
```
