local helper = require("tests.test_helper")
local whisker_loader = require("whisker.format.whisker_loader")
local CompactConverter = require("whisker.format.compact_converter")
local json = require("whisker.utils.json")

describe("Compact Format Integration", function()

  describe("File Loading", function()
    it("should load compact format file", function()
      local story, err = whisker_loader.load_from_file("stories/examples/simple_story_compact.whisker")

      assert.is_not_nil(story)
      assert.equals("The Cave", story.metadata.name)
      assert.equals("whisker Tutorial", story.metadata.author)
    end)

    it("should load correct number of passages", function()
      local story, err = whisker_loader.load_from_file("stories/examples/simple_story_compact.whisker")

      assert.is_not_nil(story)

      local passage_count = 0
      for _ in pairs(story.passages) do
        passage_count = passage_count + 1
      end

      assert.equals(5, passage_count)
    end)

    it("should preserve passage choices", function()
      local story, err = whisker_loader.load_from_file("stories/examples/simple_story_compact.whisker")

      assert.is_not_nil(story)

      local start = story.passages["start"]
      assert.is_not_nil(start)
      assert.equals(2, #start.choices)
      assert.equals("Enter the cave", start.choices[1].text)
      assert.equals("inside_cave", start.choices[1].target_passage)
    end)

    it("should set start passage correctly", function()
      local story, err = whisker_loader.load_from_file("stories/examples/simple_story_compact.whisker")

      assert.is_not_nil(story)
      assert.equals("start", story.start_passage)
    end)

    it("should preserve passage content", function()
      local story, err = whisker_loader.load_from_file("stories/examples/simple_story_compact.whisker")

      assert.is_not_nil(story)

      local start = story.passages["start"]
      assert.is_not_nil(start)
      assert.is_not_nil(start.content:find("dark cave"))
    end)
  end)

  describe("String Loading", function()
    it("should load compact format from JSON string", function()
      local compact_json = [[
{
  "format": "whisker",
  "formatVersion": "2.0",
  "metadata": {
    "title": "Test Story",
    "ifid": "TEST-001"
  },
  "passages": [
    {
      "id": "start",
      "name": "Start",
      "pid": "p1",
      "text": "Beginning",
      "choices": [
        {
          "text": "Next",
          "target": "next"
        }
      ]
    },
    {
      "id": "next",
      "name": "Next",
      "pid": "p2",
      "text": "The end."
    }
  ],
  "settings": {
    "startPassage": "start"
  }
}
]]

      local story, err = whisker_loader.load_from_string(compact_json)

      assert.is_not_nil(story)
      assert.equals("Test Story", story.metadata.name)

      local passage_count = 0
      for _ in pairs(story.passages) do
        passage_count = passage_count + 1
      end
      assert.equals(2, passage_count)
    end)
  end)

  describe("Non-Default Values", function()
    it("should preserve custom position and size", function()
      local compact_json = [[
{
  "format": "whisker",
  "formatVersion": "2.0",
  "metadata": {
    "title": "Custom Story",
    "ifid": "CUSTOM-001"
  },
  "passages": [
    {
      "id": "start",
      "name": "Start",
      "pid": "p1",
      "text": "Start",
      "position": {"x": 100, "y": 200},
      "size": {"width": 150, "height": 200},
      "tags": ["important", "start"]
    }
  ],
  "settings": {
    "startPassage": "start"
  }
}
]]

      local story, err = whisker_loader.load_from_string(compact_json)

      assert.is_not_nil(story)

      local start = story.passages["start"]
      assert.is_not_nil(start)
      assert.equals(100, start.position.x)
      assert.equals(200, start.position.y)
      assert.equals(150, start.size.width)
      assert.equals(200, start.size.height)
      assert.equals(2, #start.tags)
    end)
  end)

  describe("Conditional Choices", function()
    it("should preserve choice conditions", function()
      local compact_json = [[
{
  "format": "whisker",
  "formatVersion": "2.0",
  "metadata": {
    "title": "Conditional Story",
    "ifid": "COND-001"
  },
  "passages": [
    {
      "id": "start",
      "name": "Start",
      "pid": "p1",
      "text": "Start",
      "choices": [
        {
          "text": "Regular choice",
          "target": "next"
        },
        {
          "text": "Conditional choice",
          "target": "special",
          "condition": "has_key == true"
        }
      ]
    },
    {
      "id": "next",
      "name": "Next",
      "pid": "p2",
      "text": "Next passage"
    },
    {
      "id": "special",
      "name": "Special",
      "pid": "p3",
      "text": "Special passage"
    }
  ],
  "settings": {
    "startPassage": "start"
  }
}
]]

      local story, err = whisker_loader.load_from_string(compact_json)

      assert.is_not_nil(story)

      local start = story.passages["start"]
      assert.equals(2, #start.choices)
      assert.equals("has_key == true", start.choices[2].condition)
    end)
  end)

  describe("Backwards Compatibility", function()
    it("should work with verbose loader expectations", function()
      local story, err = whisker_loader.load_from_file("stories/examples/simple_story_compact.whisker")

      assert.is_not_nil(story)

      for id, passage in pairs(story.passages) do
        assert.is_not_nil(passage.content)
        assert.is_true(#passage.content > 0)
      end
    end)
  end)

  describe("Format Detection", function()
    it("should detect verbose vs compact formats", function()
      local converter = CompactConverter.new()

      local verbose_doc = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {title = "Test"},
        passages = {}
      }

      local compact_doc = {
        format = "whisker",
        formatVersion = "2.0",
        metadata = {title = "Test"},
        passages = {}
      }

      assert.is_true(converter:is_verbose(verbose_doc))
      assert.is_true(converter:is_compact(compact_doc))
    end)
  end)
end)
