# whisker 🎮

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/lua-5.1%2B-purple.svg)](https://www.lua.org/)

**Create interactive fiction and choice-based stories.** whisker helps you write branching narratives that run anywhere - in web browsers, on the command line, or as desktop apps.

## ✨ For Story Authors

**You don't need to be a programmer to use whisker.** Create stories using:

- 🌐 **Web Editor** - Visual story editor (just open in your browser)
- 🎨 **Twine Import** - Write in [Twine](https://twinery.org), export to whisker
- 📝 **Simple Text Format** - Easy-to-learn story syntax

**Export as standalone HTML** - Share a single file that readers can open in any browser. No installation needed.

### Quick Start for Authors

**Option 1: Use the Web Editor**

1. Open `player/web/index.html` in your browser
2. Create passages and add choices
3. Click "Play" to test
4. Export as standalone HTML to share!

**Option 2: Write in Twine**

1. Create your story in [Twine](https://twinery.org) (Harlowe, SugarCube, Chapbook, or Snowman)
2. Export as HTML
3. Import into whisker
4. Export as standalone HTML or play directly

📖 **[Complete Authoring Guide](AUTHORING.md)** - Learn how to create your first story

## 🛠️ For Developers

whisker is a full-featured interactive fiction engine built in Lua:

- 📦 **Pure Lua** - No dependencies, runs anywhere Lua runs
- 🔧 **Embeddable** - Integrate into your games or applications
- 🐛 **Developer Tools** - Built-in debugger, profiler, and validator
- ⚡ **Efficient** - Compact story format (20-40% smaller files)
- 🧪 **Well-tested** - Comprehensive test suite

📖 **[Developer Documentation](docs/README.md)** - API reference and architecture guide

## 🚀 Features

### Story Creation
- Visual web editor
- Full Twine compatibility (Harlowe, SugarCube, Chapbook, Snowman)
- Variables and conditional logic
- Multiple story endings
- Save/load system with multiple slots

### Publishing
- Export as standalone HTML (single file, works offline)
- Web player with responsive design
- Command-line player for terminal
- Desktop player with LÖVE2D

### Development
- Lua scripting for complex game mechanics
- Built-in validator to check story structure
- Performance profiler
- Interactive debugger
- Event system for custom behavior

## 📚 Documentation

### For Authors (Non-Programmers)
- **[Authoring Guide](AUTHORING.md)** - Create your first story
- **[Example Stories](stories/examples/)** - Learn from working examples

### For Developers
- **[API Reference](docs/API_REFERENCE.md)** - Complete API documentation
- **[Architecture Guide](docs/README.md)** - Engine internals
- **[Getting Started](docs/GETTING_STARTED.md)** - Installation and setup
- **[Compact Format](docs/COMPACT_FORMAT.md)** - Optimized story format

## 🎮 Try It Now

### Run an Example Story

**Web Browser** (easiest):
1. Open `player/web/index.html`
2. Load an example story from `stories/examples/`
3. Start playing!

**Command Line** (requires Lua):
```bash
# Install Lua 5.1+ (if not already installed)
# macOS: brew install lua
# Ubuntu: sudo apt-get install lua5.4
# Windows: https://www.lua.org/download.html

# Run an example
lua main.lua stories/examples/simple_story.lua
```

### Included Examples

- **simple_story.lua** - A short cave exploration (great for learning)
- **tutorial_story.lua** - Interactive tutorial teaching whisker features
- **adventure_game.lua** - Complete RPG with inventory, combat, and quests

## 🎯 Use Cases

- **Interactive Fiction** - Text adventures and choice-based narratives
- **Visual Novels** - Story-driven experiences with branching paths
- **Educational Content** - Interactive tutorials and learning experiences
- **Game Dialogue** - Rapid prototyping of conversation systems
- **Narrative Design** - Story structure visualization and testing

## 🏗️ Project Structure

```
whisker/
├── player/              # Story players (web, CLI, desktop)
│   ├── web/            # Browser-based player + editor
│   ├── cli/            # Command-line player
│   └── desktop/        # LÖVE2D desktop player
├── stories/            # Example stories and templates
│   ├── examples/       # Complete example stories
│   └── templates/      # Story templates to start from
├── engine/             # whisker engine (Lua)
│   ├── core/          # Story runtime
│   ├── format/        # Twine import/export
│   └── tools/         # Debugger, profiler, validator
├── tests/             # Test suite
├── docs/              # Documentation
├── AUTHORING.md       # Guide for story authors
├── README.md          # This file
└── main.lua           # CLI entry point
```

## 🌐 Twine Compatibility

Import and export Twine stories with full support for:

| Format | Import | Export | Notes |
|--------|--------|--------|-------|
| **Harlowe** | ✅ | ✅ | Most popular Twine format |
| **SugarCube** | ✅ | ✅ | Advanced scripting support |
| **Chapbook** | ✅ | ✅ | Modern, minimalist format |
| **Snowman** | ✅ | ✅ | JavaScript-based format |

**Converted features:**
- Passages and links
- Variables and state
- Conditional text
- Macros and commands
- Metadata and tags

## 📖 Creating Your First Story

### For Non-Programmers

See the **[Authoring Guide](AUTHORING.md)** for a complete tutorial. Here's the quick version:

1. **Open the web editor**: `player/web/index.html`
2. **Create a passage**:
   ```
   :: Start
   You stand at a crossroads.

   [[Go left->Left Path]]
   [[Go right->Right Path]]
   ```

3. **Add more passages**:
   ```
   :: Left Path
   The left path leads to a forest.

   [[Continue->Forest]]
   ```

4. **Export** as standalone HTML and share!

### For Programmers

Create stories in Lua with full programmatic control:

```lua
local Story = require("engine.core.story")
local Passage = require("engine.core.passage")
local Choice = require("engine.core.choice")

local story = Story.new({
    title = "My First Adventure",
    author = "Your Name"
})

local start = Passage.new({
    id = "start",
    content = "You wake up in a strange place. What do you do?"
})

start:add_choice(Choice.new({
    text = "Look around",
    target = "look_around"
}))

story:add_passage(start)
story:set_start_passage("start")

return story
```

Run it:
```bash
lua main.lua my_story.lua
```

## 🧰 Command Line Interface

```bash
# Play a story
lua main.lua story.lua

# Import Twine HTML and play
lua main.lua story.html

# Validate story structure
lua main.lua --validate story.lua

# Convert formats
lua main.lua --convert json story.html -o output.json

# Debug mode
lua main.lua --debug story.lua

# Performance profiling
lua main.lua --profile story.lua

# Show help
lua main.lua --help
```

## 🤝 Contributing

Contributions welcome! Whether you're:
- **Authors**: Share example stories or templates
- **Developers**: Bug fixes, features, or optimizations
- **Designers**: UI improvements or themes
- **Writers**: Documentation improvements

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Twine](https://twinery.org/) and its community
- Built with [Lua](https://www.lua.org/)
- Thanks to all contributors and users

## 📞 Support

- **Documentation:** [docs/](docs/) and [AUTHORING.md](AUTHORING.md)
- **Examples:** [stories/examples/](stories/examples/)
- **Issues:** [GitHub Issues](https://github.com/jmspring/whisker/issues)

## 🗺️ Roadmap

- [x] Core story engine
- [x] Web player and editor
- [x] Twine import/export (all major formats)
- [x] Multiple platforms (web, CLI, desktop)
- [x] Developer tools (debugger, profiler, validator)
- [x] Comprehensive test suite
- [x] Compact format for smaller files
- [ ] Enhanced web editor (visual node graph)
- [ ] Mobile player app
- [ ] Plugin system
- [ ] Cloud save integration

---

**Start creating interactive stories today!** 🚀

- **Authors**: Open `player/web/index.html` or read the [Authoring Guide](AUTHORING.md)
- **Developers**: See the [Getting Started Guide](docs/GETTING_STARTED.md) and [API Reference](docs/API_REFERENCE.md)
