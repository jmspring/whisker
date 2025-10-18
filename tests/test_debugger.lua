local helper = require("tests.test_helper")
local Debugger = require("src.tools.debugger")
local Engine = require("src.core.engine")
local GameState = require("src.core.game_state")
local Story = require("src.core.story")
local Passage = require("src.core.passage")

describe("Debugger", function()

  local function create_test_story()
    local story = Story.new({title = "Debug Test"})
    local p1 = Passage.new({id = "start", content = "Start"})
    local p2 = Passage.new({id = "next", content = "Next"})
    story:add_passage(p1)
    story:add_passage(p2)
    story:set_start_passage("start")
    return story
  end

  describe("Debugger Instance", function()
    it("should create debugger instance", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local debugger = Debugger.new(engine, game_state)

      assert.is_not_nil(debugger)
    end)

    it("should have debug modes", function()
      assert.is_not_nil(Debugger.DebugMode)
      assert.is_not_nil(Debugger.DebugMode.BREAKPOINT)
    end)

    it("should have breakpoint types", function()
      assert.is_not_nil(Debugger.BreakpointType)
      assert.is_not_nil(Debugger.BreakpointType.PASSAGE)
    end)
  end)

  describe("Debug Operations", function()
    it("should enable debugger", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local debugger = Debugger.new(engine, game_state)

      debugger:enable(Debugger.DebugMode.BREAKPOINT)

      assert.is_not_nil(debugger)
    end)

    it("should add breakpoint", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local debugger = Debugger.new(engine, game_state)

      debugger:enable(Debugger.DebugMode.BREAKPOINT)
      debugger:add_breakpoint(Debugger.BreakpointType.PASSAGE, "start")

      assert.is_not_nil(debugger)
    end)

    it("should track execution with breakpoints", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local debugger = Debugger.new(engine, game_state)

      debugger:enable(Debugger.DebugMode.BREAKPOINT)
      debugger:add_breakpoint(Debugger.BreakpointType.PASSAGE, "start")

      engine:start_story()

      local stats = debugger:get_stats()
      assert.is_not_nil(stats)
      assert.is_table(stats)
    end)
  end)

  describe("Debugger Statistics", function()
    it("should provide debug stats", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local debugger = Debugger.new(engine, game_state)

      debugger:enable(Debugger.DebugMode.BREAKPOINT)
      engine:start_story()

      local stats = debugger:get_stats()

      assert.is_not_nil(stats)
      assert.is_table(stats)
      assert.is_not_nil(stats.passages_visited)
    end)

    it("should track breakpoint hits", function()
      local story = create_test_story()
      local game_state = GameState.new()
      local engine = Engine.new(story, game_state)
      local debugger = Debugger.new(engine, game_state)

      debugger:enable(Debugger.DebugMode.BREAKPOINT)
      debugger:add_breakpoint(Debugger.BreakpointType.PASSAGE, "start")
      engine:start_story()

      local stats = debugger:get_stats()

      assert.is_not_nil(stats.breakpoints_hit)
    end)
  end)
end)
