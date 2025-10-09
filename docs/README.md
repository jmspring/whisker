# whisker - Interactive Fiction Engine

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/whisker)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/lua-5.1%2B-purple.svg)](https://www.lua.org/)

**whisker** is a powerful, flexible interactive fiction engine written in Lua. Create text-based games, visual novels, and branching narratives with an easy-to-use scripting system.

## ✨ Features

- 🎮 **Full-Featured Engine** - Complete story system with passages, choices, and variables
- 📝 **Lua Scripting** - Powerful scripting for complex game mechanics
- 🔄 **Twine Compatible** - Import and export Twine stories (Harlowe, SugarCube, Chapbook)
- 🌐 **Multi-Platform** - Console, web, and desktop deployment
- 💾 **Save System** - Multiple save slots with autosave
- 🐛 **Development Tools** - Built-in debugger, profiler, and validator
- 📱 **Responsive Web UI** - Beautiful HTML5 player included
- 🎨 **Customizable** - Extensive configuration options

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/whisker.git
cd whisker

# Run a story
lua main.lua examples/simple_story.lua
```

### Create Your First Story

```lua
local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

local story = Story.new({
    title = "My First Story",
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

Save as `my_story.lua` and run:
```bash
lua main.lua my_story.lua
```

## 📚 Documentation

- **[Getting Started](GETTING_STARTED.md)** - Installation and first steps
- **[API Reference](API_REFERENCE.md)** - Complete API documentation
- **[Story Format](STORY_FORMAT.md)** - Story file format specification
- **[Twine Compatibility](TWINE_COMPATIBILITY.md)** - Import/export Twine stories
- **[Development Guide](DEVELOPMENT_GUIDE.md)** - Advanced development topics

## 🎮 Examples

### Simple Story
```bash
lua main.lua examples/simple_story.lua
```
A minimal cave exploration with multiple endings.

### Adventure Game
```bash
lua main.lua examples/adventure_game.lua
```
Full-featured RPG with inventory, combat, and quests.

### Interactive Tutorial
```bash
lua main.lua examples/tutorial_story.lua
```
Learn whisker features by playing.

### Web Demo
```bash
open examples/web_demo.html
```
Beautiful web interface - no server required!

## 🛠️ Command-Line Interface

```bash
# Play a story
lua main.lua story.lua

# Validate story structure
lua main.lua --validate story.lua

# Convert formats
lua main.lua --convert json story.html -o story.json

# Debug mode
lua main.lua --debug story.lua

# Performance profiling
lua main.lua --profile story.lua

# Show help
lua main.lua --help
```

## 🏗️ Architecture

```
whisker/
├── src/
│   ├── core/          # Story engine
│   ├── format/        # Import/export
│   ├── parser/        # Story parsing
│   ├── platform/      # Platform support
│   ├── runtime/       # Lua interpreter
│   ├── system/        # Save system
│   ├── tools/         # Dev tools
│   ├── ui/            # User interface
│   └── utils/         # Utilities
├── examples/          # Example stories
├── tests/             # Test suite
└── docs/              # Documentation
```

## 📖 Core Concepts

### Stories
A story is a collection of passages connected by choices.

### Passages
Individual scenes or moments in your narrative.

### Choices
Links between passages that players select.

### Variables
Track game state, inventory, stats, and player progress.

### Scripting
Use Lua code for complex game mechanics and logic.

## 🎯 Use Cases

- **Interactive Fiction** - Text adventures and choice-based games
- **Visual Novels** - Story-driven experiences with branching paths
- **Educational Tools** - Interactive tutorials and learning materials
- **Game Prototyping** - Rapid story and dialogue prototyping
- **Narrative Design** - Story structure and flow visualization

## 🧪 Testing

```bash
# Run all tests
lua tests/test_all.lua

# Run specific test
lua tests/test_story.lua
```

## 📦 Dependencies

- **Lua 5.1+** - Core language
- **No external dependencies** - Batteries included!

Optional for web:
- Modern web browser with JavaScript enabled

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Twine](https://twinery.org/)
- Built with [Lua](https://www.lua.org/)
- Community contributions and feedback

## 📞 Support

- **Documentation:** [docs/](.)
- **Examples:** [examples/](../examples/)
- **Issues:** [GitHub Issues](https://github.com/yourusername/whisker/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/whisker/discussions)

## 🗺️ Roadmap

- [x] Core engine
- [x] Twine compatibility
- [x] Web runtime
- [x] Development tools
- [ ] Visual editor (planned)
- [ ] Mobile apps (planned)
- [ ] Plugin system (planned)
- [ ] Cloud saves (planned)

## 📊 Project Status

- **Version:** 1.0.0
- **Status:** Production Ready
- **Test Coverage:** 80%+
- **Documentation:** Complete

## 💖 Community

Join our growing community of interactive fiction creators!

- Share your stories
- Get help and feedback
- Contribute to development
- Learn from others

---

**Start creating your interactive fiction today!** 🚀

For detailed documentation, see the [docs](.) directory.
