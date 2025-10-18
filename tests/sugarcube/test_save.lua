local helper = require("tests.test_helper")
local parser = require("src.format.parsers.sugarcube")

describe("SugarCube Save System", function()
  local story_content
  local parsed

  setup(function()
    story_content = helper.load_fixture("sugarcube/save_test.twee")
    parsed = parser.parse(story_content)
  end)

  it("should parse textbox macro", function()
    local save_passage = helper.find_passage_with_pattern(parsed, "<>", save_passage.content)
  end)

  it("should parse array indexing", function()
    local save_passage = helper.find_passage_with_pattern(parsed, "%[_i%]")
    assert.is_not_nil(save_passage)
  end)

  it("should parse property chaining", function()
    local save_passage = helper.find_passage_with_pattern(parsed, "_slot%.id")
    assert.is_not_nil(save_passage)
  end)

  it("should parse closing button tag", function()
    local save_passage = helper.find_passage_with_pattern(parsed, "<>")
    assert.is_not_nil(save_passage)
  end)
end)