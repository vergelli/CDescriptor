CDescriptor = CDescriptor or {}
CDescriptor.UI = {}

local M = CDescriptor.UI

local function set_status(msg)
  CDescriptorWindowStatusLabel:SetText(msg or "")
end

local function set_output(text)
  CDescriptorWindowOutputBox:SetText(text)
end

function M.on_generate()
  set_status("Extracting...")
  set_output("")

  local adapters = {
    character = CDescriptor.Adapters.Character,
    skills    = CDescriptor.Adapters.Skills,
    gear      = CDescriptor.Adapters.Gear,
    sets      = CDescriptor.Adapters.Sets,
  }

  local ok, raw = pcall(CDescriptor.Extractor.extract, adapters)
  if not ok then
    set_status("Error: " .. tostring(raw))
    return
  end

  local ok2, transformed = pcall(CDescriptor.Transformer.transform, raw)
  if not ok2 then
    set_status("Error: " .. tostring(transformed))
    return
  end

  local ok3, json_str = pcall(CDescriptor.Serializer.serialize, transformed)
  if not ok3 then
    set_status("Error: " .. tostring(json_str))
    return
  end

  set_output(json_str)
  set_status("Done.")
end

function M.on_move_stop()
  local x, y = CDescriptorWindow:GetScreenRect()
  CDescriptor.Settings.set("window_x", x)
  CDescriptor.Settings.set("window_y", y)
end

function M.show()
  CDescriptorWindow:SetHidden(false)
end

function M.toggle()
  CDescriptorWindow:SetHidden(not CDescriptorWindow:IsHidden())
end
