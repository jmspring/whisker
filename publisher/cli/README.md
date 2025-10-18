# Whisker CLI Runtime Example

Terminal-based interactive fiction player with ANSI colors and box-drawing characters.

## 🚀 Running the Example

### From Project Root

```bash
lua examples/cli_runtime/run.lua
```

### With Your Own Story

```bash
lua examples/cli_runtime/run.lua path/to/your_story.json
```

## 📋 Requirements

- **Lua**: Version 5.1 or higher
- **Terminal**: Any terminal with ANSI color support
  - ✅ macOS Terminal
  - ✅ iTerm2
  - ✅ Linux terminals (GNOME Terminal, Konsole, etc.)
  - ✅ Windows Terminal
  - ✅ WSL
  - ⚠️ Old Windows CMD (limited color support)

## 🎮 Controls

### Navigation
- `[number]` - Select a choice by number (e.g., type `1` and press Enter)
- Enter your choice and press `Enter`

### Game Commands
- `help` or `?` - Show command list
- `save` or `s` - Save your game
- `load` or `l` - Load saved game
- `undo` or `u` - Undo last choice
- `restart` or `r` - Restart the story
- `quit` or `q` - Exit the game

### Display Commands
- `stats` - Toggle statistics display on/off
- `history` - Toggle passage history display on/off
- `clear` or `cls` - Clear screen and redraw

## ✨ Features

### Visual Elements
- 🎨 **ANSI Colors**: Colored text for better readability
- 📦 **Box Drawing**: Pretty borders and separators
- 📊 **Live Stats**: See your variables in real-time
- 📜 **History**: Track where you've been
- ✏️ **Markdown Support**: Bold text with `**text**`, italic with `*text*`

### Gameplay
- 💾 **Save/Load**: Save to JSON file, load anytime
- ↩️ **Undo**: Take back your last choice
- 🔄 **Restart**: Start over without reloading
- 📈 **Progress Tracking**: See your journey

### Formatting
- **Bold text** rendered in bright colors
- *Italic text* shown in dim colors
- Variable substitution with `{{variable}}`
- Automatic word wrapping to terminal width

## 🎨 Customization

Edit the configuration in `run.lua`:

```lua
local runtime = CLIRuntime:new({
    width = 80,              -- Terminal width (default: 80)
    colors = true,           -- Enable ANSI colors (default: true)
    save_file = "save.json", -- Save file location
    history_size = 10        -- History entries to show
})
```

### Disable Colors

If your terminal doesn't support colors:

```lua
local runtime = CLIRuntime:new({
    colors = false  -- Disables ANSI color codes
})
```

### Adjust Width

For wider terminals:

```lua
local runtime = CLIRuntime:new({
    width = 120  -- Wider text area
})
```

## 📖 Example Story

The included story "The Enchanted Forest" demonstrates:

- ✅ Variable tracking (health, gold, magic)
- ✅ Conditional choices based on stats
- ✅ Script execution for game logic
- ✅ Multiple paths and endings
- ✅ Rich narrative text

## 🐛 Troubleshooting

### "Module not found" error

**Problem**: Lua can't find the Whisker modules

**Solution**: Make sure you run from the project root:
```bash
# Wrong (from examples/cli_runtime/)
lua run.lua

# Correct (from project root)
lua examples/cli_runtime/run.lua
```

### Colors not showing

**Problem**: Terminal doesn't display colors

**Solution**: 
1. Try a modern terminal (Windows Terminal, iTerm2, etc.)
2. Or disable colors in the config: `colors = false`

### Text wrapping badly

**Problem**: Text doesn't fit your terminal width

**Solution**: Adjust the `width` setting to match your terminal:
```lua
local runtime = CLIRuntime:new({
    width = 100  -- Match your terminal columns
})
```

Find your terminal width with: `tput cols` (Unix/Linux/macOS)

### Save file permission errors

**Problem**: Can't write save file

**Solution**: 
1. Check file permissions in current directory
2. Or change save location:
```lua
save_file = "/full/path/to/save.json"
```

## 💡 Tips

1. **Use Tab Completion**: Some terminals support tab completion for commands
2. **Resize Window**: Increase terminal size for better experience
3. **Dark Theme**: Use a dark terminal theme for better readability
4. **Font Size**: Increase font size if text is too small
5. **Save Often**: Use quick save (`s`) to save your progress

## 🎯 Next Steps

### Modify the Story

Edit the `DEFAULT_STORY` in `run.lua` to change the narrative:

```lua
local DEFAULT_STORY = {
    title = "Your Story",
    variables = { health = 100 },
    start = "beginning",
    passages = {
        -- Add your passages here
    }
}
```

### Create Your Own Story

Create a `my_story.json` file:

```json
{
    "title": "My Adventure",
    "variables": {"health": 100},
    "start": "start",
    "passages": [
        {
            "id": "start",
            "title": "The Beginning",
            "content": "Your story begins...",
            "choices": [
                {"text": "Continue", "target": "next"}
            ]
        }
    ]
}
```

Then run:
```bash
lua examples/cli_runtime/run.lua my_story.json
```

## 📚 Learn More

- [Main README](../../README.md) - Project overview
- [Runtime Documentation](../../src/runtime/README.md) - All runtimes
- [Story Format](../../docs/FORMAT_REFERENCE.md) - Story specification
- [API Reference](../../docs/API_REFERENCE.md) - Engine API

## 🤝 Contributing

Improvements welcome!
- Better terminal detection
- More color schemes
- Enhanced formatting
- Platform-specific optimizations

---

**Enjoy your text adventures! 📖✨**