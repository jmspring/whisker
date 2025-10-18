local helper = require("tests.test_helper")
local parser = require("engine.format.parsers.snowman")

describe("Snowman Combat System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("snowman/combat_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse multiple function declarations", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.is_not_nil(combat)

    local func_count = helper.count_pattern(combat.content, "window%.%w+ = function")
    assert.is_true(func_count >= 2)
  end)

  it("should parse Math.max", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("Math%.max%(", combat.content)
  end)

  it("should parse Math.floor", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("Math%.floor%(", combat.content)
  end)

  it("should parse Math.random", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("Math%.random%(", combat.content)
  end)

  it("should parse jQuery append", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("%.append%(", combat.content)
  end)

  it("should parse jQuery text", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("%.text%(", combat.content)
  end)

  it("should parse compound assignment", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("%-=", combat.content)
  end)

  it("should parse early return", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("return;", combat.content)
  end)

  it("should parse comparison operators", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("<=", combat.content)
  end)

  it("should parse var declarations", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("var %w+", combat.content)
  end)

  it("should parse HTML div in jQuery", function()
    local combat = helper.find_passage(parsed, "StartCombat")
    assert.matches("<div", combat.content)
  end)
end)
