#!/usr/bin/env bash
#
# Installa TiFaro per l'utente corrente, con l'icona nel menu delle
# applicazioni e il comando "tifaro". Rilanciarlo aggiorna l'installazione:
# i dati (database e foto, in ~/.local/share/com.enne139.tifaro) non si
# toccano.
#
# Funziona in due modi:
#   - dall'archivio della release (TiFaro-vX.Y.Z-linux-x64.tar.gz), dove si
#     chiama installa.sh: installa il programma già compilato;
#   - dal repository (strumenti/installa_linux.sh): prima lo compila con
#     Flutter.
#
# Per togliere tutto:  installa.sh --togli

set -euo pipefail

cartella_script="$(cd "$(dirname "$0")" && pwd)"
destinazione="$HOME/.local/opt/tifaro"
lanciatore="$HOME/.local/share/applications/com.enne139.tifaro.desktop"
icona="$HOME/.local/share/icons/hicolor/scalable/apps/com.enne139.tifaro.svg"
comando="$HOME/.local/bin/tifaro"

if [[ "${1:-}" == "--togli" ]]; then
  rm -rf "$destinazione" "$lanciatore" "$icona" "$comando"
  echo "TiFaro tolto. I dati restano in ~/.local/share/com.enne139.tifaro"
  exit 0
fi

if [[ -x "$cartella_script/tifaro" && -d "$cartella_script/data" ]]; then
  # Dall'archivio: il programma è già qui accanto.
  programma="$cartella_script"
  file_icona="$cartella_script/tifaro.svg"
else
  # Dal repository: si compila la versione definitiva.
  cartella_progetto="$(cd "$cartella_script/.." && pwd)"
  (cd "$cartella_progetto" && flutter build linux --release)
  programma="$cartella_progetto/build/linux/x64/release/bundle"
  file_icona="$cartella_progetto/assets/icona/tifaro.svg"
fi

# Si sostituisce la cartella intera: file vecchi rimasti da una versione
# precedente potrebbero confondere il programma.
rm -rf "$destinazione"
mkdir -p "$destinazione" "$(dirname "$lanciatore")" "$(dirname "$icona")" "$(dirname "$comando")"
cp -r "$programma/." "$destinazione/"
cp "$file_icona" "$icona"
ln -sf "$destinazione/tifaro" "$comando"

cat > "$lanciatore" <<DESKTOP
[Desktop Entry]
Type=Application
Name=TiFaro
GenericName=Cose da fare
Comment=Attività, sotto-attività, modelli e scadenze
Exec=$destinazione/tifaro
Icon=com.enne139.tifaro
Terminal=false
Categories=Office;ProjectManagement;
Keywords=todo;attività;compiti;scadenze;
StartupWMClass=com.enne139.tifaro
DESKTOP

update-desktop-database "$(dirname "$lanciatore")" 2>/dev/null || true
echo "Installato in $destinazione: lo trovi nel menu come «TiFaro» o con il comando «tifaro»."
