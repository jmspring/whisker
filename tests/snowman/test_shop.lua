local helper = require("tests.test_helper")
local parser = require("whisker.format.parsers.snowman")

describe("Snowman Shop System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("snowman/shop_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse array of objects", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)
    assert.matches("s%.shopItems = %[", init.content)
  end)

  it("should parse Underscore findWhere", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("_%.findWhere%(", start.content)
  end)

  it("should parse negation operator", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("if %(!", start.content)
  end)

  it("should parse logical AND", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("&&", start.content)
  end)

  it("should parse Underscore.each template", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("_%.each%(", start.content)
  end)

  it("should parse template callback function", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("function%(item%)", start.content)
  end)

  it("should parse print expression in template", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("<%=", start.content)
  end)

  it("should parse HTML strong tag", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("<strong>", start.content)
  end)

  it("should parse onclick with template expression", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('onclick="buyItem%(', start.content)
  end)

  it("should parse jQuery selector in function", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%$%('#", start.content)
  end)

  it("should parse array.push()", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%.push%(", start.content)
  end)
end)
