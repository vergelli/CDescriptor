CDescriptor = CDescriptor or {}
CDescriptor.Adapters = CDescriptor.Adapters or {}

local M = {}

-- Returns all active buffs on the player.
-- Each entry contains the name, remaining duration in seconds, stack count,
-- the abilityId (for future use), and whether the player cast it themselves.
function M.get_active_buffs()
  local buffs = {}
  local now = GetGameTimeMilliseconds() / 1000
  local count = GetNumBuffs("player")

  for i = 1, count do
    local name, time_started, time_ending, buff_slot, stack_count,
          icon, _, effect_type, ability_type, _, ability_id, _, cast_by_player =
      GetUnitBuffInfo("player", i)

    if name and name ~= "" and effect_type == BUFF_EFFECT_TYPE_BUFF then
      local duration_remaining = nil
      if time_ending > 0 then
        duration_remaining = math.max(0, math.floor(time_ending - now))
      end

      buffs[#buffs + 1] = {
        name               = name,
        ability_id         = ability_id,
        duration_remaining = duration_remaining,  -- nil means permanent/passive
        stacks             = stack_count > 1 and stack_count or nil,
        cast_by_player     = cast_by_player,
      }
    end
  end

  return buffs
end

CDescriptor.Adapters.Buffs = M
