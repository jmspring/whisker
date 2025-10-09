local helper = require("tests.test_helper")
local parser = require("whisker.parsers.harlowe")

describe("Harlowe Data Structures", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("harlowe/datastructures_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse datamap initialization", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("%(dm:", start.content)
  end)

  it("should parse nested datamaps", function()
    local start = helper.find_passage(parsed, "Start")
    local dm_count = helper.count_pattern(start.content, "%(dm:")
    assert.is_true(dm_count >= 2)
  end)

  it("should parse datamap with string keys", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('"name"', start.content)
    assert.matches('"class"', start.content)
    assert.matches('"stats"', start.content)
  end)

  it("should parse datamap with numeric values", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('"level", %d+', start.content)
  end)

  it("should parse datamap property access", function()
    local passage = helper.find_passage_with_pattern(parsed, "%$player's class")
    assert.is_not_nil(passage)
  end)

  it("should parse nested property access", function()
    local passage = helper.find_passage_with_pattern(parsed, "%$player's stats's")
    assert.is_not_nil(passage)
  end)

  it("should parse input-box macro", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%(input%-box:", start.content)
  end)

  it("should parse bind keyword", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("bind %$player's name", start.content)
  end)

  it("should parse empty array initialization", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('"skills", %(a:%)', start.content)
  end)

  it("should parse property assignment", function()
    local passage = helper.find_passage_with_pattern(parsed, "%$player's class to")
    assert.is_not_nil(passage)
  end)

  it("should parse nested property modification", function()
    local passage = helper.find_passage_with_pattern(parsed, "%$player's stats's %w+ to it")
    assert.is_not_nil(passage)
  end)
end)