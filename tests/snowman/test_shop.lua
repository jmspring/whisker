local helper = require("tests.test_helper")
local parser = require("src.format.parsers.snowman")

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
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("_%.findWhere%(", init.content)
  end)

  it("should parse negation operator", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("if %(!", init.content)
  end)

  it("should parse logical AND", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("&&", init.content)
  end)

  it("should parse Underscore.each template", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.is_not_nil(shop)
    assert.matches("_%.each%(", shop.content)
  end)

  it("should parse template callback function", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("function%(item%)", shop.content)
  end)

  it("should parse print expression in template", function()
    local shop = helper.find_passage(parsed, "Shop")
    local print_count = helper.count_pattern(shop.content, "<%=")
    assert.is_true(print_count >= 2)
  end)

  it("should parse HTML strong tag", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("", shop.content)
  end)

  it("should parse onclick with template expression", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches('onclick="buyItem%(<%= item%.id %%>%)"', shop.content)
  end)

  it("should parse jQuery selector in function", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%$%('#[%w%-]+.'%)", init.content)
  end)

  it("should parse array.push()", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%.push%(", init.content)
  end)
end)