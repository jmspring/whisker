# whisker 🎮

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/lua-5.1%2B-purple.svg)](https://www.lua.org/)

**whisker** is a powerful, flexible interactive fiction engine written in Lua. Create text-based games, visual novels, and branching narratives with an easy-to-use scripting system - inspired by Twine, but built with Lua's power and flexibility.

## ✨ What is Whisker?

Whisker is a complete interactive fiction engine that allows you to create choice-based stories, text adventures, and narrative games. Whether you're a writer wanting to create branching stories, a game developer prototyping dialogue systems, or an educator building interactive learning materials, whisker provides the tools you need.

### Key Features

- 🎮 **Full-Featured Engine** - Complete story system with passages, choices, and variables
- 📝 **Lua Scripting** - Powerful scripting for complex game mechanics and logic
- 🔄 **Twine Compatible** - Import and export stories from Twine (Harlowe, SugarCube, Chapbook, Snowman)
- 🌐 **Multi-Platform** - Run on console, web browsers, and desktop
- 💾 **Save System** - Multiple save slots with autosave support
- 🐛 **Development Tools** - Built-in debugger, profiler, and validator
- 📱 **Responsive Web UI** - Beautiful HTML5 player included
- 🎨 **Highly Customizable** - Extensive configuration and theming options
- 📦 **No Dependencies** - Pure Lua implementation, batteries included
- ⚡ **Compact Format** - 20-40% smaller file sizes with full backward compatibility

## 🚀 Quick Start

### Prerequisites

- Lua 5.1 or higher ([installation instructions](docs/GETTING_STARTED.md#installing-lua))

### Installation

```bash
# Clone the repository
git clone https://github.com/jmspring/whisker.git
cd whisker

# Run an example story
lua main.lua examples/stories/simple_story.lua
```

### Your First Story

Create a file called `my_story.lua`:

```lua
local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

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

start:add_choice(Choice.new({
    text = "Go back to sleep",
    target = "sleep"
}))

story:add_passage(start)
story:set_start_passage("start")

return story
```

Run it:
```bash
lua main.lua my_story.lua
```

## 📚 Documentation

- **[Getting Started](docs/GETTING_STARTED.md)** - Complete installation guide and first story tutorial
- **[API Reference](docs/API_REFERENCE.md)** - Detailed API documentation
- **[Documentation Overview](docs/README.md)** - Full feature list and architecture guide
- **[Compact Format](docs/COMPACT_FORMAT.md)** - Optimized format with 20-40% size reduction
- **[Snowman Converter](docs/SNOWMAN_CONVERTER.md)** - Converting Twine Snowman stories
- **[Metatable Preservation](docs/METATABLE_PRESERVATION.md)** - Advanced Lua features

## 🎮 Examples

Whisker includes several example stories to help you learn:

### Simple Stories
- **[simple_story.lua](examples/stories/simple_story.lua)** - A minimal cave exploration story
- **[tutorial_story.lua](examples/stories/tutorial_story.lua)** - Learn whisker features interactively

### Complete Game
- **[adventure_game.lua](examples/stories/adventure_game.lua)** - Full RPG with inventory, combat, and quests

### Runtimes
- **[CLI Runtime](examples/cli_runtime/)** - Command-line interface
- **[Desktop Runtime](examples/desktop_runtime/)** - LÖVE2D desktop application
- **[Web Runtime](examples/web_runtime/)** - Browser-based player
- **[Web Demo](examples/web_demo.html)** - Single-file web example

Run any example:
```bash
lua main.lua examples/stories/simple_story.lua
```

Or try the web demo by opening `examples/web_demo.html` in your browser!

## 🛠️ Features in Depth

### Story Engine
- Passage-based narrative structure
- Dynamic choice generation
- Variable tracking and state management
- Conditional content and branching
- Script execution on passage enter/exit

### Twine Import/Export
- Import HTML stories from Twine
- Support for multiple formats: Harlowe, SugarCube, Chapbook, Snowman
- Convert between formats
- Export to JSON or whisker format
- Compact format (2.0) for 20-40% size reduction

### Development Tools
- **Validator** - Check story structure and find issues
- **Debugger** - Set breakpoints and inspect state
- **Profiler** - Measure performance and optimize
- **Console** - Interactive testing environment

### Runtime Options
- **CLI** - Terminal-based player for any platform
- **Web** - HTML5 player with responsive design
- **Desktop** - LÖVE2D integration for native apps

## 🏗️ Project Structure

```
whisker/
├── src/
│   ├── core/           # Story engine (passages, choices, state)
│   ├── format/         # Twine import/export and converters
│   ├── infrastructure/ # Save system, file handling, assets
│   ├── parser/         # Story file parsing
│   ├── runtime/        # Platform-specific runtimes
│   ├── tools/          # Developer tools (debugger, profiler, validator)
│   ├── ui/             # User interface components
│   └── utils/          # Utility functions
├── examples/           # Example stories and runtimes
│   ├── stories/        # Example story files
│   ├── cli_runtime/    # Command-line player
│   ├── desktop_runtime/# LÖVE2D desktop player
│   └── web_runtime/    # HTML5 web player
├── tests/              # Test suite and fixtures
├── docs/               # Documentation
├── main.lua            # Main entry point
└── config.lua          # Configuration file
```

## 🎯 Use Cases

- **Interactive Fiction** - Text adventures and choice-based games
- **Visual Novels** - Story-driven experiences with complex branching
- **Educational Tools** - Interactive tutorials and learning experiences
- **Game Prototyping** - Rapid dialogue and narrative system prototyping
- **Narrative Design** - Story structure visualization and testing

## 🧪 Command Line Interface

```bash
# Play a story
lua main.lua story.lua

# Validate story structure
lua main.lua --validate story.lua

# Convert from Twine HTML to JSON
lua main.lua --convert json story.html -o output.json

# Debug mode with breakpoints
lua main.lua --debug story.lua

# Performance profiling
lua main.lua --profile story.lua

# Show help
lua main.lua --help
```

## 🤝 Contributing

Contributions are welcome! Whether it's bug fixes, new features, documentation improvements, or example stories, we'd love your help.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Twine](https://twinery.org/) and its community
- Built with [Lua](https://www.lua.org/)
- Thanks to all contributors and users

## 📞 Support & Community

- **Documentation:** [docs/](docs/)
- **Examples:** [examples/](examples/)
- **Issues:** [GitHub Issues](https://github.com/jmspring/whisker/issues)

## 🗺️ Roadmap

- [x] Core story engine
- [x] Twine format compatibility
- [x] Multiple runtime environments
- [x] Development tools (debugger, profiler, validator)
- [x] Comprehensive test suite
- [x] Compact format (2.0) with size optimization
- [ ] Visual story editor (planned)
- [ ] Mobile runtime (planned)
- [ ] Plugin system (planned)
- [ ] Cloud save integration (planned)

---

**Start creating your interactive fiction today!** 🚀

For detailed documentation and tutorials, see the [docs](docs/) directory, especially:
- [Getting Started Guide](docs/GETTING_STARTED.md) - Your first story in 5 minutes
- [API Reference](docs/API_REFERENCE.md) - Complete API documentation
- [Full Documentation](docs/README.md) - Feature overview and architecture
