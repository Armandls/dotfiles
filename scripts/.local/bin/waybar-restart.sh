#!/usr/bin/env bash
# Arranca waybar garantizando que solo haya UNA instancia.
#
# Motivo: al iniciar Hyprland se disparan tanto 'hyprland.start' como
# 'monitor.added', y si ambos lanzan waybar acabamos con dos barras.
# Este script usa un lock para serializar y mata instancias previas antes
# de arrancar una nueva.
#
# El retardo mitiga el bug upstream de waybar (issue #3742): si el IPC de
# Hyprland no responde al instante, waybar DESACTIVA el modulo
# hyprland/workspaces de forma permanente.

LOCK=/tmp/waybar-restart.lock

# Serializar: si ya hay un arranque en curso, salir sin hacer nada
exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

# Matar instancias previas y esperar a que mueran de verdad
if pgrep -x waybar >/dev/null 2>&1; then
    pkill -x waybar
    for _ in $(seq 1 30); do
        pgrep -x waybar >/dev/null 2>&1 || break
        sleep 0.1
    done
fi

# Esperar a que el IPC de Hyprland responda con workspaces validos
for _ in $(seq 1 50); do
    out="$(hyprctl -j workspaces 2>/dev/null)"
    if [ -n "$out" ] && [ "${out:0:1}" = "[" ] && [ "$out" != "[]" ]; then
        break
    fi
    sleep 0.1
done

# Margen extra para que el IPC quede estable
sleep 0.5

# IMPORTANTE: cerrar el fd 9 (el lock) para el proceso de waybar. setsid NO
# cierra descriptores heredados por si solo: si waybar se queda con el fd 9
# abierto, el lock queda "atrapado" mientras waybar viva, y CUALQUIER
# invocacion futura de este script (monitor.added, monitor.removed, o esta
# misma en el siguiente arranque) falla el flock -n y sale sin hacer nada.
setsid waybar 9>&- >/dev/null 2>&1 < /dev/null &

exit 0
