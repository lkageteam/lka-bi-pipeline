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

Connexion directe a `75.119.154.255:3306` par defaut (fiable, cf. §Statut). Un tunnel WireGuard reste disponible en secours :

- Local : importer le fichier de config WireGuard recu separement, puis utiliser `MYSQL_HOST=10.66.66.1`.
- CI (GitHub Actions) : lancer le workflow avec l'input `use_tunnel=true` pour monter le tunnel (`scripts/wireguard_up.sh`, peer dedie) au lieu de la connexion directe.

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
