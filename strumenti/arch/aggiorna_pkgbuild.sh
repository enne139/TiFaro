#!/bin/sh
#
# Porta il pacchetto per Arch (strumenti/arch/PKGBUILD) a una nuova versione:
# cambia pkgver, rimette pkgrel a 1, calcola le impronte dei file e rigenera
# .SRCINFO, che è quello che paru legge per sapere se c'è un aggiornamento.
#
# Va lanciato DOPO che il flusso Rilascio ha pubblicato la release: prima,
# il PKGBUILD indicherebbe un archivio che su GitHub non c'è ancora, e chi
# aggiorna con paru in quel momento avrebbe un errore.
#
# Uso:  strumenti/arch/aggiorna_pkgbuild.sh [X.Y.Z]
#       senza versione prende quella di pubspec.yaml.
# Serve un sistema Arch: usa makepkg e updpkgsums (pacchetto pacman-contrib).

set -eu
cartella="$(cd "$(dirname "$0")" && pwd)"
cd "$cartella"

# La versione senza il numero di build: in pubspec.yaml è «0.6.1+7».
versione="${1:-$(sed -n 's/^version: *\([0-9][0-9.]*\).*/\1/p' ../../pubspec.yaml)}"
if [ -z "$versione" ]; then
  echo "Non trovo la versione in pubspec.yaml: indicala, per esempio 0.7.0." >&2
  exit 1
fi

archivio="https://github.com/enne139/TiFaro/releases/download/v$versione/TiFaro-v$versione-linux-x64.tar.gz"
if ! curl -fsIL -o /dev/null "$archivio"; then
  echo "La release v$versione non ha ancora la versione Linux su GitHub." >&2
  echo "Aspetta che il flusso Rilascio finisca, poi riprova." >&2
  exit 1
fi

sed -i -e "s/^pkgver=.*/pkgver=$versione/" -e "s/^pkgrel=.*/pkgrel=1/" PKGBUILD

# I file scaricati per calcolare le impronte vanno in una cartella a parte,
# così non restano qui dentro e non finiscono nel repository.
scaricati="$(mktemp -d)"
trap 'rm -rf "$scaricati"' EXIT
SRCDEST="$scaricati" updpkgsums
makepkg --printsrcinfo > .SRCINFO

echo "Pacchetto alla $versione: controlla con «git diff», poi commit e push."
