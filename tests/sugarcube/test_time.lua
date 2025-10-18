local helper = require("tests.test_helper")
local parser = require("src.format.parsers.sugarcube")

describe("SugarCube Time System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("sugarcube/time_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse StoryCaption passage", function()
    local caption = helper.find_passage(parsed, "StoryCaption")
    assert.is_not_nil(caption)
  end)

  it("should parse HTML in StoryCaption", function()
    local caption = helper.find_passage(parsed, "StoryCaption")
    assert.matches("", caption.content)
  end)

  it("should parse elseif macro", function()
    local start = helper.find_passage(parsed, "Start")
    assert.is_not_nil(start)
    assert.matches("<>", start.content)
  end)

  it("should parse closing if tag", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("<>", start.content)
  end)

  it("should parse link with passage parameter", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches('<>', start.content)
  end)

  it("should parse modulo operator", function()
    local work = helper.find_passage(parsed, "Work")
    assert.is_not_nil(work)
    assert.matches("%%", work.content)
  end)

  it("should parse Math.max", function()
    local work = helper.find_passage(parsed, "Work")
    assert.matches("Math%.max", work.content)
  end)

  it("should parse Math.min", function()
    local passages = helper.find_passages_with_pattern(parsed, "Math%.min")
    assert.is_true(#passages > 0)
  end)

  it("should parse compound increment", function()
    local work = helper.find_passage(parsed, "Work")
    assert.matches("%+=", work.content)
  end)

  it("should parse comparison in conditionals", function()
    local start = helper.find_passage(parsed, "Start")
    assert.matches("%$time < %d+", start.content)
  end)
end)