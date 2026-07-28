#!/usr/bin/env sh

escape_json() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

devices="$(bluetoothctl devices Connected 2>/dev/null || true)"

if [ -z "$devices" ]; then
  printf '{"text":"","tooltip":"Bluetooth sin dispositivos conectados","class":["idle"]}\n'
  exit 0
fi

count="$(printf '%s\n' "$devices" | awk 'NF {count++} END {print count + 0}')"
first_name="$(printf '%s\n' "$devices" | sed -n '1s/^Device [^ ]* //p')"
tooltip="$(escape_json "$(printf '%s\n' "$devices" | sed 's/^Device [^ ]* //')")"

if [ "$count" -gt 1 ]; then
  text="󰂱  $count"
else
  text="󰂱  $first_name"
fi

text="$(escape_json "$text")"

printf '{"text":"%s","tooltip":"%s","class":["connected"]}\n' "$text" "$tooltip"
