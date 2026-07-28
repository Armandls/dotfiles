#!/usr/bin/env sh

# Power menu for Waybar using wofi (native Wayland).
# Horizontal row, icon-only, ordered right-to-left.

style="$HOME/.config/waybar/scripts/power-menu.css"

# Material Design Nerd Font glyphs (present in JBMono NF), with label below.
lock="󰌾&#10;<span size='9pt'>Bloq</span>"        # nf-md-lock
suspend="󰒲&#10;<span size='9pt'>Susp</span>"     # nf-md-power_sleep
reboot="󰜉&#10;<span size='9pt'>Reinic</span>"    # nf-md-restart
shutdown="󰐥&#10;<span size='9pt'>Apagar</span>"  # nf-md-power
logout="󰍃&#10;<span size='9pt'>Salir</span>"     # nf-md-logout

# Right-to-left visual order: logout, shutdown, reboot, suspend, lock
options="$logout
$shutdown
$reboot
$suspend
$lock"

chosen="$(printf '%s\n' "$options" | wofi \
  --dmenu \
  --allow-markup \
  --style "$style" \
  --prompt "Power" \
  --hide-search \
  --columns 5 \
  --lines 1 \
  --width 480 \
  --height 130 \
  --cache-file /dev/null)"

case "$chosen" in
  *Bloq*)   hyprlock ;;
  *Susp*)   systemctl suspend ;;
  *Reinic*) systemctl reboot ;;
  *Apagar*) systemctl poweroff ;;
  *Salir*)  uwsm stop ;;
  *)        exit 0 ;;
esac
