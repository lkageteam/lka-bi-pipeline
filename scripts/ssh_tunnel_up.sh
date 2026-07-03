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
SSH_CONNECTED=0
for i in 1 2 3 4 5; do
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
    echo "Connexion SSH etablie (tentative $i)."
    break
  fi
  echo "Connexion SSH echouee (tentative $i), retry..."
  sleep 3
done

if [ "$SSH_CONNECTED" -ne 1 ]; then
  echo "ERREUR: impossible d'etablir la connexion SSH apres 5 tentatives." >&2
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
