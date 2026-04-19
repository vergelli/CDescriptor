-- Collects learned passive skills across all relevant skill lines.
CDescriptor = CDescriptor or {}
CDescriptor.Adapters = CDescriptor.Adapters or {}

local M = {}

local SKILL_TYPES = {
  SKILL_TYPE_CLASS,
  SKILL_TYPE_WEAPON,
  SKILL_TYPE_ARMOR,
  SKILL_TYPE_GUILD,
  SKILL_TYPE_WORLD,
  SKILL_TYPE_RACIAL,
  SKILL_TYPE_AVA,
}

function M.get_learned_passives()
  local result = {}
  for _, skill_type in ipairs(SKILL_TYPES) do
    local num_lines = GetNumSkillLines(skill_type)
    for line_index = 1, num_lines do
      local skill_line_id = GetSkillLineId(skill_type, line_index)
      local line_name = GetSkillLineNameById(skill_line_id)
      local num_abilities = GetNumSkillAbilities(skill_type, line_index)

      for skill_index = 1, num_abilities do
        local name, _, earned_rank, passive, _, purchased = GetSkillAbilityInfo(skill_type, line_index, skill_index)
        if passive and purchased and earned_rank and earned_rank > 0 then
          local ability_id = GetSkillAbilityId(skill_type, line_index, skill_index, false)
          local description = nil
          if ability_id and ability_id ~= 0 then
            local desc = GetAbilityDescription(ability_id, earned_rank, "player")
            if desc and desc ~= "" then description = desc end
          end
          result[#result + 1] = {
            name        = name,
            description = description,
            skill_line  = line_name,
            rank        = earned_rank,
          }
        end
      end
    end
  end
  return result
end

CDescriptor.Adapters.Passives = M
