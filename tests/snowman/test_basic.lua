local helper = require("tests.test_helper")
local parser = require("whisker.parsers.snowman")

describe("Snowman Basic Features", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("snowman/basic_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse code blocks", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)
    assert.matches("<%", init.content)
    assert.matches("%%>", init.content)
  end)

  it("should parse print blocks", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("<%=", start.content)
  end)

  it("should parse state object assignment", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("s%.player =", init.content)
  end)

  it("should parse JavaScript object literal", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("{%s*name:", init.content)
  end)

  it("should parse object properties", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("hp:", init.content)
    assert.matches("gold:", init.content)
    assert.matches("inventory:", init.content)
  end)

  it("should parse function declaration", function()
    local town = helper.find_passage(parsed, "Town")
    assert.is_not_nil(town)
    assert.matches("window%.%w+ = function", town.content)
  end)

  it("should parse Markdown links", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%[.-%]%(.-%)"):match(start.content)
  end)

  it("should parse jQuery selectors", function()
    local town = helper.find_passage(parsed, "Town")
    assert.matches("%$%('", town.content)
  end)

  it("should parse HTML button elements", function()
    local town = helper.find_passage(parsed, "Town")
    assert.matches("<button", town.content)
  end)

  it("should parse onclick handlers", function()
    local town = helper.find_passage(parsed, "Town")
    assert.matches('onclick="', town.content)
  end)

  it("should parse if statements", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("if %(", start.content)
  end)

  it("should parse prompt function", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("prompt%(", start.content)
  end)
end)