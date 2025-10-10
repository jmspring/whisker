# Whisker Story Editor/Authoring Tool
## Complete Specification & Architecture

---

## 1. Editor Overview

### Purpose
A visual, user-friendly tool for creating and editing Whisker interactive fiction stories without writing JSON or code directly.

### Target Users
- **Writers**: Focus on narrative without technical knowledge
- **Game Designers**: Create branching narratives visually
- **Educators**: Build educational interactive content
- **Hobbyists**: Create stories for fun

### Delivery Methods
1. **Web-based Editor** (Primary) - Browser application
2. **Desktop Editor** (Optional) - Electron or LÖVE2D standalone app

---

## 2. UI/UX Design

### Main Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Whisker Editor                    [Save] [Test] [Export]   │
├──────────┬────────────────────────────────────┬─────────────┤
│          │                                    │             │
│  Story   │                                    │  Properties │
│  Tree    │        Node Graph View             │   Panel     │
│          │                                    │             │
│  Start   │     ┌─────────┐                   │  Passage:   │
│  ├─Intro │     │ Intro   │                   │  "Start"    │
│  ├─Cave  │     │         │───┐               │             │
│  │ ├─Lit │     └─────────┘   │               │  Title:     │
│  │ └─Dark│          │         │               │  [______]   │
│  ├─Forest│          ▼         ▼               │             │
│  └─End   │   ┌─────────┐ ┌─────────┐         │  Content:   │
│          │   │  Cave   │ │ Forest  │         │  [______]   │
│          │   └─────────┘ └─────────┘         │  [______]   │
│  [+New]  │                                    │  [______]   │
│          │                                    │             │
│          │                                    │  Choices:   │
│          │                                    │  [+ Add]    │
│          │                                    │             │
└──────────┴────────────────────────────────────┴─────────────┘
│  Variables: health=100, gold=0   │  Word Count: 1,250       │
└──────────────────────────────────────────────────────────────┘
```

### View Modes

#### 1. **Node Graph View** (Visual Mode)
- **Passages as nodes**: Drag-and-drop interface
- **Connections as arrows**: Visual flow between passages
- **Color coding**: By passage type or status
- **Zoom/pan**: Navigate large stories
- **Minimap**: Overview of entire story

#### 2. **List View** (Outline Mode)
- **Hierarchical tree**: Passages in collapsible tree
- **Search/filter**: Find passages quickly
- **Bulk operations**: Move, duplicate, delete
- **Sort options**: Alphabetical, chronological, custom

#### 3. **Split View** (Hybrid)
- **Left**: Story tree
- **Right**: Selected passage editor
- **Bottom**: Preview pane

#### 4. **Preview Mode**
- **Live preview**: Play story as you build
- **Quick test**: Test from any passage
- **Debug mode**: See variable states

---

## 3. Core Components

### 3.1 Story Tree/Navigator
**Purpose**: Organize and navigate passages

**Features**:
- Collapsible tree structure
- Drag-and-drop reordering
- Right-click context menu
- Visual indicators (start, end, orphans)
- Search and filter
- Tags and categories

**UI Elements**:
```
📖 Story Name
├─ 🏁 Start (Starting passage)
├─ 📄 Forest Entrance
│  ├─ 📄 Deep Forest
│  │  ├─ 📄 Fairy Ring
│  │  └─ 📄 Ancient Tree
│  └─ 📄 Forest Edge
├─ 📄 Treasure Room
├─ ⚠️ Orphan Passage (warning)
└─ 🎯 Victory (ending)
```

### 3.2 Node Graph Canvas
**Purpose**: Visual story flow

**Features**:
- **Nodes**: Represent passages
  - Color-coded by type
  - Shows passage title
  - Preview of content on hover
  - Connection points for links

- **Connections**: Show flow
  - Arrows indicate direction
  - Labels show choice text
  - Conditional links shown differently
  - Loop-backs clearly marked

- **Interactions**:
  - Click to edit
  - Drag to move
  - Double-click to zoom
  - Right-click for menu
  - Connect by dragging

**Node Appearance**:
```
┌─────────────────┐
│  Forest Entry   │ ← Title
├─────────────────┤
│ You stand at... │ ← Preview
├─────────────────┤
│ 3 choices       │ ← Info
└─────────────────┘
  │  │  │
  ▼  ▼  ▼  ← Connection points
```

### 3.3 Properties Panel
**Purpose**: Edit selected passage

**Sections**:

#### Basic Info
```
Passage ID: [forest_entrance]
Title:      [The Forest Entrance]
Tags:       [outdoor] [starting] [+add]
```

#### Content Editor
```
┌─────────────────────────────────────┐
│ Rich Text Editor                    │
│                                     │
│ You stand at the edge of an ancient│
│ forest. The trees tower above you. │
│                                     │
│ Health: {{health}}                 │
│ Gold: {{gold}}                     │
│                                     │
│ [B] [I] [U] {{var}} [📎] [🖼️]     │
└─────────────────────────────────────┘
```

#### Choices Editor
```
Choice 1:
  Text:      [Enter the forest]
  Target:    [deep_forest ▼]
  Condition: [gold >= 10________]
  Script:    [set('visited', true)]

Choice 2:
  Text:      [Return home]
  Target:    [home ▼]

[+ Add Choice]
```

#### Scripts & Logic
```
On Enter Script:
┌─────────────────────────────────────┐
│ set('forest_depth', 1)              │
│ set('visited_forest', true)         │
└─────────────────────────────────────┘

On Exit Script:
┌─────────────────────────────────────┐
│ // Runs when leaving passage        │
└─────────────────────────────────────┘
```

#### Media & Assets
```
Background: [None ▼]
Music:      [forest_theme.mp3 📁]
Sound FX:   [birds.mp3 📁]
Image:      [forest.jpg 📁] [Preview]
```

### 3.4 Variable Manager
**Purpose**: Track and edit story variables

**Features**:
- List all variables
- See where used
- Set initial values
- Type checking
- Bulk import/export

**UI**:
```
┌─────────────────────────────────────┐
│ Variables                    [+ New]│
├─────────────┬──────┬────────┬───────┤
│ Name        │ Type │ Initial│ Used  │
├─────────────┼──────┼────────┼───────┤
│ health      │ num  │ 100    │ 15x   │
│ gold        │ num  │ 0      │ 8x    │
│ player_name │ str  │"Hero"  │ 3x    │
│ has_key     │ bool │ false  │ 5x    │
│ inventory   │ arr  │ []     │ 12x   │
└─────────────┴──────┴────────┴───────┘

[Edit] [Delete] [Find Usage]
```

### 3.5 Test/Preview Panel
**Purpose**: Test story without leaving editor

**Features**:
- Embedded player
- Variable inspector
- Step-by-step debugging
- Passage path tracking
- Screenshot/recording

**UI**:
```
┌─────────────────────────────────────┐
│ Preview              [Debug] [Reset]│
├─────────────────────────────────────┤
│                                     │
│  Story plays here...                │
│                                     │
├─────────────────────────────────────┤
│ Debug Info:                         │
│ Current: forest_entrance            │
│ Variables: health=100, gold=50      │
│ History: [Start] → [Forest Entry]   │
└─────────────────────────────────────┘
```

### 3.6 Toolbar
**Purpose**: Quick actions

**Buttons**:
```
[📁 New] [📂 Open] [💾 Save] [💾 Save As]
[↶ Undo] [↷ Redo]
[✂️ Cut] [📋 Copy] [📄 Paste]
[▶️ Test] [🔍 Preview] [📤 Export]
[⚙️ Settings] [❓ Help]
```

### 3.7 Status Bar
**Purpose**: Show project info

**Display**:
```
Passages: 15 | Words: 2,450 | Modified: 2m ago | Auto-saved ✓
```

---

## 4. Feature Set

### Essential Features (MVP)

#### Story Management
- ✅ Create new story
- ✅ Open existing story
- ✅ Save story (JSON format)
- ✅ Auto-save
- ✅ Export to runtime formats

#### Passage Editing
- ✅ Add/delete passages
- ✅ Edit title and content
- ✅ Rich text formatting (bold, italic)
- ✅ Variable insertion helper
- ✅ Add/remove choices

#### Visual Flow
- ✅ Node graph view
- ✅ Connect passages visually
- ✅ Zoom and pan
- ✅ Auto-layout algorithm

#### Testing
- ✅ Preview story
- ✅ Test from any passage
- ✅ Variable inspector

### Advanced Features (v2.0)

#### Collaboration
- Multiple authors
- Version control integration
- Comments and notes
- Change tracking

#### Templates
- Story templates
- Passage templates
- Choice templates
- Common patterns

#### Analysis
- Story statistics
- Readability metrics
- Complexity analysis
- Dead end detection
- Unreachable passages

#### Media
- Image library
- Audio manager
- Asset optimization
- Preview in context

#### Publishing
- Export to web
- Export to desktop
- Export to mobile
- Standalone HTML generation

---

## 5. Directory Layout

### Complete File Structure

```
whisker/
├── src/
│   ├── core/                         # Existing core engine
│   ├── runtime/                      # Existing runtimes
│   ├── format/                       # Existing format converters
│   │
│   ├── editor/                       # ⭐ NEW: Editor components
│   │   ├── core/                     # Editor core functionality
│   │   │   ├── project.lua          # Project management
│   │   │   ├── passage_manager.lua  # Passage CRUD operations
│   │   │   ├── variable_manager.lua # Variable tracking
│   │   │   ├── link_manager.lua     # Connection management
│   │   │   └── history_manager.lua  # Undo/redo system
│   │   │
│   │   ├── ui/                       # UI components
│   │   │   ├── tree_view.lua        # Story tree navigator
│   │   │   ├── node_graph.lua       # Visual graph editor
│   │   │   ├── properties_panel.lua # Property editor
│   │   │   ├── text_editor.lua      # Rich text editor
│   │   │   ├── choice_editor.lua    # Choice editor widget
│   │   │   ├── variable_panel.lua   # Variable manager UI
│   │   │   ├── preview_panel.lua    # Story preview
│   │   │   ├── toolbar.lua          # Main toolbar
│   │   │   └── status_bar.lua       # Status display
│   │   │
│   │   ├── validation/               # Story validation
│   │   │   ├── validator.lua        # Main validator
│   │   │   ├── rules.lua            # Validation rules
│   │   │   └── reporter.lua         # Error reporting
│   │   │
│   │   ├── export/                   # Export functionality
│   │   │   ├── html_exporter.lua    # Export to HTML
│   │   │   ├── json_exporter.lua    # Export to JSON
│   │   │   ├── package_builder.lua  # Build distributable
│   │   │   └── template_manager.lua # Export templates
│   │   │
│   │   ├── import/                   # Import from other formats
│   │   │   ├── twine_importer.lua   # Import Twine stories
│   │   │   ├── json_importer.lua    # Import JSON
│   │   │   └── markdown_importer.lua# Import from Markdown
│   │   │
│   │   └── assets/                   # Asset management
│   │       ├── asset_manager.lua    # Manage media assets
│   │       ├── image_handler.lua    # Image processing
│   │       └── audio_handler.lua    # Audio processing
│   │
│   └── tools/                        # Existing tools
│
├── editor/                           # ⭐ NEW: Editor applications
│   ├── web/                          # Web-based editor
│   │   ├── index.html               # Main HTML file
│   │   ├── css/
│   │   │   ├── editor.css           # Main styles
│   │   │   ├── node-graph.css       # Graph styles
│   │   │   ├── properties.css       # Panel styles
│   │   │   └── themes/
│   │   │       ├── light.css
│   │   │       └── dark.css
│   │   ├── js/
│   │   │   ├── editor.js            # Main editor logic
│   │   │   ├── node-graph.js        # Graph implementation
│   │   │   ├── text-editor.js       # Rich text editor
│   │   │   ├── tree-view.js         # Tree navigator
│   │   │   ├── properties-panel.js  # Properties UI
│   │   │   ├── preview.js           # Preview functionality
│   │   │   └── export.js            # Export handlers
│   │   ├── lib/                      # Third-party libraries
│   │   │   ├── dagre.js             # Graph layout
│   │   │   ├── quill.js             # Rich text editor
│   │   │   └── jsplumb.js           # Node connections
│   │   └── assets/
│   │       ├── icons/
│   │       └── templates/
│   │
│   ├── desktop/                      # Desktop editor (LÖVE2D)
│   │   ├── main.lua                 # Main entry point
│   │   ├── conf.lua                 # Configuration
│   │   ├── editor_runtime.lua       # Editor runtime
│   │   └── ui/
│   │       ├── graph_editor.lua
│   │       ├── text_editor.lua
│   │       └── panels.lua
│   │
│   └── templates/                    # Story templates
│       ├── blank.json               # Empty story
│       ├── tutorial.json            # Tutorial template
│       ├── rpg.json                 # RPG template
│       ├── mystery.json             # Mystery template
│       └── educational.json         # Educational template
│
├── examples/                         # Existing examples
│
├── docs/
│   ├── editor/                       # ⭐ NEW: Editor documentation
│   │   ├── EDITOR_GUIDE.md          # User guide
│   │   ├── KEYBOARD_SHORTCUTS.md    # Shortcuts reference
│   │   ├── TEMPLATES.md             # Template guide
│   │   └── TROUBLESHOOTING.md       # Common issues
│   │
│   └── ...                           # Existing docs
│
└── tests/
    └── editor/                       # ⭐ NEW: Editor tests
        ├── test_project.lua
        ├── test_passage_manager.lua
        ├── test_validator.lua
        └── test_export.lua
```

---

## 6. Component Architecture

### Data Flow

```
┌─────────────┐
│   Editor    │
│     UI      │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│   Project   │────▶│   Validator  │
│   Manager   │     └──────────────┘
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│  Passage    │────▶│    Export    │
│  Manager    │     │   Manager    │
└─────────────┘     └──────────────┘
       │                    │
       ▼                    ▼
┌─────────────┐     ┌──────────────┐
│  Variable   │     │   Runtime    │
│  Manager    │     │   Formats    │
└─────────────┘     └──────────────┘
```

### Core Classes

#### Project
```lua
Project = {
    metadata = {
        title = "",
        author = "",
        version = "",
        created = "",
        modified = ""
    },
    variables = {},
    passages = {},
    connections = {},
    settings = {}
}
```

#### Passage
```lua
Passage = {
    id = "",
    title = "",
    content = "",
    tags = {},
    position = {x = 0, y = 0}, -- For graph view
    choices = {},
    script = "",
    metadata = {}
}
```

#### Choice
```lua
Choice = {
    text = "",
    target = "",
    condition = "",
    script = ""
}
```

---

## 7. Technology Stack

### Web Editor (Recommended)

#### Frontend
- **Framework**: React or Vue.js
- **Graph Library**: D3.js or Cytoscape.js
- **Text Editor**: Quill or TipTap
- **UI Components**: Material-UI or Ant Design
- **State Management**: Redux or Vuex
- **File Handling**: File API

#### Backend (Optional)
- **Server**: Node.js + Express (for cloud storage)
- **Database**: MongoDB (for project storage)
- **Auth**: JWT or OAuth (for multi-user)

### Desktop Editor (Alternative)

#### LÖVE2D-based
- **Language**: Lua
- **UI**: Love-ImGui or custom widgets
- **Graph**: Custom implementation
- **Text**: Love.graphics text input

#### Electron-based
- **Framework**: Electron
- **UI**: Same as web editor
- **File Access**: Node.js fs module

---

## 8. User Workflows

### 8.1 Creating a New Story

1. Click "New Project"
2. Enter story metadata (title, author)
3. Choose template or start blank
4. Editor opens with start passage
5. Begin writing

### 8.2 Adding Passages

**Method 1: Tree View**
1. Right-click in tree
2. Select "New Passage"
3. Enter title
4. Passage created and selected

**Method 2: Graph View**
1. Double-click empty space
2. New node appears
3. Edit inline or in properties

**Method 3: From Choice**
1. Add choice to passage
2. Type new passage name in target
3. Click "Create New Passage"
4. Passage created and linked

### 8.3 Connecting Passages

**Method 1: Graph View**
1. Click connection point on source node
2. Drag to target node
3. Connection created
4. Edit choice text in properties

**Method 2: Choice Editor**
1. Add choice in properties panel
2. Select target from dropdown
3. Or type name to create new passage

### 8.4 Testing Story

1. Click "Preview" button
2. Story plays in preview panel
3. Variables shown in debug panel
4. Click passages to jump
5. Edit and test iteratively

### 8.5 Exporting Story

1. Click "Export" button
2. Choose format:
   - Web (HTML + JS)
   - Desktop (LÖVE package)
   - JSON (for runtime)
3. Configure export options
4. Click "Export"
5. Download or save file

---

## 9. File Formats

### Project File (.whisker)

JSON format containing entire project:

```json
{
  "metadata": {
    "title": "My Story",
    "author": "Author Name",
    "version": "1.0.0",
    "created": "2025-10-09T12:00:00Z",
    "modified": "2025-10-09T15:30:00Z"
  },
  "variables": {
    "health": {"type": "number", "initial": 100},
    "gold": {"type": "number", "initial": 0}
  },
  "passages": [
    {
      "id": "start",
      "title": "Beginning",
      "content": "Story starts here...",
      "position": {"x": 100, "y": 100},
      "choices": [...]
    }
  ],
  "settings": {
    "startPassage": "start",
    "theme": "default"
  }
}
```

### Export Formats

#### HTML Export
Single-file HTML with embedded story and runtime

#### JSON Export
Whisker story format for use with runtimes

#### Package Export
Zipped folder with all assets and runtime

---

## 10. Implementation Priority

### Phase 1: Core Editor (MVP)
- ✅ Project management (new, open, save)
- ✅ Passage editor (add, edit, delete)
- ✅ Basic text editor
- ✅ Choice editor
- ✅ Simple list view
- ✅ Export to JSON
- ✅ Preview functionality

**Estimated Time**: 4-6 weeks

### Phase 2: Visual Editor
- ✅ Node graph view
- ✅ Drag-and-drop connections
- ✅ Visual flow editing
- ✅ Auto-layout
- ✅ Zoom/pan controls

**Estimated Time**: 3-4 weeks

### Phase 3: Enhanced Features
- ✅ Variable manager
- ✅ Rich text editing
- ✅ Validation and error checking
- ✅ Undo/redo
- ✅ Templates

**Estimated Time**: 3-4 weeks

### Phase 4: Polish & Export
- ✅ Multiple export formats
- ✅ Theme support
- ✅ Asset management
- ✅ Documentation
- ✅ Tutorial

**Estimated Time**: 2-3 weeks

**Total MVP**: 12-17 weeks

---

## 11. Success Metrics

### Usability
- Time to create first story: < 10 minutes
- Learning curve: Functional in 30 minutes
- User satisfaction: > 4.5/5 stars

### Performance
- Load time: < 2 seconds
- Auto-save: < 500ms
- Preview refresh: < 1 second
- Support stories: Up to 500 passages

### Compatibility
- Browsers: Chrome, Firefox, Safari, Edge
- Platforms: Windows, macOS, Linux
- File formats: Whisker, Twine, JSON

---

## 12. Future Enhancements

### Advanced Features
- 🤝 Collaboration (real-time multi-user)
- 🌐 Cloud storage integration
- 📊 Analytics dashboard
- 🎨 Custom themes
- 🔌 Plugin system
- 🗣️ Localization support

### AI Integration
- ✨ AI writing assistant
- 🤖 Auto-complete suggestions
- 📝 Grammar checking
- 🎯 Story analysis

### Community Features
- 📚 Story marketplace
- ⭐ Rating system
- 💬 Comments and feedback
- 🏆 Challenges and contests

---

This comprehensive specification provides a complete roadmap for building the Whisker story editor!