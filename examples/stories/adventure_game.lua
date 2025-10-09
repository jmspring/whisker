-- examples/adventure_game.lua
-- A full-featured adventure game demonstrating whisker capabilities
-- Includes: variables, conditions, Lua scripting, multiple paths, and endings

local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

-- Create the story
local story = Story.new({
    title = "The Dragon's Lair",
    author = "whisker Examples",
    ifid = "ADVENTURE-001",
    version = "1.0",
    description = "A classic fantasy adventure with multiple paths and endings"
})

-- Initialize story variables
story.variables = {
    player_name = "Hero",
    health = 100,
    gold = 0,
    has_sword = false,
    has_key = false,
    has_potion = false,
    wizard_helped = false,
    dragon_defeated = false,
    villagers_saved = false
}

-- ============================================================================
-- START PASSAGES
-- ============================================================================

local start = Passage.new({
    id = "start",
    content = [[
**The Dragon's Lair**
*A whisker Adventure*

You are {{player_name}}, a brave adventurer seeking glory and fortune.
A fearsome dragon has been terrorizing the nearby village, and the
villagers are offering a reward of 1000 gold pieces to anyone who
can defeat it.

Your journey begins at the village square...

**Health:** {{health}} | **Gold:** {{gold}}
    ]],
    on_enter = [[
-- Initialize game if first visit
if not game_state:get_variable("game_started") then
    game_state:set_variable("game_started", true)
    game_state:set_variable("visits_to_village", 0)
end
    ]]
})

start:add_choice(Choice.new({
    text = "Visit the blacksmith",
    target = "blacksmith"
}))

start:add_choice(Choice.new({
    text = "Visit the wizard",
    target = "wizard"
}))

start:add_choice(Choice.new({
    text = "Go directly to the dragon's lair",
    target = "dragon_approach"
}))

-- ============================================================================
-- VILLAGE PASSAGES
-- ============================================================================

local blacksmith = Passage.new({
    id = "blacksmith",
    content = [[
The blacksmith's forge glows with heat. A burly man with soot-covered
arms greets you.

"Looking for a weapon? I have a fine sword for 50 gold pieces.
With it, you might stand a chance against that dragon!"

**Health:** {{health}} | **Gold:** {{gold}}
    ]]
})

blacksmith:add_choice(Choice.new({
    text = "Buy the sword (50 gold)",
    target = "buy_sword",
    condition = "gold >= 50 and not has_sword",
    action = [[
        game_state:set_variable("gold", game_state:get_variable("gold") - 50)
        game_state:set_variable("has_sword", true)
    ]]
}))

blacksmith:add_choice(Choice.new({
    text = "You already have a sword",
    target = "blacksmith",
    condition = "has_sword",
    visible = false
}))

blacksmith:add_choice(Choice.new({
    text = "Not enough gold",
    target = "blacksmith",
    condition = "gold < 50 and not has_sword",
    visible = false
}))

blacksmith:add_choice(Choice.new({
    text = "Leave the shop",
    target = "start"
}))

local buy_sword = Passage.new({
    id = "buy_sword",
    content = [[
The blacksmith hands you a gleaming steel sword. It feels perfectly
balanced in your hand.

"This blade has served me well. May it serve you better against
the dragon!"

**You obtained: Steel Sword**
**Gold: {{gold}}**
    ]]
})

buy_sword:add_choice(Choice.new({
    text = "Thank the blacksmith and leave",
    target = "start"
}))

local wizard = Passage.new({
    id = "wizard",
    content = [[
You climb the spiral stairs to the wizard's tower. The old man looks
up from his spellbook.

"Ah, the dragon slayer! I can help you, but I need something in return.
Bring me the golden key from the old ruins, and I'll give you a
powerful healing potion."

**Health:** {{health}} | **Gold:** {{gold}}
    ]]
})

wizard:add_choice(Choice.new({
    text = "Give the wizard the golden key",
    target = "wizard_trade",
    condition = "has_key and not wizard_helped"
}))

wizard:add_choice(Choice.new({
    text = "You already helped the wizard",
    target = "wizard",
    condition = "wizard_helped",
    visible = false
}))

wizard:add_choice(Choice.new({
    text = "Promise to find the key",
    target = "ruins_path",
    condition = "not has_key"
}))

wizard:add_choice(Choice.new({
    text = "Leave the tower",
    target = "start"
}))

local wizard_trade = Passage.new({
    id = "wizard_trade",
    content = [[
The wizard takes the golden key and smiles.

"Excellent! This is exactly what I needed."

He hands you a glowing red potion.

"This potion will restore your health when you need it most.
Use it wisely!"

**You obtained: Healing Potion**
    ]],
    on_enter = [[
        game_state:set_variable("has_potion", true)
        game_state:set_variable("wizard_helped", true)
    ]]
})

wizard_trade:add_choice(Choice.new({
    text = "Thank the wizard and leave",
    target = "start"
}))

-- ============================================================================
-- RUINS PASSAGES
-- ============================================================================

local ruins_path = Passage.new({
    id = "ruins_path",
    content = [[
You travel to the ancient ruins on the outskirts of the village.
The crumbling stone structures are covered in vines and moss.

In the center of the ruins, you see a pedestal with a glowing
golden key!

But as you approach, a skeleton warrior rises from the ground
to block your path!
    ]]
})

ruins_path:add_choice(Choice.new({
    text = "Fight the skeleton (requires sword)",
    target = "ruins_fight",
    condition = "has_sword"
}))

ruins_path:add_choice(Choice.new({
    text = "Try to sneak past",
    target = "ruins_sneak"
}))

ruins_path:add_choice(Choice.new({
    text = "Retreat to the village",
    target = "start"
}))

local ruins_fight = Passage.new({
    id = "ruins_fight",
    content = [[
You draw your sword and charge at the skeleton warrior!

The battle is fierce, but your steel blade shatters the ancient
bones. The skeleton collapses into dust.

You grab the golden key from the pedestal!

**You obtained: Golden Key**
**Health: {{health - 10}}** (You took some damage in the fight)
    ]],
    on_enter = [[
        game_state:set_variable("has_key", true)
        game_state:set_variable("health", game_state:get_variable("health") - 10)
    ]]
})

ruins_fight:add_choice(Choice.new({
    text = "Return to the village",
    target = "start"
}))

local ruins_sneak = Passage.new({
    id = "ruins_sneak",
    content = [[
You try to sneak past the skeleton, but your foot kicks a loose
stone!

The skeleton turns toward you with blazing red eyes and attacks!

Without a weapon, you barely escape with your life.

**Health: {{health - 30}}** (You took heavy damage!)
    ]],
    on_enter = [[
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - 30))
    ]]
})

ruins_sneak:add_choice(Choice.new({
    text = "Retreat to the village",
    target = "start",
    condition = "health > 0"
}))

ruins_sneak:add_choice(Choice.new({
    text = "You have died...",
    target = "game_over",
    condition = "health <= 0"
}))

-- ============================================================================
-- DRAGON PASSAGES
-- ============================================================================

local dragon_approach = Passage.new({
    id = "dragon_approach",
    content = [[
You make your way through the dark forest to the dragon's lair.
The mountain looms ahead, with smoke rising from a cave entrance.

As you approach, you see bones scattered around the entrance.
The dragon is home.

**Health:** {{health}} | **Gold:** {{gold}}
**Equipment:** {{has_sword and "Steel Sword" or "None"}}
{{has_potion and "| Healing Potion" or ""}}
    ]]
})

dragon_approach:add_choice(Choice.new({
    text = "Enter the lair boldly",
    target = "dragon_fight"
}))

dragon_approach:add_choice(Choice.new({
    text = "Try to sneak in quietly",
    target = "dragon_sneak"
}))

dragon_approach:add_choice(Choice.new({
    text = "Return to the village to prepare",
    target = "start"
}))

local dragon_fight = Passage.new({
    id = "dragon_fight",
    content = [[
You march into the dragon's lair with determination!

The massive red dragon rises from its pile of gold, flames flickering
in its nostrils.

"FOOLISH MORTAL!" it roars.

The dragon unleashes a torrent of fire!
    ]],
    on_enter = [[
        local health = game_state:get_variable("health")
        local has_sword = game_state:get_variable("has_sword")
        local damage = has_sword and 30 or 50
        game_state:set_variable("health", health - damage)
    ]]
})

dragon_fight:add_choice(Choice.new({
    text = "Fight with your sword!",
    target = "dragon_victory",
    condition = "has_sword and health > 0"
}))

dragon_fight:add_choice(Choice.new({
    text = "Use the healing potion!",
    target = "dragon_heal",
    condition = "has_potion and health > 0 and health < 50"
}))

dragon_fight:add_choice(Choice.new({
    text = "You have been defeated...",
    target = "game_over",
    condition = "health <= 0"
}))

dragon_fight:add_choice(Choice.new({
    text = "Flee from the dragon!",
    target = "start",
    condition = "health > 0"
}))

local dragon_heal = Passage.new({
    id = "dragon_heal",
    content = [[
You quickly drink the healing potion!

A warm glow flows through your body, healing your wounds.

**Health restored to 100!**

Now, with renewed strength, you face the dragon!
    ]],
    on_enter = [[
        game_state:set_variable("health", 100)
        game_state:set_variable("has_potion", false)
    ]]
})

dragon_heal:add_choice(Choice.new({
    text = "Attack the dragon!",
    target = "dragon_victory"
}))

local dragon_sneak = Passage.new({
    id = "dragon_sneak",
    content = [[
You creep quietly into the lair, trying to avoid waking the dragon.

The dragon appears to be sleeping on its massive pile of gold.

You spot the villagers' stolen treasures in the corner!
    ]]
})

dragon_sneak:add_choice(Choice.new({
    text = "Try to steal the treasure quietly",
    target = "dragon_steal"
}))

dragon_sneak:add_choice(Choice.new({
    text = "Attack while the dragon sleeps",
    target = "dragon_victory",
    condition = "has_sword"
}))

dragon_sneak:add_choice(Choice.new({
    text = "Leave quietly",
    target = "start"
}))

local dragon_steal = Passage.new({
    id = "dragon_steal",
    content = [[
You carefully gather some of the stolen treasure...

But your hand bumps a gold coin, which clinks loudly!

The dragon's eyes snap open!

"THIEF!" it roars, lunging at you!

You barely escape with your life, but you managed to grab
some gold!

**+200 Gold**
**Health: {{health - 40}}**
    ]],
    on_enter = [[
        local gold = game_state:get_variable("gold")
        local health = game_state:get_variable("health")
        game_state:set_variable("gold", gold + 200)
        game_state:set_variable("health", math.max(0, health - 40))
    ]]
})

dragon_steal:add_choice(Choice.new({
    text = "Run back to the village!",
    target = "start",
    condition = "health > 0"
}))

dragon_steal:add_choice(Choice.new({
    text = "You have died...",
    target = "game_over",
    condition = "health <= 0"
}))

-- ============================================================================
-- ENDING PASSAGES
-- ============================================================================

local dragon_victory = Passage.new({
    id = "dragon_victory",
    content = [[
With a mighty swing of your sword, you strike the dragon's weak spot!

The dragon roars in pain and collapses. As it falls, it transforms
into a shimmering spirit.

"Thank you, brave hero," the spirit says. "I was cursed to take
this form. You have freed me."

The spirit vanishes, leaving behind a massive treasure hoard!

You return to the village as a hero. The grateful villagers give
you 1000 gold pieces, and you keep the dragon's treasure as well!

**VICTORY!**

Final Stats:
- Health: {{health}}
- Gold: {{gold + 3000}}
- Status: **HERO OF THE VILLAGE**

*THE END*
    ]],
    on_enter = [[
        game_state:set_variable("dragon_defeated", true)
        game_state:set_variable("villagers_saved", true)
        local gold = game_state:get_variable("gold")
        game_state:set_variable("gold", gold + 3000)
    ]]
})

local game_over = Passage.new({
    id = "game_over",
    content = [[
**GAME OVER**

You have been defeated in your quest.

The dragon continues to terrorize the village, and your story
ends here.

Final Stats:
- Health: 0
- Gold: {{gold}}

Perhaps you should have prepared better?

*THE END*
    ]]
})

-- ============================================================================
-- BUILD THE STORY
-- ============================================================================

-- Add all passages
local passages = {
    start, blacksmith, buy_sword, wizard, wizard_trade,
    ruins_path, ruins_fight, ruins_sneak,
    dragon_approach, dragon_fight, dragon_heal, dragon_sneak, dragon_steal,
    dragon_victory, game_over
}

for _, passage in ipairs(passages) do
    story:add_passage(passage)
end

-- Set starting passage
story:set_start_passage("start")

-- Return the story
return story