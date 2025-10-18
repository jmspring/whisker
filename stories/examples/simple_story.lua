-- examples/simple_story.lua
-- A minimal working example of a whisker story
-- Demonstrates basic story structure with passages and choices

local Story = require("engine.core.story")
local Passage = require("engine.core.passage")
local Choice = require("engine.core.choice")

-- Create the story
local story = Story.new({
    title = "The Cave",
    author = "whisker Tutorial",
    ifid = "SIMPLE-001",
    version = "1.0"
})

-- Passage 1: Start
local start = Passage.new({
    id = "start",
    content = [[
You stand at the entrance of a dark cave. A cool breeze flows from within,
carrying the scent of moss and ancient stone.

Do you enter the cave?
    ]]
})

start:add_choice(Choice.new({
    text = "Enter the cave",
    target = "inside_cave"
}))

start:add_choice(Choice.new({
    text = "Walk away",
    target = "walk_away"
}))

-- Passage 2: Inside Cave
local inside = Passage.new({
    id = "inside_cave",
    content = [[
You step into the darkness. As your eyes adjust, you see two passages:
one leads left, the other right.

The left passage glows with a faint blue light.
The right passage echoes with the sound of dripping water.
    ]]
})

inside:add_choice(Choice.new({
    text = "Take the left passage",
    target = "left_passage"
}))

inside:add_choice(Choice.new({
    text = "Take the right passage",
    target = "right_passage"
}))

inside:add_choice(Choice.new({
    text = "Go back outside",
    target = "start"
}))

-- Passage 3: Left Passage (Good ending)
local left = Passage.new({
    id = "left_passage",
    content = [[
You follow the blue glow deeper into the cave. The light grows brighter
until you emerge into a vast chamber filled with glowing crystals.

In the center of the chamber, you find an ancient treasure chest!

**You've discovered the Crystal Cavern!**

*THE END*
    ]]
})

-- Passage 4: Right Passage (Bad ending)
local right = Passage.new({
    id = "right_passage",
    content = [[
You follow the sound of water into a narrow tunnel. The ground becomes
slippery and suddenly gives way beneath you!

You fall into an underground river and are swept away into the darkness.

**Game Over**

*THE END*
    ]]
})

-- Passage 5: Walk Away
local away = Passage.new({
    id = "walk_away",
    content = [[
You decide the cave is too dangerous and walk away. Perhaps it's
better to live to explore another day.

**You've chosen safety over adventure.**

*THE END*
    ]]
})

-- Add all passages to the story
story:add_passage(start)
story:add_passage(inside)
story:add_passage(left)
story:add_passage(right)
story:add_passage(away)

-- Set the starting passage
story:set_start_passage("start")

-- Return the story
return story