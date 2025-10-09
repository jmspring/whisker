-- test_debugger.lua
local Debugger = require("src.tools.debugger")
local Engine = require("src.core.engine")
local GameState = require("src.core.game_state")
local Story = require("src.core.story")
local Passage = require("src.core.passage")

-- Create simple story
local story = Story:new({title = "Debug Test"})
local p1 = Passage:new({id = "start", content = "Start"})
local p2 = Passage:new({id = "next", content = "Next"})
story:add_passage(p1)
story:add_passage(p2)
story:set_start_passage("start")

-- Create engine
local game_state = GameState:new()
local engine = Engine:new(story, game_state)

-- Setup debugger
local debugger = Debugger:new(engine, game_state)
debugger:enable(Debugger.DebugMode.BREAKPOINT)

-- Add breakpoint
debugger:add_breakpoint(Debugger.BreakpointType.PASSAGE, "start")

-- Test
print("=== Debugger Test ===")
engine:start_story()

-- Check stats
local stats = debugger:get_stats()
print("Passages visited:", stats.passages_visited)
print("Breakpoints hit:", stats.breakpoints_hit)
print("✅ Debugger operational!")
