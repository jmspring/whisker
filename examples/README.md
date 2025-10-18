# Whisker Runtime Examples

This directory contains working examples for each Whisker runtime platform.

## 📁 Directory Structure

```
examples/
├── README.md                    # This file
├── web_demo.html               # Standalone web demo (no server needed!)
│
├── stories/                    # Example story files
│   ├── simple_story.lua       # Minimal cave exploration
│   ├── adventure_game.lua     # Full RPG with combat & items
│   └── tutorial_story.lua     # Interactive tutorial
│
├── cli_runtime/               # Command-line terminal interface
│   ├── run.lua               # Main CLI example
│   └── README.md             # CLI-specific instructions
│
├── desktop_runtime/          # LÖVE2D desktop application
│   ├── main.lua             # Main LÖVE2D file
│   ├── conf.lua             # LÖVE2D configuration
│   └── README.md            # Desktop-specific instructions
│
└── web_runtime/             # Browser-based web player
    ├── index.html          # Complete web demo
    └── README.md           # Web-specific instructions
```

## 🚀 Quick Start

### Standalone Web Demo (Easiest!)

The quickest way to see Whisker in action:

```bash
# Simply open in your browser - no server needed!
open examples/web_demo.html

# Or double-click the file in your file manager
```

**What you'll see:**
- Beautiful, feature-complete web interface with **"The Enchanted Forest"** story
- Sidebar with stats (health, gold) and history
- Save/load to browser localStorage (5 slots)
- Undo functionality with keyboard shortcuts
- Responsive design that works on mobile

**Keyboard Shortcuts:**
- `Ctrl+S` - Save game
- `Ctrl+Z` - Undo last action
- `Ctrl+L` - Load game

This is a great starting point to understand how Whisker stories work!

---

### CLI Runtime (Terminal)

```bash
# From project root - plays the default story
lua publisher/cli/run.lua

# Or play one of the example stories
lua publisher/cli/run.lua stories/examples/simple_story.lua
lua publisher/cli/run.lua stories/examples/adventure_game.lua
lua publisher/cli/run.lua stories/examples/tutorial_story.lua

# Or with your own story
lua publisher/cli/run.lua path/to/story.json
```

**Requirements:**
- Lua 5.1 or higher
- Terminal with ANSI color support (most modern terminals)

**Features:**
- ✅ Colored text output
- ✅ Box-drawing characters
- ✅ Stats and history sidebar
- ✅ Save/load to JSON
- ✅ Full keyboard commands

---

### Desktop Runtime (LÖVE2D)

```bash
# From project root
cd publisher/desktop
love .

# Or on macOS
open -a love publisher/desktop
```

**Requirements:**
- LÖVE2D 11.3+ ([download here](https://love2d.org/))

**Features:**
- ✅ Native windowed GUI
- ✅ Mouse and keyboard input
- ✅ Beautiful themes (default, dark, sepia)
- ✅ Smooth animations
- ✅ Modal dialogs
- ✅ Resizable window

**Keyboard Shortcuts:**
- `F1` - Settings
- `F5` - Quick Save
- `F9` - Quick Load
- `Ctrl+Z` - Undo
- `Ctrl+R` - Restart
- `Tab` - Toggle Sidebar
- `ESC` - Quit

---

### Web Runtime (Browser)

```bash
# From project root, start a web server
python3 -m http.server 8000

# Then open in browser:
# http://localhost:8000/publisher/web/index.html
```

**Requirements:**
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Local web server (or just open the file directly in some browsers)

**Features:**
- ✅ Responsive design
- ✅ Mobile-friendly
- ✅ LocalStorage save/load
- ✅ Multiple themes
- ✅ Keyboard shortcuts
- ✅ Progress tracking

**Keyboard Shortcuts:**
- `Ctrl+S` - Save
- `Ctrl+L` - Load
- `Ctrl+Z` - Undo

---

## 📚 Example Stories

The `stories/` directory contains three example stories demonstrating different aspects of Whisker:

### 1. simple_story.lua - Minimal Example
A basic cave exploration story perfect for beginners.

**Demonstrates:**
- Basic story structure with passages and choices
- Simple branching narrative
- Multiple endings (3 different outcomes)
- Clean, readable code

**Play time:** ~2 minutes

```bash
lua publisher/cli/run.lua stories/examples/simple_story.lua
```

### 2. adventure_game.lua - Full-Featured RPG
A complete fantasy adventure with all Whisker features.

**Demonstrates:**
- Complex variable management (health, gold, inventory)
- Conditional choices based on items and stats
- Lua scripting for game logic
- Multiple interconnected locations
- Combat and item systems
- 5+ different endings

**Story:** Defeat a dragon terrorizing a village. Visit the blacksmith, wizard, explore ruins, and face the dragon!

**Play time:** ~10-15 minutes

```bash
lua publisher/cli/run.lua stories/examples/adventure_game.lua
```

### 3. tutorial_story.lua - Interactive Tutorial
Learn Whisker by playing! An interactive guide covering all features.

**Covers:**
- Lesson 1: Basic story structure
- Lesson 2: Variables and state management
- Lesson 3: Conditional choices
- Lesson 4: Lua scripting and randomness

**Perfect for:** New users, understanding features, teaching examples

**Play time:** ~5-10 minutes

```bash
lua publisher/cli/run.lua stories/examples/tutorial_story.lua
```

---

## 🌐 Web Demo

The standalone `web_demo.html` file contains **"The Enchanted Forest"** - a polished adventure demonstrating production-quality Whisker implementation:

**Story Features:**
- ✨ Variable tracking (health, gold, hasKey)
- 🎯 Conditional choices and gated content
- 📜 Scripted events with on_enter and action scripts
- 🎲 Multiple paths (explore, search, take risks)
- 💾 Save/load to browser localStorage (5 save slots)
- ↩️ Full undo functionality
- 📊 Progress tracking and statistics sidebar

**UI Features:**
- Responsive design (desktop & mobile)
- Beautiful gradient theme with animations
- Stats sidebar showing current variables
- History log of visited passages
- Modal dialogs for save/load
- Keyboard shortcuts for power users
- LocalStorage persistence

**Story:** Explore an enchanted forest, meet a fairy who offers a golden key, find treasures, and unlock ancient secrets!

## 🎮 Playing the Examples

### Recommended Learning Path

1. **Start with web_demo.html** - Get a feel for Whisker stories with the best UI
2. **Read simple_story.lua** - Understand basic story structure
3. **Play tutorial_story.lua** - Learn all features interactively
4. **Study adventure_game.lua** - See advanced techniques
5. **Try the runtimes** - Explore CLI and desktop implementations
6. **Create your own!** - Use the stories as templates

### Gameplay Tips for Adventure Stories

- 🔍 Search thoroughly to find gold and items
- 🧘 Manage your resources (health, gold, inventory)
- 💡 Read carefully - hints are in the descriptions
- 🤝 Be kind to NPCs for rewards
- 💰 Save gold for important purchases
- 🎲 Try different paths to discover all endings

## 🛠️ Customizing Examples

### Using Your Own Story

All examples support loading custom stories:

**CLI:**
```bash
lua publisher/cli/run.lua my_story.lua  # Lua format
lua publisher/cli/run.lua my_story.json  # JSON format
```

**Desktop:**
Place your story file in `publisher/desktop/` directory and update the story path in `main.lua`

**Web Runtime:**
Edit the `STORY_DATA` constant in `publisher/web/index.html`

**Standalone Web Demo:**
Edit the `demoStory` object in `examples/web_demo.html` (around line 300)

**Using Example Stories as Templates:**
The stories in `stories/examples/` are great starting points. Copy one and modify it:
```bash
cp stories/examples/simple_story.lua my_story.lua
# Edit my_story.lua with your own content
lua publisher/cli/run.lua my_story.lua
```

### Story Format

Stories are JSON objects:

```json
{
    "title": "My Story",
    "author": "Your Name",
    "variables": {
        "health": 100,
        "score": 0
    },
    "start": "first_passage",
    "passages": [
        {
            "id": "first_passage",
            "title": "The Beginning",
            "content": "Your adventure starts here. Health: {{health}}",
            "script": "set('score', get('score') + 10)",
            "choices": [
                {
                    "text": "Continue",
                    "target": "next_passage",
                    "condition": "health > 50"
                }
            ]
        }
    ]
}
```

## 📚 Learning from Examples

### For Developers

Study the examples to learn:

1. **How to integrate Whisker engine** into your app
2. **How to process story content** (variables, markdown)
3. **How to implement save/load** systems
4. **How to create custom UIs** for stories
5. **How to handle user input** across platforms

### Code Locations

- **Engine integration**: See initialization code in each `main`/`run` file
- **Story loading**: Look for `load_story()` methods
- **Rendering**: Check `render()` / `draw()` functions
- **Save systems**: Find `save_game()` / `load_game()` implementations

## 🔧 Troubleshooting

### CLI Runtime Issues

**Problem**: Colors not showing
- **Solution**: Check terminal ANSI support or disable colors in config

**Problem**: "Module not found" error
- **Solution**: Run from project root, not from examples directory

### Desktop Runtime Issues

**Problem**: "No main.lua found"
- **Solution**: Run from inside `publisher/desktop/` or specify full path

**Problem**: Fonts not loading
- **Solution**: Update to LÖVE2D 11.3 or higher

### Web Runtime Issues

**Problem**: Page won't load
- **Solution**: Use a web server (not file:// protocol) or check browser console

**Problem**: CSS not applied
- **Solution**: Verify path to `../../lib/whisker/runtime/web_runtime.css` is correct

## 🎯 Next Steps

After trying the examples:

1. **Modify the story** - Edit the story data to see changes
2. **Create your own story** - Write a story.json file
3. **Customize the UI** - Change colors, fonts, layouts
4. **Add features** - Implement achievements, statistics, etc.
5. **Deploy your game** - Package for distribution

## 📖 Documentation

For more information:
- Main README: `../../README.md`
- Runtime docs: `../../lib/whisker/runtime/README.md`
- API Reference: `../../docs/API_REFERENCE.md`
- Story format: `../../docs/FORMAT_REFERENCE.md`

## 🤝 Contributing

Found a bug? Have an improvement?
- Open an issue on GitHub
- Submit a pull request
- Share your stories!

## 📝 License

See project LICENSE file.

---

**Happy storytelling! 🎭**
