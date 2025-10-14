-- test_validator.lua
local Validator = require("src.tools.validator")
local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

-- Create a story with some issues
local story = Story.new({title = "Test"})

local p1 = Passage.new({
    id = "start",
    content = "Start passage with {{undefined_var}}"
})
p1:add_choice(Choice.new({
    text = "Go somewhere",
    target = "missing_passage"  -- Dead link!
}))

local p2 = Passage.new({
    id = "orphan",
    content = "This passage is unreachable"
})

story:add_passage(p1)
story:add_passage(p2)
story:set_start_passage("start")

-- Run validator
local validator = Validator.new()
print(validator:generate_report("text"))
