CDescriptor = CDescriptor or {}
CDescriptor.UI = {}

local M = CDescriptor.UI

local function set_progress(value, label)
  CDescriptorWindowProgressBar:SetValue(value)
  CDescriptorWindowProgressLabel:SetText(label or "")
end

local function set_output(text)
  CDescriptorWindowOutputBox:SetText(text)
end

function M.on_generate()
  set_progress(0, "Extrayendo datos...")
  set_output("")

  local adapters = {
    character = CDescriptor.Adapters.Character,
    skills    = CDescriptor.Adapters.Skills,
    gear      = CDescriptor.Adapters.Gear,
    sets      = CDescriptor.Adapters.Sets,
  }

  local ok, raw = pcall(CDescriptor.Extractor.extract, adapters)
  if not ok then
    set_progress(0, "Error en extracción: " .. tostring(raw))
    return
  end
  set_progress(1, "Transformando datos...")

  local ok2, transformed = pcall(CDescriptor.Transformer.transform, raw)
  if not ok2 then
    set_progress(1, "Error en transformación: " .. tostring(transformed))
    return
  end
  set_progress(2, "Serializando...")

  local ok3, json_str = pcall(CDescriptor.Serializer.serialize, transformed)
  if not ok3 then
    set_progress(2, "Error en serialización: " .. tostring(json_str))
    return
  end

  set_output(json_str)
  set_progress(3, "Listo.")
end

function M.on_copy()
  local text = CDescriptorWindowOutputBox:GetText()
  if text and text ~= "" then
    CopyToClipboard(text)
  end
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
