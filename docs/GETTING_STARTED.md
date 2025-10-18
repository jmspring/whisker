# Getting Started with whisker

This guide will help you create your first interactive fiction story with whisker in just a few minutes.

## 📋 Prerequisites

- **Lua 5.1 or higher** installed on your system
- A text editor (VS Code, Sublime, Atom, or any editor)
- Basic knowledge of Lua (helpful but not required)

### Installing Lua

**macOS:**
```bash
brew install lua
```

**Ubuntu/Debian:**
```bash
sudo apt-get install lua5.3
```

**Windows:**
Download from [lua.org](https://www.lua.org/download.html) or use [LuaForWindows](https://github.com/rjpcomputing/luaforwindows)

**Verify Installation:**
```bash
lua -v
# Should show: Lua 5.x.x
```

## 🚀 Installation

### Option 1: Clone Repository

```bash
git clone https://github.com/jmspring/whisker.git
cd whisker
```

### Option 2: Download ZIP

1. Download from [GitHub releases](https://github.com/jmspring/whisker/releases)
2. Extract to your preferred location
3. Open terminal/command prompt in the directory

### Verify Installation

```bash
# Show version
lua main.lua --version

# Show help
lua main.lua --help

# Run example
lua main.lua examples/simple_story.lua
```

## 📖 Your First Story

### Step 1: Create the Story File

Create a new file called `my_first_story.lua`:

```lua
-- my_first_story.lua
local Story = require("whisker.core.story")
local Passage = require("whisker.core.passage")
local Choice = require("whisker.core.choice")

-- Create the story
local story = Story.new({
    title = "My First Adventure",
    author = "Your Name",
    ifid = "MY-FIRST-001",
    version = "1.0"
})

-- Create the starting passage
local start = Passage.new({
    id = "start",
    content = [[
Welcome to your first whisker adventure!

You find yourself standing at a crossroads.
The sun is setting, and you must choose a path.
    ]]
})

-- Add choices to the start passage
start:add_choice(Choice.new({
    text = "Take the forest path",
    target = "forest"
}))

start:add_choice(Choice.new({
    text = "Follow the river",
    target = "river"
}))

-- Create the forest passage
local forest = Passage.new({
    id = "forest",
    content = [[
You venture into the dark forest. The trees whisper secrets
as you walk deeper into the woods.

After hours of walking, you find a mysterious cottage!

**THE END**
    ]]
})

-- Create the river passage
local river = Passage.new({
    id = "river",
    content = [[
You follow the winding river downstream. The sound of water
is soothing as you walk along the bank.

Eventually, you reach a peaceful village!

**THE END**
    ]]
})

-- Add all passages to the story
story:add_passage(start)
story:add_passage(forest)
story:add_passage(river)

-- Set the starting passage
story:set_start_passage("start")

-- Return the story
return story
```

### Step 2: Run Your Story

```bash
lua main.lua my_first_story.lua
```

You should see:
```
============================================================
  My First Adventure
  by Your Name
============================================================

Welcome to your first whisker adventure!

You find yourself standing at a crossroads.
The sun is setting, and you must choose a path.

1. Take the forest path
2. Follow the river

>
```

### Step 3: Play Through

- Type `1` or `2` to make a choice
- Press Enter to continue
- Type `quit` to exit

Congratulations! You've created and played your first whisker! 🎉

## 🎓 Learning Path

### Level 1: Basics (You Are Here!)
✅ Create simple stories with passages and choices
✅ Understand story structure
✅ Run stories from command line

### Level 2: Variables and State
Learn to track game state:

```lua
-- Initialize variables in your story
story.variables = {
    player_name = "Hero",
    health = 100,
    gold = 0
}

-- Use variables in passage content
local passage = Passage.new({
    id = "show_stats",
    content = [[
Name: {{player_name}}
Health: {{health}}
Gold: {{gold}}
    ]]
})
```

**Next:** Read [API_REFERENCE.md](API_REFERENCE.md) for variable usage

### Level 3: Conditional Choices
Make choices appear based on conditions:

```lua
passage:add_choice(Choice.new({
    text = "Enter the castle (requires key)",
    target = "castle",
    condition = "has_key == true"
}))
```

### Level 4: Lua Scripting
Add complex game logic:

```lua
local passage = Passage.new({
    id = "combat",
    content = "You attack the enemy!",
    on_enter = [[
        local damage = math.random(10, 20)
        local enemy_health = game_state:get_variable("enemy_health")
        game_state:set_variable("enemy_health", enemy_health - damage)
    ]]
})
```

**Next:** Study [examples/adventure_game.lua](../examples/adventure_game.lua)

### Level 5: Advanced Features
- Profiling and optimization
- Converting from Twine
- Web deployment
- Custom UI themes

**Next:** Read [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)

## 📝 Story Structure Best Practices

### 1. Organize Your Code

```lua
-- Group related passages
local start_passages = {}
local village_passages = {}
local dungeon_passages = {}

-- Add them in logical order
for _, p in ipairs(start_passages) do
    story:add_passage(p)
end
```

### 2. Use Descriptive IDs

```lua
-- Good ✅
"village_entrance"
"blacksmith_shop"
"final_boss_battle"

-- Bad ❌
"p1"
"passage2"
"scene_x"
```

### 3. Comment Your Logic

```lua
-- Check if player has completed the quest
if game_state:get_variable("quest_completed") then
    -- Reward the player
    game_state:set_variable("gold", gold + 100)
end
```

### 4. Test Frequently

```bash
# Validate your story
lua main.lua --validate my_story.lua

# Test all paths
lua main.lua my_story.lua
```

## 🛠️ Development Workflow

### 1. Write Story

Create or edit your `.lua` story file in your favorite editor.

### 2. Validate

Check for errors before playing:

```bash
lua main.lua --validate my_story.lua
```

Fix any errors reported by the validator.

### 3. Test Play

```bash
lua main.lua my_story.lua
```

Play through different paths to test all branches.

### 4. Debug (Optional)

If something isn't working:

```bash
lua main.lua --debug my_story.lua
```

Set breakpoints and inspect variables.

### 5. Profile (Optional)

Check performance:

```bash
lua main.lua --profile my_story.lua
```

Optimize slow passages.

### 6. Deploy

Choose your deployment method:
- Console: Ship the `.lua` file
- Web: Use `web_demo.html` as template
- Convert: Export to other formats

## 🌐 Web Deployment

### Quick Web Demo

1. Copy the web template:
```bash
cp examples/web_demo.html my_game.html
```

2. Edit the story data in the `<script>` section

3. Open `my_game.html` in any browser

### Full Web Deployment

See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) for:
- Custom styling
- Server deployment
- Mobile optimization
- SEO considerations

## 🎮 Playing Stories

### Basic Commands

While playing a story:

- **Numbers (1, 2, 3...)** - Select a choice
- **save** or **s** - Save your game
- **load** or **l** - Load a saved game
- **undo** or **u** - Undo last action
- **restart** or **r** - Restart the story
- **help** or **h** - Show help
- **quit** or **q** - Exit the game

### Save System

```bash
> save
Enter save name: Before the big battle
Select save slot (1-10): 1
Game saved!
```

To load:
```bash
> load
Available saves:
  Slot 1: Before the big battle (2 minutes ago)
Select slot to load: 1
Game loaded!
```

## 📚 Learning Resources

### Example Stories

1. **simple_story.lua** - Start here!
   - Basic passages and choices
   - Multiple endings
   - Clean, readable code

2. **tutorial_story.lua** - Interactive guide
   - Learn by playing
   - Covers all features
   - Self-documenting

3. **adventure_game.lua** - Full example
   - Variables and inventory
   - Combat system
   - Multiple quests
   - Complex branching

### Documentation

- **[API Reference](API_REFERENCE.md)** - Complete API docs
- **[Story Format](STORY_FORMAT.md)** - Format specification
- **[Development Guide](DEVELOPMENT_GUIDE.md)** - Advanced topics

### External Resources

- [Lua Tutorial](https://www.lua.org/pil/)
- [Twine Documentation](https://twinery.org/wiki/)
- [Interactive Fiction Theory](http://inform7.com/learn/)

## ❓ Common Questions

### How do I add images/sound?

See [API_REFERENCE.md](API_REFERENCE.md) - Asset Manager section

### How do I import a Twine story?

```bash
lua main.lua --convert json my_twine_story.html -o converted.json
```

See [TWINE_COMPATIBILITY.md](TWINE_COMPATIBILITY.md)

### Can I use this commercially?

Yes! MIT license allows commercial use.

### How do I create a visual editor?

The visual editor is planned for future release. For now, use:
- Text editor with syntax highlighting
- Twine for visual design, then import
- Draw story structure on paper first

### How do I add multiplayer?

Multiplayer is not currently supported, but you can:
- Use separate game instances
- Share save files manually
- Build custom backend integration

## 🐛 Troubleshooting

### "Module not found" Error

```bash
# Make sure you're in the project root
cd /path/to/whisker
lua main.lua my_story.lua
```

### Story Won't Run

```bash
# Validate first
lua main.lua --validate my_story.lua

# Check for syntax errors in your .lua file
```

### Choices Don't Appear

- Check passage IDs match choice targets
- Verify conditions are correct
- Use validator: `lua main.lua --validate story.lua`

### Variables Don't Work

- Initialize variables in `story.variables`
- Use correct syntax: `{{variable_name}}`
- Check spelling matches exactly

## ✅ Next Steps

Now that you've created your first story:

1. ✅ Add more passages and choices
2. ✅ Try using variables
3. ✅ Add conditional choices
4. ✅ Experiment with Lua scripting
5. ✅ Play the tutorial: `lua main.lua examples/tutorial_story.lua`
6. ✅ Study the adventure game example
7. ✅ Read the [API Reference](API_REFERENCE.md)
8. ✅ Deploy to web using the HTML template

## 🎉 You're Ready!

You now know enough to create your own interactive fiction stories!

**Happy storytelling!** ✨

---

**Need Help?**
- Check [API_REFERENCE.md](API_REFERENCE.md) for detailed docs
- See [examples/](../examples/) for more complex examples
- Open an issue on GitHub for bugs or questions
