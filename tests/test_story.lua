local helper = require("tests.test_helper")
local Story = require("engine.core.story")
local Passage = require("engine.core.passage")
local Choice = require("engine.core.choice")
local Engine = require("engine.core.engine")
local GameState = require("engine.core.game_state")

describe("Story Integration", function()

  local function create_test_story()
    local story = Story.new()
    story:set_metadata("name", "Test Story")
    story:set_metadata("author", "whisker Engine")
    story:set_metadata("ifid", "TEST-001")

    local start = Passage.new("start", "start")
    start:set_content("You wake up in a mysterious room. What do you do?")

    local look = Passage.new("look_around", "look_around")
    look:set_content("The room is dimly lit. You see a door and a window.")

    local door = Passage.new("try_door", "try_door")
    door:set_content("The door is locked. Game Over.")

    local choice1 = Choice.new("Look around", "look_around")
    start:add_choice(choice1)

    local choice2 = Choice.new("Try the door", "try_door")
    start:add_choice(choice2)

    local choice3 = Choice.new("Examine the window", "try_door")
    look:add_choice(choice3)

    story:add_passage(start)
    story:add_passage(look)
    story:add_passage(door)
    story:set_start_passage("start")

    return story
  end

  describe("Story Creation", function()
    it("should create a story with metadata", function()
      local story = Story.new()
      story:set_metadata("name", "Test Story")
      story:set_metadata("author", "Test Author")

      assert.equals("Test Story", story:get_metadata("name"))
      assert.equals("Test Author", story:get_metadata("author"))
    end)

    it("should add passages to story", function()
      local story = Story.new()
      local passage = Passage.new("test", "test")
      story:add_passage(passage)

      assert.is_not_nil(story:get_passage("test"))
    end)

    it("should set start passage", function()
      local story = create_test_story()
      assert.equals("start", story:get_start_passage())
    end)
  end)

  describe("Passage Creation", function()
    it("should create passage with content", function()
      local passage = Passage.new("test", "test")
      passage:set_content("Test content")

      assert.equals("Test content", passage:get_content())
    end)

    it("should add choices to passage", function()
      local passage = Passage.new("test", "test")
      local choice = Choice.new("Test choice", "target")
      passage:add_choice(choice)

      local choices = passage:get_choices()
      assert.equals(1, #choices)
    end)
  end)

  describe("Choice Creation", function()
    it("should create choice with text and target", function()
      local choice = Choice.new("Test text", "target_passage")

      assert.equals("Test text", choice:get_text())
      assert.equals("target_passage", choice:get_target())
    end)
  end)

  describe("Engine Integration", function()
    it("should create engine with story and game state", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      assert.is_not_nil(engine)
    end)

    it("should start story and return initial content", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      local content = engine:start_story()

      assert.is_not_nil(content)
      assert.is_not_nil(content.passage)
      assert.is_not_nil(content.passage.content)
    end)

    it("should display initial passage content", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      local content = engine:start_story()

      assert.is_not_nil(content.passage.content:match("mysterious room"))
    end)

    it("should provide choices from initial passage", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      local content = engine:start_story()

      assert.is_not_nil(content.choices)
      assert.is_true(#content.choices > 0)
    end)

    it("should have correct number of choices", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      local content = engine:start_story()

      assert.equals(2, #content.choices)
    end)

    it("should have properly formatted choice text", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      local content = engine:start_story()

      assert.equals("Look around", content.choices[1]:get_text())
      assert.equals("Try the door", content.choices[2]:get_text())
    end)
  end)

  describe("Full Story Flow", function()
    it("should allow navigation through story", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)

      local content = engine:start_story()
      assert.is_not_nil(content)

      -- Verify we can access the story structure
      assert.is_not_nil(story:get_passage("start"))
      assert.is_not_nil(story:get_passage("look_around"))
      assert.is_not_nil(story:get_passage("try_door"))
    end)
  end)
end)
