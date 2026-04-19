-- Maps raw extractor output to the output schema.
-- Pure Lua: no ESO globals, no UI. Fully testable offline.
CDescriptor = CDescriptor or {}

local M = {}

local SLOT_LABELS = { "1", "2", "3", "4", "5" }

-- Strips ESO color markup: |cRRGGBBtext|r  →  text
local function strip_markup(s)
  if type(s) ~= "string" then return s end
  return (s:gsub("|c%x%x%x%x%x%x(.-)%|r", "%1"))
end

local function format_skill_slot(slot_data)
  if not slot_data or slot_data.name == "" then return nil end
  local name = strip_markup(slot_data.name)
  if slot_data.is_ultimate then
    name = name .. " (Ultimate)"
  end
  if slot_data.scripts and next(slot_data.scripts) then
    return { name = name, scripts = slot_data.scripts }
  end
  return name
end

local function transform_bar(bar_slots)
  if not bar_slots then return {} end
  local out = {}
  for i = 1, 5 do
    local entry = format_skill_slot(bar_slots[i])
    if entry ~= nil then out[SLOT_LABELS[i]] = entry end
  end
  local ult = format_skill_slot(bar_slots[6])
  if ult ~= nil then out["R"] = ult end
  return out
end

local function transform_weapon_slot(item)
  if not item then return nil end
  local weapon_name = item.weapon_type or item.name
  return {
    item    = weapon_name,
    set     = item.set_name,
    quality = item.quality,
    enchant = item.enchant,
    trait   = strip_markup(item.trait),
  }
end

local function transform_armor_slot(item)
  if not item then return nil end
  return {
    item    = item.name,
    weight  = item.armor_type,
    set     = item.set_name,
    quality = item.quality,
    enchant = item.enchant,
    trait   = strip_markup(item.trait),
  }
end

local function transform_jewelry_slot(item)
  if not item then return nil end
  return {
    item    = item.name,
    set     = item.set_name,
    quality = item.quality,
    enchant = item.enchant,
    trait   = strip_markup(item.trait),
  }
end

local function transform_gear(gear)
  if not gear then return {} end
  return {
    weapons = {
      bar_1 = transform_weapon_slot(gear.bar_1_weapon),
      bar_2 = transform_weapon_slot(gear.bar_2_weapon),
    },
    armor = {
      head     = transform_armor_slot(gear.head),
      shoulder = transform_armor_slot(gear.shoulder),
      chest    = transform_armor_slot(gear.chest),
      gloves   = transform_armor_slot(gear.gloves),
      waist    = transform_armor_slot(gear.waist),
      legs     = transform_armor_slot(gear.legs),
      boots    = transform_armor_slot(gear.boots),
    },
    jewelry = {
      neck   = transform_jewelry_slot(gear.neck),
      ring_1 = transform_jewelry_slot(gear.ring_1),
      ring_2 = transform_jewelry_slot(gear.ring_2),
    },
  }
end

local function transform_sets(sets)
  if not sets then return {} end
  local out = {}
  for name, data in pairs(sets) do
    out[name] = {
      description = strip_markup(data.description),
    }
  end
  return out
end

function M.transform(raw)
  local character = raw.character or {}
  local skills    = raw.skills or {}
  return {
    character   = {
      name            = character.name,
      class           = character.class,
      race            = character.race,
      level           = character.level,
      champion_points = character.champion_points,
    },
    bar_1_skills = transform_bar(skills.bar_1),
    bar_2_skills = transform_bar(skills.bar_2),
    gear         = transform_gear(raw.gear),
    sets_buffs   = transform_sets(raw.sets),
  }
end

CDescriptor.Transformer = M
return M
