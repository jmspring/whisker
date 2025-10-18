local helper = require("tests.test_helper")
local SaveSystem = require("whisker.infrastructure.save_system")
local GameState = require("whisker.core.game_state")
local Story = require("whisker.core.story")
local Passage = require("whisker.core.passage")

describe("Save System", function()

  describe("Module Loading", function()
    it("should load SaveSystem module", function()
      assert.is_not_nil(SaveSystem)
    end)

    it("should create save system instance", function()
      local save_system = SaveSystem.new({
        save_directory = "tests/saves"
      })
      assert.is_not_nil(save_system)
    end)
  end)

  describe("GameState Creation", function()
    it("should create GameState instance", function()
      local game_state = GameState.new()
      assert.is_not_nil(game_state)
    end)

    it("should set variables on GameState", function()
      local game_state = GameState.new()
      game_state:set_variable("test", "value")
      assert.equals("value", game_state:get_variable("test"))
    end)
  end)

  describe("Story Creation", function()
    it("should create test story", function()
      local story = Story.new({
        title = "Save Test Story",
        author = "Test Suite",
        ifid = "TEST-SAVE-001"
      })

      assert.is_not_nil(story)
      assert.equals("Save Test Story", story:get_metadata("name"))
    end)

    it("should add passages to story", function()
      local story = Story.new({title = "Test"})
      local passage = Passage.new({id = "start", content = "Start"})
      story:add_passage(passage)

      assert.is_not_nil(story:get_passage("start"))
    end)
  end)
end)
