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

local function get_bar_slots(hotbar_category)
  local crafted_map = build_crafted_ability_map()
  local slots = {}
  for slot = 1, 6 do
    local name = GetSlotName(slot, hotbar_category) or ""
    local slot_data = {
      name        = name,
      ability_id  = GetSlotBoundId(slot, hotbar_category),
      is_ultimate = (slot == 6),
      scripts     = nil,
    }
    -- Attempt scribing match by display name
    local crafted_id = crafted_map[name]
    if crafted_id then
      local scripts = get_scribing_scripts(crafted_id)
      if next(scripts) then
        slot_data.scripts = scripts
      end
    end
    slots[slot] = slot_data
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
