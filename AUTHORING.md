# Authoring Stories with Whisker

**whisker** is a tool for creating interactive fiction - choice-based stories where readers make decisions that affect the outcome. This guide will help you create your own interactive stories using whisker.

## Quick Start

### What You'll Need

- **Web Browser** - Use the included web editor to create stories without any installation
- **Text Editor** (optional) - For advanced features, you can edit story files directly

### Creating Your First Story

The easiest way to start is with the **Web Editor**:

1. Open `publisher/web/index.html` in your web browser
2. Start writing passages and adding choices
3. Click "Export" to save your story

Or you can **write stories in Twine** and import them into whisker - see [Importing from Twine](#importing-from-twine) below.

## Story Structure

Every whisker story is made up of **passages** connected by **choices**:

### Passages

A **passage** is a single screen or moment in your story. It contains:
- **Text** describing what's happening
- **Choices** the reader can make
- **Variables** to track the story state (optional)

### Example Story

Here's a simple story structure:

```
START PASSAGE: "The Cave"
  Text: "You stand before a dark cave. What do you do?"
  Choices:
    → "Enter the cave" (goes to passage "Inside Cave")
    → "Walk away" (goes to passage "Ending: Safe")

PASSAGE: "Inside Cave"
  Text: "It's dark inside. You hear a growl."
  Choices:
    → "Run!" (goes to passage "Ending: Escaped")
    → "Stay quiet" (goes to passage "Ending: Found Treasure")
```

## Creating Stories in Different Ways

### Option 1: Web Editor (Easiest)

The web editor provides a visual interface similar to Twine:

1. **Open**: `publisher/web/index.html` in your browser
2. **Create Passages**: Click "New Passage" to add story moments
3. **Add Choices**: Use `[[Choice Text->Passage Name]]` syntax
4. **Preview**: Click "Play" to test your story
5. **Export**: Save as HTML to share with readers

### Option 2: Twine (Most Popular)

whisker is fully compatible with Twine stories:

1. **Create in Twine**: Use [Twinery.org](https://twinery.org) to create your story
2. **Export**: File → Publish to File → Save as HTML
3. **Convert**: Open the HTML file in whisker's web editor
4. **Play**: Your story is ready!

**Supported Twine formats:**
- Harlowe
- SugarCube
- Chapbook
- Snowman

### Option 3: Direct Lua (Advanced)

For programmers, you can write stories directly in Lua:

```lua
local Story = require("whisker.core.story")
local Passage = require("whisker.core.passage")
local Choice = require("whisker.core.choice")

local story = Story.new({
    title = "My Adventure",
    author = "Your Name"
})

local start = Passage.new({
    id = "start",
    content = "Your adventure begins..."
})

start:add_choice(Choice.new({
    text = "Continue",
    target = "next_passage"
}))

story:add_passage(start)
story:set_start_passage("start")

return story
```

Save this as `my_story.lua` and run: `lua bin/whisker my_story.lua`

## Adding Interactivity

### Variables

Track information across your story using variables:

**In Twine/Web Editor:**
```
(set: $gold to 100)
(set: $hasKey to true)

You have $gold gold pieces.
```

**Check variables:**
```
(if: $gold >= 50)[
  You can afford the sword!
]
```

### Conditional Choices

Show choices only when conditions are met:

```
(if: $hasKey)[
  [[Unlock the door->Treasury]]
]

(if: $gold >= 100)[
  [[Buy the sword->Shop]]
]
```

### Combining Variables and Text

```
Your score: $score
Gold: $gold
Health: $health

(if: $health < 20)[
  You're badly wounded!
]
```

## Story Organization Tips

### Keep It Simple

- **Start small**: Create 5-10 passages first, then expand
- **One idea per passage**: Don't overwhelm readers
- **2-4 choices**: Too many options can be paralyzing

### Map Your Story

Before writing:
1. Sketch your story structure on paper
2. Identify major decision points
3. Plan different endings

### Test Frequently

- Play through your story often
- Ask friends to test
- Check for dead ends (passages with no choices)

## Publishing Your Story

### For Web

Export your story as a standalone HTML file:

1. In the web editor, click "Export"
2. Choose "Standalone HTML"
3. Share the file - readers can open it in any browser!

### For Players

If readers have whisker installed, share the `.whisker` file:

1. Export as "Whisker JSON"
2. Readers run: `lua bin/whisker your_story.whisker`

## Importing from Twine

whisker fully supports importing Twine stories:

### From Twine 2

1. In Twine: **Story Menu → Publish to File**
2. Save the HTML file
3. In whisker web editor: **File → Import → Select your HTML**
4. Your story is imported and ready to edit or play!

### Supported Features

whisker converts these Twine features automatically:

- **Passages and links**
- **Variables** (`$variable` in Harlowe/SugarCube, `{variable}` in Chapbook)
- **Conditionals** (if/else statements)
- **Basic macros** (set, if, link, etc.)

### Format Notes

- **Harlowe**: Most common Twine format, fully supported
- **SugarCube**: Advanced features like `<<script>>` supported
- **Chapbook**: Modifiers and inserts converted
- **Snowman**: JavaScript-based format, basic support

## Advanced Features

### Save/Load System

Stories automatically support:
- **Multiple save slots**
- **Autosave** on each choice
- **Undo** to go back

Players access these via the web interface or commands.

### Custom Styling

In HTML exports, add CSS to customize appearance:

```html
<style>
  body {
    background: #2c3e50;
    color: #ecf0f1;
    font-family: Georgia, serif;
  }
  .passage {
    max-width: 600px;
    margin: 0 auto;
  }
</style>
```

### Sound and Images

Reference media files in your passages:

```
![A dark cave](images/cave.jpg)

You hear a distant sound...
<audio src="sounds/growl.mp3" autoplay>
```

## Example Stories

whisker includes several example stories to learn from:

- **`stories/examples/simple_story.lua`** - Basic cave exploration
- **`stories/examples/tutorial_story.lua`** - Interactive tutorial
- **`stories/examples/adventure_game.lua`** - Full RPG with inventory and combat

Open these in the web editor or run them directly to see how they work.

## Tips for Great Stories

### Writing

- **Start strong**: Hook readers immediately
- **Show, don't tell**: "You hear footsteps" not "You're scared"
- **Meaningful choices**: Decisions should matter

### Design

- **Branch and merge**: Not every choice needs a completely different path
- **Multiple endings**: Give players reasons to replay
- **Consequences**: Reference earlier choices in later passages

### Polish

- **Proofread**: Typos break immersion
- **Playtest**: Watch someone else play
- **Iterate**: First draft is never final

## Getting Help

- **Documentation**: See `docs/` folder for detailed guides
- **Examples**: Study the included example stories
- **Community**: Check the [GitHub Issues](https://github.com/jmspring/whisker/issues) for help

## Next Steps

Once you're comfortable with basic stories:

1. **Read the full documentation**: `docs/README.md`
2. **Try advanced features**: Variables, conditions, custom functions
3. **Explore the examples**: Learn from complete games
4. **Share your stories**: Export and publish!

---

**Ready to create?** Open `publisher/web/index.html` and start writing your first interactive story!
