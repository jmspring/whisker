local helper = require("tests.test_helper")
local parser = require("whisker.format.parsers.chapbook")

describe("Chapbook Conditionals System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("chapbook/conditionals_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse if modifier", function()
    local stats = helper.find_passage(parsed, "Stats")
    assert.is_not_nil(stats)
    assert.matches("%[if ", stats.content)
  end)

  it("should parse else modifier", function()
    local stats = helper.find_passage(parsed, "Stats")
    assert.matches("%[else%]", stats.content)
  end)

  it("should parse continue modifier", function()
    local stats = helper.find_passage(parsed, "Stats")
    assert.matches("%[continue%]", stats.content)
  end)

  it("should parse string equality comparison", function()
    local stats = helper.find_passage(parsed, "Stats")
    assert.matches('playerClass === "Warrior"', stats.content)
  end)

  it("should parse multiple if conditions", function()
    local stats = helper.find_passage(parsed, "Stats")
    local if_count = helper.count_pattern(stats.content, "%[if ")
    assert.is_true(if_count >= 3)
  end)

  it("should parse numeric comparison", function()
    local stats = helper.find_passage(parsed, "Stats")
    assert.matches("level < %d+", stats.content)
  end)

  it("should parse variable assignment in passage", function()
    local warrior = helper.find_passage(parsed, "SelectWarrior")
    assert.is_not_nil(warrior)
    assert.matches('playerClass: "Warrior"', warrior.content)
  end)

  it("should parse numeric variable updates", function()
    local warrior = helper.find_passage(parsed, "SelectWarrior")
    assert.matches("health: %d+", warrior.content)
  end)

  it("should identify vars section separator", function()
    local passages_with_vars = {}
    for _, passage in ipairs(parsed.passages) do
      if passage.content:match("%-%-") then
        table.insert(passages_with_vars, passage)
      end
    end
    assert.is_true(#passages_with_vars >= 3)
  end)

  it("should parse variable interpolation in modifiers", function()
    local stats = helper.find_passage(parsed, "Stats")
    assert.matches("{playerClass}", stats.content)
    assert.matches("{health}", stats.content)
    assert.matches("{level}", stats.content)
  end)

  it("should not allow nested conditionals", function()
    -- Chapbook doesn't support nested conditionals by design
    -- This test verifies the parser recognizes this
    local has_nested = false
    for _, passage in ipairs(parsed.passages) do
      -- Check for if within if (shouldn't exist in valid Chapbook)
      if passage.content:match("%[if.--%[if") then
        has_nested = true
      end
    end
    assert.is_false(has_nested)
  end)
end)