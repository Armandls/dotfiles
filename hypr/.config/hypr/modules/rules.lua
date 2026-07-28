-- Reglas de ventana para Hyprland
-- Sintaxis: hl.window_rule({ name = ..., match = { ... }, <propiedad> })
-- El campo para forzar flotar es `float = true` (no `floating`).

-- Diálogos y portal GTK -> flotantes
hl.window_rule({
  name  = "float-dialogs",
  match = { class = "(xdg-desktop-portal-gtk|org.freedesktop.impl.portal.desktop.gtk)" },
  float = true,
})

-- Apps de ajustes / utilidades pequeñas -> flotantes
hl.window_rule({
  name  = "float-utils",
  match = { class = "(galculator|org.kde.kcalc|blueman-manager|nm-connection-editor|pavucontrol)" },
  float = true,
})

-- Popups de Kitty -> flotantes
hl.window_rule({
  name  = "float-kitty-popup",
  match = { class = "kitty", title = "^(popup)$" },
  float = true,
})
