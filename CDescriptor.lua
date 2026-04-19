-- Entry point: initializes the addon after all files are loaded.
CDescriptor = CDescriptor or {}
CDescriptor.name    = "CDescriptor"
CDescriptor.version = "0.1.0"

-- Debug helper: CDescriptor.log("mensaje") imprime al chat de ESO.
-- Desactivar en produccion cambiando DEBUG a false.
local DEBUG = true
function CDescriptor.log(msg)
    if DEBUG then d("[CDescriptor] " .. tostring(msg)) end
end

local function on_addon_loaded()
  CDescriptor.log("Cargado v" .. CDescriptor.version .. " — /cdescriptor para abrir")
  CDescriptor.Settings.load()
  CDescriptorWindowGenerateButton:SetText("Generar")
  CDescriptorWindowCopyButton:SetText("Copy")

  -- Restore window position if saved
  local x = CDescriptor.Settings.get("window_x")
  local y = CDescriptor.Settings.get("window_y")
  if x and y then
    CDescriptorWindow:ClearAnchors()
    CDescriptorWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  end

  SLASH_COMMANDS["/cdescriptor"] = function()
    CDescriptor.UI.toggle()
  end
end

CDescriptor.Events.register_addon_loaded(CDescriptor.name, on_addon_loaded)
