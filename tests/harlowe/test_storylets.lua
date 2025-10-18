local helper = require("tests.test_helper")
local parser = require("src.format.parsers.harlowe")

describe("Harlowe Storylets System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("harlowe/storylets_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse storylet macro", function()
    local passage = helper.find_passage_with_pattern(parsed, "%(storylet:")
    assert.is_not_nil(passage)
  end)

  it("should parse storylet with when condition", function()
    local passages_with_storylets = helper.find_passages_with_pattern(parsed, "%(storylet: when")
    assert.is_true(#passages_with_storylets >= 2)
  end)

  it("should parse relationship variable conditions", function()
    local passage = helper.find_passage_with_pattern(parsed, "%$relationship [<>=]+")
    assert.is_not_nil(passage)
    assert.matches("%$relationship [<>=]+", passage.content)
  end)

  it("should parse link-storylet macro", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("%(link%-storylet:", start.content)
  end)

  it("should parse increment operations", function()
    local passages = helper.find_passages_with_pattern(parsed, "it %+ %d+")
    assert.is_true(#passages > 0)
  end)

  it("should parse decrement operations", function()
    local passages = helper.find_passages_with_pattern(parsed, "it %- %d+")
    assert.is_true(#passages > 0)
  end)

  it("should parse day variable", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%$day", start.content)
  end)

  it("should identify multiple storylet passages", function()
    local count = 0
    for _, passage in ipairs(parsed.passages) do
      if passage.content:match("%(storylet:") then
        count = count + 1
      end
    end
    assert.is_true(count >= 2)
  end)
end)