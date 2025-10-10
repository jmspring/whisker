# Whisker Runtime Layer

This directory contains platform-specific runtime implementations for playing Whisker interactive fiction stories.

## Overview

**Runtimes** provide the user interface and platform integration for Whisker stories. They use the core engine (`src/core/`) but add platform-specific features like rendering, input handling, and save/load interfaces.

## Available Runtimes

### 1. Web Runtime (`web_runtime.lua` + `web_runtime.css`)

Browser-based player using Lua-in-browser (Fengari or Lua.vm).

**Features:**
- ✅ Responsive web interface
- ✅ Save/load with localStorage
- ✅ Multiple themes (default, dark, light, sepia)
- ✅ Font size adjustment
- ✅ Keyboard shortcuts
- ✅ Mobile-friendly design
- ✅ Auto-save functionality

**Requirements:**
- Fengari (Lua 5.3 for browsers) or Lua.vm
- Modern web browser

**Usage:**
```lua
local WebRuntime = require('src.runtime.web_runtime')
local runtime = WebRuntime:new('whisker-container')

runtime:initialize()
runtime:load_story(story_data)
runtime:start_story()
```

**Deployment:**
Copy `web_runtime.css` to your web assets directory and include it in your HTML.

---

### 2. CLI Runtime (`cli_runtime.lua`)

Command-line interface for terminal-based play.

**Features:**
- ✅ ANSI color support
- ✅ Box-drawing characters
- ✅ Word wrapping
- ✅ Stats and history display
- ✅ Save/load to JSON files
- ✅ Keyboard commands
- ✅ Undo/restart support

**Requirements:**
- Standard Lua 5.1+
- Terminal with ANSI color support (most modern terminals)

**Usage:**
```lua
local CLIRuntime = require('src.runtime.cli_runtime')

local runtime = CLIRuntime:new({
    width = 80,           -- Terminal width
    colors = true,        -- Enable ANSI colors
    save_file = "save.json"
})

runtime:initialize()
runtime:load_story_from_file("story.json")
runtime:start()
runtime:run()  -- Starts game loop
```

**Commands:**
- `[number]` - Choose an option
- `help` or `?` - Show help
- `save` or `s` - Save game
- `load` or `l` - Load game
- `undo` or `u` - Undo last choice
- `restart` or `r` - Restart story
- `stats` - Toggle stats display
- `history` - Toggle history display
- `clear` - Clear and redraw screen
- `quit` or `q` - Exit

---

### 3. Desktop Runtime (`desktop_runtime.lua`)

Graphical desktop application using LÖVE2D.

**Features:**
- ✅ Native windowed interface
- ✅ Mouse and keyboard input
- ✅ Smooth animations
- ✅ Multiple themes
- ✅ Save/load with modal dialogs
- ✅ Sidebar with stats/history
- ✅ Scroll support
- ✅ Resizable window

**Requirements:**
- LÖVE2D 11.3+ (https://love2d.org/)
- Works on Windows, macOS, Linux

**Usage:**

Create a `main.lua` file in your LÖVE2D project:

```lua
local DesktopRuntime = require('src.runtime.desktop_runtime')
local runtime

function love.load()
    runtime = DesktopRuntime:new({
        width = 1280,
        height = 720,
        theme = "default",  -- "default", "dark", "sepia"
        font_size = 20
    })

    runtime:load()
    runtime:load_story_from_file("story.json")
    runtime:start()
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
```

**Keyboard Shortcuts:**
- `F1` - Settings
- `F5` - Quick save
- `F9` - Quick load
- `Ctrl+Z` - Undo
- `Ctrl+R` - Restart
- `Tab` - Toggle sidebar
- `Arrow Keys` - Scroll
- `Page Up/Down` - Fast scroll
- `Home/End` - Jump to top/bottom
- `ESC` - Quit

---

## Runtime Architecture

### Core vs Runtime

```
┌─────────────────────────────────────┐
│         Runtime Layer               │  Platform-specific
│  (web, CLI, desktop)                │  - UI/UX
│  - Input handling                   │  - Rendering
│  - Display/rendering                │  - Platform APIs
│  - Save/load UI                     │
├─────────────────────────────────────┤
│         Core Engine                 │  Platform-agnostic
│  (src/core/)                        │  - Story logic
│  - Story engine                     │  - State management
│  - Game state                       │  - Lua execution
│  - Lua interpreter                  │  - Choice processing
│  - Passage/choice logic             │
└─────────────────────────────────────┘
```

### Why Separate Runtimes?

1. **Platform Independence**: Core engine works everywhere
2. **UI Flexibility**: Different platforms need different interfaces
3. **Easy Distribution**: Package only what's needed for each platform
4. **Maintainability**: Changes to UI don't affect engine logic
5. **Extensibility**: Easy to add new platforms (mobile, VR, etc.)

## Creating a New Runtime

To create a runtime for a new platform:

1. **Inherit from base pattern:**
```lua
local NewRuntime = {}
NewRuntime.__index = NewRuntime

function NewRuntime:new(config)
    local instance = {
        engine = nil,
        config = config or {}
    }
    setmetatable(instance, self)
    return instance
end
```

2. **Initialize the engine:**
```lua
function NewRuntime:initialize()
    local Engine = require('src.core.engine')
    self.engine = Engine:new()
    self.engine:initialize()
    self:register_callbacks()
end
```

3. **Register callbacks:**
```lua
function NewRuntime:register_callbacks()
    self.engine:on("passage_entered", function(id)
        self:render_passage()
    end)
    -- etc.
end
```

4. **Implement platform-specific methods:**
- `render_passage()` - Display current passage
- `render_choices()` - Show available choices
- `handle_input()` - Process user input
- `save_game()` / `load_game()` - Persistence

5. **Process content:**
```lua
function NewRuntime:process_content(content)
    -- Replace {{variables}}
    content = content:gsub("{{([%w_]+)}}", function(var)
        return self.engine:get_variable(var) or ""
    end)

    -- Apply platform-specific formatting
    return content
end
```

## Runtime Comparison

| Feature | Web | CLI | Desktop |
|---------|-----|-----|---------|
| Graphics | ✅ Rich | ❌ Text-only | ✅ Rich |
| Colors | ✅ CSS | ✅ ANSI | ✅ Full RGB |
| Mouse | ✅ Yes | ❌ No | ✅ Yes |
| Keyboard | ✅ Yes | ✅ Yes | ✅ Yes |
| Themes | ✅ 4 themes | ⚠️ Colors only | ✅ 3 themes |
| Save/Load | ✅ localStorage | ✅ File | ✅ File |
| Distribution | ✅ URL | ✅ Script | ⚠️ Packaged |
| Dependencies | Fengari | None | LÖVE2D |
| File Size | ~500KB | ~50KB | ~2MB |
| Best For | Web sharing | Servers, scripts | Desktop apps |

## File Organization

```
whisker/
├── src/runtime/
│   ├── README.md                # This file
│   ├── web_runtime.lua         # Browser runtime
│   ├── web_runtime.css         # Web styles
│   ├── cli_runtime.lua         # Terminal runtime
│   └── desktop_runtime.lua     # LÖVE2D runtime
│
└── examples/                    # Top-level examples directory
    ├── cli_runtime/            # CLI runtime examples
    │   ├── run.lua
    │   └── story.json
    ├── desktop_runtime/        # LÖVE2D runtime examples
    │   ├── main.lua
    │   ├── conf.lua
    │   └── story.json
    └── web_runtime/            # Web runtime examples
        ├── index.html
        └── story.json
```

## Testing Runtimes

### Web Runtime
```bash
# Start a local web server from project root
python3 -m http.server 8000
# Open http://localhost:8000/examples/web_runtime/index.html
```

### CLI Runtime
```bash
# From project root
lua examples/cli_runtime/run.lua

# Or with a custom story
lua examples/cli_runtime/run.lua path/to/story.json
```

### Desktop Runtime
```bash
# From project root
cd examples/desktop_runtime/
love .
```

## Best Practices

1. **Keep runtimes thin** - Logic belongs in core engine
2. **Use engine callbacks** - Don't poll state
3. **Process content consistently** - Use `process_content()` method
4. **Handle all choice conditions** - Use `evaluate_choice_condition()`
5. **Implement save/load** - Use engine's `save_game()` / `load_game()`
6. **Support undo** - Call `engine:undo()`
7. **Theme support** - Make colors/styles configurable
8. **Error handling** - Gracefully handle engine errors

## Common Issues

### "Engine not initialized"
Make sure to call `engine:initialize()` before using it.

### "Passage not rendering"
Register the `passage_entered` callback and implement `render_passage()`.

### "Variables not updating"
Use `engine:get_variable()` not direct access to state.

### "Choices not working"
Check choice conditions with `evaluate_choice_condition()`.

## Future Runtimes

Potential platforms for future runtimes:

- **Mobile** (React Native + Lua bridge)
- **Voice** (Alexa/Google Home)
- **VR** (LÖVE with VR support)
- **Telegram Bot** (Chat-based play)
- **Discord Bot** (Server-based play)
- **Native GUI** (wxWidgets + Lua)

## Contributing

When adding a new runtime:

1. Follow the existing patterns
2. Document all configuration options
3. Provide usage examples
4. Test with multiple stories
5. Add to this README
6. Create example project

## License

See project LICENSE file.