#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Sin display manager: si el login es en la consola física tty1 y todavia no
# hay una sesion grafica, arranca Hyprland via uwsm (mismo comando que usaba
# el .desktop de SDDM) y sustituye este shell por el (exec), para que al
# cerrar sesion getty@tty1 vuelva a mostrar un prompt de login limpio.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec uwsm start -e -D Hyprland hyprland.desktop
fi
