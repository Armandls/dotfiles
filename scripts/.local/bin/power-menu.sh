#!/usr/bin/env bash
# Abre wlogout como una sola fila de 5 botones cuadrados y centrados.
#
# wlogout solo acepta márgenes en píxeles, así que se calculan aquí a partir
# del monitor enfocado para que la fila quede centrada tanto en el portátil
# (1920x1080) como en el externo (2560x1440). Si ya está abierto, lo cierra.

pkill -x wlogout && exit 0

read -r w h < <(hyprctl -j monitors | python3 -c '
import json, sys
m = next(m for m in json.load(sys.stdin) if m["focused"])
print(round(m["width"] / m["scale"]), round(m["height"] / m["scale"]))')

size=204   # lado de cada botón: min-width/min-height de style.css + 2px de borde por lado
gap=24
x=$(((w - 5 * size - 4 * gap) / 2))
y=$(((h - size) / 2))

exec wlogout -p layer-shell -b 5 -c "$gap" -L "$x" -R "$x" -T "$y" -B "$y"
