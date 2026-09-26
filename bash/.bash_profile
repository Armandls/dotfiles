#
# ~/.bash_profile
#

# Scripts propios (paquete stow "scripts" -> ~/.local/bin) al principio del
# PATH. Va antes del exec de uwsm para que lo herede toda la sesion grafica;
# el case evita duplicarlo si este fichero se carga mas de una vez.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Sin display manager: si el login es en la consola física tty1 y todavia no
# hay una sesion grafica, arranca Hyprland via uwsm (mismo comando que usaba
# el .desktop de SDDM) y sustituye este shell por el (exec), para que al
# cerrar sesion getty@tty1 vuelva a mostrar un prompt de login limpio.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec uwsm start -e -D Hyprland hyprland.desktop
fi
