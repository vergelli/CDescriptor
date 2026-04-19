-- Orchestrates data collection. Receives adapters as parameter for testability.
CDescriptor = CDescriptor or {}

local M = {}

function M.extract(adapters)
  return {
    character = adapters.character.get_info(),
    skills    = adapters.skills.get_all_bars(),
    gear      = adapters.gear.get_equipped(),
    sets      = adapters.sets.get_active_sets(),
    stats     = adapters.stats.get_stats(),
    buffs     = adapters.buffs.get_active_buffs(),
  }
end

CDescriptor.Extractor = M
return M
