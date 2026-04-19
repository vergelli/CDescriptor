-- Tests for lib/json.lua and pipeline/serializer.lua
-- Run offline with: busted spec/test_serializer.lua

CDescriptor = {}
local json = require("lib.json")
CDescriptor.JSON = json
local serializer = require("pipeline.serializer")

describe("json encoder", function()

  it("encodes nil as null", function()
    assert.equals("null", json.encode(nil))
  end)

  it("encodes booleans", function()
    assert.equals("true",  json.encode(true))
    assert.equals("false", json.encode(false))
  end)

  it("encodes integers without decimal", function()
    assert.equals("42",  json.encode(42))
    assert.equals("-7",  json.encode(-7))
    assert.equals("0",   json.encode(0))
  end)

  it("encodes strings with escaping", function()
    assert.equals('"hello"',       json.encode("hello"))
    assert.equals('"say \\"hi\\""', json.encode('say "hi"'))
    assert.equals('"line\\nbreak"', json.encode("line\nbreak"))
  end)

  it("encodes empty object", function()
    assert.equals("{}", json.encode({}))
  end)

  it("encodes flat object", function()
    local out = json.encode({ a = 1 })
    assert.truthy(out:match('"a": 1'))
  end)

  it("encodes array", function()
    local out = json.encode({ 10, 20, 30 })
    assert.truthy(out:match('%['))
    assert.truthy(out:match('10'))
    assert.truthy(out:match('20'))
  end)

  it("encodes nested table", function()
    local out = json.encode({ character = { name = "Joehl", level = 50 } })
    assert.truthy(out:match('"character"'))
    assert.truthy(out:match('"name"'))
    assert.truthy(out:match('"Joehl"'))
  end)

  it("produces deterministic key order", function()
    local out1 = json.encode({ b = 2, a = 1, c = 3 })
    local out2 = json.encode({ c = 3, b = 2, a = 1 })
    assert.equals(out1, out2)
  end)

end)

describe("serializer", function()

  it("serializes a transformed table to a JSON string", function()
    local data = {
      character = { name = "Joehl", class = "Templar" },
      sets_buffs = {},
    }
    local result = serializer.serialize(data)
    assert.is_string(result)
    assert.truthy(result:match('"Joehl"'))
    assert.truthy(result:match('"Templar"'))
  end)

  it("returns valid JSON that starts with {", function()
    local result = serializer.serialize({ x = 1 })
    assert.equals("{", result:sub(1, 1))
  end)

end)
