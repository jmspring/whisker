# Whisker Story Editor

**A professional, web-based editor for creating interactive fiction stories.**

Version 1.0.0 - All Phases Complete ✅

---

## 🌟 Overview

Whisker Story Editor is a complete, production-ready tool for authoring interactive fiction. Create branching narratives with a visual graph editor, manage variables, validate your work, and export to multiple formats—all in your web browser.

---

## ✨ Key Features

### 📝 **Dual Editing Modes**
- **Graph View**: Visual node-based editing with drag-and-drop
- **List View**: Traditional form-based passage editing
- Switch seamlessly between views

### 🎨 **Rich Text Support**
- Markdown formatting (bold, italic, headings, lists, links)
- Format toolbar for quick styling
- Variable insertion `{{variableName}}`
- Live preview of your story

### 🔍 **Validation System**
- 8 automatic checks for errors
- Real-time issue detection
- Click to jump to problems
- Error, warning, and info levels

### ⏮️ **Undo/Redo**
- 50 levels of history
- Keyboard shortcuts (Ctrl+Z, Ctrl+Shift+Z)
- Full project state tracking
- Visual history indicator

### 📦 **Variables Manager**
- String, number, and boolean types
- Set initial values
- Insert with one click
- Used throughout your story

### 📤 **Multiple Export Formats**
- Whisker JSON (runtime)
- Standalone HTML (self-contained)
- Whisker Project (re-editable)
- Markdown (documentation)
- Twine HTML (import to Twine 2)

### 🎨 **5 Beautiful Themes**
- Dark (default)
- Light
- High Contrast
- Solarized Dark
- Nord

### 📎 **Asset Management**
- Upload images and audio
- Visual gallery
- Quick insert into content
- Embedded in project

### 📚 **Story Templates**
- Blank Story
- Simple Choice
- Complex Story
- Game Template (RPG)
- Quiz/Survey
- Interactive Tutorial

### ⚙️ **Comprehensive Settings**
- Auto-save configuration
- Editor preferences
- Graph behavior
- Advanced options

---

## 🚀 Quick Start

### Option 1: Start from Scratch
1. Open `index.html` in your browser
2. Click **"Create New Project"**
3. Enter your story title
4. Start writing passages

### Option 2: Use a Template
1. Open `index.html` in your browser
2. Click **"Choose Template"**
3. Select a template
4. Customize and expand

### Option 3: Open Existing Project
1. Open `index.html` in your browser
2. Click **"Open"**
3. Select your `.whisker` file
4. Continue editing

---

## 📖 Basic Usage

### Creating Passages

**In List View:**
1. Click **"+ Add"** in sidebar
2. Enter passage title
3. Write content in editor
4. Add choices with **"+ Add Choice"**

**In Graph View:**
1. Double-click empty space
2. Enter title
3. Connect passages by dragging connectors
4. Double-click node to edit

### Using Variables

1. Open **Variables panel** (right sidebar)
2. Click **"+ Add Variable"**
3. Enter name, type, and initial value
4. Insert into content with `{{variableName}}`

### Exporting Your Story

1. Click **"Export ▾"** in toolbar
2. Choose format (HTML recommended for sharing)
3. Configure options
4. Click **"Export"**
5. Share the downloaded file!

---

## 🎯 View Modes

### Graph View
Perfect for planning and visualizing story structure:
- Visual nodes for each passage
- Connection lines show choice paths
- Drag to rearrange
- Zoom and pan for large stories
- Auto-layout button for organization

### List View
Ideal for focused writing:
- Full passage editor
- Choice management
- Content formatting
- Variable insertion
- Preview panel

---

## 🎨 User Interface

### Toolbar
- New/Open/Save/Export buttons
- Theme selector
- Settings
- Undo/Redo with history counter

### Left Sidebar
- Passage list
- Quick passage switching
- Content preview
- Add passage button

### Main Panel
- View toggle (Graph/List)
- Passage editor
- Rich text toolbar
- Choice editor
- Validation panel

### Right Sidebars
- **Variables Panel**: Manage story variables
- **Preview Panel**: Test your story live

### Bottom Panel
- Status messages
- Passage count
- Validation status

---

## ⌨️ Keyboard Shortcuts

### Global
- `Ctrl/Cmd + Z` - Undo
- `Ctrl/Cmd + Shift + Z` or `Ctrl/Cmd + Y` - Redo
- `Escape` - Clear selection / close menus

### Graph View
- `Delete` or `Backspace` - Delete selected passages
- `Mouse Wheel` - Zoom
- `Click + Drag` - Pan canvas
- `Ctrl/Cmd + Click` - Multi-select

---

## 📦 File Formats

### .whisker (Project File)
Complete project with:
- All passages and content
- Variables and settings
- Node positions
- Metadata
- Assets (if any)

**Use for:** Saving and reopening projects

### .json (Whisker JSON)
Runtime-optimized story:
- Passages and choices
- Variables
- Settings
- No editor data

**Use for:** Web players, runtime deployment

### .html (Standalone)
Self-contained HTML file:
- Embedded story data
- Built-in player
- No dependencies
- Works offline

**Use for:** Sharing, email, hosting

### .md (Markdown)
Human-readable format:
- Passage structure
- Content and choices
- Documentation-friendly

**Use for:** Version control, review

### .html (Twine)
Twine 2 compatible:
- Harlowe format
- Import into Twine
- Continue editing there

**Use for:** Twine collaboration

---

## 🎓 Tutorials

### Tutorial 1: Your First Story (5 minutes)

1. **Create project**: Click "Create New Project"
2. **Edit start**: Modify the "Start" passage content
3. **Add choice**: Click "+ Add Choice"
4. **Create target**: Type new passage name, select "Create New Passage"
5. **Write ending**: Add content to new passage
6. **Preview**: Click "Restart" in preview panel
7. **Export**: Use Export menu → Standalone HTML

### Tutorial 2: Using Variables (10 minutes)

1. **Add variable**: Variables panel → "+ Add Variable"
2. **Name it**: e.g., "player_name"
3. **Set type**: Choose "string"
4. **Use it**: In content, type `{{player_name}}`
5. **Change value**: Update in Variables panel
6. **Preview**: See variable in preview

### Tutorial 3: Graph View (10 minutes)

1. **Switch view**: Click "Graph" button
2. **Arrange**: Drag nodes to organize
3. **Connect**: Click node connector, drag to target
4. **Auto-layout**: Click lightning bolt ⚡
5. **Zoom**: Mouse wheel or controls
6. **Edit**: Double-click node for List view

---

## 🔧 Settings Guide

### General Settings
- **Auto-save**: Automatically save periodically
- **Auto-save interval**: How often (seconds)
- **Confirm deletions**: Ask before deleting
- **Auto-validate**: Check for errors automatically
- **Live preview**: Update preview as you type

### Editor Settings
- **Font size**: 10-24px
- **Line height**: 1.0-2.5
- **Word wrap**: Wrap long lines

### Graph Settings
- **Auto-layout on open**: Arrange on project open
- **Snap to grid**: Align nodes to grid
- **Grid size**: 10-50px

### Advanced Settings
- **Max undo steps**: 10-100 levels
- **Debug mode**: Show console logs
- **Reset settings**: Restore defaults
- **Clear cache**: Remove all stored data

---

## 📚 Story Templates

### Blank Story
- Single start passage
- Perfect for starting from scratch

### Simple Choice
- 4 passages
- Basic branching
- 2 paths merging

### Complex Story
- 8 passages
- Multiple branches
- Loops and complexity

### Game Template
- 6 passages
- Variables (health, gold, items)
- RPG-style structure

### Quiz/Survey
- 5 passages
- Question format
- Score tracking

### Interactive Tutorial
- 6 passages
- Step-by-step
- Navigation structure

---

## 🎨 Themes

### Dark (Default)
Modern dark theme with blue accents

### Light
Clean bright theme for daytime

### High Contrast
Maximum accessibility, black and white

### Solarized Dark
Precision colors, reduced eye strain

### Nord
Arctic colors, cool and calming

**Change theme:** Click "🎨 Theme" in toolbar

---

## ✅ Validation Checks

The editor automatically checks for:

1. **Broken Links** ⛔ - Choices to non-existent passages
2. **Orphaned Passages** ⚠️ - Not linked from anywhere
3. **Empty Passages** ⚠️ - No content
4. **Undefined Variables** ⚠️ - Using `{{var}}` not defined
5. **Dead Ends** ℹ️ - Passages with no choices
6. **Circular References** ⚠️ - Links to self
7. **Duplicate IDs** ⛔ - Same ID used twice
8. **Missing Start** ⛔ - Invalid start passage

**Run validation:** Click "Validate" in validation panel

---

## 💡 Tips & Tricks

### Writing Tips
- Keep passages focused (2-3 paragraphs max)
- Use descriptive choice text
- Test frequently in preview
- Use variables for personalization

### Organization Tips
- Name passages descriptively
- Use graph view for structure
- Group related passages together
- Use auto-layout for cleanup

### Performance Tips
- Validate before exporting
- Keep assets small (< 1MB)
- Limit to ~500 passages per project
- Save frequently

### Workflow Tips
- Start with template
- Plan in graph view
- Write in list view
- Test in preview
- Export early and often

---

## 🐛 Troubleshooting

### Editor Won't Load
- Try a different browser (Chrome, Firefox, Edge recommended)
- Check JavaScript is enabled
- Clear browser cache
- Try incognito/private mode

### Can't Save/Open Projects
- Check file permissions
- Try different location
- Ensure .whisker extension
- Check file isn't corrupted

### Preview Not Working
- Check start passage exists
- Validate for broken links
- Restart preview
- Check browser console

### Export Fails
- Validate first
- Try different format
- Check file size
- Verify project has content

### Graph View Issues
- Try auto-layout
- Refresh browser
- Check passage positions
- Zoom to fit

---

## 📊 Project Limits

**Recommended:**
- Passages: Up to 500
- Variables: Up to 100
- Assets: Up to 20 files
- Asset size: < 1MB each
- Total project: < 50MB

**Technical:**
- Undo history: 50 levels
- Auto-save: Every 60 seconds (configurable)
- Validation: Real-time
- Export: Unlimited

---

## 🌐 Browser Support

### Fully Supported
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Edge 90+
- ✅ Safari 14+

### Requirements
- JavaScript enabled
- localStorage available
- Modern CSS support
- ES6+ JavaScript

---

## 📁 Project Structure

```
editor/web/
├── index.html           # Main application
├── css/
│   ├── editor.css       # Core styles
│   ├── graph.css        # Graph view
│   ├── variables.css    # Enhanced features
│   └── themes.css       # Theme system
├── js/
│   ├── editor.js        # Core editor
│   ├── graph.js         # Graph view
│   ├── variables.js     # Variables manager
│   ├── validation.js    # Validation system
│   ├── history.js       # Undo/redo
│   ├── templates.js     # Story templates
│   ├── export.js        # Export system
│   ├── theme.js         # Theme manager
│   ├── assets.js        # Asset manager
│   └── settings.js      # Settings manager
└── docs/
    ├── README.md        # This file
    ├── PHASE3_FEATURES.md
    └── PHASE4_COMPLETE.md
```

---

## 🔗 Additional Resources

### Documentation
- **Phase 3 Features**: See `PHASE3_FEATURES.md`
- **Phase 4 Complete**: See `PHASE4_COMPLETE.md`
- **Inline Help**: Tooltips throughout UI

### Examples
- All templates serve as examples
- Create from template to see structure
- Export to markdown to study format

### Community
- GitHub repository (if available)
- Issue tracker
- Discussion forums
- Example stories

---

## 📝 File Format Specification

### Whisker JSON Structure

```json
{
  "metadata": {
    "title": "Story Title",
    "author": "Author Name",
    "version": "1.0.0",
    "created": "ISO timestamp",
    "modified": "ISO timestamp"
  },
  "settings": {
    "startPassage": "passage_id"
  },
  "variables": {
    "var_name": {
      "type": "string|number|boolean",
      "initial": "value"
    }
  },
  "passages": [
    {
      "id": "unique_id",
      "title": "Passage Title",
      "content": "Story text with {{variables}}",
      "position": { "x": 100, "y": 100 },
      "choices": [
        {
          "text": "Choice text",
          "target": "target_passage_id"
        }
      ]
    }
  ],
  "assets": {
    "filename.png": {
      "name": "filename.png",
      "type": "image/png",
      "size": 12345,
      "data": "base64_data_url"
    }
  }
}
```

---

## 🎯 Development Roadmap

### ✅ Phase 1: Core Editor (Complete)
- Project management
- Passage editor
- Choice editor
- List view
- Preview

### ✅ Phase 2: Visual Editor (Complete)
- Graph view
- Drag-and-drop
- Visual connections
- Zoom/pan controls
- Auto-layout

### ✅ Phase 3: Enhanced Features (Complete)
- Variable manager
- Rich text editing
- Validation system
- Undo/redo
- Story templates

### ✅ Phase 4: Polish & Export (Complete)
- Multiple export formats
- Theme system
- Asset management
- Settings manager

### 🔮 Future Possibilities
- Cloud storage integration
- Collaboration features
- AI writing assistant
- Advanced analytics
- Plugin system

---

## 🙏 Credits

**Whisker Story Editor** was built to provide a modern, accessible, and powerful tool for interactive fiction authors.

Special thanks to the interactive fiction community and tools like Twine that inspired this project.

---

## 📄 License

Open source under MIT License (modify as needed)

---

## 🆘 Support

### Getting Help
1. Check this README
2. Review Phase 3 and Phase 4 documentation
3. Try a different browser
4. Clear cache and retry
5. Check browser console for errors

### Reporting Issues
- Include browser and version
- Describe steps to reproduce
- Attach example project if possible
- Note any error messages

---

## 🎉 Get Started!

Ready to create your story? Open `index.html` and start writing!

**Happy Storytelling!** ✨📚

---

**Version**: 1.0.0  
**Released**: October 2025  
**Status**: Production Ready  
**Phases**: 4/4 Complete ✅