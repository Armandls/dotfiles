# dotfiles

Configuración personal de mi entorno **Arch Linux + Hyprland** (Wayland) en un
portátil ASUS con gráficos híbridos. Gestionado con [GNU Stow](https://www.gnu.org/software/stow/).

Tema: **Nord** (oscuro), unificado en GTK y Qt.

## Capturas

![desktop](screenshots/desktop.png)
## Stack

| Componente | Programa |
|------------|----------|
| Compositor | Hyprland `0.56.0` (Wayland) |
| Session manager | uwsm `0.26.6` |
| Display manager | SDDM `0.21` (tema sugar-candy) |
| Barra | Waybar `0.15` |
| Lanzador | Rofi `2.0` |
| Notificaciones | Dunst `1.13` |
| Fondo / idle / lock | hyprpaper · hypridle · hyprlock |
| Terminal | Kitty `0.48` |
| Gestor de archivos | Dolphin |
| Audio | PipeWire `1.6` + WirePlumber |
| Red | NetworkManager |
| Bluetooth | BlueZ + Blueman |
| Permisos | polkit + hyprpolkitagent |
| Capturas | grim + slurp + wl-clipboard |
| Portapapeles | wl-clipboard |
| Fuente | JetBrainsMono Nerd Font |
| Tema GTK/Qt | Nordic (GTK) + qt6ct/Fusion con paleta Nord |

## Particularidades de este setup

- **Arranque con UKI (Unified Kernel Image)** cargado por GRUB, con **TPM2**
  y arranque medido. Kernel + initramfs + microcode empaquetados en un solo
  `.efi` firmable.
- **Sesión lanzada con uwsm** (Hyprland gestionado como servicios de systemd
  de usuario), no con el arranque directo clásico.
- **Portátil ASUS con gráficos híbridos**: AMD Radeon 680M (iGPU) +
  NVIDIA RTX 3050 Mobile (dGPU), con `nvidia-open` + `mesa` y pila EGL/Wayland.
  Gestión ASUS con `asusctl` / `supergfxctl`.
- **Límite de carga de batería al 60%** para alargar su vida útil.
- **Config de Hyprland en Lua** (no el formato `.conf` tradicional).
- Variables de entorno Wayland gestionadas vía `~/.config/environment.d/`.

## Estructura (paquetes Stow)

```
.dotfiles/
├── hypr/          → ~/.config/hypr
├── waybar/        → ~/.config/waybar
├── rofi/          → ~/.config/rofi
├── dunst/         → ~/.config/dunst
├── kitty/         → ~/.config/kitty
├── gtk-3.0/       → ~/.config/gtk-3.0
├── gtk-4.0/       → ~/.config/gtk-4.0
├── qt6ct/         → ~/.config/qt6ct
├── environment.d/ → ~/.config/environment.d
└── bash/          → ~/.bashrc, ~/.bash_profile
```

## Instalación

```bash
# 1. Clonar en el HOME
git clone https://github.com/Armandls/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Instalar dependencias (repos oficiales)
sudo pacman -S --needed hyprland uwsm waybar rofi dunst hyprpaper hypridle \
  hyprlock kitty dolphin sddm pipewire wireplumber networkmanager bluez \
  blueman polkit hyprpolkitagent grim slurp wl-clipboard brightnessctl \
  power-profiles-daemon nvidia-open mesa qt6ct stow \
  ttf-jetbrains-mono-nerd tela-circle-icon-theme-nord

# 3. Dependencias AUR
yay -S --needed nordic-theme asusctl supergfxctl

# 4. Desplegar con Stow
stow bash dunst environment.d gtk-3.0 gtk-4.0 hypr kitty qt6ct rofi waybar
```

## Licencia

[MIT](LICENSE)
