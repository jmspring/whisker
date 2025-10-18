local helper = require("tests.test_helper")
local parser = require("src.format.parsers.sugarcube")

describe("SugarCube Inventory System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("sugarcube/inventory_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse StoryInit passage", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)
  end)

  it("should parse set macro", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("<>", shop.content)
  end)

  it("should parse temporary variables", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("_itemKey", shop.content)
    assert.matches("_item", shop.content)
  end)

  it("should parse capture macro", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<<capture", shop.content)
  end)

  it("should parse link macro", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<<link", shop.content)
  end)

  it("should parse if macro", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<<if", shop.content)
  end)

  it("should parse closing tags", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("<>", shop.content)
    assert.matches("<>", shop.content)
    assert.matches("<>", shop.content)
    assert.matches("<>", shop.content)
  end)

  it("should parse array push method", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("%$inventory%.push%(", shop.content)
  end)

  it("should parse compound assignment", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("%$gold %-%=", shop.content)
  end)

  it("should parse property access", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.matches("_item%.price", shop.content)
  end)
end)