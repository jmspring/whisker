#!/usr/bin/env lua
-- examples/cli_runtime/run.lua
-- Command-line runtime example for Whisker
-- Usage: lua examples/cli_runtime/run.lua [story.json]

-- Add project root to package path
local project_root = arg[0]:match("(.*/)")  or "./"
package.path = project_root .. "../../?.lua;" .. 
               project_root .. "../../?/init.lua;" .. 
               package.path

-- Load dependencies
local CLIRuntime = require('src.runtime.cli_runtime')
local json = require('src.utils.json')

-- Default story if no file provided
local DEFAULT_STORY = {
    title = "The Enchanted Forest",
    author = "Whisker Demo Team",
    variables = {
        player_name = "Adventurer",
        gold = 0,
        health = 100,
        has_key = false,
        forest_depth = 0
    },
    start = "forest_entrance",
    passages = {
        {
            id = "forest_entrance",
            title = "The Forest Entrance",
            content = [[Welcome, **{{player_name}}**!

You stand at the edge of an ancient forest. The trees tower above you, their branches forming a canopy that blocks most of the sunlight. A worn path leads deeper into the woods.

*Health:* {{health}} | *Gold:* {{gold}} coins

The forest seems to call to you. What will you do?]],
            choices = {
                {
                    text = "Follow the path deeper into the forest",
                    target = "deep_forest"
                },
                {
                    text = "Search the forest edge for items",
                    target = "forest_edge"
                },
                {
                    text = "Set up camp and rest",
                    target = "rest_camp"
                }
            }
        },
        {
            id = "deep_forest",
            title = "Deep in the Forest",
            content = [[The path winds through dense undergrowth. You hear strange sounds all around you—rustling leaves, distant bird calls, and something else...

*Depth:* {{forest_depth}} steps into the forest

Suddenly, you spot a glowing circle of mushrooms ahead. The fairy ring pulses with an otherworldly light.]],
            script = [[
                context.set('forest_depth', context.get('forest_depth') + 1)
            ]],
            choices = {
                {
                    text = "Step into the mushroom circle",
                    target = "fairy_ring"
                },
                {
                    text = "Avoid it and continue on the path",
                    target = "ancient_tree"
                },
                {
                    text = "Return to the entrance",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "forest_edge",
            title = "Searching the Forest Edge",
            content = [[You carefully search along the edge of the forest, pushing aside leaves and checking hollow logs.

After a few minutes, you spot something glinting in the undergrowth. It's a small leather pouch! Inside, you find **50 gold coins**!

You also notice some edible berries nearby. Eating them restores **10 health**.]],
            script = [[
                context.set('gold', context.get('gold') + 50)
                context.set('health', math.min(100, context.get('health') + 10))
            ]],
            choices = {
                {
                    text = "Take the gold and continue exploring",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "rest_camp",
            title = "Resting at Camp",
            content = [[You gather some wood and make a small fire. The warmth is comforting as you rest and tend to your wounds.

After some time, you feel much better. **Health fully restored!**

As you prepare to continue, you notice strange markings on a nearby tree. They seem to form a map pointing deeper into the forest.]],
            script = [[
                context.set('health', 100)
            ]],
            choices = {
                {
                    text = "Follow the map's directions",
                    target = "deep_forest"
                },
                {
                    text = "Return to the entrance",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "fairy_ring",
            title = "The Fairy Ring",
            content = [[As you step into the circle, the world shimmers and distorts. Colors become more vivid, sounds more musical. A tiny fairy materializes before you, no larger than your hand.

"Greetings, brave one!" she chimes in a voice like bells. "I can offer you a golden key that opens the ancient tree's door. But such magic has a price—**30 gold coins**."

*Your gold:* {{gold}} coins]],
            choices = {
                {
                    text = "Buy the golden key (30 gold)",
                    target = "bought_key",
                    condition = "gold >= 30",
                    script = [[
                        context.set('gold', context.get('gold') - 30)
                        context.set('has_key', true)
                    ]]
                },
                {
                    text = "Politely decline and leave",
                    target = "ancient_tree"
                },
                {
                    text = "You don't have enough gold...",
                    target = "ancient_tree",
                    condition = "gold < 30"
                }
            }
        },
        {
            id = "bought_key",
            title = "The Golden Key",
            content = [[The fairy hands you an ornate golden key. It's warm to the touch and seems to pulse with its own inner light.

**"This will open what needs opening,"** she whispers mysteriously, then vanishes in a shower of sparkles.

You carefully place the key in your pouch, feeling its weight and importance.]],
            choices = {
                {
                    text = "Continue your journey",
                    target = "ancient_tree"
                }
            }
        },
        {
            id = "ancient_tree",
            title = "The Ancient Tree",
            content = [[You come upon a massive oak tree, easily a thousand years old. Its trunk is so wide that ten people could barely encircle it.

Carved into the bark is an ornate door with a golden keyhole. Strange runes glow faintly around its frame.]],
            choices = {
                {
                    text = "Use the golden key to open the door",
                    target = "treasure_room",
                    condition = "has_key === true"
                },
                {
                    text = "Try to force the door open",
                    target = "failed_entry",
                    condition = "has_key === false"
                },
                {
                    text = "Examine the runes more closely",
                    target = "rune_study"
                },
                {
                    text = "Return to the entrance",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "failed_entry",
            title = "A Failed Attempt",
            content = [[You push against the door with all your strength, but it doesn't budge even a millimeter. The ancient wood is harder than stone.

As you strain against it, you hear a faint whisper from the tree itself: **"Only the key of light may open this door."**

You'll need to find that key somehow. **(-5 health from your efforts)**]],
            script = [[
                context.set('health', math.max(0, context.get('health') - 5))
            ]],
            choices = {
                {
                    text = "Search for another way",
                    target = "deep_forest"
                },
                {
                    text = "Give up and leave",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "rune_study",
            title = "Ancient Knowledge",
            content = [[You study the glowing runes carefully. Though you don't understand the language, their meaning somehow becomes clear in your mind:

**"Seek the guardians of the circle bright,
Where mushrooms dance in fairy light.
With gold exchange for key of gold,
The tree's great secrets to behold."**

It seems you need to find a fairy ring and trade gold for a key.]],
            choices = {
                {
                    text = "Continue your search",
                    target = "deep_forest"
                },
                {
                    text = "Return to entrance",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "treasure_room",
            title = "The Treasure of the Ancients",
            content = [[The golden key fits perfectly into the lock. With a satisfying click, the door swings open to reveal a chamber within the tree.

The room is filled with treasures beyond imagination:
- **500 gold coins** scattered across the floor
- Ancient artifacts glowing with magic
- Scrolls of forgotten knowledge
- A crown made of living wood and starlight

**You've discovered the legendary treasure of the Enchanted Forest!**

*Achievement Unlocked: Master Explorer*
*Final Gold:* {{gold}} coins → {{gold}} + 500 = *RICH!*]],
            script = [[
                context.set('gold', context.get('gold') + 500)
            ]],
            choices = {
                {
                    text = "Take the treasures and return triumphant",
                    target = "victory"
                },
                {
                    text = "Explore more of the forest",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "victory",
            title = "A Hero Returns",
            content = [[You emerge from the forest, laden with treasures and knowledge. The ancient tree's door closes behind you with a gentle whisper of gratitude.

**Final Statistics:**
- Health: {{health}}
- Gold: {{gold}} coins
- Forest Depth Reached: {{forest_depth}} steps
- Key Obtained: {{has_key}}

The forest will remember you, brave **{{player_name}}**. Your legend will be told for generations to come.

**Thank you for playing!**]],
            choices = {
                {
                    text = "Start a new adventure",
                    target = "forest_entrance"
                }
            }
        }
    }
}

-- Print welcome banner
local function print_banner()
    print([[
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║              WHISKER INTERACTIVE FICTION                      ║
║              Command-Line Runtime Example                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
    ]])
end

-- Main function
local function main()
    print_banner()

    -- Determine story source
    local story_file = arg[1]
    local story_data

    if story_file then
        -- Load from file
        print("Loading story from: " .. story_file)
        local file = io.open(story_file, "r")

        if not file then
            print("ERROR: Could not open story file: " .. story_file)
            print("Using default example story instead...")
            story_data = DEFAULT_STORY
        else
            local content = file:read("*all")
            file:close()

            local success, result = pcall(json.decode, content)
            if success then
                story_data = result
                print("Story loaded successfully!")
            else
                print("ERROR: Failed to parse story JSON: " .. tostring(result))
                print("Using default example story instead...")
                story_data = DEFAULT_STORY
            end
        end
    else
        -- Use default story
        print("No story file provided. Using default example story.")
        print("(You can provide a story file: lua run.lua path/to/story.json)")
        story_data = DEFAULT_STORY
    end

    print()

    -- Create and configure runtime
    local runtime = CLIRuntime:new({
        width = 80,              -- Terminal width in characters
        colors = true,           -- Enable ANSI colors
        save_file = "save.json", -- Save file location
        history_size = 10        -- Number of history entries to show
    })

    -- Initialize runtime
    if not runtime:initialize() then
        print("ERROR: Failed to initialize runtime")
        return 1
    end

    -- Load story
    if not runtime:load_story(story_data) then
        print("ERROR: Failed to load story")
        return 1
    end

    -- Start story
    if not runtime:start() then
        print("ERROR: Failed to start story")
        return 1
    end

    -- Run game loop
    runtime:run()

    return 0
end

-- Execute
os.exit(main())