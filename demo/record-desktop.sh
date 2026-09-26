#!/usr/bin/env bash
# Records the desktop demo GIF for the README: a scripted tour on workspaces
# 4 and 5 (kitty + nano, Rofi, VSCodium, Dolphin, pavucontrol, Dunst,
# wlogout) with wf-recorder, then converted to demo/desktop.gif with ffmpeg.
# Run it from the repository root: demo/record-desktop.sh
# Don't touch the keyboard/mouse while it runs: if focus leaves workspaces
# 4-5 the recording is discarded, so nothing from other workspaces leaks in.
set -u

repo_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
work=/tmp/desktop-demo
out="$work/desktop.mp4"
gif="$repo_dir/demo/desktop.gif"
read -r monitor w h < <(hyprctl -j monitors | python3 -c '
import json, sys
m = next(m for m in json.load(sys.stdin) if m["focused"])
print(m["name"], m["width"], m["height"])')
pids=()

d() { hyprctl dispatch "$1" > /dev/null; }
cursor() { d "hl.dsp.cursor.move({ x = $1, y = $2 })"; }
# Type into a demo kitty window through its own remote-control socket
typ() {  # typ <socket> <text>, one key at a time, like a person
	local sock i
	sock=$(ls "$work/$1"* | head -1)
	for ((i = 0; i < ${#2}; i++)); do
		kitty @ --to "unix:$sock" send-text -- "${2:i:1}" || return 1
		sleep 0.05
	done
}
key() { kitty @ --to "unix:$(ls "$work/$1"* | head -1)" send-text -- "$2"; }
term() {  # term <socket> <dir> [bash args]: open a kitty that typ/key can drive
	setsid kitty -o allow_remote_control=yes --listen-on "unix:$work/$1" --directory "$2" bash "${@:3}" > /dev/null 2>&1 &
	pids+=($!)
}

# Demo-only config overlay: a symlink to every ~/.config entry except
# Dolphin (don't restore open tabs) and fastfetch (hide the local IP)
rm -rf "$work"
mkdir -p "$work/config/fastfetch" "$work/codium/User"
for f in "$HOME"/.config/*; do
	case ${f##*/} in dolphinrc | fastfetch) ;; *) ln -s "$f" "$work/config/" ;; esac
done
{ cat "$HOME/.config/dolphinrc" 2> /dev/null; printf '\n[General]\nRememberOpenedTabs=false\n'; } > "$work/config/dolphinrc"
XDG_CONFIG_HOME="$work/config" fastfetch --gen-config > /dev/null 2>&1
sed -i '/"localip",/d' "$work/config/fastfetch/config.jsonc"
export XDG_CONFIG_HOME="$work/config"
# Only the first terminal shows fastfetch: the others source .bashrc with it muted
printf 'fastfetch() { :; }\nsource ~/.bashrc\nunset -f fastfetch\n' > "$work/bashrc-quiet"

# VSCodium with a throwaway profile (no recent projects or restored windows)
# that keeps the real settings and extensions
python3 - "$HOME/.config/VSCodium/User/settings.json" "$work/codium/User/settings.json" << 'EOF'
import json, re, sys
try:
    s = open(sys.argv[1]).read()
    s = re.sub(r"^\s*//.*$", "", s, flags=re.M)
    settings = json.loads(re.sub(r",(\s*[}\]])", r"\1", s))
except (OSError, ValueError):
    settings = {}
settings.update({
    "security.workspace.trust.enabled": False,
    "workbench.startupEditor": "none",
    "workbench.secondarySideBar.defaultVisibility": "hidden",
    "window.restoreWindows": "none",
    "update.mode": "none",
    "extensions.autoCheckUpdates": False,
    "workbench.tips.enabled": False,
    "telemetry.telemetryLevel": "off",
})
json.dump(settings, open(sys.argv[2], "w"), indent=2)
EOF

# VSCodium takes a few seconds to start: open it on workspace 5 beforehand
d 'hl.dsp.focus({ workspace = 5 })'
setsid codium --user-data-dir "$work/codium" --extensions-dir "$HOME/.vscode-oss/extensions" \
	"$repo_dir" "$repo_dir/hypr/.config/hypr/hyprland.lua" > /dev/null 2>&1 &
for _ in $(seq 40); do
	hyprctl -j clients | grep -q '"class": "codium"' && break
	sleep 0.25
done
sleep 1.5

d 'hl.dsp.focus({ workspace = 4 })'
cursor $((w - 5)) $((h - 5))
sleep 1

wf-recorder -o "$monitor" -r 30 -c libx264 -f "$out" -y > "$work/wf-recorder.log" 2>&1 &
rec=$!
( while kill -0 "$rec" 2> /dev/null; do
	case $(hyprctl -j activeworkspace | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])') in
	4 | 5) ;; *) touch "$work/tainted"; break ;;
	esac
	sleep 0.2
done ) &
watch=$!
sleep 1.2                                   # empty desktop: wallpaper + waybar

# Workspace 4: terminals
term kitty1 "$repo_dir"
sleep 1.6
typ kitty1 "la"; key kitty1 $'\r'
sleep 1.5

term kitty2 "$HOME/.config/hypr" --rcfile "$work/bashrc-quiet"   # two at once, typing at once
term kitty3 "$repo_dir" --rcfile "$work/bashrc-quiet"
sleep 1.4
typ kitty2 "nano hyprland.lua" &
t2=$!
typ kitty3 "git log --oneline --graph -15" &
t3=$!
wait "$t2" "$t3"
sleep 0.3
key kitty2 $'\r'; key kitty3 $'\r'
sleep 1.5
key kitty2 $'\e[6~'; sleep 0.9              # PageDown
key kitty2 $'\e[6~'; sleep 1

d 'hl.dsp.window.move({ direction = "left" })'
sleep 0.8
d 'hl.dsp.window.resize({ x = 200, y = 0, relative = true })'
sleep 1

rofi -show drun > /dev/null 2>&1 &
rofi_pid=$!
sleep 1.8
kill "$rofi_pid" 2> /dev/null
sleep 0.3

# Workspace 5: VSCodium (already open), then more apps
d 'hl.dsp.focus({ workspace = 5 })'
sleep 1.8

setsid dolphin "$repo_dir" > /dev/null 2>&1 &
pids+=($!)
sleep 2
setsid pavucontrol > /dev/null 2>&1 &    # floats (rules.lua)
pids+=($!)
sleep 2.2

dunstify -a demo -u normal "Nord everywhere" "Hyprland · Waybar · Rofi · Dunst" > /dev/null
sleep 2

# wlogout, stepping the keyboard focus (styled like hover) through every
# button to show its accent. Only Right is sent, never Enter
cursor $((w - 5)) $((h - 5))
"$HOME/.local/bin/power-menu.sh" > /dev/null 2>&1 &
sleep 1
for _ in 1 2 3 4; do
	d 'hl.dsp.send_shortcut({ mods = "", key = "Right" })'
	sleep 0.55
done
sleep 0.3
pkill -x wlogout
sleep 0.5

# Close VSCodium through its main process only: killing its renderers too
# makes it show a "window terminated unexpectedly" dialog
codium_pids() {
	hyprctl -j clients | python3 -c 'import json,sys;print(*{c["pid"] for c in json.load(sys.stdin) if c["class"]=="codium"})'
}
kill "${pids[@]}" $(codium_pids) 2> /dev/null
for _ in $(seq 25); do
	[ -z "$(codium_pids)" ] && break
	sleep 0.2
done
sleep 1                                     # back to an empty desktop

kill -INT "$rec"
wait "$rec"
kill "$watch" 2> /dev/null
d 'hl.dsp.focus({ workspace = 1 })'
if [ -e "$work/tainted" ]; then
	rm -f "$out"
	echo "Discarded: focus left workspaces 4-5 during the recording" >&2
	exit 1
fi

# Blur the IP shown by Waybar's network module (top left, at scale 1)
ffmpeg -v error -y -i "$out" -filter_complex "\
[0]split[a][b];[b]crop=170:34:242:7,boxblur=luma_radius=12:luma_power=4:chroma_radius=7:chroma_power=4[bl];\
[a][bl]overlay=242:7,fps=10,scale=1024:-1:flags=lanczos,split[s0][s1];\
[s0]palettegen=max_colors=128:stats_mode=diff[p];[s1][p]paletteuse=dither=none:diff_mode=rectangle" "$gif"
ls -la "$gif"
