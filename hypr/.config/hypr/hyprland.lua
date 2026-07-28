local displays = require("modules.displays")
require("modules.binds")

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
    gaps_out = 15,
  },

  debug = {
    -- Fuerza que scale = 1 se respete (evita que Hyprland salte a 1.5 en 2560x1440).
    disable_scale_checks = true,
  },
})



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
