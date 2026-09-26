# Demo GIF for the README, made with VHS (https://github.com/charmbracelet/vhs)
# Run it from the repository root: vhs demo/demo.tape

Output demo/demo.gif

Require bash
Require stow
Require eza
Require nano

Set Shell bash
Set FontFamily "JetBrainsMono Nerd Font"
Set FontSize 16
Set Width 1100
Set Height 760
Set Padding 20
Set Theme "nord"
Set TypingSpeed 60ms
Set WindowBar Colorful

# Create the fake HOME and prepare the shell without recording it
Hide
Type "source demo/setup.sh && clear"
Enter
Sleep 500ms
Show

# One Stow package per program
Type "ls"
Sleep 400ms
Enter
Sleep 2.5s

# Deploy everything into the (fake) HOME
Type "stow -v -t ~ bash dunst environment.d eza gtk-3.0 gtk-4.0 hypr kitty nano qt6ct rofi scripts waybar wlogout"
Sleep 500ms
Enter
Sleep 3s

Type "clear && ll ~/.config"
Sleep 400ms
Enter
Sleep 3.5s

# Hyprland is configured in Lua
Type "clear && lt hypr/.config/hypr"
Sleep 400ms
Enter
Sleep 2.5s

Type "nano -v ~/.config/hypr/modules/binds.lua"
Sleep 400ms
Enter
Sleep 3s
PageDown
Sleep 3s
Ctrl+Q
Sleep 800ms

# Waybar: entry point that includes one file per module
Type "clear && nano -v ~/.config/waybar/config.jsonc"
Sleep 400ms
Enter
Sleep 4s
Ctrl+Q
Sleep 800ms

# Dunst rules for Claude Code notifications
Type "clear && nano -v +/[claude-permission] ~/.config/dunst/dunstrc"
Sleep 400ms
Enter
Sleep 4s
Ctrl+Q
Sleep 1s
