CDescriptor = CDescriptor or {}
CDescriptor.Adapters = CDescriptor.Adapters or {}

local M = {}

local function build_crafted_ability_map()
  local map = {}
  if not IsScribingEnabled or not IsScribingEnabled() then return map end
  local n = GetNumCraftedAbilities()
  for i = 1, n do
    local id = GetCraftedAbilityIdAtIndex(i)
    local name = GetCraftedAbilityDisplayName(id) or ""
    map[name] = id
  end
  return map
end

local function get_scribing_scripts(crafted_id)
  local p_id, s_id, t_id = GetCraftedAbilityActiveScriptIds(crafted_id)
  local slots = { p_id, s_id, t_id }
  local labels = { "a", "b", "c" }
  local scripts = {}
  for i, script_id in ipairs(slots) do
    if script_id and script_id ~= 0 then
      scripts[labels[i]] = {
        name        = GetCraftedAbilityScriptDisplayName(script_id) or "",
        description = GetCraftedAbilityScriptDescription(crafted_id, script_id) or "",
      }
    end
  end
  return scripts
end

local function get_bar_slots(hotbar_category, crafted_map, slot_names_out)
  local slots = {}
  local skill_index = 1

  for slot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
    local slot_type = GetSlotType(slot, hotbar_category)
    local is_ultimate = (slot_type == ACTION_SLOT_TYPE_ULTIMATE)
    local name = GetSlotName(slot, hotbar_category) or ""

    if slot_names_out then
      slot_names_out[#slot_names_out + 1] = name
    end

    local slot_data = {
      name        = name,
      ability_id  = GetSlotBoundId(slot, hotbar_category),
      is_ultimate = is_ultimate,
      scripts     = nil,
    }

    local crafted_id = crafted_map[name]
    if crafted_id then
      local scripts = get_scribing_scripts(crafted_id)
      if next(scripts) then
        slot_data.scripts = scripts
      end
    end

    if is_ultimate then
      slots[6] = slot_data
    else
      slots[skill_index] = slot_data
      skill_index = skill_index + 1
    end
  end

  return slots
end

function M.get_all_bars()
  local crafted_map = build_crafted_ability_map()
  local slot_names = nil

  if CDescriptor.Constants and CDescriptor.Constants.DEBUG then
    slot_names = {}
  end

  local result = {
    bar_1 = get_bar_slots(HOTBAR_CATEGORY_PRIMARY,  crafted_map, slot_names),
    bar_2 = get_bar_slots(HOTBAR_CATEGORY_BACKUP,   crafted_map, slot_names),
  }

  if CDescriptor.Constants and CDescriptor.Constants.DEBUG then
    local crafted_names = {}
    for name in pairs(crafted_map) do
      crafted_names[#crafted_names + 1] = name
    end
    result._debug = {
      crafted_ability_names = crafted_names,
      slot_names            = slot_names,
    }
  end

  return result
end

CDescriptor.Adapters.Skills = M
