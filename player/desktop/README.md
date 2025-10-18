# Whisker Desktop Runtime Example

Native desktop application built with LÖVE2D game framework.

## 🚀 Running the Example

### Quick Start

```bash
# Navigate to the example directory
cd examples/desktop_runtime

# Run with LÖVE
love .
```

### Alternative Methods

```bash
# From project root
love examples/desktop_runtime

# macOS
open -a love examples/desktop_runtime

# Windows (if LÖVE is in PATH)
"C:\Program Files\LOVE\love.exe" examples/desktop_runtime
```

## 📋 Requirements

### LÖVE2D Framework

Download and install LÖVE 11.3 or higher:
- **Website**: https://love2d.org/
- **Windows**: Download `.exe` installer
- **macOS**: Download `.dmg` or use `brew install love`
- **Linux**: `sudo apt install love` (Ubuntu/Debian) or check your package manager

### System Requirements

- **OS**: Windows 7+, macOS 10.9+, Linux
- **RAM**: 512MB minimum
- **Graphics**: Any GPU with OpenGL 2.1+ support
- **Disk**: ~5MB for runtime + story files

## 🎮 Controls

### Mouse
- **Click** - Select choices
- **Hover** - Highlight choices with animation
- **Scroll Wheel** - Scroll through long passages

### Keyboard Shortcuts

#### Game Controls
- `F5` - Quick Save (Slot 1)
- `F9` - Quick Load (Slot 1)
- `Ctrl+Z` - Undo last choice
- `Ctrl+R` - Restart story

#### Navigation
- `Arrow Up/Down` - Scroll passage
- `Page Up/Down` - Fast scroll
- `Home` - Jump to top
- `End` - Jump to bottom

#### UI Controls
- `F1` - Open Settings modal
- `Tab` - Toggle sidebar visibility
- `ESC` - Quit application

## ✨ Features

### Visual Design
- 🎨 **Multiple Themes**: Default (purple), Dark, Sepia
- 🖼️ **Responsive Layout**: Adapts to window size
- ✨ **Smooth Animations**: Fade effects and transitions
- 🎯 **Hover Effects**: Interactive button feedback
- 📊 **Live Stats Sidebar**: Real-time variable tracking

### Gameplay
- 💾 **Save System**: 5 save slots with timestamps
- 📜 **Passage History**: Track your journey
- 📈 **Progress Bar**: Visual completion indicator
- ↩️ **Undo System**: Take back choices
- 🔄 **Quick Save/Load**: One-key save/load

### Window Features
- 📏 **Resizable Window**: Drag to resize (800x600 minimum)
- 🎯 **Centered UI**: Content centers automatically
- 📱 **Responsive**: Works from 800px to 4K+
- 🖱️ **Smooth Scrolling**: Mouse wheel and keyboard

## 🎨 Themes

### Default Theme
- Purple gradient header (#667eea → #764ba2)
- Clean white background
- High contrast for readability

### Dark Theme
- Dark background (#1a1a1a)
- Light text (#e0e0e0)
- Reduced eye strain for night use

### Sepia Theme
- Warm, book-like colors
- Beige background (#f4ecd8)
- Easy on the eyes for long reading

**Change theme**: Press `F1` for settings or edit `main.lua`:
```lua
runtime = DesktopRuntime:new({
    theme = "dark"  -- "default", "dark", or "sepia"
})
```

## 📁 File Structure

```
examples/desktop_runtime/
├── main.lua      # Main application file
├── conf.lua      # LÖVE configuration
├── story.json    # Optional custom story (auto-loaded if present)
└── README.md     # This file
```

## 🎯 Customization

### Using Your Own Story

**Option 1**: Place `story.json` in this directory
```json
{
    "title": "My Story",
    "variables": {"health": 100},
    "start": "first",
    "passages": [...]
}
```

The app will automatically load it on startup.

**Option 2**: Edit `main.lua` and modify `DEFAULT_STORY`

### Changing Settings

Edit `main.lua`:

```lua
runtime = DesktopRuntime:new({
    width = 1280,        -- Window width
    height = 720,        -- Window height
    theme = "default",   -- Color theme
    font_size = 20,      -- Base font size
    debug = false        -- Debug mode
})
```

### Window Configuration

Edit `conf.lua`:

```lua
t.window.width = 1920    -- Starting width
t.window.height = 1080   -- Starting height
t.window.minwidth = 800  -- Minimum width
t.window.minheight = 600 -- Minimum height
```

## 🐛 Troubleshooting

### LÖVE not found

**Problem**: `love: command not found`

**Solution**: 
1. Install LÖVE from https://love2d.org/
2. Add LÖVE to your PATH
3. Or use full path to LÖVE executable

### "No game" error

**Problem**: LÖVE can't find `main.lua`

**Solution**: 
```bash
# Make sure you're in the right directory
cd examples/desktop_runtime
love .

# Or specify full path
love /full/path/to/examples/desktop_runtime
```

### Module not found errors

**Problem**: Can't find `src.core.engine` or similar

**Solution**: 
- Run from the `examples/desktop_runtime` directory
- OR ensure package paths are set correctly in `main.lua`

### Fonts not loading

**Problem**: Text not displaying or wrong fonts

**Solution**:
- Update to LÖVE 11.3 or higher
- Check console for font loading errors
- Verify `fonts` directory exists (auto-created)

### Save files not working

**Problem**: Can't save or load games

**Solution**:
- Check LÖVE save directory: `love.filesystem.getSaveDirectory()`
- On macOS: `~/Library/Application Support/LOVE/whisker/`
- On Windows: `%APPDATA%\LOVE\whisker\`
- On Linux: `~/.local/share/love/whisker/`

### Low performance

**Problem**: Slow or laggy

**Solution**:
1. Update graphics drivers
2. Enable VSync in `conf.lua`: `t.window.vsync = 1`
3. Reduce window size
4. Close other applications

## 💡 Tips & Tricks

### Development
1. **Live Reload**: Edit `main.lua` and restart (future: hot reload)
2. **Debug Mode**: Set `debug = true` for console output
3. **Console**: Run LÖVE from terminal to see print statements

### Gameplay
1. **Quick Save Often**: F5 saves to slot 1 instantly
2. **Explore Fully**: Use undo to try different paths
3. **Read Sidebar**: Stats show important variables
4. **Check History**: See where you've been

### Distribution
1. **Create .love file**: `zip -r game.love .` (from this directory)
2. **Bundle executable**: See LÖVE docs for platform-specific
3. **Include story**: Embed story.json in the package

## 📦 Packaging for Distribution

### Create a .love file

```bash
# From examples/desktop_runtime directory
zip -r MyStory.love .

# Run the .love file
love MyStory.love
```

### Platform-Specific Executables

See LÖVE documentation:
- **Windows**: https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable
- **macOS**: https://love2d.org/wiki/Game_Distribution#Creating_a_macOS_Application
- **Linux**: https://love2d.org/wiki/Game_Distribution#Linux

## 🎯 Next Steps

### Customize the UI

Edit colors, fonts, and layout in `desktop_runtime.lua`:

```lua
-- Change colors
self.colors.background = {1, 1, 1}  -- RGB values
self.colors.text = {0, 0, 0}

-- Change fonts
self.font_size = 24  -- Larger text
```

### Add Features

Ideas for enhancements:
- 🎵 Background music
- 🔊 Sound effects for choices
- 🖼️ Image support for passages
- 🎬 Transition effects
- 📊 Achievement system
- 🗺️ Story map view

### Create Your Story

1. Write story in JSON format
2. Place as `story.json` in this directory
3. Run with `love .`
4. Test and iterate

## 📚 Learn More

- [LÖVE Documentation](https://love2d.org/wiki/Main_Page)
- [Whisker Runtime Docs](../../src/runtime/README.md)
- [Story Format Guide](../../docs/FORMAT_REFERENCE.md)
- [API Reference](../../docs/API_REFERENCE.md)

## 🤝 Contributing

Ideas for improvements:
- More themes and customization
- Better animations
- Achievement system
- Statistics tracking
- Story map visualization
- Multiple story selection

---

**Happy game development! 🎮✨**