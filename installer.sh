#!/bin/sh
# Ajoute le dépôt APT signé de mawena, puis installe les paquets demandés.
#   curl -fsSL https://mawena.github.io/apt/installer.sh | sudo sh                    (dépôt seul)
#   curl -fsSL https://mawena.github.io/apt/installer.sh | sudo sh -s -- gagarine ccs (dépôt et paquets)
# Ensuite, `sudo apt update && sudo apt upgrade` apporte les nouvelles versions.
set -eu

DEPOT=https://mawena.github.io/apt
CLE=/usr/share/keyrings/mawena-depot.gpg
SOURCE=/etc/apt/sources.list.d/mawena-depot.sources

if [ "$(id -u)" -ne 0 ]; then
  echo "Dépôt mawena : à lancer en administrateur : curl -fsSL $DEPOT/installer.sh | sudo sh -s -- <paquets>" >&2
  exit 1
fi
if ! command -v apt-get >/dev/null 2>&1; then
  echo "Dépôt mawena : apt-get introuvable ; il faut Ubuntu ou une distribution Debian." >&2
  exit 1
fi

telecharger() {   # adresse fichier
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"
  else echo "Dépôt mawena : il faut curl ou wget." >&2; exit 1
  fi
}

echo "1/3 Clé du dépôt -> $CLE"
telecharger "$DEPOT/mawena-depot.gpg" "$CLE.tmp" && chmod 644 "$CLE.tmp" && mv "$CLE.tmp" "$CLE"
echo "2/3 Dépôt -> $SOURCE"
telecharger "$DEPOT/mawena-depot.sources" "$SOURCE.tmp" && chmod 644 "$SOURCE.tmp" && mv "$SOURCE.tmp" "$SOURCE"
echo "3/3 Mise à jour des index"
apt-get update
# Le paquet mawena-depot garde la clé et la source à jour lors des prochains apt upgrade.
apt-get install -y mawena-depot "$@"
echo
if [ $# -gt 0 ]; then echo "Installé : $*"; else echo "Dépôt ajouté. Installer un paquet : sudo apt install <paquet>"; fi
