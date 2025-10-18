local helper = require("tests.test_helper")
local parser = require("whisker.format.parsers.harlowe")

describe("Harlowe Combat System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("harlowe/combat_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse link-repeat macro", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.is_not_nil(combat)
    assert.matches("%(link%-repeat:", combat.content)
  end)

  it("should parse random function", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%(random: %d+, %d+%)", combat.content)
  end)

  it("should parse append macro with named hook", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%(append: %?%w+%)", combat.content)
  end)

  it("should parse go-to macro", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%(go%-to:", combat.content)
  end)

  it("should parse contains operator", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("contains", combat.content)
  end)

  it("should parse array subtraction", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("it %- %(a:", combat.content)
  end)

  it("should parse min function", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%(min:", combat.content)
  end)

  it("should parse named hook definition", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("|%w+>%[%]", combat.content)
  end)

  it("should parse link macro", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%(link:", combat.content)
  end)

  it("should parse nested macros in link-repeat", function()
    local combat = helper.find_passage(parsed, "Combat")
    local content = combat.content

    -- Find link-repeat block
    local link_repeat_start = content:match("%(link%-repeat:")
    assert.is_not_nil(link_repeat_start)

    -- Should contain nested set and if macros
    assert.matches("%(link%-repeat:.*%(set:", content)
  end)

  it("should parse comparison in conditionals", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%$enemyHP <= 0", combat.content)
  end)

  it("should parse variable updates", function()
    local combat = helper.find_passage(parsed, "Combat")
    assert.matches("%(set: %$%w+ to it [%+%-] ", combat.content)
  end)
end)