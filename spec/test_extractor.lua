-- Tests for pipeline/extractor.lua using mock adapters
-- Run offline with: busted spec/test_extractor.lua

CDescriptor = {}
local extractor = require("pipeline.extractor")

local function make_mock_adapters(overrides)
  local defaults = {
    character = {
      get_info = function()
        return { name = "Joehl", class = "Templar", race = "Altmer", level = 50, effective_level = 160 }
      end,
    },
    skills = {
      get_all_bars = function()
        return { bar_1 = {}, bar_2 = {} }
      end,
    },
    gear = {
      get_equipped = function()
        return { head = { name = "Ozezan Helm", quality = "gold" } }
      end,
    },
    sets = {
      get_active_sets = function()
        return { ["Spell Power Cure"] = { description = "Grants Major Courage" } }
      end,
    },
  }
  if overrides then
    for k, v in pairs(overrides) do defaults[k] = v end
  end
  return defaults
end

describe("extractor", function()

  it("calls all four adapters and returns their data", function()
    local result = extractor.extract(make_mock_adapters())
    assert.equals("Joehl",   result.character.name)
    assert.equals("Templar", result.character.class)
    assert.is_table(result.skills)
    assert.is_table(result.gear)
    assert.is_table(result.sets)
  end)

  it("passes through character data unchanged", function()
    local result = extractor.extract(make_mock_adapters())
    assert.equals(50,  result.character.level)
    assert.equals(160, result.character.effective_level)
  end)

  it("passes through gear data unchanged", function()
    local result = extractor.extract(make_mock_adapters())
    assert.equals("Ozezan Helm", result.gear.head.name)
  end)

  it("passes through sets data unchanged", function()
    local result = extractor.extract(make_mock_adapters())
    assert.equals("Grants Major Courage", result.sets["Spell Power Cure"].description)
  end)

  it("handles adapters returning empty tables", function()
    local mocks = make_mock_adapters({
      gear = { get_equipped = function() return {} end },
      sets = { get_active_sets = function() return {} end },
    })
    local result = extractor.extract(mocks)
    assert.same({}, result.gear)
    assert.same({}, result.sets)
  end)

end)
