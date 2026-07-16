#!/usr/bin/env bash
# Monte un tunnel SSH (port forward local) vers le serveur MySQL depuis un
# runner GitHub Actions, comme alternative a la connexion directe / au
# tunnel WireGuard si ceux-ci sont bloques (soupcon de blocage anti-abus
# specifique aux IP GitHub Actions cote fournisseur du serveur).
set -euo pipefail

: "${SSH_HOST:?SSH_HOST manquant}"
: "${SSH_USER:?SSH_USER manquant}"
: "${MYSQL_PORT:?MYSQL_PORT manquant}"
# Au moins un moyen d'auth : cle (SSH_PKEY, preferee) ou mot de passe
# (SSH_PASS, repli). Voir bloc de commentaires ci-dessous pour le pourquoi.
if [ -z "${SSH_PKEY:-}" ] && [ -z "${SSH_PASS:-}" ]; then
  echo "ERREUR: ni SSH_PKEY ni SSH_PASS fournis." >&2
  exit 1
fi

# sshpass n'est necessaire que pour le repli mot de passe.
if [ -n "${SSH_PASS:-}" ]; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq sshpass
fi

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
# HISTORIQUE DES ECHECS (resume, details dans
# D:\LKA\MYSQL_CONNECTION_METHODS.md §6) :
# - 2026-07-08 (run 28892973670) : 5/5 "Permission denied" en 30s -> passe
#   a 15 tentatives etalees sur 4 min.
# - 2026-07-16 (run 29481386042) : 15/15 refus sur 5 min, mot de passe
#   correct, pendant que d'autres runners passaient. L'analyse cross-repo
#   (lka-bi-pipeline + TSA-flushed + mobile-care-refresh, fenetres d'echec
#   correlees en heure malgre des IP sources differentes) montre que le
#   serveur traverse des FENETRES de refus de l'auth MOT DE PASSE (saturation
#   sshd/PAM/fail2ban due au brute-force botnet sur root). Conclusions :
#   1) l'auth par CLE (SSH_PKEY) est preferee - elle n'est pas sujette a ces
#      refus et n'alimente pas fail2ban ;
#   2) le mot de passe ne sert plus que de repli tant que la cle n'est pas
#      installee sur le serveur ;
#   3) rafale courte (6 tentatives, ~2 min) : insister plus longtemps depuis
#      la meme IP ne marche jamais (15/15 refus observes) et nourrit le ban ;
#      les pannes longues sont couvertes par auto-retry.yml qui rejoue le
#      job sur un runner NEUF (= nouvelle IP).

SSH_COMMON_OPTS=(
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=15
  -o ServerAliveInterval=15
  -o ServerAliveCountMax=3
  -o ExitOnForwardFailure=yes
  -L "127.0.0.1:${MYSQL_PORT}:127.0.0.1:${MYSQL_PORT}"
)

KEY_FILE=""
if [ -n "${SSH_PKEY:-}" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  KEY_FILE="$HOME/.ssh/lka_pipeline_key"
  printf '%s\n' "$SSH_PKEY" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
fi

# $1 = "cle" ou "mot de passe"
ssh_connect() {
  if [ "$1" = "cle" ]; then
    ssh -N -f \
      -i "$KEY_FILE" \
      -o IdentitiesOnly=yes \
      -o BatchMode=yes \
      -o PreferredAuthentications=publickey \
      "${SSH_COMMON_OPTS[@]}" \
      "${SSH_USER}@${SSH_HOST}"
  else
    sshpass -p "$SSH_PASS" ssh -N -f \
      -o PreferredAuthentications=password,keyboard-interactive \
      "${SSH_COMMON_OPTS[@]}" \
      "${SSH_USER}@${SSH_HOST}"
  fi
}

SSH_CONNECTED=0
ATTEMPT=0
for delay in 5 10 20 30 45 0; do
  ATTEMPT=$((ATTEMPT + 1))
  if [ -n "$KEY_FILE" ] && ssh_connect "cle"; then
    SSH_CONNECTED=1
    echo "Connexion SSH etablie par CLE (tentative $ATTEMPT)."
    break
  fi
  if [ -n "${SSH_PASS:-}" ] && ssh_connect "mot de passe"; then
    SSH_CONNECTED=1
    echo "Connexion SSH etablie par MOT DE PASSE (tentative $ATTEMPT) - installer la cle publique sur le serveur pour fiabiliser (cf. MYSQL_CONNECTION_METHODS.md §6)."
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
