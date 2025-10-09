-- test_profiler.lua
local Profiler = require("src.tools.profiler")
local Engine = require("src.core.engine")
local GameState = require("src.core.game_state")
local Story = require("src.core.story")
local Passage = require("src.core.passage")

-- Create simple story
local story = Story:new({title = "Profiler Test"})
local p1 = Passage:new({id = "start", content = "Test passage"})
story:add_passage(p1)
story:set_start_passage("start")

-- Create engine
local game_state = GameState:new()
local engine = Engine:new(story, game_state)

-- Start profiling
local profiler = Profiler:new(engine, game_state)
profiler:start(Profiler.ProfileMode.FULL)

-- Run story
engine:start_story()

-- Stop and report
profiler:stop()
print(profiler:generate_report("text"))
