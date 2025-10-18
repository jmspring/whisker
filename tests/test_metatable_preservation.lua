local helper = require("tests.test_helper")
local Story = require("whisker.core.story")
local Passage = require("whisker.core.passage")
local Choice = require("whisker.core.choice")
local Engine = require("whisker.core.engine")
local SaveSystem = require("whisker.infrastructure.save_system")
local json = require("whisker.utils.json")

describe("Metatable Preservation", function()

  local function create_test_story()
    local story = Story.new({
      title = "Test Story",
      author = "Test Author"
    })

    local passage = Passage.new({
      id = "start",
      name = "Start",
      content = "Welcome to the test story!"
    })

    local choice = Choice.new({
      text = "Continue",
      target = "next"
    })

    passage:add_choice(choice)
    story:add_passage(passage)
    story:set_start_passage("start")

    return story, passage, choice
  end

  describe("Initial Metatable", function()
    it("should have methods on Story", function()
      local story = Story.new({title = "Test"})
      assert.equals("function", type(story.get_metadata))
    end)

    it("should have methods on Passage", function()
      local passage = Passage.new({id = "test", content = "Test"})
      assert.equals("function", type(passage.get_content))
    end)

    it("should have methods on Choice", function()
      local choice = Choice.new({text = "Test", target = "test"})
      assert.equals("function", type(choice.get_text))
    end)

    it("should preserve methods before serialization", function()
      local story, passage, choice = create_test_story()

      assert.equals("Test Story", story:get_metadata("name"))
      assert.equals("Welcome to the test story!", passage:get_content())
      assert.equals("Continue", choice:get_text())
    end)
  end)

  describe("Story.restore_metatable", function()
    it("should restore Story metatable after serialization", function()
      local story = create_test_story()
      local serialized = story:serialize()

      assert.is_nil(getmetatable(serialized))

      local restored = Story.restore_metatable(serialized)

      assert.equals("function", type(restored.get_metadata))
      assert.equals("Test Story", restored:get_metadata("name"))
    end)

    it("should restore nested Passage metatable", function()
      local story = create_test_story()
      local serialized = story:serialize()
      local restored = Story.restore_metatable(serialized)

      local passage = restored:get_passage("start")
      assert.is_not_nil(passage)
      assert.equals("function", type(passage.get_content))
      assert.equals("Welcome to the test story!", passage:get_content())
    end)

    it("should restore nested Choice metatable", function()
      local story = create_test_story()
      local serialized = story:serialize()
      local restored = Story.restore_metatable(serialized)

      local passage = restored:get_passage("start")
      local choices = passage:get_choices()
      assert.is_true(#choices > 0)
      assert.equals("function", type(choices[1].get_text))
      assert.equals("Continue", choices[1]:get_text())
    end)
  end)

  describe("Story.from_table", function()
    it("should create Story with metatable from table", function()
      local story = create_test_story()
      local serialized = story:serialize()
      local restored = Story.from_table(serialized)

      assert.equals("function", type(restored.get_metadata))
      assert.equals("Test Story", restored:get_metadata("name"))
    end)

    it("should restore nested objects from table", function()
      local story = create_test_story()
      local serialized = story:serialize()
      local restored = Story.from_table(serialized)

      local passage = restored:get_passage("start")
      assert.is_not_nil(passage)
      assert.equals("function", type(passage.get_content))

      local choices = passage:get_choices()
      assert.is_true(#choices > 0)
      assert.equals("function", type(choices[1].get_text))
    end)
  end)

  describe("JSON Round-Trip", function()
    it("should preserve metatables through JSON serialization", function()
      local story = create_test_story()
      local serialized = story:serialize()
      local json_string = json.encode(serialized)
      local from_json = json.decode(json_string)

      assert.is_nil(getmetatable(from_json))

      local restored = Story.from_table(from_json)

      assert.equals("function", type(restored.get_metadata))
      assert.equals("Test Story", restored:get_metadata("name"))

      local passage = restored:get_passage("start")
      assert.equals("function", type(passage.get_content))
    end)
  end)

  describe("Engine Integration", function()
    it("should auto-restore metatables when loading story", function()
      local story = create_test_story()
      local serialized = story:serialize()
      local json_string = json.encode(serialized)
      local from_json = json.decode(json_string)

      local engine = Engine.new()
      engine:load_story(from_json)

      assert.is_not_nil(engine.current_story)
      assert.equals("function", type(engine.current_story.get_start_passage))
    end)
  end)

  describe("Individual Object Restoration", function()
    it("should restore Passage metatable", function()
      local plain_passage = {
        id = "test",
        name = "Test Passage",
        content = "Test content",
        choices = {}
      }

      local restored = Passage.restore_metatable(plain_passage)
      assert.equals("function", type(restored.get_content))
      assert.equals("Test content", restored:get_content())
    end)

    it("should create Passage from table", function()
      local plain_passage = {
        id = "test",
        name = "Test Passage",
        content = "Test content",
        choices = {}
      }

      local restored = Passage.from_table(plain_passage)
      assert.equals("function", type(restored.get_content))
      assert.equals("Test content", restored:get_content())
    end)

    it("should restore Choice metatable", function()
      local plain_choice = {
        text = "Test choice",
        target_passage = "target",
        condition = nil,
        action = nil
      }

      local restored = Choice.restore_metatable(plain_choice)
      assert.equals("function", type(restored.get_text))
      assert.equals("Test choice", restored:get_text())
    end)

    it("should create Choice from table", function()
      local plain_choice = {
        text = "Test choice",
        target_passage = "target",
        condition = nil,
        action = nil
      }

      local restored = Choice.from_table(plain_choice)
      assert.equals("function", type(restored.get_text))
      assert.equals("Test choice", restored:get_text())
    end)
  end)

  describe("Deep Nesting", function()
    it("should preserve metatables for deeply nested objects", function()
      local story = Story.new({title = "Complex Story"})

      for i = 1, 3 do
        local passage = Passage.new({
          id = "passage" .. i,
          name = "Passage " .. i,
          content = "Content " .. i
        })

        for j = 1, 2 do
          local choice = Choice.new({
            text = "Choice " .. j,
            target = "passage" .. ((i % 3) + 1)
          })
          passage:add_choice(choice)
        end

        story:add_passage(passage)
      end

      story:set_start_passage("passage1")

      local serialized = story:serialize()
      local restored = Story.from_table(serialized)

      for i = 1, 3 do
        local p = restored:get_passage("passage" .. i)
        assert.is_not_nil(p)
        assert.equals("function", type(p.get_content))

        local choices = p:get_choices()
        assert.equals(2, #choices)

        for j = 1, 2 do
          assert.equals("function", type(choices[j].get_text))
        end
      end
    end)
  end)

  describe("Idempotency", function()
    it("should handle restoring metatable on object that already has it", function()
      local story = Story.new({title = "Test"})
      local restored = Story.restore_metatable(story)

      assert.equals(story, restored)
    end)
  end)
end)
