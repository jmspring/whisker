local helper = require("tests.test_helper")
local parser = require("src.format.parsers.sugarcube")

describe("SugarCube Shop System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("sugarcube/shop_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse array of objects", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)
    assert.matches("%$shopItems to %[", init.content)
  end)

  it("should parse object with multiple properties", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("id:", init.content)
    assert.matches("name:", init.content)
    assert.matches("price:", init.content)
    assert.matches("stock:", init.content)
  end)

  it("should parse for loop", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.is_not_nil(shop)
    assert.matches("<%<for", shop.content)
  end)

  it("should parse else clause", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<%<else%>%>", shop.content)
  end)

  it("should parse nested property access", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("_item%.stock", shop.content)
  end)

  it("should parse array index with property access", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("%$shopItems%[_i%]%.stock", shop.content)
  end)

  it("should parse capture with multiple variables", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<%<capture", shop.content)
  end)
end)
