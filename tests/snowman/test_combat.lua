local helper = require("tests.test_helper")
local parser = require("whisker.parsers.snowman")

describe("Snowman Combat System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("snowman/combat_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse multiple function declarations", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)

    local func_count = helper.count_pattern(init.content, "window%.%w+ = function")
    assert.is_true(func_count >= 2)
  end)

  it("should parse Math.max", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("Math%.max%(", init.content)
  end)

  it("should parse Math.floor", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("Math%.floor%(", init.content)
  end)

  it("should parse Math.random", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("Math%.random%(", init.content)
  end)

  it("should parse jQuery append", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%.append%(", init.content)
  end)

  it("should parse jQuery text", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%.text%(", init.content)
  end)

  it("should parse compound assignment", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%-=", init.content)
  end)

  it("should parse early return", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("return;", init.content)
  end)

  it("should parse comparison operators", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("<=", init.content)
  end)

  it("should parse var declarations", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("var %w+", init.content)
  end)

  it("should parse HTML div in jQuery", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("", init.content)
  end)
end)