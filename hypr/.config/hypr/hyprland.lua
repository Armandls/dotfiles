local displays = require("modules.displays")
require("modules.binds")
require("modules.rules")

hl.config({
  input = {
    kb_layout = "es",
    touchpad = {
      natural_scroll = true,
    },
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },

  general =  {
    gaps_in  = 5,
    gaps_out = 15,
    border_size = 2,
    col = {
      -- Gradiente Frost (Nord) para la ventana activa
      active_border   = { colors = { "rgba(88c0d0ee)", "rgba(5e81acee)" }, angle = 45 },
      inactive_border = "rgba(3b4252aa)",
    },
    resize_on_border = true,
  },

  decoration = {
    rounding = 10,
    active_opacity   = 1.0,
    inactive_opacity = 0.95,

    blur = {
      enabled = true,
      size    = 6,
      passes  = 2,
      vibrancy = 0.1696,
    },

    shadow = {
      enabled = true,
      range   = 15,
      render_power = 3,
      -- Nord Polar Night oscuro para la sombra
      color   = "rgba(1a1a1aee)",
    },
  },

  animations = {
    enabled = true,
  },

  debug = {
    -- Fuerza que scale = 1 se respete (evita que Hyprland salte a 1.5 en 2560x1440).
    disable_scale_checks = true,
  },
})

-- Curvas bezier suaves (animaciones sutiles)
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

-- Animaciones sutiles: suaves y rápidas
hl.animation({ leaf = "global",     enabled = true, speed = 8,    bezier = "easeOutQuint" })
hl.animation({ leaf = "border",     enabled = true, speed = 6,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 6,    bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5,    bezier = "linear",       style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,    bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,    bezier = "almostLinear", style = "fade" })



hl.on("hyprland.start", function()
  hl.exec_cmd("pidof hypridle || hypridle")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpaper")

  displays.apply()
end)

hl.on("monitor.added", function()
  displays.apply()
end)

hl.on("monitor.removed", function()
  displays.apply()
end)

hl.on("config.reloaded", function()
  displays.apply()
end)
