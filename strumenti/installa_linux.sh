#!/usr/bin/env bash
#
# Compila TiFaro per Linux e lo installa per l'utente corrente, con l'icona
# nel menu delle applicazioni. Rilanciarlo aggiorna l'installazione: i dati
# (database e foto, in ~/.local/share/com.enne139.tifaro) non si toccano.
#
# Uso, dalla cartella del progetto:  strumenti/installa_linux.sh
# Per togliere tutto:               strumenti/installa_linux.sh --togli

set -euo pipefail

cartella_progetto="$(cd "$(dirname "$0")/.." && pwd)"
destinazione="$HOME/.local/opt/tifaro"
lanciatore="$HOME/.local/share/applications/com.enne139.tifaro.desktop"
icona="$HOME/.local/share/icons/hicolor/scalable/apps/com.enne139.tifaro.svg"
comando="$HOME/.local/bin/tifaro"

if [[ "${1:-}" == "--togli" ]]; then
  rm -rf "$destinazione" "$lanciatore" "$icona" "$comando"
  echo "TiFaro tolto. I dati restano in ~/.local/share/com.enne139.tifaro"
  exit 0
fi

cd "$cartella_progetto"
flutter build linux --release

# Si sostituisce la cartella intera: file vecchi rimasti da una versione
# precedente potrebbero confondere il programma.
rm -rf "$destinazione"
mkdir -p "$destinazione" "$(dirname "$lanciatore")" "$(dirname "$icona")" "$(dirname "$comando")"
cp -r build/linux/x64/release/bundle/. "$destinazione/"
cp assets/icona/tifaro.svg "$icona"
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
