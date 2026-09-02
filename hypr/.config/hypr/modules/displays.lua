-- Gestion de monitores / perfiles de pantalla
--
-- Comportamiento deseado:
--   * Monitor externo conectado + tapa abierta -> ambas pantallas muestran
--     lo mismo (el portatil hace mirror del externo).
--   * Tapa cerrada (con externo conectado)     -> solo el externo, portatil apagado.
--   * Tapa abierta de nuevo                     -> portatil vuelve a mirror del externo.
--   * Externo desconectado                      -> todo en el portatil a su modo nativo.
--
-- IMPORTANTE: los nombres de conector pueden cambiar (eDP-1 -> eDP-2, DP-6 -> DP-1)
-- segun el orden de carga de los drivers. Por eso NO se usan nombres fijos:
-- el portatil se detecta por el prefijo "eDP" y el externo es cualquier otro.

local M = {}

-- Estado de la tapa del portatil. Lo actualizan los binds del Lid Switch.
M.lid_closed = false

-- Devuelve el nombre del monitor interno (eDP*) o nil si no esta presente.
local function find_laptop()
  for _, mon in ipairs(hl.get_monitors()) do
    if mon.name and mon.name:match("^eDP") then
      return mon.name
    end
  end
  return nil
end

-- Devuelve el nombre del primer monitor externo (no eDP) o nil.
local function find_external()
  for _, mon in ipairs(hl.get_monitors()) do
    if mon.name and not mon.name:match("^eDP") then
      return mon.name
    end
  end
  return nil
end

-- Aplica el perfil de pantalla segun los monitores presentes y el estado de la tapa.
function M.apply()
  local laptop   = find_laptop()
  local external = find_external()

  if external then
    -- El externo manda: modo preferido, escala 1.
    hl.monitor({
      output   = external,
      mode     = "preferred",
      position = "0x0",
      scale    = 1,
    })

    if laptop then
      if M.lid_closed then
        -- Tapa cerrada: solo el externo.
        hl.monitor({ output = laptop, disabled = true })
      else
        -- Tapa abierta: el portatil refleja (mirror) al externo.
        hl.monitor({
          output   = laptop,
          mode     = "preferred",
          position = "auto",
          scale    = 1,
          mirror   = external,
        })
      end
    end
  elseif laptop then
    -- Sin externo: todo en el portatil, modo nativo, sin mirror.
    hl.monitor({
      output   = laptop,
      mode     = "preferred",
      position = "0x0",
      scale    = 1,
    })
  end
end

return M
