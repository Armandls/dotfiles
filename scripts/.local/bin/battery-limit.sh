#!/usr/bin/env bash
# Fija el limite de carga de la bateria al 60% para alargar su vida util.
# Lo invoca battery-limit.service en cada arranque.

THRESHOLD=60
BAT_PATH=/sys/class/power_supply/BAT0/charge_control_end_threshold

if [ -w "$BAT_PATH" ]; then
    echo "$THRESHOLD" > "$BAT_PATH"
elif [ -e "$BAT_PATH" ]; then
    # Requiere privilegios (el service corre como root, asi que deberia poder)
    printf '%s\n' "$THRESHOLD" | tee "$BAT_PATH" > /dev/null
else
    echo "No se encontro $BAT_PATH" >&2
    exit 1
fi
