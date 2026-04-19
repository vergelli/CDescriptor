-- NOTE on scribing detection:
-- GetSlotBoundId returns an ability ID. Crafted (scribing) ability IDs come from
-- GetCraftedAbilityIdAtIndex. It is unclear without in-game testing whether these
-- IDs overlap. Current implementation matches by display name (case-insensitive prefix).
-- This should be validated and refined after first in-game test.
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

-- ACTION_BAR_FIRST_NORMAL_SLOT_INDEX and ACTION_BAR_ULTIMATE_SLOT_INDEX are
-- 0-indexed constants; the GetSlot* API is 1-indexed, hence the +1.
-- This skips slots 1-2 (Light/Heavy Attack) and reads only the 5 skill slots
-- and the ultimate slot.
local function get_bar_slots(hotbar_category)
  local crafted_map = build_crafted_ability_map()
  local slots = {}
  local skill_index = 1

  for slot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
    local slot_type = GetSlotType(slot, hotbar_category)
    local is_ultimate = (slot_type == ACTION_SLOT_TYPE_ULTIMATE)
    local name = GetSlotName(slot, hotbar_category) or ""

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
  return {
    bar_1 = get_bar_slots(HOTBAR_CATEGORY_PRIMARY),
    bar_2 = get_bar_slots(HOTBAR_CATEGORY_BACKUP),
  }
end

CDescriptor.Adapters.Skills = M
