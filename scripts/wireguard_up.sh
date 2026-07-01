#!/usr/bin/env bash
# Monte le tunnel WireGuard vers le serveur MySQL depuis un runner GitHub Actions.
# Contourne l'instabilite reseau diagnostiquee sur la route directe
# (~30% d'echecs TCP observes vers l'IP publique du serveur).
set -euo pipefail

: "${WG_CI_PRIVATE_KEY:?WG_CI_PRIVATE_KEY manquant}"
: "${WG_SERVER_PUBLIC_KEY:?WG_SERVER_PUBLIC_KEY manquant}"
: "${WG_SERVER_ENDPOINT:?WG_SERVER_ENDPOINT manquant}"
: "${WG_CLIENT_ADDRESS:?WG_CLIENT_ADDRESS manquant}"

sudo apt-get update -qq
sudo apt-get install -y -qq wireguard

sudo mkdir -p /etc/wireguard
umask 077
echo "$WG_CI_PRIVATE_KEY" | sudo tee /etc/wireguard/ci_private.key > /dev/null
sudo chmod 600 /etc/wireguard/ci_private.key

CI_PRIVATE_KEY=$(sudo cat /etc/wireguard/ci_private.key)

sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
PrivateKey = ${CI_PRIVATE_KEY}
Address = ${WG_CLIENT_ADDRESS}

[Peer]
PublicKey = ${WG_SERVER_PUBLIC_KEY}
Endpoint = ${WG_SERVER_ENDPOINT}
AllowedIPs = 10.66.66.1/32
PersistentKeepalive = 25
EOF
sudo chmod 600 /etc/wireguard/wg0.conf

sudo wg-quick up wg0

echo "Tunnel WireGuard actif. Test de connectivite MySQL (10.66.66.1:3306)..."
for i in 1 2 3 4 5; do
  if timeout 5 bash -c "cat < /dev/null > /dev/tcp/10.66.66.1/3306" 2>/dev/null; then
    echo "Connexion TCP a 10.66.66.1:3306 OK (tentative $i)."
    exit 0
  fi
  echo "Tentative $i echouee, retry..."
  sleep 2
done

echo "ERREUR: impossible d'atteindre 10.66.66.1:3306 via le tunnel apres 5 tentatives." >&2
exit 1
