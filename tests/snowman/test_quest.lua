local helper = require("tests.test_helper")
local parser = require("src.format.parsers.snowman")

describe("Snowman Quest System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("snowman/quest_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse nested object structure", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.is_not_nil(init)
    assert.matches("s%.quests = {", init.content)
  end)

  it("should parse object with multiple properties", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("id:", init.content)
    assert.matches("title:", init.content)
    assert.matches("progress:", init.content)
    assert.matches("maxProgress:", init.content)
    assert.matches("completed:", init.content)
  end)

  it("should parse logical OR", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("||", init.content)
  end)

  it("should parse Math.min", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("Math%.min%(", init.content)
  end)

  it("should parse comparison with equals", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches(">=", init.content)
  end)

  it("should parse ternary operator", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%?", init.content)
    -- Check for ternary pattern (condition ? true : false)
    assert.matches("%? .+ :", init.content)
  end)

  it("should parse string concatenation", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("'' %+", init.content)
  end)

  it("should parse jQuery html() method", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("%.html%(", init.content)
  end)

  it("should parse script tag", function()
    local log = helper.find_passage(parsed, "QuestLog")
    assert.is_not_nil(log)
    assert.matches("", log.content)
    assert.matches("", log.content)
  end)

  it("should parse function call without arguments", function()
    local log = helper.find_passage(parsed, "QuestLog")
    assert.matches("%w+%(%)", log.content)
  end)

  it("should parse Underscore.each with callback", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("_%.each%(s%.quests, function", init.content)
  end)

  it("should parse closing brace and semicolon", function()
    local init = helper.find_passage(parsed, "StoryInit")
    assert.matches("};", init.content)
  end)
end)