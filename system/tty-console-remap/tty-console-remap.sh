#!/usr/bin/env bash
# Remapea la consola virtual de tty1 al framebuffer visible, segun el estado
# de la tapa y la presencia de un monitor externo.
#
# Motivo: en este portatil de graficos hibridos (AMD interno + NVIDIA
# externo), la consola de texto de tty1 (el login antes de que arranque
# Hyprland) se pinta por defecto en el framebuffer de la GPU AMD/boot_vga,
# que alimenta el panel interno. Si la tapa esta cerrada y solo hay monitor
# externo, ese prompt de login nunca se ve en ninguna pantalla.
#
# Misma logica que hypr/.config/hypr/modules/displays.lua (portatil = prefijo
# de conector "eDP", externo = cualquier otro conector conectado, estado de
# tapa via /proc/acpi/button/lid), pero resuelta contra framebuffers de
# consola en vez de monitores de Hyprland, porque esto corre ANTES del login.
#
# Los indices de framebuffer NO se hardcodean (podrian no ser siempre fb0/fb1
# segun el orden de carga de los drivers): se resuelven dinamicamente
# haciendo match del nombre de driver del conector contra /proc/fb.

set -euo pipefail

CON2FBMAP=/usr/local/bin/con2fbmap
CONSOLE=1

# La regla udev reevalua esto en caliente (hotplug de monitor, tapa) para
# cubrir el caso de estar todavia en el prompt de tty1 sin loguear. Pero DRM
# tambien genera eventos "change" constantemente mientras Hyprland esta
# corriendo (cambios de modo propios al iniciar/reconfigurar), lo que
# reactivaba este script EN MEDIO del arranque de Hyprland y tocaba el
# con2fbmap de tty1 mientras Hyprland ya tenia el control de esa misma GPU
# (visto en journalctl: 4 disparos en el mismo segundo coincidiendo con el
# arranque de Hyprland, y la sesion salio rota). Con Hyprland ya corriendo no
# hay consola de login que remapear, asi que no hacer nada.
if pgrep -x Hyprland >/dev/null 2>&1; then
    exit 0
fi

lid_closed() {
    local f
    for f in /proc/acpi/button/lid/*/state; do
        [ -f "$f" ] || continue
        grep -q closed "$f" && return 0
        return 1
    done
    return 1
}

# Conector DRM que cumple el criterio pedido ("laptop" = prefijo eDP,
# "external" = cualquier otro), de entre los que estan conectados.
find_connector() {
    local status_file conn
    for status_file in /sys/class/drm/card*-*/status; do
        [ -f "$status_file" ] || continue
        # Coincidencia exacta: "disconnected" tambien contiene la subcadena
        # "connected", asi que un grep -q sin ancla los confundiria.
        [ "$(cat "$status_file")" = "connected" ] || continue
        conn=$(basename "$(dirname "$status_file")")
        conn=${conn#*-}
        if [ "$1" = laptop ] && [[ "$conn" == eDP* ]]; then
            echo "$conn"
            return 0
        fi
        if [ "$1" = external ] && [[ "$conn" != eDP* ]]; then
            echo "$conn"
            return 0
        fi
    done
    return 1
}

# Driver (amdgpu, nvidia, ...) que maneja el conector dado.
driver_for_connector() {
    local status_file card driver
    for status_file in /sys/class/drm/card*-"$1"/status; do
        [ -f "$status_file" ] || continue
        card=$(basename "$(dirname "$status_file")")
        card=${card%%-*}
        driver=$(basename "$(readlink -f "/sys/class/drm/$card/device/driver")")
        echo "$driver"
        return 0
    done
    return 1
}

# Indice de framebuffer (/proc/fb) cuyo nombre empieza por el driver dado.
fb_index_for_driver() {
    awk -v d="$1" '$0 ~ "^[0-9]+ "d {print $1; exit}' /proc/fb
}

# nvidia_drm puede tardar en cargar respecto a amdgpu (no esta forzado en
# mkinitcpio MODULES=()), asi que se reintenta brevemente antes de rendirse.
resolve_target_fb() {
    local laptop_conn external_conn target_conn driver fb
    laptop_conn=$(find_connector laptop || true)
    external_conn=$(find_connector external || true)

    target_conn="$laptop_conn"
    if [ -n "$external_conn" ] && lid_closed; then
        target_conn="$external_conn"
    fi
    [ -n "$target_conn" ] || return 1

    driver=$(driver_for_connector "$target_conn") || return 1
    fb=$(fb_index_for_driver "$driver")
    [ -n "$fb" ] || return 1
    echo "$fb"
}

target_fb=""
for _ in $(seq 1 30); do
    if target_fb=$(resolve_target_fb); then
        break
    fi
    sleep 0.2
done

[ -n "$target_fb" ] || exit 0

current_fb=$("$CON2FBMAP" "$CONSOLE" 2>/dev/null || echo -1)
if [ "$current_fb" != "$target_fb" ]; then
    "$CON2FBMAP" "$CONSOLE" "$target_fb"
fi
