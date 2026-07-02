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
# StrictHostKeyChecking=no : runner ephemere, pas de known_hosts a gerer.
sshpass -p "$SSH_PASS" ssh -N -f \
  -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=15 \
  -o ServerAliveCountMax=3 \
  -o ExitOnForwardFailure=yes \
  -L "127.0.0.1:${MYSQL_PORT}:127.0.0.1:${MYSQL_PORT}" \
  "${SSH_USER}@${SSH_HOST}"

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
