CDescriptor = CDescriptor or {}
CDescriptor.Adapters = CDescriptor.Adapters or {}

local M = {}

function M.get_info()
  return {
    name             = GetUnitName("player"),
    class            = GetUnitClass("player"),
    race             = GetUnitRace("player"),
    level            = GetUnitLevel("player"),
    champion_points  = GetUnitChampionPoints("player"),
  }
end

CDescriptor.Adapters.Character = M
