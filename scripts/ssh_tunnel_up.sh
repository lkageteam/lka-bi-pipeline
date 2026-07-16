#!/usr/bin/env bash
# Monte un tunnel SSH (port forward local) vers le serveur MySQL depuis un
# runner GitHub Actions, comme alternative a la connexion directe / au
# tunnel WireGuard si ceux-ci sont bloques (soupcon de blocage anti-abus
# specifique aux IP GitHub Actions cote fournisseur du serveur).
set -euo pipefail

: "${SSH_HOST:?SSH_HOST manquant}"
: "${SSH_USER:?SSH_USER manquant}"
: "${SSH_PASS:?SSH_PASS manquant}"
: "${MYSQL_PORT:?MYSQL_PORT manquant}"

sudo apt-get update -qq
sudo apt-get install -y -qq sshpass

# -N: pas de commande distante, juste le forward. -f: en arriere-plan.
# StrictHostKeyChecking=no + UserKnownHostsFile=/dev/null : runner
# ephemere, pas de known_hosts a gerer. UserKnownHostsFile=/dev/null est
# INDISPENSABLE en plus de StrictHostKeyChecking=no : bug reel observe
# (2026-07-03, runs 28665241886/28665326438) - la cle hote presentee par
# le serveur varie d'une tentative a l'autre au sein du MEME job (routage
# reseau instable cote fournisseur, deja documente). Sans
# UserKnownHostsFile=/dev/null, la 1ere tentative ecrit une cle dans
# known_hosts et la tentative suivante, recevant une cle differente, est
# categoriquement refusee ("REMOTE HOST IDENTIFICATION HAS CHANGED") meme
# avec StrictHostKeyChecking=no - ce flag ne desactive que le prompt pour
# un HOTE INCONNU, pas le refus pour un hote deja connu dont la cle a
# change.
#
# L'authentification SSH elle-meme est intermittente sur ce serveur (deja
# observe lors du diagnostic reseau initial : ~30-40% d'echecs meme avec le
# bon mot de passe, "Permission denied" sporadique sans lien avec le mot de
# passe reel). Retry sur la connexion, pas seulement sur le test TCP final.
#
# CORRECTION (2026-07-08) : run 28892973670 (cron du 2026-07-07 19:30) a
# echoue avec 5/5 tentatives en "Permission denied", toutes dans une fenetre
# de ~30s - ca ressemble a une panne cote serveur CORRELEE (rafale courte),
# pas a des echecs independants aleatoires. Avec seulement 5 tentatives
# espacees de 3s, on n'a aucune chance de survivre a une rafale de 30-60s.
# Passe a 15 tentatives avec un backoff croissant (5s -> 15s -> 30s) pour
# etaler les tentatives sur ~4 minutes au lieu de 15s, et ainsi avoir de
# bien meilleures chances de retomber en dehors de la fenetre de panne.
#
# CORRECTION (2026-07-16) : run 29481386042 - 15/15 refus "Permission
# denied" sur 5 min. Le refus soutenu pour une meme IP (alors que les crons
# voisins passent depuis d'autres runners) pointe vers un ban d'IP cote
# serveur (fail2ban/anti-abus), que nos propres rafales d'auth mot de passe
# ENTRETIENNENT : apres les premiers echecs, chaque tentative suivante est
# refusee d'office ET prolonge le ban. Insister depuis la meme IP est
# contre-productif. On redescend donc a 6 tentatives (~2 min, assez pour
# une rafale courte) ; les pannes plus longues sont couvertes par
# auto-retry.yml qui rejoue le job sur un runner NEUF (= nouvelle IP).
SSH_CONNECTED=0
ATTEMPT=0
for delay in 5 10 20 30 45 0; do
  ATTEMPT=$((ATTEMPT + 1))
  if sshpass -p "$SSH_PASS" ssh -N -f \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ConnectTimeout=15 \
    -o ServerAliveInterval=15 \
    -o ServerAliveCountMax=3 \
    -o ExitOnForwardFailure=yes \
    -L "127.0.0.1:${MYSQL_PORT}:127.0.0.1:${MYSQL_PORT}" \
    "${SSH_USER}@${SSH_HOST}"; then
    SSH_CONNECTED=1
    echo "Connexion SSH etablie (tentative $ATTEMPT)."
    break
  fi
  echo "Connexion SSH echouee (tentative $ATTEMPT), retry dans ${delay}s..."
  sleep "$delay"
done

if [ "$SSH_CONNECTED" -ne 1 ]; then
  echo "ERREUR: impossible d'etablir la connexion SSH apres $ATTEMPT tentatives." >&2
  exit 1
fi

echo "Tunnel SSH monte. Test de connectivite MySQL (127.0.0.1:${MYSQL_PORT}) via le tunnel..."
for i in 1 2 3; do
  if timeout 25 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${MYSQL_PORT}" 2>/dev/null; then
    echo "Connexion TCP via tunnel SSH OK (tentative $i)."
    exit 0
  fi
  echo "Tentative $i echouee (apres 25s), retry..."
done

echo "ERREUR: impossible d'atteindre MySQL via le tunnel SSH apres 3 tentatives de 25s." >&2
exit 1
