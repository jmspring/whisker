local helper = require("tests.test_helper")
local parser = require("whisker.parsers.chapbook")

describe("Chapbook Variables System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("chapbook/variables_test.twee")
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
    assert.is_true(passage_names["Shop"])
    assert.is_true(passage_names["BuyItem"])
  end)

  it("should parse variable declarations at passage start", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)

    local vars_section = helper.extract_chapbook_vars_section(start.content)
    assert.is_not_nil(vars_section)
  end)

  it("should parse string variable assignment", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('name: "Hero"', start.content)
  end)

  it("should parse numeric variable assignment", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("gold: %d+", start.content)
  end)

  it("should parse array variable assignment", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("inventory: %[%]", start.content)
  end)

  it("should parse object variable assignment", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("stats: {", start.content)
    assert.matches("strength:", start.content)
  end)

  it("should parse variable interpolation in text", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("{name}", start.content)
    assert.matches("{gold}", start.content)
  end)

  it("should parse comments with double dash", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%-%-", start.content)
  end)

  it("should parse arithmetic in variable assignment", function()
    local buy = helper.find_passage(parsed, "BuyItem")
    assert.is_not_nil(buy)
    assert.matches("gold: gold %- %d+", buy.content)
  end)

  it("should parse array concat method", function()
    local buy = helper.find_passage(parsed, "BuyItem")
    assert.matches("%.concat%(%[", buy.content)
  end)

  it("should parse conditional with comparison", function()
    local shop = helper.find_passage(parsed, "Shop")
    assert.is_not_nil(shop)
    assert.matches("%[if gold >= price%]", shop.content)
  end)

  it("should parse standard links", function()
    local start = helper.find_passage(parsed, "Start")
    local links = helper.find_standard_links(start.content)
    assert.is_true(#links > 0)
  end)
end)