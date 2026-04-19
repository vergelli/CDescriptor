CDescriptor = CDescriptor or {}
CDescriptor.UI = {}

local M = CDescriptor.UI
local C  -- populated in M.init() to avoid referencing constants before they load
local Controls = {}

-- Called from CDescriptor.lua after all files and controls are ready.
function M.init()
  C = CDescriptor.Constants
  local names = C.CONTROLS
  Controls.window   = _G[names.WINDOW]
  Controls.output   = _G[names.OUTPUT_BOX]
  Controls.status   = _G[names.STATUS_LABEL]
  Controls.generate = _G[names.GENERATE_BUTTON]
  Controls.copy     = _G[names.COPY_BUTTON]

  Controls.generate:SetText(C.UI.GENERATE_BUTTON)
  Controls.copy:SetText(C.UI.COPY_BUTTON)
end

local function set_status(msg)
  Controls.status:SetText(msg or "")
end

local function set_output(text)
  Controls.output:SetText(text)
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
  set_status(C.UI.STATUS_DONE)
end

function M.on_move_stop()
  local x, y = Controls.window:GetScreenRect()
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_X, x)
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_Y, y)
end

function M.toggle()
  Controls.window:SetHidden(not Controls.window:IsHidden())
end
