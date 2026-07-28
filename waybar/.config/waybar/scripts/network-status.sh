#!/usr/bin/env sh

escape_json() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# Pick WiFi signal icon by strength (0-100).
wifi_icon() {
  s="$1"
  if [ "$s" -ge 80 ]; then printf '󰤨'
  elif [ "$s" -ge 60 ]; then printf '󰤥'
  elif [ "$s" -ge 40 ]; then printf '󰤢'
  elif [ "$s" -ge 20 ]; then printf '󰤟'
  else printf '󰤯'
  fi
}

iface="$(ip -o -4 route show to default 2>/dev/null | awk '{for (i = 1; i <= NF; i++) if ($i == "dev") {print $(i + 1); exit}}')"

if [ -z "$iface" ]; then
  text="󰤣  <span size='11pt'>Sin red</span>"
  printf '{"text":"%s","tooltip":"No Connection","class":["disconnected"]}\n' "$text"
  exit 0
fi

addr="$(ip -o -4 addr show dev "$iface" scope global 2>/dev/null | awk '{print $4; exit}')"

if [ -z "$addr" ]; then
  text="󱘖  <span size='11pt'>Sin IP</span>"
  printf '{"text":"%s","tooltip":"%s  No IP","class":["disconnected"]}\n' "$text" "$(escape_json "$iface")"
  exit 0
fi

case "$iface" in
  wl*|wifi*|wlan*)
    # Active WiFi network: SSID and signal strength via nmcli.
    line="$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" {print; exit}')"
    ssid="$(printf '%s' "$line" | cut -d: -f2)"
    signal="$(printf '%s' "$line" | cut -d: -f3)"
    [ -z "$signal" ] && signal=0
    case "$signal" in
      *[!0-9]*|"") signal=0 ;;
    esac
    icon="$(wifi_icon "$signal")"
    [ -z "$ssid" ] && ssid="$iface"
    text="$icon  <span size='11pt'>$(escape_json "$addr")</span>"
    tooltip="$(escape_json "$ssid    $signal%    $iface    $addr")"
    printf '{"text":"%s","tooltip":"%s","class":["connected"]}\n' "$text" "$tooltip"
    ;;
  *)
    icon="󰈀"
    text="$icon  <span size='11pt'>$(escape_json "$addr")</span>"
    tooltip="$(escape_json "$iface    $addr")"
    printf '{"text":"%s","tooltip":"%s","class":["connected"]}\n' "$text" "$tooltip"
    ;;
esac
