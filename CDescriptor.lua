-- Entry point: initializes the addon after all files are loaded.
CDescriptor = CDescriptor or {}
CDescriptor.name    = "CDescriptor"
CDescriptor.version = "0.1.0"

-- Debug helper: set DEBUG = false to disable in production.
local DEBUG = true
function CDescriptor.log(msg)
    if DEBUG then d("[CDescriptor] " .. tostring(msg)) end
end

local function on_addon_loaded()
  CDescriptor.log("Loaded v" .. CDescriptor.version .. " — /cdescriptor to open")
  CDescriptor.Settings.load()
  CDescriptorWindowGenerateButton:SetText("Generate")
  CDescriptorWindowCopyButton:SetText("Copy")

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
