#!/usr/bin/env bash
# Control del tunel WireGuard desde waybar.
#
# Uso:
#   vpn-toggle.sh toggle   -> si hay tunel activo lo baja; si no, abre el selector
#   vpn-toggle.sh menu     -> menu rofi para elegir perfil o desconectar
#
# Garantiza exclusividad mutua: nunca deja dos tuneles arriba a la vez
# (ver docs/OPERATIONS.md del proyecto myVPN).
#
# Requiere una regla sudoers que permita sin contrasena:
#   wg-quick up|down casa-full|casa-split

set -u

PROFILES=(casa-full casa-split)
ROFI_THEME="$HOME/.config/rofi/config.rasi"

notify() {
    notify-send -a "VPN" -i network-vpn "$1" "${2:-}" 2>/dev/null || true
}

refresh_waybar() {
    # signal 8 -> definido en modules/vpn.jsonc
    pkill -SIGRTMIN+8 waybar 2>/dev/null || true
}

active_profile() {
    for p in "${PROFILES[@]}"; do
        if ip link show "$p" >/dev/null 2>&1; then
            printf '%s' "$p"
            return 0
        fi
    done
    return 1
}

down_all() {
    for p in "${PROFILES[@]}"; do
        if ip link show "$p" >/dev/null 2>&1; then
            sudo -n wg-quick down "$p" >/dev/null 2>&1
        fi
    done
}

bring_up() {
    local target="$1"
    # Exclusividad: bajar cualquier tunel antes de subir el nuevo
    down_all
    if sudo -n wg-quick up "$target" >/dev/null 2>&1; then
        notify "Conectada" "$target"
    else
        notify "Error al conectar" "$target (revisa permisos sudo)"
    fi
    refresh_waybar
}

disconnect() {
    local current
    if current="$(active_profile)"; then
        down_all
        notify "Desconectada" "$current"
    fi
    refresh_waybar
}

# Menu rofi. casa-full primero (perfil mas usado).
choose_profile() {
    local current options chosen
    current="$(active_profile || printf '')"

    options="󰦝  Full tunnel   (todo por la VPS)\n󰦟  Split tunnel  (solo LAN de casa)"
    if [ -n "$current" ]; then
        options="$options\n󰦞  Desconectar   ($current)"
    fi

    chosen="$(printf '%b' "$options" | rofi -dmenu -i \
        -p "VPN" \
        -theme "$ROFI_THEME" \
        -no-custom 2>/dev/null)"

    case "$chosen" in
        *"Full tunnel"*)   bring_up "casa-full" ;;
        *"Split tunnel"*)  bring_up "casa-split" ;;
        *"Desconectar"*)   disconnect ;;
        *)                 exit 0 ;;   # cancelado
    esac
}

case "${1:-toggle}" in
    toggle)
        if active_profile >/dev/null; then
            disconnect
        else
            choose_profile
        fi
        ;;
    menu)
        choose_profile
        ;;
    *)
        printf 'Uso: %s {toggle|menu}\n' "$(basename "$0")" >&2
        exit 1
        ;;
esac
