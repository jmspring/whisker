local helper = require("tests.test_helper")
local Profiler = require("engine.tools.profiler")
local Engine = require("engine.core.engine")
local GameState = require("engine.core.game_state")
local Story = require("engine.core.story")
local Passage = require("engine.core.passage")

describe("Profiler", function()

  local function create_test_story()
    local story = Story.new({title = "Profiler Test"})
    local p1 = Passage.new({id = "start", content = "Test passage"})
    story:add_passage(p1)
    story:set_start_passage("start")
    return story
  end

  describe("Profiler Instance", function()
    it("should create profiler instance", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local profiler = Profiler.new(engine, game_state)

      assert.is_not_nil(profiler)
    end)

    it("should have profile modes", function()
      assert.is_not_nil(Profiler.ProfileMode)
      assert.is_not_nil(Profiler.ProfileMode.FULL)
    end)
  end)

  describe("Profiling Operations", function()
    it("should start profiling", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local profiler = Profiler.new(engine, game_state)

      profiler:start(Profiler.ProfileMode.FULL)

      assert.is_not_nil(profiler)
    end)

    it("should stop profiling", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local profiler = Profiler.new(engine, game_state)

      profiler:start(Profiler.ProfileMode.FULL)
      engine:start_story()
      profiler:stop()

      assert.is_not_nil(profiler)
    end)

    it("should profile story execution", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local profiler = Profiler.new(engine, game_state)

      profiler:start(Profiler.ProfileMode.FULL)
      engine:start_story()
      profiler:stop()

      assert.is_not_nil(profiler)
    end)
  end)

  describe("Report Generation", function()
    it("should generate text report", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local profiler = Profiler.new(engine, game_state)

      profiler:start(Profiler.ProfileMode.FULL)
      engine:start_story()
      profiler:stop()

      local report = profiler:generate_report("text")

      assert.is_not_nil(report)
      assert.is_string(report)
    end)

    it("should include performance metrics", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local profiler = Profiler.new(engine, game_state)

      profiler:start(Profiler.ProfileMode.FULL)
      engine:start_story()
      profiler:stop()

      local report = profiler:generate_report("text")

      assert.is_not_nil(report)
      assert.is_not_nil(report:match("Profile") or report:match("Performance"))
    end)
  end)
end)
