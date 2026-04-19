-- Converts a transformed Lua table to a JSON string.
-- Depends on CDescriptor.JSON (lib/json.lua). No business logic here.
CDescriptor = CDescriptor or {}

local M = {}

function M.serialize(data)
  local json = CDescriptor.JSON
  assert(json, "CDescriptor.JSON not loaded")
  return json.encode(data)
end

CDescriptor.Serializer = M
return M
