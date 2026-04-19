-- Tests for pipeline/transformer.lua
-- Run offline with: busted spec/test_transformer.lua

-- Bootstrap: simulate the CDescriptor global and load the module
CDescriptor = {}
local transformer = require("pipeline.transformer")

describe("transformer", function()

  describe("transform()", function()

    it("maps character fields", function()
      local raw = {
        character = { name = "Joehl", class = "Templar", race = "Altmer", level = 50, effective_level = 160 },
        skills    = { bar_1 = {}, bar_2 = {} },
        gear      = {},
        sets      = {},
      }
      local out = transformer.transform(raw)
      assert.equals("Joehl",   out.character.name)
      assert.equals("Templar", out.character.class)
      assert.equals("Altmer",  out.character.race)
      assert.equals(50,        out.character.level)
      assert.equals(160,       out.character.champion_points)
    end)

    it("labels regular skills 1-5 and R for ultimate", function()
      local bar = {
        { name = "Skill A", ability_id = 1, is_ultimate = false },
        { name = "Skill B", ability_id = 2, is_ultimate = false },
        { name = "Skill C", ability_id = 3, is_ultimate = false },
        { name = "Skill D", ability_id = 4, is_ultimate = false },
        { name = "Skill E", ability_id = 5, is_ultimate = false },
        { name = "Big Ult",  ability_id = 6, is_ultimate = true  },
      }
      local raw = { character = {}, skills = { bar_1 = bar, bar_2 = {} }, gear = {}, sets = {} }
      local out = transformer.transform(raw)
      assert.equals("Skill A",           out.bar_1_skills["1"])
      assert.equals("Skill E",           out.bar_1_skills["5"])
      assert.equals("Big Ult (Ultimate)", out.bar_1_skills["R"])
    end)

    it("includes scribing scripts inline when present", function()
      local bar = {
        { name = "Scribing Skill", ability_id = 10, is_ultimate = false, scripts = {
            a = { name = "Damage Shield", description = "Absorbs damage" },
          }
        },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = true  },
      }
      local raw = { character = {}, skills = { bar_1 = bar, bar_2 = {} }, gear = {}, sets = {} }
      local out = transformer.transform(raw)
      local slot = out.bar_1_skills["1"]
      assert.is_table(slot)
      assert.equals("Scribing Skill", slot.name)
      assert.is_table(slot.scripts)
      assert.equals("Damage Shield", slot.scripts.a.name)
    end)

    it("skips empty skill slots", function()
      local bar = {
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "Only Skill", ability_id = 2, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = false },
        { name = "", ability_id = 0, is_ultimate = true },
      }
      local raw = { character = {}, skills = { bar_1 = bar, bar_2 = {} }, gear = {}, sets = {} }
      local out = transformer.transform(raw)
      assert.is_nil(out.bar_1_skills["1"])
      assert.equals("Only Skill", out.bar_1_skills["2"])
    end)

    it("maps armor slots with weight", function()
      local raw = {
        character = {},
        skills    = { bar_1 = {}, bar_2 = {} },
        gear = {
          head = { name = "Ozezan Helm", quality = "gold", trait = "Divines",
                   enchant = "Maximum Magicka", set_name = "Ozezan", armor_type = "Light" },
        },
        sets = {},
      }
      local out = transformer.transform(raw)
      local head = out.gear.armor.head
      assert.equals("Ozezan Helm",    head.item)
      assert.equals("Light",          head.weight)
      assert.equals("gold",           head.quality)
      assert.equals("Divines",        head.trait)
      assert.equals("Maximum Magicka", head.enchant)
      assert.equals("Ozezan",         head.set)
    end)

    it("maps weapon slots with weapon_type as item name", function()
      local raw = {
        character = {},
        skills    = { bar_1 = {}, bar_2 = {} },
        gear = {
          bar_1_weapon = { name = "SPC Staff", weapon_type = "Restoration Staff",
                           quality = "gold", trait = "Powered", enchant = "Absorb Magicka",
                           set_name = "SPC" },
        },
        sets = {},
      }
      local out = transformer.transform(raw)
      local w = out.gear.weapons.bar_1
      assert.equals("Restoration Staff", w.item)
      assert.equals("SPC",               w.set)
    end)

    it("passes sets_buffs through unchanged", function()
      local sets = { ["Spell Power Cure"] = { description = "Grants Major Courage" } }
      local raw = { character = {}, skills = { bar_1 = {}, bar_2 = {} }, gear = {}, sets = sets }
      local out = transformer.transform(raw)
      assert.equals("Grants Major Courage", out.sets_buffs["Spell Power Cure"].description)
    end)

    it("handles nil gear gracefully", function()
      local raw = { character = {}, skills = { bar_1 = {}, bar_2 = {} }, gear = nil, sets = {} }
      local out = transformer.transform(raw)
      assert.is_table(out.gear)
    end)

  end)
end)
