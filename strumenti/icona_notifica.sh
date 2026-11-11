#!/bin/sh
# Rigenera l'icona piccola degli avvisi su Android (ic_notifica) dal suo SVG,
# nelle cinque densità: 24 dp, cioè da 24 a 96 pixel. Serve rsvg-convert.
set -e
cd "$(dirname "$0")/.."
for coppia in mdpi:24 hdpi:36 xhdpi:48 xxhdpi:72 xxxhdpi:96; do
  densita=${coppia%%:*}
  lato=${coppia##*:}
  mkdir -p "android/app/src/main/res/drawable-$densita"
  rsvg-convert -w "$lato" -h "$lato" assets/icona/tifaro_notifica.svg \
    -o "android/app/src/main/res/drawable-$densita/ic_notifica.png"
done
