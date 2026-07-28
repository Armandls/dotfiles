-- Gestion de monitores / perfiles de pantalla
--
-- Comportamiento deseado:
--   * Monitor externo (DP-6) conectado + tapa abierta -> ambas pantallas muestran
--     lo mismo (eDP-1 hace mirror de DP-6).
--   * Tapa cerrada (con externo conectado)            -> solo DP-6, eDP-1 apagado.
--   * Tapa abierta de nuevo                            -> eDP-1 vuelve a mirror de DP-6.
--   * Externo desconectado                             -> todo en eDP-1 a su modo nativo.
--
-- Toda la logica corre DENTRO de Hyprland usando la API Lua nativa (hl.monitor,
-- hl.get_monitors). No se usa "hyprctl eval" (no evalua Lua) ni scripts externos.

local M = {}

local EXTERNAL = "DP-6"
local LAPTOP   = "eDP-1"

-- Estado de la tapa del portatil. Lo actualizan los binds del Lid Switch.
M.lid_closed = false

-- Comprueba si un monitor (por nombre de output) esta fisicamente presente.
local function monitor_present(name)
  for _, mon in ipairs(hl.get_monitors()) do
    if mon.name == name then
      return true
    end
  end
  return false
end

-- Aplica el perfil de pantalla segun los monitores presentes y el estado de la tapa.
function M.apply()
  local has_external = monitor_present(EXTERNAL)

  if has_external then
    -- El externo manda: modo nativo, escala 1.
    hl.monitor({
      output   = EXTERNAL,
      mode     = "2560x1440@59.95",
      position = "0x0",
      scale    = 1,
    })

    if M.lid_closed then
      -- Tapa cerrada: solo el externo.
      hl.monitor({ output = LAPTOP, disabled = true })
    else
      -- Tapa abierta: el portatil refleja (mirror) al externo.
      hl.monitor({
        output   = LAPTOP,
        mode     = "1920x1080@144",
        position = "auto",
        scale    = 1,
        mirror   = EXTERNAL,
      })
    end
  else
    -- Sin externo: todo en el portatil, modo nativo, sin mirror.
    hl.monitor({
      output   = LAPTOP,
      mode     = "1920x1080@144",
      position = "0x0",
      scale    = 1,
    })
  end
end

return M
