CDescriptor = CDescriptor or {}
CDescriptor.Settings = {}

local M = CDescriptor.Settings
local DEFAULTS = {
  window_x      = nil,
  window_y      = nil,
  window_w      = 620,
  window_h      = 530,
  include_sets     = true,   -- ON by default
  include_stats    = false,  -- OFF by default
  include_buffs    = false,  -- OFF by default
  include_passives = false,  -- OFF by default
}

function M.load()
  if CDescriptorSavedVars == nil then
    CDescriptorSavedVars = {}
  end
  for k, v in pairs(DEFAULTS) do
    if CDescriptorSavedVars[k] == nil then
      CDescriptorSavedVars[k] = v
    end
  end
end

function M.get(key)
  return CDescriptorSavedVars and CDescriptorSavedVars[key]
end

function M.set(key, value)
  if CDescriptorSavedVars then
    CDescriptorSavedVars[key] = value
  end
end
