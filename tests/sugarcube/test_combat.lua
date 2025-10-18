local helper = require("tests.test_helper")
local parser = require("engine.format.parsers.sugarcube")

describe("SugarCube Combat System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("sugarcube/combat_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse object initialization in StoryInit", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)
    assert.matches("%$player to {", init.content)
  end)

  it("should parse enemy initialization", function()
    local init_combat = helper.find_passage(parsed, "InitCombat")
    assert.is_not_nil(init_combat)
    assert.matches("%$enemy to {", init_combat.content)
  end)

  it("should parse Math.max function", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.is_not_nil(combat)
    assert.matches("Math%.max%(", combat.content)
  end)

  it("should parse random function", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("random%(", combat.content)
  end)

  it("should parse append macro with selector", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches('<<append "#log">>', combat.content)
  end)

  it("should parse goto macro", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("<<goto", combat.content)
  end)

  it("should parse replace macro", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("<<replace", combat.content)
  end)

  it("should parse compound assignment operators", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%-=", combat.content)
  end)

  it("should parse comparison operators", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("<=", combat.content)
  end)

  it("should parse property access on objects", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%$player%.hp", combat.content)
    assert.matches("%$enemy%.hp", combat.content)
  end)

  it("should parse division in expressions", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("/", combat.content)
  end)

  it("should parse HTML elements", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("<div", combat.content)
  end)
end)
