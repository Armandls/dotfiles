#!/usr/bin/env sh
# Estado del tunel WireGuard para waybar.
# Detecta el perfil activo sin necesitar root (ip link no requiere privilegios).

escape_json() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# Perfiles gestionados (el orden importa: se muestra el primero que este activo)
PROFILES="casa-full casa-split"

active=""
for p in $PROFILES; do
  if ip link show "$p" >/dev/null 2>&1; then
    active="$p"
    break
  fi
done

if [ -z "$active" ]; then
  printf '{"text":"󰦞","tooltip":"VPN desconectada  ·  clic para conectar","class":["disconnected"]}\n'
  exit 0
fi

# IP del tunel (si esta disponible)
addr="$(ip -o -4 addr show dev "$active" 2>/dev/null | awk '{print $4; exit}')"
[ -z "$addr" ] && addr="sin IP"

case "$active" in
  casa-full)
    icon="󰦝"
    label="FULL"
    class="full"
    desc="Todo el trafico por la VPS"
    ;;
  casa-split)
    icon="󰦟"
    label="SPLIT"
    class="split"
    desc="Solo acceso a la LAN de casa"
    ;;
  *)
    icon="󰦝"
    label="$active"
    class="full"
    desc="Tunel activo"
    ;;
esac

text="$icon  <span size='11pt'>$label</span>"
tooltip="$(escape_json "$active    $addr")\n$(escape_json "$desc")\n\nClic: desconectar  ·  Clic derecho: cambiar perfil"

printf '{"text":"%s","tooltip":"%s","class":["%s"]}\n' "$text" "$tooltip" "$class"
