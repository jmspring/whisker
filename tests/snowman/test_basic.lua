local helper = require("tests.test_helper")
local parser = require("engine.format.parsers.snowman")

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
    assert.is_true(init.content:find("<%", 1, true) ~= nil)
    assert.is_true(init.content:find("%>", 1, true) ~= nil)
  end)

  it("should parse print blocks", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.is_true(start.content:find("<%", 1, true) ~= nil)
    assert.is_true(start.content:find("%>", 1, true) ~= nil)
    assert.is_true(start.content:find("<%=", 1, true) ~= nil)
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
    local shop = helper.find_passage(parsed, "Shop")
    assert.is_not_nil(shop)
    assert.matches("window%.%w+ = function", shop.content)
  end)

  it("should parse Markdown links", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%[.-%]%(.-%)", start.content)
  end)

  it("should parse jQuery selectors", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("%$%('", shop.content)
  end)

  it("should parse HTML button elements", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<button", shop.content)
  end)

  it("should parse onclick handlers", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches('onclick="', shop.content)
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
