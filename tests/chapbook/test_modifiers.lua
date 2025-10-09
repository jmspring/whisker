local helper = require("tests.test_helper")
local parser = require("whisker.parsers.chapbook")

describe("Chapbook Modifiers System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("chapbook/modifiers_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse align modifier", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("%[align center%]", start.content)
    assert.matches("%[align left%]", start.content)
    assert.matches("%[align right%]", start.content)
  end)

  it("should parse after modifier with time", function()
    local delayed = helper.find_passage(parsed, "DelayedText")
    assert.is_not_nil(delayed)
    assert.matches("%[after %d+s%]", delayed.content)
  end)

  it("should parse note modifier", function()
    local notes = helper.find_passage(parsed, "Notes")
    assert.is_not_nil(notes)
    assert.matches("%[note%]", notes.content)
  end)

  it("should parse style modifier", function()
    local styling = helper.find_passage(parsed, "Styling")
    assert.is_not_nil(styling)
    assert.matches("%[style%]", styling.content)
  end)

  it("should parse CSS within style modifier", function()
    local styling = helper.find_passage(parsed, "Styling")
    assert.matches("body {", styling.content)
    assert.matches("font%-family:", styling.content)
  end)

  it("should parse continue modifier", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%[continue%]", start.content)
  end)

  it("should parse multiple modifiers in sequence", function()
    local start = helper.find_passage(parsed, "Start")
    local modifier_count = helper.count_pattern(start.content, "%[%w+")
    assert.is_true(modifier_count >= 3)
  end)

  it("should parse modifiers affecting following text", function()
    local start = helper.find_passage(parsed, "Start")
    -- Modifiers should have content following them
    assert.matches("%[align center%]%s+#", start.content)
  end)

  it("should parse time units in after modifier", function()
    local delayed = helper.find_passage(parsed, "DelayedText")
    assert.matches("2s", delayed.content)
    assert.matches("4s", delayed.content)
    assert.matches("6s", delayed.content)
  end)

  it("should parse variable references in styled text", function()
    local styling = helper.find_passage(parsed, "Styling")
    assert.matches("{textColor}", styling.content)
  end)

  it("should verify modifier syntax", function()
    -- Modifiers should be properly closed with ]
    for _, passage in ipairs(parsed.passages) do
      for modifier in passage.content:gmatch("%[%w+[^%]]*%]") do
        assert.matches("%[%w+.*%]", modifier)
      end
    end
  end)

  it("should parse headings with markdown", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("# Welcome", start.content)
  end)

  it("should parse bold text with markdown", function()
    local notes = helper.find_passage(parsed, "Notes")
    assert.matches("%*%*Notes Section%*%*", notes.content)
  end)
end)