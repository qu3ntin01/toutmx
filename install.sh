#!/bin/sh
# Installation de ToutMX.
#   curl -fsSL https://toutmx.com/install.sh | sudo sh
#   curl -fsSL https://toutmx.com/install.sh | sudo sh -s -- --channel dev
set -eu

CHANNEL=stable
BASES="${TOUTMX_DOWNLOAD_BASE:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --channel) CHANNEL="$2"; shift 2 ;;
    --base) BASES="$2"; shift 2 ;;
    -h|--help) echo "usage : install.sh [--channel stable|dev] [--base URL]"; exit 0 ;;
    *) echo "option inconnue : $1" >&2; exit 2 ;;
  esac
done
case "$CHANNEL" in stable|dev) ;; *) echo "canal inconnu : $CHANNEL" >&2; exit 2 ;; esac
# Dépôt principal, puis dépôt de secours.
[ -n "$BASES" ] || BASES="https://repo.qu3ntin.com/toutmx/toutmx/-/raw/$CHANNEL https://raw.githubusercontent.com/qu3ntin01/toutmx/$CHANNEL"

[ "$(id -u)" -eq 0 ] || { echo "Ce script doit être lancé en root (sudo)." >&2; exit 1; }
[ "$(uname -s)" = Linux ] || { echo "ToutMX s'installe sur Linux." >&2; exit 1; }
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "architecture non prise en charge : $(uname -m)" >&2; exit 1 ;;
esac
command -v curl >/dev/null || { echo "curl est requis." >&2; exit 1; }
command -v sha256sum >/dev/null || { echo "sha256sum est requis." >&2; exit 1; }
command -v systemctl >/dev/null || { echo "systemd est requis." >&2; exit 1; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
FILE="toutmx-linux-$ARCH.tar.gz"
OK=0
for BASE in $BASES; do
  echo "Téléchargement depuis $BASE"
  if curl -fsSL "$BASE/$FILE" -o "$TMP/$FILE" && curl -fsSL "$BASE/SHA256SUMS" -o "$TMP/SHA256SUMS"; then OK=1; break; fi
done
[ "$OK" -eq 1 ] || { echo "Téléchargement impossible." >&2; exit 1; }
(cd "$TMP" && grep " $FILE\$" SHA256SUMS | sha256sum -c - >/dev/null) || { echo "Somme de contrôle invalide : installation interrompue." >&2; exit 1; }
tar -C "$TMP" -xzf "$TMP/$FILE"

install -d -m 0755 /etc/toutmx
install -d -m 0750 /var/lib/toutmx
systemctl stop toutmx 2>/dev/null || true
install -m 0755 "$TMP/toutmx/toutmx" /usr/local/bin/toutmx
install -m 0755 "$TMP/toutmx/toutmx-engine" /usr/local/bin/toutmx-engine
[ -f /etc/toutmx/toutmx.env ] || install -m 0640 "$TMP/toutmx/toutmx.env.example" /etc/toutmx/toutmx.env
install -m 0644 "$TMP/toutmx/toutmx.service" /etc/systemd/system/toutmx.service
systemctl daemon-reload
systemctl enable --now toutmx

VERSION="$(cat "$TMP/toutmx/VERSION")"
ADDR="$(hostname -I 2>/dev/null | awk '{print $1}')"; [ -n "$ADDR" ] || ADDR="$(hostname)"
echo
echo "ToutMX $VERSION est installé."
echo "Ouvrez https://$ADDR:9543 pour lancer l'assistant d'installation."
echo "Le certificat du panel est auto-signé : votre navigateur demandera une confirmation."
