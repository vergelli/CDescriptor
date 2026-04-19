-- Minimal JSON serializer (encode only). No external dependencies.
CDescriptor = CDescriptor or {}

local M = {}

local ESCAPE = {
  ['"']  = '\\"',
  ['\\'] = '\\\\',
  ['\b'] = '\\b',
  ['\f'] = '\\f',
  ['\n'] = '\\n',
  ['\r'] = '\\r',
  ['\t'] = '\\t',
}

local function encode_string(s)
  return '"' .. s:gsub('["\\\b\f\n\r\t]', ESCAPE):gsub('[\0-\031]', function(c)
    return ('\\u%04x'):format(c:byte())
  end) .. '"'
end

-- Returns true only if t is a non-empty sequence with integer keys 1..n
local function is_array(t)
  local max = 0
  local count = 0
  for k in pairs(t) do
    if type(k) ~= 'number' or k < 1 or math.floor(k) ~= k then return false end
    if k > max then max = k end
    count = count + 1
  end
  return count == max and count > 0
end

local encode_value -- forward declaration

encode_value = function(val, indent, step)
  local t = type(val)
  if val == nil then
    return 'null'
  elseif t == 'boolean' then
    return tostring(val)
  elseif t == 'number' then
    if val ~= val then return '"NaN"' end
    if val == math.huge then return '"Infinity"' end
    if val == -math.huge then return '"-Infinity"' end
    if math.floor(val) == val then
      return string.format('%d', val)
    end
    return string.format('%g', val)
  elseif t == 'string' then
    return encode_string(val)
  elseif t == 'table' then
    local inner = indent .. step
    if is_array(val) then
      local parts = {}
      for i = 1, #val do
        parts[i] = inner .. encode_value(val[i], inner, step)
      end
      return '[\n' .. table.concat(parts, ',\n') .. '\n' .. indent .. ']'
    else
      local parts = {}
      for k, v in pairs(val) do
        local key = encode_string(tostring(k))
        parts[#parts + 1] = inner .. key .. ': ' .. encode_value(v, inner, step)
      end
      table.sort(parts)
      if #parts == 0 then return '{}' end
      return '{\n' .. table.concat(parts, ',\n') .. '\n' .. indent .. '}'
    end
  else
    return encode_string('[' .. t .. ']')
  end
end

function M.encode(val, indent_step)
  return encode_value(val, '', indent_step or '  ')
end

CDescriptor.JSON = M
return M
