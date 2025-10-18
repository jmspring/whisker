local helper = require("tests.test_helper")
local parser = require("engine.format.parsers.harlowe")

describe("Harlowe Inventory System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("harlowe/inventory_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse story successfully", function()
    assert.is_not_nil(parsed)
    assert.is_not_nil(parsed.passages)
    assert.is_table(parsed.passages)
  end)

  it("should identify all passages", function()
    assert.is_true(#parsed.passages >= 3)

    local passage_names = {}
    for _, p in ipairs(parsed.passages) do
      passage_names[p.name] = true
    end

    assert.is_true(passage_names["Start"])
    assert.is_true(passage_names["Market"])
    assert.is_true(passage_names["BuySword"])
  end)

  it("should parse set macro with array initialization", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)

    -- Check for array initialization (a:)
    assert.matches("%(a:%)", start.content)
  end)

  it("should parse numeric variable assignment", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%(set: %$maxItems to %d+%)", start.content)
    assert.matches("%(set: %$gold to %d+%)", start.content)
  end)

  it("should parse variable interpolation", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%$gold", start.content)
    assert.matches("%$maxItems", start.content)
  end)

  it("should parse array property access", function()
    local market = helper.find_passage(parsed, "Market")
    assert.is_not_nil(market)
    assert.matches("%$inventory's length", market.content)
  end)

  it("should parse conditional blocks with if macro", function()
    local market = helper.find_passage(parsed, "Market")
    assert.matches("{%(if:", market.content)
  end)

  it("should parse comparison operators", function()
    local buy = helper.find_passage(parsed, "BuySword")
    assert.is_not_nil(buy)
    assert.matches("%$gold >= %d+", buy.content)
  end)

  it("should parse array concatenation with 'it' keyword", function()
    local buy = helper.find_passage(parsed, "BuySword")
    assert.matches("it %+ %(a:", buy.content)
  end)

  it("should parse arithmetic operations with 'it'", function()
    local buy = helper.find_passage(parsed, "BuySword")
    assert.matches("it %- %d+", buy.content)
  end)

  it("should parse links with arrow syntax", function()
    local start = helper.find_passage(parsed, "Start")
    local links = helper.find_harlowe_links(start.content)

    assert.is_true(#links > 0)
    assert.equals("Market", links[1].target)
  end)

  it("should parse nested if-else blocks", function()
    local buy = helper.find_passage(parsed, "BuySword")
    assert.matches("%(if:", buy.content)
    assert.matches("%]%(else:%)", buy.content)
  end)
end)