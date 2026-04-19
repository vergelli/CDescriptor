-- Collects unique set bonus descriptions from all equipped items.
-- Uses GetItemLinkSetBonusInfo to get the highest-tier bonus description per set.
CDescriptor = CDescriptor or {}
CDescriptor.Adapters = CDescriptor.Adapters or {}

local M = {}

local WEAPON_SLOTS = {
  EQUIP_SLOT_MAIN_HAND,
  EQUIP_SLOT_OFF_HAND,
  EQUIP_SLOT_BACKUP_MAIN,
  EQUIP_SLOT_BACKUP_OFF,
}
local ARMOR_SLOTS = {
  EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST,
  EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
  EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
}

local function get_set_bonus_description(link)
  local has_set, set_name, num_bonuses = GetItemLinkSetInfo(link, true)
  if not has_set or num_bonuses == 0 then return nil, nil end

  local best_desc = ""
  for i = 1, num_bonuses do
    local _, desc = GetItemLinkSetBonusInfo(link, true, i)
    if desc and desc ~= "" then
      best_desc = desc
    end
  end
  return set_name, best_desc
end

function M.get_active_sets()
  local sets = {}
  local all_slots = {}
  for _, s in ipairs(WEAPON_SLOTS) do all_slots[#all_slots+1] = s end
  for _, s in ipairs(ARMOR_SLOTS)  do all_slots[#all_slots+1] = s end

  for _, equip_slot in ipairs(all_slots) do
    local _, has_item = GetEquippedItemInfo(equip_slot)
    if has_item then
      local link = GetItemLink(BAG_WORN, equip_slot, LINK_STYLE_BRACKETS)
      if link and link ~= "" then
        local set_name, desc = get_set_bonus_description(link)
        if set_name and not sets[set_name] then
          sets[set_name] = { description = desc }
        end
      end
    end
  end
  return sets
end

CDescriptor.Adapters.Sets = M
