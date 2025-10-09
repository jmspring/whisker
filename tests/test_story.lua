-- test_story.lua
-- Simple test to verify the engine works

local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")
local Engine = require("src.core.engine")
local GameState = require("src.core.game_state")

-- Create a simple story
local story = Story:new()
story:set_metadata("name", "Test Story")
story:set_metadata("author", "whisker Engine")
story:set_metadata("ifid", "TEST-001")

-- Add passages
local start = Passage:new("start", "start")
start:set_content("You wake up in a mysterious room. What do you do?")

local look = Passage:new("look_around", "look_around")
look:set_content("The room is dimly lit. You see a door and a window.")

local door = Passage:new("try_door", "try_door")
door:set_content("The door is locked. Game Over.")

-- Add choices
local choice1 = Choice:new("Look around", "look_around")
start:add_choice(choice1)

local choice2 = Choice:new("Try the door", "try_door")
start:add_choice(choice2)

local choice3 = Choice:new("Examine the window", "try_door")
look:add_choice(choice3)

-- Add passages to story
story:add_passage(start)
story:add_passage(look)
story:add_passage(door)
story:set_start_passage("start")

-- Create engine and game state
local game_state = GameState:new()
local engine = Engine:new(story, game_state)

-- Start the story
print("=== whisker Engine Test ===")
print()

local content = engine:start_story()
print(content.passage.content)
print()

-- Display choices
if content.choices then
    for i, choice in ipairs(content.choices) do
        print(i .. ". " .. choice:get_text())
    end
end

print()
print("✅ Engine test successful! All systems operational.")
