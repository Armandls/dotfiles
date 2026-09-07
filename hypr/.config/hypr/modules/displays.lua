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

-- Lee el estado real de la tapa desde ACPI (legible sin root).
-- Devuelve true si esta cerrada, false si esta abierta o no se puede leer.
local function lid_is_closed()
  local paths = {
    "/proc/acpi/button/lid/LID0/state",
    "/proc/acpi/button/lid/LID/state",
  }
  for _, path in ipairs(paths) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a") or ""
      f:close()
      if content:match("closed") then
        return true
      end
      return false
    end
  end
  return false
end

-- Estado de la tapa del portatil. Se inicializa con el estado REAL (para que
-- arrancar con la tapa ya cerrada aplique el perfil correcto) y luego lo
-- mantienen actualizado los binds del Lid Switch.
M.lid_closed = lid_is_closed()

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

-- Vuelve a leer el estado real de la tapa (util al arrancar, cuando los binds
-- del Lid Switch aun no han disparado ningun evento).
function M.refresh_lid()
  M.lid_closed = lid_is_closed()
end

-- Numero de workspaces gestionados (coincide con los binds SUPER+1..5 y con
-- persistent-workspaces de waybar).
local WORKSPACE_COUNT = 5

-- Ancla los workspaces al monitor indicado y los hace persistentes.
--
-- Motivo: Hyprland reparte los workspaces por ORDEN DE DETECCION de monitores.
-- La pantalla interna (GPU AMD, boot_vga) se inicializa antes que el externo
-- (GPU NVIDIA), asi que el externo recibia el workspace 2 en vez del 1.
-- Anclandolos explicitamente al monitor activo se evita ese reparto arbitrario.
local function assign_workspaces(monitor)
  if not monitor then
    return
  end
  for i = 1, WORKSPACE_COUNT do
    hl.workspace_rule({
      workspace  = tostring(i),
      monitor    = monitor,
      persistent = true,
      default    = (i == 1),
    })
  end
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

  -- Anclar los workspaces al monitor que se esta usando realmente.
  local target = external or laptop
  assign_workspaces(target)
end

-- Enfoca el workspace 1. Se llama al arrancar (no dentro de apply()) porque
-- durante la reconfiguracion de monitores el cambio de workspace se ignora.
function M.focus_first_workspace()
  hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end

return M
