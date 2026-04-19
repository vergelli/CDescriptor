-- Defines __key_order arrays for JSON serialization order.
-- Centralizing here avoids scattering ordering decisions across transform logic.
CDescriptor = CDescriptor or {}

CDescriptor.KeyOrders = {
  ROOT         = { "character", "bar_1_skills", "bar_2_skills", "gear", "sets_buffs", "stats", "buffs", "passive_skills", "champion_points" },
  BAR          = { "1", "2", "3", "4", "5", "R" },
  SCRIPTS      = { "a", "b", "c" },
  SCRIPT_ENTRY = { "name", "description" },
  SET_ENTRY    = { "bonuses", "count_equipped" },
  BUFF_ENTRY   = { "name", "description", "stacks", "source" },
  PASSIVE_ENTRY   = { "name", "description", "skill_line", "rank" },
  CP_DISCIPLINE   = { "slottable", "passive" },
  CP_SKILL_ENTRY  = { "name", "points" },
}
