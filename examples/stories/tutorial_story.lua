-- examples/tutorial_story.lua
-- Interactive tutorial demonstrating whisker features
-- Learn by example with hands-on demonstrations

local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

local story = Story.new({
    title = "whisker Tutorial",
    author = "whisker Team",
    ifid = "TUTORIAL-001",
    version = "1.0",
    description = "Learn to create interactive fiction with whisker"
})

-- Tutorial variables
story.variables = {
    tutorial_progress = 0,
    learned_basics = false,
    learned_variables = false,
    learned_conditions = false,
    learned_scripting = false,
    player_score = 0
}

-- ============================================================================
-- INTRODUCTION
-- ============================================================================

local intro = Passage.new({
    id = "intro",
    content = [[
**Welcome to the whisker Tutorial!**

This interactive tutorial will teach you how to create interactive
fiction stories using the whisker engine.

You'll learn about:
• Basic story structure
• Variables and state management
• Conditional choices
• Lua scripting
• Multiple endings

Let's get started!
    ]]
})

intro:add_choice(Choice.new({
    text = "Begin the tutorial",
    target = "lesson1_intro"
}))

-- ============================================================================
-- LESSON 1: BASIC STRUCTURE
-- ============================================================================

local lesson1_intro = Passage.new({
    id = "lesson1_intro",
    content = [[
**Lesson 1: Basic Story Structure**

A whisker story is made up of three main components:

1. **Story** - The container for your entire narrative
2. **Passages** - Individual scenes or moments in your story
3. **Choices** - Links that connect passages together

Right now, you're reading a passage. The buttons you see below
are choices that will take you to different passages.

Let's practice navigating!
    ]]
})

lesson1_intro:add_choice(Choice.new({
    text = "Go to Passage A",
    target = "lesson1_a"
}))

lesson1_intro:add_choice(Choice.new({
    text = "Go to Passage B",
    target = "lesson1_b"
}))

local lesson1_a = Passage.new({
    id = "lesson1_a",
    content = [[
**Passage A**

You chose Passage A! This is a different passage from the one
you just read.

Notice how the content changed completely? That's how passages work.
Each passage can have its own unique text and choices.
    ]]
})

lesson1_a:add_choice(Choice.new({
    text = "Continue to Lesson 2",
    target = "lesson2_intro"
}))

lesson1_a:add_choice(Choice.new({
    text = "Go back and try Passage B",
    target = "lesson1_intro"
}))

local lesson1_b = Passage.new({
    id = "lesson1_b",
    content = [[
**Passage B**

You chose Passage B! This passage is different from Passage A.

In your own stories, you can create as many passages as you need
to tell your narrative. Stories can be linear (one path) or
branching (multiple paths).
    ]]
})

lesson1_b:add_choice(Choice.new({
    text = "Continue to Lesson 2",
    target = "lesson2_intro"
}))

lesson1_b:add_choice(Choice.new({
    text = "Go back and try Passage A",
    target = "lesson1_intro"
}))

-- ============================================================================
-- LESSON 2: VARIABLES
-- ============================================================================

local lesson2_intro = Passage.new({
    id = "lesson2_intro",
    content = [[
**Lesson 2: Variables**

Variables let you track information throughout your story.
They can store numbers, text, or true/false values.

You can display variables in your text using double curly braces:
{{variable_name}}

For example, your current score is: **{{player_score}}**

Let's practice with variables!
    ]],
    on_enter = [[
        game_state:set_variable("learned_basics", true)
        local progress = game_state:get_variable("tutorial_progress")
        game_state:set_variable("tutorial_progress", progress + 1)
    ]]
})

lesson2_intro:add_choice(Choice.new({
    text = "Increase my score by 10",
    target = "lesson2_add_score",
    action = [[
        local score = game_state:get_variable("player_score")
        game_state:set_variable("player_score", score + 10)
    ]]
}))

lesson2_intro:add_choice(Choice.new({
    text = "Skip to Lesson 3",
    target = "lesson3_intro"
}))

local lesson2_add_score = Passage.new({
    id = "lesson2_add_score",
    content = [[
**Score Updated!**

Great job! Your score is now: **{{player_score}}**

Variables are perfect for tracking:
• Player statistics (health, score, inventory)
• Story state (which events happened)
• NPC relationships
• Game progress

Notice how the score persists as you navigate between passages?
That's the power of variables!
    ]],
    on_enter = [[
        game_state:set_variable("learned_variables", true)
    ]]
})

lesson2_add_score:add_choice(Choice.new({
    text = "Add 10 more points",
    target = "lesson2_add_score",
    action = [[
        local score = game_state:get_variable("player_score")
        game_state:set_variable("player_score", score + 10)
    ]]
}))

lesson2_add_score:add_choice(Choice.new({
    text = "Continue to Lesson 3",
    target = "lesson3_intro"
}))

-- ============================================================================
-- LESSON 3: CONDITIONAL CHOICES
-- ============================================================================

local lesson3_intro = Passage.new({
    id = "lesson3_intro",
    content = [[
**Lesson 3: Conditional Choices**

Choices can have conditions that determine whether they appear
or are enabled. This creates dynamic stories that respond to
player actions.

Your current score is: **{{player_score}}**

Notice how some choices below only appear if you meet certain
requirements!
    ]]
})

lesson3_intro:add_choice(Choice.new({
    text = "This choice always appears",
    target = "lesson3_always"
}))

lesson3_intro:add_choice(Choice.new({
    text = "This choice requires 20+ score",
    target = "lesson3_high_score",
    condition = "player_score >= 20"
}))

lesson3_intro:add_choice(Choice.new({
    text = "This choice requires learning variables",
    target = "lesson3_learned",
    condition = "learned_variables"
}))

lesson3_intro:add_choice(Choice.new({
    text = "Go back and increase score",
    target = "lesson2_add_score"
}))

lesson3_intro:add_choice(Choice.new({
    text = "Continue to Lesson 4",
    target = "lesson4_intro"
}))

local lesson3_always = Passage.new({
    id = "lesson3_always",
    content = [[
**Always Available**

This passage is reachable because its choice has no conditions.

Unconditional choices are useful for:
• Main story paths
• "Go back" options
• Help or information

Conditional choices are useful for:
• Unlocking new areas after collecting items
• Skill-based options
• Story branches based on previous choices
    ]]
})

lesson3_always:add_choice(Choice.new({
    text = "Return to Lesson 3",
    target = "lesson3_intro"
}))

local lesson3_high_score = Passage.new({
    id = "lesson3_high_score",
    content = [[
**High Score Path**

Congratulations! You had enough points to access this passage.

This demonstrates how you can gate content behind requirements,
creating a sense of progression and reward in your stories.
    ]]
})

lesson3_high_score:add_choice(Choice.new({
    text = "Return to Lesson 3",
    target = "lesson3_intro"
}))

local lesson3_learned = Passage.new({
    id = "lesson3_learned",
    content = [[
**Knowledge Check**

You completed the variables lesson, so this option appeared!

This shows how you can track player progress and unlock new
content based on what they've learned or accomplished.
    ]],
    on_enter = [[
        game_state:set_variable("learned_conditions", true)
    ]]
})

lesson3_learned:add_choice(Choice.new({
    text = "Return to Lesson 3",
    target = "lesson3_intro"
}))

-- ============================================================================
-- LESSON 4: LUA SCRIPTING
-- ============================================================================

local lesson4_intro = Passage.new({
    id = "lesson4_intro",
    content = [[
**Lesson 4: Lua Scripting**

whisker lets you write Lua code to create complex game logic.
You can use scripting in two ways:

1. **on_enter** scripts - Run when entering a passage
2. **action** scripts - Run when selecting a choice

Scripts can:
• Perform calculations
• Modify multiple variables
• Generate random outcomes
• Create complex game mechanics

Let's try a simple dice roll!
    ]]
})

lesson4_intro:add_choice(Choice.new({
    text = "Roll the dice (1-6)",
    target = "lesson4_dice",
    action = [[
        math.randomseed(os.time())
        local roll = math.random(1, 6)
        game_state:set_variable("dice_roll", roll)
        game_state:set_variable("player_score",
            game_state:get_variable("player_score") + roll)
    ]]
}))

lesson4_intro:add_choice(Choice.new({
    text = "Continue to graduation",
    target = "graduation"
}))

local lesson4_dice = Passage.new({
    id = "lesson4_dice",
    content = [[
**Dice Roll Result**

You rolled a: **{{dice_roll}}**

Your new score is: **{{player_score}}**

This demonstrates how scripts can create randomness and variety
in your stories. You can use similar techniques for:
• Combat systems
• Random events
• Procedural content
• Success/failure checks
    ]],
    on_enter = [[
        game_state:set_variable("learned_scripting", true)
    ]]
})

lesson4_dice:add_choice(Choice.new({
    text = "Roll again",
    target = "lesson4_dice",
    action = [[
        math.randomseed(os.time())
        local roll = math.random(1, 6)
        game_state:set_variable("dice_roll", roll)
        game_state:set_variable("player_score",
            game_state:get_variable("player_score") + roll)
    ]]
}))

lesson4_dice:add_choice(Choice.new({
    text = "Continue to graduation",
    target = "graduation"
}))

-- ============================================================================
-- GRADUATION
-- ============================================================================

local graduation = Passage.new({
    id = "graduation",
    content = [[
**🎓 Tutorial Complete!**

Congratulations! You've completed the whisker tutorial.

**What you learned:**
• Basic story structure {{learned_basics and "✓" or "✗"}}
• Variables and state {{learned_variables and "✓" or "✗"}}
• Conditional choices {{learned_conditions and "✓" or "✗"}}
• Lua scripting {{learned_scripting and "✓" or "✗"}}

**Final Score:** {{player_score}}
**Progress:** {{tutorial_progress}}/4 lessons

You're now ready to create your own interactive fiction stories!

Check out the other examples:
• simple_story.lua - A minimal example
• adventure_game.lua - A full-featured game

*THE END*
    ]]
})

-- ============================================================================
-- BUILD THE STORY
-- ============================================================================

local passages = {
    intro,
    lesson1_intro, lesson1_a, lesson1_b,
    lesson2_intro, lesson2_add_score,
    lesson3_intro, lesson3_always, lesson3_high_score, lesson3_learned,
    lesson4_intro, lesson4_dice,
    graduation
}

for _, passage in ipairs(passages) do
    story:add_passage(passage)
end

story:set_start_passage("intro")

return story