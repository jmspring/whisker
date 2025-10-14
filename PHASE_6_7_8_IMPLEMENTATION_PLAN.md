# Phase 6, 7, 8 Implementation Plan

**Date**: October 13, 2025
**Features**: Backend Test Coverage, Real-time Preview, Enhanced Graph Editor

---

## Phase 6: Complete Lua Backend Test Coverage

### Current State
- **42 Lua source files** in `src/`
- **35 test files** in `tests/`
- **~20 modules** lack dedicated tests
- **Test runner** exists (`tests/test_all.lua`)
- **Several tests failing** due to API changes

### Goals
- ✅ 80%+ code coverage on backend
- ✅ All existing tests passing
- ✅ CI/CD with GitHub Actions
- ✅ Automated test reports

### Tasks

#### 6.1 Fix Existing Failing Tests (Priority: HIGH)
**Issue**: Multiple tests failing with "Cannot set start passage: passage 'start' does not exist"

**Root Cause**: API change in Story class - passages must be added before setting start passage

**Files to Fix**:
- `tests/test_story.lua`
- `tests/test_validator.lua`
- `tests/test_profiler.lua`
- `tests/test_debugger.lua`
- `tests/test_metatable_preservation.lua`

**Fix**: Update test files to add passages before calling `set_start_passage()`

```lua
-- OLD (broken):
story:set_start_passage("start")
story:add_passage(start_passage)

-- NEW (fixed):
story:add_passage(start_passage)
story:set_start_passage("start")
```

#### 6.2 Create Missing Unit Tests

**Priority Modules Needing Tests**:
1. **`src/core/engine.lua`** - Core game loop
2. **`src/core/game_state.lua`** - State management
3. **`src/core/event_system.lua`** - Event bus
4. **`src/core/choice.lua`** - Choice system
5. **`src/utils/file_utils.lua`** - File operations
6. **`src/utils/string_utils.lua`** - String helpers
7. **`src/parser/lexer.lua`** - Lexical analysis
8. **`src/parser/parser.lua`** - Parsing logic

**Test Template**:
```lua
-- tests/test_<module>.lua
local ModuleName = require("src.path.module")

print("=== ModuleName Test Suite ===\n")

local tests_passed = 0
local tests_failed = 0

-- Test 1: Basic functionality
local function test_basic()
    local obj = ModuleName:new()
    -- assertions
    return true
end

if test_basic() then
    print("✅ Test 1: Basic functionality")
    tests_passed = tests_passed + 1
else
    print("❌ Test 1: Basic functionality")
    tests_failed = tests_failed + 1
end

-- Summary
print(string.format("\n=== Results: %d passed, %d failed ===", tests_passed, tests_failed))
assert(tests_failed == 0, "Some tests failed")
```

#### 6.3 Set Up CI/CD with GitHub Actions

**File**: `.github/workflows/lua-tests.yml`

```yaml
name: Lua Backend Tests

on:
  push:
    branches: [ main, feature/** ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install Lua
      run: |
        sudo apt-get update
        sudo apt-get install -y lua5.3 luarocks

    - name: Run Lua Tests
      run: lua tests/test_all.lua

    - name: Upload Test Report
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: lua-test-report
        path: tests/test_report.txt

    - name: Check Test Results
      run: |
        if [ ! -f tests/test_report.txt ]; then
          echo "Test report not generated"
          exit 1
        fi
        FAILED=$(grep "Failed:" tests/test_report.txt | awk '{print $2}')
        if [ "$FAILED" != "0" ]; then
          echo "Tests failed: $FAILED"
          exit 1
        fi
```

#### 6.4 Add Code Coverage Tracking

**Install LuaCov**:
```bash
luarocks install luacov
```

**Run with Coverage**:
```bash
lua -lluacov tests/test_all.lua
luacov
```

**Generate Report**:
```lua
-- Add to test_all.lua at end:
if os.getenv("COVERAGE") then
    require("luacov.runner").shutdown()
end
```

---

## Phase 7: Real-time Preview/Playtest Mode

### Goal
Enable in-editor story testing without export

### Architecture

```
┌─────────────────────────────────────────────────┐
│  Editor UI (editor/web/index.html)              │
│  ┌────────────────────────────────────────┐    │
│  │  Toolbar                                │    │
│  │  [Edit] [Graph] [Preview] [Settings]   │    │
│  └────────────────────────────────────────┘    │
│                                                  │
│  ┌────────────────┬────────────────────────┐   │
│  │  Edit/Graph    │  Preview Panel         │   │
│  │  View          │  ┌─────────────────┐   │   │
│  │                │  │ Passage Content  │   │   │
│  │                │  │                  │   │   │
│  │                │  │ [Choice 1]       │   │   │
│  │                │  │ [Choice 2]       │   │   │
│  │                │  └─────────────────┘   │   │
│  │                │  ┌─────────────────┐   │   │
│  │                │  │ Debug Panel      │   │   │
│  │                │  │ Variables:       │   │   │
│  │                │  │  health = 100    │   │   │
│  │                │  │  gold = 50       │   │   │
│  │                │  └─────────────────┘   │   │
│  └────────────────┴────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### Tasks

#### 7.1 Create Preview Mode UI

**File**: `editor/web/js/preview.js`

```javascript
class PreviewMode {
    constructor(editor) {
        this.editor = editor;
        this.runtime = null;
        this.gameState = {};
        this.history = [];
        this.isPreviewing = false;
    }

    initialize() {
        this.createPreviewPanel();
        this.setupEventListeners();
    }

    createPreviewPanel() {
        // Create split-view panel
        const previewHTML = `
            <div id="previewPanel" class="preview-panel hidden">
                <div class="preview-header">
                    <h3>Story Preview</h3>
                    <button class="btn-small" onclick="previewMode.stop()">
                        Stop Preview
                    </button>
                    <button class="btn-small" onclick="previewMode.restart()">
                        Restart
                    </button>
                    <button class="btn-small" onclick="previewMode.toggleDebug()">
                        Toggle Debug
                    </button>
                </div>
                <div class="preview-content">
                    <div id="previewPassage" class="preview-passage">
                        <!-- Passage content rendered here -->
                    </div>
                </div>
                <div id="previewDebug" class="preview-debug hidden">
                    <h4>Debug Information</h4>
                    <div class="debug-section">
                        <h5>Game State</h5>
                        <pre id="debugState"></pre>
                    </div>
                    <div class="debug-section">
                        <h5>History</h5>
                        <div id="debugHistory"></div>
                    </div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', previewHTML);
    }

    start() {
        if (!this.editor.project || !this.editor.project.passages.length) {
            alert('No project loaded or project is empty');
            return;
        }

        this.isPreviewing = true;
        this.gameState = this.initializeGameState();
        this.history = [];

        // Show preview panel
        document.getElementById('previewPanel').classList.remove('hidden');

        // Initialize runtime
        this.runtime = new PreviewRuntime(this.editor.project, this.gameState);

        // Navigate to start passage
        const startPassageId = this.editor.project.settings.startPassage;
        this.navigateToPassage(startPassageId);
    }

    navigateToPassage(passageId) {
        const passage = this.editor.project.passages.find(p => p.id === passageId);

        if (!passage) {
            console.error('Passage not found:', passageId);
            return;
        }

        // Process passage content (template rendering, etc.)
        const processedContent = this.runtime.processPassage(passage);

        // Render passage
        this.renderPassage(processedContent, passage);

        // Add to history
        this.history.push({
            passageId: passageId,
            state: {...this.gameState}
        });

        // Update debug panel
        if (!document.getElementById('previewDebug').classList.contains('hidden')) {
            this.updateDebugPanel();
        }
    }

    renderPassage(content, passage) {
        const container = document.getElementById('previewPassage');

        // Render content
        container.innerHTML = `
            <div class="passage-title">${passage.title}</div>
            <div class="passage-text">${content.html}</div>
            <div class="passage-choices">
                ${passage.choices.map((choice, i) => `
                    <button class="choice-btn"
                            onclick="previewMode.selectChoice(${i})">
                        ${choice.text}
                    </button>
                `).join('')}
            </div>
        `;
    }

    selectChoice(index) {
        const currentPassage = this.getCurrentPassage();
        const choice = currentPassage.choices[index];

        if (choice && choice.target) {
            this.navigateToPassage(choice.target);
        }
    }

    stop() {
        this.isPreviewing = false;
        document.getElementById('previewPanel').classList.add('hidden');
        this.runtime = null;
        this.gameState = {};
        this.history = [];
    }

    restart() {
        this.stop();
        this.start();
    }

    toggleDebug() {
        document.getElementById('previewDebug').classList.toggle('hidden');
        if (!document.getElementById('previewDebug').classList.contains('hidden')) {
            this.updateDebugPanel();
        }
    }

    updateDebugPanel() {
        // Update game state display
        document.getElementById('debugState').textContent =
            JSON.stringify(this.gameState, null, 2);

        // Update history
        const historyHTML = this.history.map((entry, i) => `
            <div class="history-entry">
                <strong>Step ${i + 1}:</strong> ${entry.passageId}
            </div>
        `).join('');
        document.getElementById('debugHistory').innerHTML = historyHTML;
    }

    initializeGameState() {
        const state = {};

        // Initialize variables from project
        if (this.editor.project.variables) {
            for (const [name, varData] of Object.entries(this.editor.project.variables)) {
                state[name] = varData.initial;
            }
        }

        return state;
    }

    getCurrentPassage() {
        if (this.history.length === 0) return null;
        const lastEntry = this.history[this.history.length - 1];
        return this.editor.project.passages.find(p => p.id === lastEntry.passageId);
    }
}

// Make globally available
let previewMode = null;
```

#### 7.2 Create Preview Runtime

**File**: `editor/web/js/preview-runtime.js`

```javascript
class PreviewRuntime {
    constructor(project, gameState) {
        this.project = project;
        this.gameState = gameState;
    }

    processPassage(passage) {
        let content = passage.content;

        // Process template variables {{varname}}
        content = this.processVariables(content);

        // Process conditional blocks {{#if condition}}...{{/if}}
        content = this.processConditionals(content);

        // Process Lua blocks {{lua: code}}
        content = this.processLua(content);

        return {
            html: this.markdownToHTML(content),
            raw: content
        };
    }

    processVariables(content) {
        return content.replace(/\{\{([^}]+)\}\}/g, (match, varName) => {
            varName = varName.trim();

            // Skip Lua blocks and conditionals
            if (varName.startsWith('lua:') || varName.startsWith('#')) {
                return match;
            }

            return this.gameState[varName] !== undefined
                ? this.gameState[varName]
                : match;
        });
    }

    processConditionals(content) {
        // {{#if varname}}content{{/if}}
        const ifRegex = /\{\{#if\s+(\w+)\}\}(.*?)\{\{\/if\}\}/gs;

        return content.replace(ifRegex, (match, varName, innerContent) => {
            return this.gameState[varName] ? innerContent : '';
        });
    }

    processLua(content) {
        // {{lua: game_state:set("var", value)}}
        const luaRegex = /\{\{lua:\s*game_state:set\("(\w+)",\s*(.+?)\)\}\}/g;

        return content.replace(luaRegex, (match, varName, value) => {
            try {
                // Evaluate the value
                const evalValue = eval(value);
                this.gameState[varName] = evalValue;
                return ''; // Lua blocks don't render
            } catch (e) {
                console.error('Lua eval error:', e);
                return `<span class="error">Lua Error: ${e.message}</span>`;
            }
        });
    }

    markdownToHTML(content) {
        return content
            .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
            .replace(/\*([^*]+)\*/g, '<em>$1</em>')
            .replace(/__([^_]+)__/g, '<u>$1</u>')
            .replace(/\n\n/g, '</p><p>')
            .replace(/\n/g, '<br>');
    }
}
```

#### 7.3 Add Preview Button to Toolbar

**File**: `editor/web/index.html` (modify toolbar)

```html
<button class="btn" onclick="previewMode.start()" title="Preview Story">
    ▶️ Preview
</button>
```

#### 7.4 Add Preview Styles

**File**: `editor/web/css/preview.css`

```css
.preview-panel {
    position: fixed;
    right: 0;
    top: 60px;
    bottom: 0;
    width: 40%;
    background: var(--bg-secondary);
    border-left: 1px solid var(--border-color);
    display: flex;
    flex-direction: column;
    z-index: 100;
}

.preview-panel.hidden {
    display: none;
}

.preview-header {
    padding: 15px;
    background: var(--bg-tertiary);
    border-bottom: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    gap: 10px;
}

.preview-content {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
}

.preview-passage {
    max-width: 600px;
    margin: 0 auto;
}

.passage-title {
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 20px;
    color: var(--text-primary);
}

.passage-text {
    font-size: 16px;
    line-height: 1.6;
    margin-bottom: 30px;
    color: var(--text-secondary);
}

.passage-choices {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.choice-btn {
    padding: 12px 20px;
    background: var(--accent-color);
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    text-align: left;
    font-size: 15px;
    transition: background 0.2s;
}

.choice-btn:hover {
    background: var(--accent-hover);
}

.preview-debug {
    border-top: 1px solid var(--border-color);
    padding: 15px;
    background: var(--bg-primary);
    max-height: 300px;
    overflow-y: auto;
}

.debug-section {
    margin-bottom: 15px;
}

.debug-section h5 {
    margin: 0 0 10px 0;
    color: var(--text-primary);
}

#debugState {
    background: var(--bg-secondary);
    padding: 10px;
    border-radius: 4px;
    font-size: 12px;
    overflow-x: auto;
}

.history-entry {
    padding: 5px;
    margin-bottom: 5px;
    background: var(--bg-secondary);
    border-radius: 3px;
}
```

---

## Phase 8: Enhanced Graph Editor

### Goal
Make graph editor competitive with Twine's visual interface

### Features to Add

#### 8.1 Drag & Drop Passage Creation

**Interaction**: Double-click canvas → create new passage at that location

**Implementation**: Add to `graph.js`

```javascript
// In graph.js, add to initialize():
this.canvas.addEventListener('dblclick', (e) => {
    const rect = this.canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left - this.panX) / this.zoom;
    const y = (e.clientY - rect.top - this.panY) / this.zoom;

    this.createPassageAtPosition(x, y);
});

createPassageAtPosition(x, y) {
    const newPassage = {
        id: this.generateUniqueId(),
        title: `New Passage`,
        content: '',
        choices: [],
        position: { x, y },
        tags: []
    };

    this.editor.project.passages.push(newPassage);
    this.render();

    // Open passage for editing
    this.editor.editPassage(newPassage);
}
```

#### 8.2 Visual Link Creation

**Interaction**: Drag from passage → drop on another passage → create choice

**Implementation**:

```javascript
// Link creation state
this.linkDragStart = null;
this.linkDragEnd = null;

// Mouse down on passage
onPassageMouseDown(passage, e) {
    if (e.shiftKey) {
        // Start link creation
        this.linkDragStart = passage;
        this.isCreatingLink = true;
        e.preventDefault();
    } else {
        // Start passage drag
        this.startDrag(passage, e);
    }
}

// Mouse move
onCanvasMouseMove(e) {
    if (this.isCreatingLink) {
        const rect = this.canvas.getBoundingClientRect();
        this.linkDragEnd = {
            x: (e.clientX - rect.left - this.panX) / this.zoom,
            y: (e.clientY - rect.top - this.panY) / this.zoom
        };
        this.render();
    }
}

// Mouse up
onCanvasMouseUp(e) {
    if (this.isCreatingLink) {
        const targetPassage = this.getPassageAtPosition(
            this.linkDragEnd.x,
            this.linkDragEnd.y
        );

        if (targetPassage && targetPassage !== this.linkDragStart) {
            this.createLink(this.linkDragStart, targetPassage);
        }

        this.isCreatingLink = false;
        this.linkDragStart = null;
        this.linkDragEnd = null;
        this.render();
    }
}

createLink(fromPassage, toPassage) {
    const choice = {
        text: `Go to ${toPassage.title}`,
        target: toPassage.id
    };

    fromPassage.choices.push(choice);
    this.editor.renderAll();
}
```

#### 8.3 Multi-Select

**Interaction**: Drag rectangle to select multiple passages, then move together

**Implementation**:

```javascript
// Selection state
this.selectedPassages = new Set();
this.selectionStart = null;
this.selectionRect = null;

// Canvas mouse down (empty space)
onEmptySpaceMouseDown(e) {
    if (!e.ctrlKey) {
        this.selectedPassages.clear();
    }

    this.selectionStart = {
        x: (e.clientX - this.panX) / this.zoom,
        y: (e.clientY - this.panY) / this.zoom
    };
}

// Canvas mouse move (selection drag)
onSelectionDrag(e) {
    this.selectionRect = {
        x1: this.selectionStart.x,
        y1: this.selectionStart.y,
        x2: (e.clientX - this.panX) / this.zoom,
        y2: (e.clientY - this.panY) / this.zoom
    };

    // Find passages in rect
    this.selectedPassages.clear();
    for (const passage of this.editor.project.passages) {
        if (this.isPassageInRect(passage, this.selectionRect)) {
            this.selectedPassages.add(passage.id);
        }
    }

    this.render();
}

// Move selected passages together
moveSelectedPassages(deltaX, deltaY) {
    for (const passageId of this.selectedPassages) {
        const passage = this.editor.project.passages.find(p => p.id === passageId);
        if (passage) {
            passage.position.x += deltaX;
            passage.position.y += deltaY;
        }
    }
    this.render();
}
```

#### 8.4 Auto-Layout

**Interaction**: Menu → "Auto-Layout" → organize passages automatically

**Algorithms**:
1. **Tree Layout** - Start passage at top, branches below
2. **Force-Directed** - Physics-based layout
3. **Grid Layout** - Organize in rows

**Implementation**:

```javascript
autoLayoutTree() {
    const startPassageId = this.editor.project.settings.startPassage;
    const startPassage = this.editor.project.passages.find(p => p.id === startPassageId);

    if (!startPassage) return;

    const levels = this.calculatePassageLevels(startPassage);
    const horizontalSpacing = 300;
    const verticalSpacing = 200;

    for (const [level, passages] of levels.entries()) {
        const yPos = level * verticalSpacing + 100;
        const totalWidth = (passages.length - 1) * horizontalSpacing;
        const startX = -totalWidth / 2 + 400; // Center horizontally

        passages.forEach((passage, index) => {
            passage.position.x = startX + index * horizontalSpacing;
            passage.position.y = yPos;
        });
    }

    this.render();
}

calculatePassageLevels(startPassage) {
    const levels = new Map();
    const visited = new Set();
    const queue = [{passage: startPassage, level: 0}];

    while (queue.length > 0) {
        const {passage, level} = queue.shift();

        if (visited.has(passage.id)) continue;
        visited.add(passage.id);

        if (!levels.has(level)) {
            levels.set(level, []);
        }
        levels.get(level).push(passage);

        // Add children to queue
        for (const choice of passage.choices) {
            const childPassage = this.editor.project.passages.find(p => p.id === choice.target);
            if (childPassage && !visited.has(childPassage.id)) {
                queue.push({passage: childPassage, level: level + 1});
            }
        }
    }

    return levels;
}
```

#### 8.5 Minimap

**Implementation**:

```html
<!-- Add to graph view -->
<div id="minimap" class="minimap">
    <canvas id="minimapCanvas"></canvas>
</div>
```

```javascript
renderMinimap() {
    const miniCanvas = document.getElementById('minimapCanvas');
    const ctx = miniCanvas.getContext('2d');

    // Scale down entire graph
    const scale = 0.1;
    ctx.clearRect(0, 0, miniCanvas.width, miniCanvas.height);
    ctx.save();
    ctx.scale(scale, scale);

    // Draw passages as small dots
    for (const passage of this.editor.project.passages) {
        ctx.fillStyle = '#3498db';
        ctx.fillRect(passage.position.x, passage.position.y, 10, 10);
    }

    // Draw viewport rectangle
    ctx.strokeStyle = '#e74c3c';
    ctx.lineWidth = 2;
    ctx.strokeRect(
        -this.panX / this.zoom,
        -this.panY / this.zoom,
        this.canvas.width / this.zoom,
        this.canvas.height / this.zoom
    );

    ctx.restore();
}
```

---

## Implementation Timeline

### Week 1: Backend Tests
- Day 1-2: Fix failing tests
- Day 3-4: Add missing unit tests
- Day 5: Set up CI/CD

### Week 2: Preview Mode
- Day 1-2: Create preview UI and runtime
- Day 3: Add debug panel
- Day 4-5: Testing and polish

### Week 3: Graph Editor
- Day 1: Drag & drop creation
- Day 2: Visual link creation
- Day 3: Multi-select
- Day 4: Auto-layout
- Day 5: Minimap and polish

---

## Success Metrics

### Phase 6
- ✅ All 35+ tests passing
- ✅ 80%+ code coverage
- ✅ CI/CD running on every commit
- ✅ 0 failing tests in main branch

### Phase 7
- ✅ Preview works for all passage types
- ✅ Variables update correctly
- ✅ Debug panel shows accurate state
- ✅ Smooth navigation between passages

### Phase 8
- ✅ All interactions feel natural
- ✅ Performance: 60 FPS with 100+ passages
- ✅ Auto-layout produces readable graphs
- ✅ Multi-select works intuitively

---

**Next Step**: Begin with Phase 6.1 - Fix failing Lua tests
