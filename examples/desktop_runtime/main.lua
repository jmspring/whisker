-- examples/desktop_runtime/main.lua
-- LÖVE2D desktop runtime example for Whisker
-- Run with: love examples/desktop_runtime/

-- Add parent directories to package path for requiring src modules
package.path = "../../?.lua;../../?/init.lua;" .. package.path

-- Load dependencies
local DesktopRuntime = require('src.runtime.desktop_runtime')
local json = require('src.utils.json')

-- Global runtime instance
local runtime

-- Example story data (same as CLI for consistency)
local DEFAULT_STORY = {
    title = "The Enchanted Forest",
    author = "Whisker Desktop Demo",
    variables = {
        player_name = "Hero",
        gold = 0,
        health = 100,
        magic_power = 50,
        has_key = false,
        has_map = false,
        forest_reputation = 0
    },
    start = "forest_entrance",
    passages = {
        {
            id = "forest_entrance",
            title = "The Forest Entrance",
            content = [[Welcome, **{{player_name}}**!

You stand at the edge of an ancient, mystical forest. Towering trees form a natural cathedral around you, their leaves shimmering with an ethereal glow. A well-worn path leads deeper into the woods.

Your current status:
• Health: {{health}}
• Magic: {{magic_power}}
• Gold: {{gold}} coins
• Reputation: {{forest_reputation}}

The forest beckons. What will you do?]],
            choices = {
                {
                    text = "🌲 Venture deeper into the forest",
                    target = "deep_forest"
                },
                {
                    text = "🔍 Search the forest edge",
                    target = "forest_edge"
                },
                {
                    text = "🏕️ Set up camp and rest",
                    target = "rest"
                },
                {
                    text = "📜 Read the ancient signpost",
                    target = "signpost"
                }
            }
        },
        {
            id = "signpost",
            title = "The Ancient Signpost",
            content = [[An old wooden signpost stands at the forest entrance, covered in moss and strange carvings. You brush away the growth and read:

**"BEWARE YE WHO ENTER HERE"**

Below that, in smaller runes:
"The fairy folk guard treasures old,
Trade your coins for keys of gold,
The ancient tree shall test your might,
Only the worthy gain its sight."

You also notice a crude map carved into the back of the sign. **You've gained the Forest Map!**]],
            script = [[
                context.set('has_map', true)
            ]],
            choices = {
                {
                    text = "📍 Enter the forest with the map",
                    target = "deep_forest"
                },
                {
                    text = "↩️ Return to the entrance",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "deep_forest",
            title = "Deep in the Forest",
            content = [[The path winds through dense undergrowth. Magical motes of light dance between the trees, and you hear the tinkling of distant bells.

You spot three paths ahead:
1. A glowing fairy circle to the left
2. A massive ancient tree straight ahead
3. A crystal-clear stream to the right]],
            choices = {
                {
                    text = "✨ Approach the fairy circle",
                    target = "fairy_ring"
                },
                {
                    text = "🌳 Examine the ancient tree",
                    target = "ancient_tree"
                },
                {
                    text = "💧 Follow the stream",
                    target = "stream"
                },
                {
                    text = "↩️ Return to entrance",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "forest_edge",
            title = "Searching the Edge",
            content = [[You carefully search the forest edge, moving leaves and checking hollow logs.

Your search is rewarded! You find:
• **50 gold coins** in a leather pouch
• **Healing herbs** (+20 health)
• A **glowing crystal** (+10 magic power)

The forest seems pleased by your careful, respectful searching. **+5 Reputation**]],
            script = [[
                context.set('gold', context.get('gold') + 50)
                context.set('health', math.min(100, context.get('health') + 20))
                context.set('magic_power', math.min(100, context.get('magic_power') + 10))
                context.set('forest_reputation', context.get('forest_reputation') + 5)
            ]],
            choices = {
                {
                    text = "Continue exploring",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "rest",
            title = "Peaceful Rest",
            content = [[You gather firewood and create a cozy camp. As you rest, you feel the forest's magic healing you.

**Fully rested!**
• Health: 100
• Magic: 100

The forest spirits seem to approve of your presence. **+3 Reputation**]],
            script = [[
                context.set('health', 100)
                context.set('magic_power', 100)
                context.set('forest_reputation', context.get('forest_reputation') + 3)
            ]],
            choices = {
                {
                    text = "Continue your journey",
                    target = "forest_entrance"
                }
            }
        },
        {
            id = "stream",
            title = "The Crystal Stream",
            content = [[You follow the stream through the forest. The water is so clear you can see every pebble on the bottom.

As you drink from the stream, you feel revitalized! **+30 Health, +20 Magic**

A water sprite emerges from the stream. "Thank you for not polluting my home," she says, handing you **25 gold coins**. **+5 Reputation**]],
            script = [[
                context.set('health', math.min(100, context.get('health') + 30))
                context.set('magic_power', math.min(100, context.get('magic_power') + 20))
                context.set('gold', context.get('gold') + 25)
                context.set('forest_reputation', context.get('forest_reputation') + 5)
            ]],
            choices = {
                {
                    text = "Thank the sprite and continue",
                    target = "deep_forest"
                }
            }
        },
        {
            id = "fairy_ring",
            title = "The Fairy Circle",
            content = [[You step into a ring of glowing mushrooms. The air shimmers, and a beautiful fairy appears before you.

"Greetings, traveler! Your reputation precedes you. (Reputation: {{forest_reputation}})"

She offers you a **Golden Key** for **30 gold coins**. This key opens the Ancient Tree's treasure room.

Your current gold: {{gold}} coins]],
            choices = {
                {
                    text = "💰 Buy the Golden Key (30 gold)",
                    target = "got_key",
                    condition = "gold >= 30",
                    script = [[
                        context.set('gold', context.get('gold') - 30)
                        context.set('has_key', true)
                        context.set('forest_reputation', context.get('forest_reputation') + 10)
                    ]]
                },
                {
                    text = "🙏 Ask for a discount (requires reputation 10+)",
                    target = "discounted_key",
                    condition = "forest_reputation >= 10 and gold >= 15",
                    script = [[
                        context.set('gold', context.get('gold') - 15)
                        context.set('has_key', true)
                        context.set('forest_reputation', context.get('forest_reputation') + 5)
                    ]]
                },
                {
                    text = "❌ Decline politely",
                    target = "deep_forest"
                },
                {
                    text = "💸 Not enough gold...",
                    target = "deep_forest",
                    condition = "gold < 30"
                }
            }
        },
        {
            id = "got_key",
            title = "The Golden Key",
            content = [[The fairy hands you an ornate golden key that glows with inner light.

"Use it wisely," she whispers before vanishing in a shower of sparkles.

**Golden Key obtained!**
**+10 Forest Reputation for fair dealing**]],
            choices = {
                {
                    text = "Continue your quest",
                    target = "ancient_tree"
                }
            }
        },
        {
            id = "discounted_key",
            title = "A Friend's Discount",
            content = [[The fairy smiles warmly. "Your kindness to the forest has not gone unnoticed. For you, only 15 gold."

She hands you the **Golden Key** at a discount.

"The forest protects its friends," she says before disappearing.

**Golden Key obtained at half price!**
**+5 Forest Reputation**]],
            choices = {
                {
                    text = "Continue your quest",
                    target = "ancient_tree"
                }
            }
        },
        {
            id = "ancient_tree",
            title = "The Ancient Tree",
            content = [[Before you stands a colossal oak tree, its trunk wider than a house. An ornate door is carved into the bark, with a golden keyhole in the center.

Ancient runes glow around the door frame. The tree emanates powerful magic.]],
            choices = {
                {
                    text = "🔑 Use the Golden Key",
                    target = "treasure_room",
                    condition = "has_key === true"
                },
                {
                    text = "🔮 Use magic to open (50 magic)",
                    target = "magic_entry",
                    condition = "magic_power >= 50 and has_key === false",
                    script = [[
                        context.set('magic_power', context.get('magic_power') - 50)
                    ]]
                },
                {
                    text = "💪 Try to force it open",
                    target = "failed_entry",
                    condition = "has_key === false"
                },
                {
                    text = "↩️ Leave and explore more",
                    target = "deep_forest"
                }
            }
        },
        {
            id = "magic_entry",
            title = "Magical Prowess",
            content = [[You channel your magical energy into the door. The runes flare brightly and the door slowly swings open!

**-50 Magic Power**

The tree whispers: "Clever mortal. Few possess such power."

**+20 Forest Reputation for magical skill**]],
            script = [[
                context.set('forest_reputation', context.get('forest_reputation') + 20)
            ]],
            choices = {
                {
                    text = "Enter the treasure room",
                    target = "treasure_room"
                }
            }
        },
        {
            id = "failed_entry",
            title = "A Futile Attempt",
            content = [[You push and pull at the door with all your might, but it won't budge. The ancient wood is harder than steel.

Your efforts cost you **-10 health** and tire you out (**-15 magic**).

The tree whispers: "Only those with the key or great magical power may enter."]],
            script = [[
                context.set('health', math.max(0, context.get('health') - 10))
                context.set('magic_power', math.max(0, context.get('magic_power') - 15))
            ]],
            choices = {
                {
                    text = "Search for another way",
                    target = "deep_forest"
                }
            }
        },
        {
            id = "treasure_room",
            title = "The Ancient Treasure",
            content = [[The door opens to reveal a chamber of wonders within the tree!

**TREASURE FOUND:**
• 💰 **500 gold coins**
• 🔮 **Eternal Magic Amulet** (+50 permanent magic)
• ❤️ **Heart of the Forest** (full health restoration)
• 👑 **Crown of Nature** (Achievement Unlocked!)

**YOU WIN!**

Final Stats:
• Health: {{health}}
• Magic: {{magic_power}}
• Gold: {{gold}} coins
• Reputation: {{forest_reputation}}

The forest will remember you forever, noble **{{player_name}}**!]],
            script = [[
                context.set('gold', context.get('gold') + 500)
                context.set('magic_power', math.min(100, context.get('magic_power') + 50))
                context.set('health', 100)
            ]],
            choices = {
                {
                    text = "🎮 Start New Adventure",
                    target = "forest_entrance"
                },
                {
                    text = "🚪 Exit and Save",
                    target = "exit"
                }
            }
        },
        {
            id = "exit",
            title = "Until Next Time",
            content = [[Thank you for playing The Enchanted Forest!

Your adventure has been saved automatically.

**Press F5 to save manually**
**Press F9 to load a saved game**
**Press Escape to quit**

May your future adventures be just as grand!]],
            choices = {
                {
                    text = "Return to the beginning",
                    target = "forest_entrance"
                }
            }
        }
    }
}

-- LÖVE2D Callbacks
function love.load()
    -- Set window icon and title
    love.window.setTitle("Whisker - The Enchanted Forest")
    
    -- Create runtime with configuration
    runtime = DesktopRuntime:new({
        width = 1280,
        height = 720,
        theme = "default",  -- Options: "default", "dark", "sepia"
        font_size = 20,
        debug = false
    })
    
    -- Initialize the runtime
    runtime:load()
    
    -- Try to load story from JSON file first
    local story_loaded = false
    
    if love.filesystem.getInfo("story.json") then
        print("Found story.json, attempting to load...")
        local success, err = pcall(function()
            runtime:load_story_from_file("story.json")
            story_loaded = true
        end)
        
        if not success then
            print("Failed to load story.json: " .. tostring(err))
            print("Using default story instead.")
        end
    end
    
    -- Fall back to default story if file not found or failed to load
    if not story_loaded then
        print("Loading default example story...")
        runtime:load_story(DEFAULT_STORY)
    end
    
    -- Start the story
    runtime:start()
    
    print("\n=== Whisker Desktop Runtime Started ===")
    print("Keyboard Shortcuts:")
    print("  F1: Settings")
    print("  F5: Quick Save")
    print("  F9: Quick Load")
    print("  Ctrl+Z: Undo")
    print("  Ctrl+R: Restart")
    print("  Tab: Toggle Sidebar")
    print("  ESC: Quit")
    print("=======================================\n")
end

function love.update(dt)
    runtime:update(dt)
end

function love.draw()
    runtime:draw()
end

function love.mousepressed(x, y, button)
    runtime:mousepressed(x, y, button)
end

function love.mousemoved(x, y)
    runtime:mousemoved(x, y)
end

function love.wheelmoved(x, y)
    runtime:wheelmoved(x, y)
end

function love.keypressed(key)
    runtime:keypressed(key)
end

function love.resize(w, h)
    runtime:resize(w, h)
end

-- Handle quit confirmation
function love.quit()
    print("Thanks for playing!")
    return false
end