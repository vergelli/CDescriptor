CDescriptor = CDescriptor or {}
CDescriptor.UI = {}

local M = CDescriptor.UI
local C  -- populated in M.init() to avoid referencing constants before they load
local Controls = {}

function M.init()
  C = CDescriptor.Constants
  local names = C.CONTROLS
  Controls.window    = _G[names.WINDOW]
  Controls.output    = _G[names.OUTPUT_BOX]
  Controls.scrollbar = _G[names.SCROLLBAR]
  Controls.status    = _G[names.STATUS_LABEL]
  Controls.generate  = _G[names.GENERATE_BUTTON]
  Controls.copy      = _G[names.COPY_BUTTON]

  Controls.generate:SetText(C.UI.GENERATE_BUTTON)
  Controls.copy:SetText(C.UI.COPY_BUTTON)
  Controls.scrollbar:SetMinMax(1, 1)
  Controls.scrollbar:SetValue(1)
end

local function set_status(msg)
  Controls.status:SetText(msg or "")
end

local function set_output(text)
  Controls.output:SetText(text)
end

local function update_scrollbar()
  local extents = Controls.output:GetScrollExtents()
  if extents and extents > 0 then
    Controls.scrollbar:SetMinMax(1, 1 + extents)
    Controls.scrollbar:SetValue(1)
    Controls.scrollbar:SetHidden(false)
  else
    Controls.scrollbar:SetHidden(true)
  end
end

function M.on_generate()
  set_status(C.UI.STATUS_EXTRACT)
  set_output(C.UI.STATUS_IDLE)

  local adapters = {
    character = CDescriptor.Adapters.Character,
    skills    = CDescriptor.Adapters.Skills,
    gear      = CDescriptor.Adapters.Gear,
    sets      = CDescriptor.Adapters.Sets,
  }

  local ok, raw = pcall(CDescriptor.Extractor.extract, adapters)
  if not ok then
    set_status(C.UI.STATUS_ERROR .. tostring(raw))
    return
  end

  local ok2, transformed = pcall(CDescriptor.Transformer.transform, raw)
  if not ok2 then
    set_status(C.UI.STATUS_ERROR .. tostring(transformed))
    return
  end

  local ok3, json_str = pcall(CDescriptor.Serializer.serialize, transformed)
  if not ok3 then
    set_status(C.UI.STATUS_ERROR .. tostring(json_str))
    return
  end

  set_output(json_str)
  update_scrollbar()
  set_status(C.UI.STATUS_DONE)
end

function M.on_copy()
  Controls.output:TakeFocus()
  Controls.output:SelectAll()
  set_status(C.UI.STATUS_COPY)
end

-- Called from slider OnValueChanged (hardware events only).
function M.on_scroll(value)
  Controls.output:SetTopLineIndex(math.floor(value))
end

-- Called from EditBox OnMouseWheel after scrolling.
function M.on_editbox_scroll(lineIndex)
  Controls.scrollbar:SetValue(lineIndex)
end

function M.on_move_stop()
  local x, y = Controls.window:GetScreenRect()
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_X, x)
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_Y, y)
end

function M.toggle()
  Controls.window:SetHidden(not Controls.window:IsHidden())
end
