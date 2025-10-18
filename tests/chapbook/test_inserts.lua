local helper = require("tests.test_helper")
local parser = require("src.format.parsers.chapbook")

describe("Chapbook Inserts System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("chapbook/inserts_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse text input insert", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("{text input for:", start.content)
  end)

  it("should parse cycling link insert", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("{cycling link for:", start.content)
  end)

  it("should parse dropdown menu insert", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("{dropdown menu for:", start.content)
  end)

  it("should parse insert with choices array", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("choices: %[", start.content)
  end)

  it("should parse link to insert", function()
    local summary = helper.find_passage(parsed, "Summary")
    assert.is_not_nil(summary)
    assert.matches("{link to:", summary.content)
  end)

  it("should parse link with label parameter", function()
    local summary = helper.find_passage(parsed, "Summary")
    assert.matches("label:", summary.content)
  end)

  it("should parse back link insert", function()
    local adventure = helper.find_passage(parsed, "Adventure")
    assert.is_not_nil(adventure)
    assert.matches("{back link}", adventure.content)
  end)

  it("should parse variable in insert parameter", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("for: 'playerName'", start.content)
  end)

  it("should parse string array in choices", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("'Blue', 'Red'", start.content)
  end)

  it("should parse comparison in conditional with insert", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('%[if playerName !== ""%]', start.content)
  end)

  it("should parse arithmetic expression in variable assignment", function()
    local continue = helper.find_passage(parsed, "QuestContinue")
    assert.is_not_nil(continue)
    assert.matches("questProgress %+ %d+", continue.content)
  end)

  it("should parse variable interpolation", function()
    local summary = helper.find_passage(parsed, "Summary")
    assert.matches("{playerName}", summary.content)
    assert.matches("{favoriteColor}", summary.content)
  end)

  it("should parse comparison operators", function()
    local adventure = helper.find_passage(parsed, "Adventure")
    assert.matches("===", adventure.content)
    assert.matches(">", adventure.content)
  end)

  it("should validate insert syntax", function()
    -- Inserts must be on one line
    for _, passage in ipairs(parsed.passages) do
      for insert in passage.content:gmatch("{[^}]+}") do
        assert.is_false(insert:match("\n"))
      end
    end
  end)
end)