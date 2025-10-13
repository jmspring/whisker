# Next Steps: Full Twine Support & Complete HTML Exports

**Created:** 2025-10-13
**Status:** Planning
**Priority:** High

---

## Overview

This plan covers two major feature additions:
1. **Full Twine Import/Export** - Bidirectional compatibility with Twine 2
2. **Complete HTML Exports** - Fully-featured standalone HTML with embedded LuaWhiskerPlayer

---

## Part 1: Full Twine Import Support

### Current State
✅ **Twine Export** - Basic export exists (`export.js:579-611`)
- Exports to Twine HTML format
- Includes passages, positions, links
- Uses Harlowe format

❌ **Twine Import** - Does not exist yet

### Goal
Enable importing Twine 2 story files into Whisker editor with full preservation of:
- Passages and content
- Links/choices
- Variables (best effort)
- Metadata (title, author, IFID)
- Passage positions (for graph view)

### Implementation Tasks

#### Task 1: Create Twine Parser Module
**File:** `editor/web/js/twine-parser.js` (new file)

**Features:**
```javascript
class TwineParser {
    /**
     * Parse Twine 2 HTML file
     * @param {string} htmlContent - Raw HTML from .html file
     * @returns {Object} Parsed story data in Whisker format
     */
    static parse(htmlContent) {
        // 1. Extract <tw-storydata> element
        // 2. Parse story metadata (name, ifid, format, etc.)
        // 3. Extract all <tw-passagedata> elements
        // 4. Convert each passage to Whisker format
        // 5. Parse links and convert to choices
        // 6. Return Whisker-compatible project structure
    }

    /**
     * Extract story metadata from tw-storydata
     */
    static extractMetadata(storyDataElement) {
        return {
            title: storyDataElement.getAttribute('name'),
            author: storyDataElement.getAttribute('creator') || 'Unknown',
            ifid: storyDataElement.getAttribute('ifid'),
            format: storyDataElement.getAttribute('format'),
            startPassage: storyDataElement.getAttribute('start')
        };
    }

    /**
     * Parse a single Twine passage
     */
    static parsePassage(passageElement) {
        const pid = passageElement.getAttribute('pid');
        const name = passageElement.getAttribute('name');
        const tags = passageElement.getAttribute('tags').split(' ');
        const position = passageElement.getAttribute('position').split(',');
        const content = passageElement.textContent;

        // Convert Twine link syntax to Whisker choices
        const choices = this.extractLinks(content);
        const cleanContent = this.stripLinks(content);

        return {
            id: this.generatePassageId(name),
            title: name,
            content: cleanContent,
            choices: choices,
            position: {
                x: parseInt(position[0]),
                y: parseInt(position[1])
            },
            tags: tags,
            twineData: { pid, originalName: name }
        };
    }

    /**
     * Extract Twine links from content
     * Supports formats:
     * - [[Link text]]
     * - [[Link text|Passage Name]]
     * - [[Link text->Passage Name]]
     * - [[Passage Name<-Link text]]
     */
    static extractLinks(content) {
        const linkRegex = /\[\[([^\]]+)\]\]/g;
        const choices = [];

        let match;
        while ((match = linkRegex.exec(content)) !== null) {
            const linkContent = match[1];
            const choice = this.parseLinkFormat(linkContent);
            if (choice) choices.push(choice);
        }

        return choices;
    }

    /**
     * Parse different Twine link formats
     */
    static parseLinkFormat(linkContent) {
        // [[Text|Target]]
        if (linkContent.includes('|')) {
            const [text, target] = linkContent.split('|');
            return { text: text.trim(), target: this.generatePassageId(target.trim()) };
        }

        // [[Text->Target]]
        if (linkContent.includes('->')) {
            const [text, target] = linkContent.split('->');
            return { text: text.trim(), target: this.generatePassageId(target.trim()) };
        }

        // [[Target<-Text]]
        if (linkContent.includes('<-')) {
            const [target, text] = linkContent.split('<-');
            return { text: text.trim(), target: this.generatePassageId(target.trim()) };
        }

        // [[Text]] (text is also the target)
        return {
            text: linkContent.trim(),
            target: this.generatePassageId(linkContent.trim())
        };
    }

    /**
     * Remove Twine links from content (they become choices)
     */
    static stripLinks(content) {
        return content.replace(/\[\[([^\]]+)\]\]/g, '').trim();
    }

    /**
     * Generate Whisker-style passage IDs from Twine names
     */
    static generatePassageId(name) {
        return name
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '_')
            .replace(/^_+|_+$/g, '');
    }

    /**
     * Convert Twine macros/variables (basic support)
     */
    static convertTwineMacros(content) {
        // Basic conversions:
        // (set: $var to value) -> {{lua: game_state:set("var", value)}}
        // (if: $var)[content] -> {{#if var}}content{{/if}}
        // $var -> {{var}}

        let converted = content;

        // Convert variable display: $var -> {{var}}
        converted = converted.replace(/\$(\w+)/g, '{{$1}}');

        // Convert (set:) macros - simplified
        converted = converted.replace(
            /\(set:\s*\$(\w+)\s+to\s+([^\)]+)\)/g,
            '{{lua: game_state:set("$1", $2)}}'
        );

        // Convert (if:) macros - basic case
        converted = converted.replace(
            /\(if:\s*\$(\w+)\)\[([^\]]+)\]/g,
            '{{#if $1}}$2{{/if}}'
        );

        return converted;
    }

    /**
     * Detect Twine story format
     */
    static detectFormat(storyDataElement) {
        const format = storyDataElement.getAttribute('format') || '';

        if (format.includes('Harlowe')) return 'harlowe';
        if (format.includes('SugarCube')) return 'sugarcube';
        if (format.includes('Snowman')) return 'snowman';
        if (format.includes('Chapbook')) return 'chapbook';

        return 'unknown';
    }
}
```

#### Task 2: Add Import UI to Editor
**File:** `editor/web/index.html`

Add "Import from Twine" button to toolbar:
```html
<button class="btn-secondary btn" onclick="twineImporter.showImportDialog()">
    Import from Twine
</button>
```

**File:** `editor/web/js/twine-importer.js` (new file)

```javascript
class TwineImporter {
    constructor(editor) {
        this.editor = editor;
    }

    showImportDialog() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.html';
        input.onchange = (e) => this.handleFileSelect(e);
        input.click();
    }

    async handleFileSelect(event) {
        const file = event.target.files[0];
        if (!file) return;

        try {
            const htmlContent = await file.text();
            const whiskerProject = TwineParser.parse(htmlContent);

            // Confirm import
            const confirmed = confirm(
                `Import "${whiskerProject.metadata.title}" from Twine?\n\n` +
                `Passages: ${whiskerProject.passages.length}\n` +
                `Format: ${whiskerProject.metadata.format || 'Unknown'}\n\n` +
                `This will replace your current project.`
            );

            if (confirmed) {
                this.editor.project = whiskerProject;
                this.editor.renderAll();
                this.editor.updateStatus(`✓ Imported from Twine: ${whiskerProject.metadata.title}`);
            }
        } catch (error) {
            console.error('Twine import failed:', error);
            alert(`Failed to import Twine story:\n\n${error.message}`);
        }
    }
}
```

#### Task 3: Enhanced Twine Export
**File:** `editor/web/js/export.js`

Enhance existing `exportTwine()` method:

```javascript
exportTwine() {
    console.log('[Export] Generating enhanced Twine HTML...');

    // Detect if Lua is used
    const hasLua = this.detectLuaUsage();

    let html = `<tw-storydata name="${this.escapeXML(this.editor.project.metadata.title)}" `;
    html += `creator="Whisker" creator-version="1.0.0" `;
    html += `ifid="${this.editor.project.metadata.ifid || this.generateIFID()}" `;
    html += `format="Harlowe" format-version="3.2.3" `;
    html += `start="${this.editor.project.settings.startPassage}" `;
    html += `options="" hidden>\n`;

    // Add special metadata passage for Lua support
    if (hasLua) {
        html += `<tw-passagedata pid="1" name="StoryData" tags="script">\n`;
        html += `{\n`;
        html += `  "whisker": {\n`;
        html += `    "requiresLua": true,\n`;
        html += `    "fengariVersion": "0.1.4"\n`;
        html += `  }\n`;
        html += `}\n`;
        html += `</tw-passagedata>\n`;
    }

    // Export passages
    this.editor.project.passages.forEach((passage, index) => {
        const pos = passage.position || { x: 100 + (index * 200), y: 100 };
        const pid = passage.twineData?.pid || (index + 2);

        html += `<tw-passagedata pid="${pid}" `;
        html += `name="${this.escapeXML(passage.title)}" `;
        html += `tags="${passage.tags ? passage.tags.join(' ') : ''}" `;
        html += `position="${pos.x},${pos.y}">\n`;

        // Convert Whisker content to Twine format
        let content = this.convertWhiskerToTwine(passage.content);

        // Add choices as Twine links
        passage.choices.forEach(choice => {
            const targetPassage = this.editor.project.passages.find(p => p.id === choice.target);
            const targetTitle = targetPassage ? targetPassage.title : choice.target;
            content += `\n[[${choice.text}|${targetTitle}]]`;
        });

        html += this.escapeXML(content);
        html += `\n</tw-passagedata>\n`;
    });

    html += `</tw-storydata>`;

    this.downloadFile(
        html,
        this.getFilename('_twine.html'),
        'text/html'
    );

    return true;
}

/**
 * Convert Whisker syntax to Twine/Harlowe syntax
 */
convertWhiskerToTwine(content) {
    let converted = content;

    // Convert {{variable}} to $variable
    converted = converted.replace(/\{\{(\w+)\}\}/g, '$$$$1');

    // Convert {{#if var}} to (if: $var)[
    converted = converted.replace(/\{\{#if\s+(\w+)\}\}/g, '(if: $$$$1)[');
    converted = converted.replace(/\{\{\/if\}\}/g, ']');
    converted = converted.replace(/\{\{else\}\}/g, '](else:)[');

    // Convert {{lua:}} blocks to Harlowe (run:) macro
    converted = converted.replace(
        /\{\{lua:([\s\S]*?)\}\}/g,
        '(run: (js: "$1"))'
    );

    return converted;
}
```

---

## Part 2: Complete HTML Export with Full Runtime

### Current State
✅ **Basic HTML Export** - Works but minimal
- Simple player with basic rendering
- Variables display
- No save/load, no history, no theming
- Basic styling only

❌ **Full Runtime Export** - Not implemented

### Goal
Export standalone HTML files that include:
- **Full LuaWhiskerPlayer** with all features
- **Complete CSS** from `web_runtime.css`
- **Full UI** (stats sidebar, history, controls)
- **Save/Load system** (localStorage)
- **Theme support** (light/dark/sepia)
- **Undo/Redo** functionality
- **Settings** (font size, animations)
- **Progress tracking**
- **Responsive design**

### Implementation Tasks

#### Task 1: Create Embeddable Runtime Template
**File:** `editor/web/js/runtime-template.js` (new file)

```javascript
/**
 * Full Whisker Runtime Template
 * This is the complete runtime that gets embedded in HTML exports
 */
class RuntimeTemplate {
    /**
     * Get the full HTML template with embedded runtime
     */
    static getFullRuntime(storyData, options = {}) {
        const needsLua = options.needsLua || false;
        const title = storyData.metadata?.title || 'Whisker Story';
        const author = storyData.metadata?.author || '';

        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${this.escape(title)}</title>
    ${needsLua ? this.getFengariScript() : ''}
    ${this.getEmbeddedCSS()}
</head>
<body>
    ${this.getHTMLStructure(storyData)}
    ${this.getEmbeddedPlayer(needsLua)}
    ${this.getInitializationScript(storyData)}
</body>
</html>`;
    }

    /**
     * Get Fengari script tag
     */
    static getFengariScript() {
        return `<!-- Fengari: Lua VM for JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js"></script>`;
    }

    /**
     * Get embedded CSS from web_runtime.css
     */
    static getEmbeddedCSS() {
        // Option 1: Inline the full CSS
        // Option 2: Minify and inline
        // For now, we'll reference it, but in production, inline it
        return `<style>
        ${this.getMinifiedCSS()}
    </style>`;
    }

    /**
     * Get minified CSS (read from web_runtime.css and minify)
     */
    static getMinifiedCSS() {
        // This would be the full CSS from web_runtime.css, minified
        // For implementation: read the CSS file and minify it
        return `/* Full web_runtime.css content, minified */`;
    }

    /**
     * Get HTML structure matching web_runtime.css classes
     */
    static getHTMLStructure(storyData) {
        return `
    <div class="whisker-app" id="whisker-container">
        <!-- Header -->
        <div class="whisker-header">
            <div class="whisker-title-section">
                <h1 class="whisker-title" id="story-title">${this.escape(storyData.metadata?.title)}</h1>
                <div class="whisker-subtitle" id="story-author">${this.escape(storyData.metadata?.author)}</div>
            </div>
            <div class="whisker-controls">
                <button class="whisker-btn whisker-save-btn" onclick="player.showSaveModal()">
                    <span class="whisker-icon">💾</span>
                    <span class="whisker-btn-text">Save</span>
                </button>
                <button class="whisker-btn whisker-load-btn" onclick="player.showLoadModal()">
                    <span class="whisker-icon">📂</span>
                    <span class="whisker-btn-text">Load</span>
                </button>
                <button class="whisker-btn whisker-undo-btn" onclick="player.undo()">
                    <span class="whisker-icon">↶</span>
                    <span class="whisker-btn-text">Undo</span>
                </button>
                <button class="whisker-btn whisker-restart-btn" onclick="player.restart()">
                    <span class="whisker-icon">↻</span>
                    <span class="whisker-btn-text">Restart</span>
                </button>
                <button class="whisker-btn whisker-settings-btn" onclick="player.showSettingsModal()">
                    <span class="whisker-icon">⚙️</span>
                    <span class="whisker-btn-text">Settings</span>
                </button>
            </div>
        </div>

        <!-- Progress Bar -->
        <div class="whisker-progress-bar">
            <div class="whisker-progress-fill" id="progress-bar"></div>
        </div>

        <!-- Main Content -->
        <div class="whisker-main">
            <div class="whisker-content">
                <div class="whisker-passage">
                    <h2 class="whisker-passage-title" id="passage-title"></h2>
                    <div class="whisker-passage-content" id="passage-content"></div>
                    <div class="whisker-choices" id="choices-container"></div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="whisker-sidebar">
                <div class="whisker-sidebar-section">
                    <div class="whisker-sidebar-heading">Stats</div>
                    <div class="whisker-stats" id="stats-container"></div>
                </div>
                <div class="whisker-sidebar-section">
                    <div class="whisker-sidebar-heading">Progress</div>
                    <div class="whisker-progress-info" id="progress-info"></div>
                </div>
                <div class="whisker-sidebar-section">
                    <div class="whisker-sidebar-heading">History</div>
                    <div class="whisker-history" id="history-container"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Save/Load Modal -->
    <div class="whisker-modal" id="saveLoadModal">
        <div class="whisker-modal-overlay" onclick="player.hideModal('saveLoadModal')"></div>
        <div class="whisker-modal-content">
            <div class="whisker-modal-header">
                <h2 class="whisker-modal-title" id="modal-title">Save Game</h2>
                <button class="whisker-modal-close" onclick="player.hideModal('saveLoadModal')">×</button>
            </div>
            <div class="whisker-modal-body" id="save-load-content"></div>
        </div>
    </div>

    <!-- Settings Modal -->
    <div class="whisker-modal" id="settingsModal">
        <div class="whisker-modal-overlay" onclick="player.hideModal('settingsModal')"></div>
        <div class="whisker-modal-content">
            <div class="whisker-modal-header">
                <h2 class="whisker-modal-title">Settings</h2>
                <button class="whisker-modal-close" onclick="player.hideModal('settingsModal')">×</button>
            </div>
            <div class="whisker-modal-body" id="settings-content"></div>
        </div>
    </div>

    <!-- Notifications -->
    <div class="whisker-notifications" id="notifications"></div>`;
    }

    /**
     * Get embedded player (LuaWhiskerPlayer or standard)
     */
    static getEmbeddedPlayer(needsLua) {
        if (needsLua) {
            return `<script>
        ${this.getLuaWhiskerPlayerCode()}
    </script>`;
        } else {
            return `<script>
        ${this.getStandardWhiskerPlayerCode()}
    </script>`;
        }
    }

    /**
     * Get full LuaWhiskerPlayer code
     */
    static getLuaWhiskerPlayerCode() {
        // Read from examples/web_runtime/lua-runtime.html
        // Extract the LuaWhiskerPlayer class
        // Return as string
        return `// Full LuaWhiskerPlayer class from lua-runtime.html`;
    }

    /**
     * Get standard WhiskerPlayer code
     */
    static getStandardWhiskerPlayerCode() {
        // Similar player but without Lua support
        return `// Standard WhiskerPlayer class`;
    }

    /**
     * Get initialization script
     */
    static getInitializationScript(storyData) {
        return `<script>
        // Story data
        const STORY_DATA = ${JSON.stringify(storyData, null, 2)};

        // Initialize player
        window.player = new ${storyData.needsLua ? 'LuaWhiskerPlayer' : 'WhiskerPlayer'}();
        player.loadStory(STORY_DATA);
        player.start();

        console.log('Whisker story loaded successfully!');
    </script>`;
    }

    /**
     * Escape HTML
     */
    static escape(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}
```

#### Task 2: Update Export System
**File:** `editor/web/js/export.js`

Replace `exportHTML()` with new implementation:

```javascript
exportHTML() {
    console.log('[Export] Generating full-featured HTML export...');

    const needsLua = this.detectLuaUsage();
    console.log('[Export] Lua support:', needsLua);

    // Prepare story data
    const storyData = {
        metadata: this.editor.project.metadata,
        settings: this.editor.project.settings,
        variables: this.options.includeVariables ? this.editor.project.variables : {},
        passages: this.editor.project.passages.map(p => ({
            id: p.id,
            title: p.title,
            content: p.content,
            choices: p.choices
        })),
        needsLua: needsLua
    };

    // Generate full runtime HTML
    const html = RuntimeTemplate.getFullRuntime(storyData, {
        needsLua: needsLua,
        includeStats: this.options.includeVariables,
        theme: this.options.theme || 'light'
    });

    this.downloadFile(
        html,
        this.getFilename('.html'),
        'text/html'
    );

    console.log('[Export] Full HTML export complete');
    return true;
}
```

#### Task 3: Extract Player Code as Module
**File:** `src/runtime/lua-whisker-player.js` (new file)

Extract LuaWhiskerPlayer class from `lua-runtime.html` into standalone module:

```javascript
/**
 * LuaWhiskerPlayer - Full-featured Whisker player with Lua support
 * Can be embedded in standalone HTML exports or used in web runtime
 */
class LuaWhiskerPlayer {
    // Full implementation from lua-runtime.html
    // This becomes the canonical source
}

// Make available for embedding
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LuaWhiskerPlayer;
}
```

#### Task 4: CSS Inlining Tool
**File:** `editor/web/js/css-inliner.js` (new file)

```javascript
/**
 * Read and minify CSS for embedding
 */
class CSSInliner {
    /**
     * Read CSS file and return minified version
     */
    static async getMinifiedCSS() {
        try {
            const response = await fetch('../../src/runtime/web_runtime.css');
            const css = await response.text();
            return this.minify(css);
        } catch (error) {
            console.error('Failed to load CSS:', error);
            return '';
        }
    }

    /**
     * Simple CSS minifier
     */
    static minify(css) {
        return css
            .replace(/\/\*[\s\S]*?\*\//g, '') // Remove comments
            .replace(/\s+/g, ' ')              // Collapse whitespace
            .replace(/\s*([{}:;,])\s*/g, '$1') // Remove space around special chars
            .trim();
    }
}
```

---

## Implementation Priority

### Phase 1: Full HTML Export (Highest Priority)
**Estimated Time:** 4-6 hours

**Why First:**
- Immediately useful for all users
- Makes exports production-ready
- Showcases Whisker's full capabilities
- Required for proper Lua story distribution

**Tasks:**
1. Create `runtime-template.js` with full template
2. Extract `lua-whisker-player.js` as standalone module
3. Create `css-inliner.js` for CSS embedding
4. Update `exportHTML()` in `export.js`
5. Test exports with various stories (Lua and non-Lua)

**Deliverables:**
- Standalone HTML files with full UI
- Save/load functionality
- Theme support
- Complete responsive design
- ~50-60KB exports (without Lua), ~550-600KB (with Lua)

### Phase 2: Twine Import (Second Priority)
**Estimated Time:** 6-8 hours

**Why Second:**
- Opens Whisker to existing Twine user base
- Allows testing Whisker with proven content
- Enables migration path from Twine
- More complex than export due to format differences

**Tasks:**
1. Create `twine-parser.js` with full parsing
2. Create `twine-importer.js` for UI integration
3. Add import button to editor
4. Test with various Twine stories (Harlowe, SugarCube)
5. Handle edge cases and format differences

**Deliverables:**
- Import button in editor toolbar
- Parser for Twine 2 HTML format
- Link format conversion
- Basic macro conversion (Harlowe → Whisker)
- Position preservation for graph view

### Phase 3: Enhanced Twine Export (Third Priority)
**Estimated Time:** 2-3 hours

**Why Third:**
- Current export is functional
- Enhancement improves round-trip capability
- Supports Twine → Whisker → Twine workflow

**Tasks:**
1. Enhance `exportTwine()` with better conversion
2. Add metadata for Lua support indication
3. Convert Whisker syntax to Harlowe
4. Preserve passage positions
5. Add format selection (Harlowe, SugarCube, etc.)

**Deliverables:**
- Better Whisker → Twine conversion
- Lua support metadata
- Format selection in export dialog
- Improved round-trip compatibility

---

## Testing Strategy

### For Full HTML Export
1. **Basic stories** - No Lua, simple variables
2. **RPG stories** - Full Lua, all templates
3. **Large stories** - 50+ passages
4. **Various browsers** - Chrome, Firefox, Safari, Edge
5. **Mobile devices** - iOS Safari, Chrome Android
6. **Offline functionality** - Disconnect and test
7. **Save/load** - Multiple slots, data persistence
8. **Themes** - Light, dark, sepia

### For Twine Import
1. **Simple Harlowe stories** - Basic links
2. **Complex Harlowe** - Macros, variables
3. **SugarCube stories** - Different syntax
4. **Large Twine stories** - Performance testing
5. **Various link formats** - All Twine link styles
6. **Position preservation** - Graph view accuracy

---

## File Structure After Implementation

```
whisker/
├── editor/web/js/
│   ├── twine-parser.js          [NEW] Parse Twine HTML
│   ├── twine-importer.js        [NEW] Import UI
│   ├── runtime-template.js      [NEW] Full HTML template
│   ├── css-inliner.js          [NEW] CSS minifier
│   ├── export.js               [MODIFIED] Enhanced exports
│   └── ...
├── src/runtime/
│   ├── lua-whisker-player.js   [NEW] Extracted player
│   ├── whisker-player.js       [NEW] Standard player
│   ├── web_runtime.css         [EXISTING]
│   └── ...
├── examples/
│   ├── exports/                [NEW] Example exports
│   │   ├── basic-story.html
│   │   ├── rpg-story.html
│   │   └── twine-imported.whisker
│   └── ...
└── docs/
    ├── TWINE_IMPORT_GUIDE.md   [NEW]
    ├── EXPORT_GUIDE.md         [NEW]
    └── ...
```

---

## Success Criteria

### Full HTML Export ✓
- [ ] Exported files match runtime experience
- [ ] Save/load works in exported files
- [ ] All themes work (light/dark/sepia)
- [ ] File size < 100KB (no Lua), < 600KB (with Lua)
- [ ] Works offline without internet
- [ ] Responsive on mobile devices
- [ ] Backward compatible with old exports

### Twine Import ✓
- [ ] Imports Harlowe stories successfully
- [ ] Converts links to choices correctly
- [ ] Preserves passage positions
- [ ] Handles all link formats
- [ ] Converts basic macros
- [ ] Shows clear error messages
- [ ] Doesn't corrupt existing project

### Twine Export Enhancement ✓
- [ ] Exports work in Twine 2
- [ ] Round-trip (Twine → Whisker → Twine) preserves content
- [ ] Lua metadata included
- [ ] Format selection works
- [ ] Position data preserved

---

## Documentation Needed

1. **TWINE_IMPORT_GUIDE.md**
   - How to import from Twine
   - Supported formats and features
   - Known limitations
   - Conversion examples

2. **EXPORT_GUIDE.md**
   - Export format comparison
   - Full HTML export features
   - Customization options
   - Distribution best practices

3. **TWINE_COMPATIBILITY.md**
   - Twine format comparison
   - Macro conversion table
   - Feature mapping
   - Migration guide

4. **Update README.md**
   - Add Twine compatibility section
   - Showcase export features
   - Add example exports

---

## Estimated Total Time

| Phase | Time | Difficulty |
|-------|------|------------|
| Full HTML Export | 4-6 hours | Medium-High |
| Twine Import | 6-8 hours | High |
| Enhanced Twine Export | 2-3 hours | Medium |
| Testing | 3-4 hours | Medium |
| Documentation | 2-3 hours | Low |
| **Total** | **17-24 hours** | **High** |

---

## Next Immediate Step

**Start with Phase 1: Full HTML Export**

1. Create `editor/web/js/runtime-template.js`
2. Extract LuaWhiskerPlayer to `src/runtime/lua-whisker-player.js`
3. Update `export.js` to use RuntimeTemplate
4. Test with existing stories

This gives immediate value and can be delivered incrementally while working on Twine support.

---

**Would you like me to start implementing Phase 1 (Full HTML Export) now?**
