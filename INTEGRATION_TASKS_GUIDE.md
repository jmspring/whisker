# Integration Tasks - Implementation Guide

**Status:** Ready to implement
**Prerequisites:** ✅ Lua runtime working (lua-runtime.html)

---

## Overview

We've completed "DO NOW" tasks. Here's the detailed guide for "DO NEXT" tasks:

### DO NOW ✅ COMPLETE
1. ✅ Created RPG story loader
2. ✅ Validated all 20+ templates
3. ✅ Documented findings

### DO NEXT 🔄 READY TO IMPLEMENT
4. 🔄 Integrate Lua into main runtime
5. 🔄 Add Lua to editor preview
6. 🔄 Update export system

---

## Task 4: Integrate Lua into Main Runtime

**Goal:** Make `examples/web_runtime/index.html` Lua-enabled by default

### Changes Needed

#### Step 1: Add Fengari to `<head>`
```html
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Whisker - Interactive Fiction</title>

    <!-- ADD THIS: Fengari Lua VM -->
    <script src="https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js"></script>

    <link rel="stylesheet" href="../../src/runtime/web_runtime.css">
```

#### Step 2: Replace WhiskerPlayer with LuaWhiskerPlayer

**Option A: Replace the class** (Recommended)
- Copy `LuaWhiskerPlayer` class from `lua-runtime.html`
- Replace `WhiskerPlayer` entirely
- Keep same interface (loadStory, start, etc.)

**Option B: Extend the class**
- Keep `WhiskerPlayer` for backward compatibility
- Add Lua methods:
  - `initializeLua()`
  - `executeLuaCode(code)`
  - Update `processInline()` to call `executeLuaCode()`

#### Step 3: Add Lua Block Processing

**In `processInline()` method, add:**
```javascript
processInline(content) {
    if (!content) return '';

    // ADD THIS: Process {{lua:}} blocks FIRST
    content = content.replace(/\{\{lua:([\s\S]*?)\}\}/g, (match, code) => {
        if (this.luaState && typeof fengari !== 'undefined') {
            this.executeLuaCode(code.trim());
        } else {
            console.warn('Lua runtime not available, skipping:', code.substring(0, 30) + '...');
        }
        return ''; // Lua blocks don't output text
    });

    // Rest of existing code...
    content = content.replace(/\{\{(.+?)\}\}/g, (match, expression) => {
        // ... existing variable substitution
    });

    return content;
}
```

#### Step 4: Test

1. Open `examples/web_runtime/index.html`
2. Add a {{lua:}} block to demo story
3. Verify it executes
4. Check console for Lua initialization message

---

## Task 5: Add Lua to Editor Preview

**Goal:** Execute {{lua:}} blocks in editor preview, not just show indicator

### Changes Needed

#### Step 1: Add Fengari to Editor

**File:** `editor/web/index.html`

```html
<head>
    <!-- Existing head content -->

    <!-- ADD THIS: Fengari for preview -->
    <script src="https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js"></script>
</head>
```

#### Step 2: Update Template Processor

**File:** `editor/web/js/template-processor.js`

**Current code:**
```javascript
static processLuaBlocks(content, variables) {
    // Shows indicator only
    return content.replace(/\{\{lua:([\s\S]*?)\}\}/g, (match, code) => {
        const codePreview = code.trim().split('\n')[0].substring(0, 50);
        return `<span style="...">🌙 Lua: ${codePreview}</span>`;
    });
}
```

**New code:**
```javascript
static processLuaBlocks(content, variables) {
    // Execute if Fengari available, otherwise show indicator
    if (typeof fengari !== 'undefined') {
        return content.replace(/\{\{lua:([\s\S]*?)\}\}/g, (match, code) => {
            try {
                this.executeLuaInPreview(code.trim(), variables);
                return ''; // Lua blocks don't output
            } catch (error) {
                console.error('Preview Lua error:', error);
                return `<span style="color: #ef4444;">Lua Error</span>`;
            }
        });
    } else {
        // Fallback: show indicator
        return content.replace(/\{\{lua:([\s\S]*?)\}\}/g, (match, code) => {
            const codePreview = code.trim().split('\n')[0].substring(0, 50);
            return `<span style="...">🌙 Lua: ${codePreview}</span>`;
        });
    }
}

static executeLuaInPreview(code, variables) {
    // Similar to LuaWhiskerPlayer.executeLuaCode()
    // Create Lua state
    // Set up game_state bridge
    // Execute code
    // Update variables object
}
```

#### Step 3: Initialize Lua State

**Add to `TemplateProcessor` class:**
```javascript
static initializeLua() {
    if (typeof fengari === 'undefined') {
        console.warn('Fengari not loaded, Lua preview disabled');
        this.luaState = null;
        return;
    }

    const lua = fengari.lua;
    const lauxlib = fengari.lauxlib;
    const lualib = fengari.lualib;

    this.luaState = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(this.luaState);

    console.log('✅ Lua preview enabled');
}
```

**Call during editor initialization:**
```javascript
// In editor initialization
document.addEventListener('DOMContentLoaded', () => {
    // Existing initialization...

    // ADD THIS:
    if (typeof TemplateProcessor !== 'undefined') {
        TemplateProcessor.initializeLua();
    }
});
```

#### Step 4: Benefits

- Authors see **actual results** in preview
- Test Lua code without exporting
- Catch errors during authoring
- Faster iteration

---

## Task 6: Update Export System

**Goal:** Exported HTML files include Lua runtime automatically

### Changes Needed

#### Step 1: Modify Export Function

**File:** `editor/web/js/export.js`

**Find the `exportToStandaloneHTML()` function**

**Current structure:**
```javascript
exportToStandaloneHTML() {
    const html = `<!DOCTYPE html>
<html>
<head>
    <title>${story.title}</title>
    <style>/* styles */</style>
</head>
<body>
    <div id="whisker-container"></div>
    <script>
        // WhiskerPlayer class
        // Story data
        // Initialize
    </script>
</body>
</html>`;

    return html;
}
```

**New structure:**
```javascript
exportToStandaloneHTML() {
    const needsLua = this.detectLuaUsage(this.project);

    const html = `<!DOCTYPE html>
<html>
<head>
    <title>${story.title}</title>
    ${needsLua ? '<script src="https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js"></script>' : ''}
    <style>/* styles */</style>
</head>
<body>
    <div id="whisker-container"></div>
    <script>
        // Use LuaWhiskerPlayer if needsLua, else WhiskerPlayer
        ${needsLua ? this.getLuaWhiskerPlayerCode() : this.getWhiskerPlayerCode()}
        // Story data
        // Initialize
    </script>
</body>
</html>`;

    return html;
}
```

#### Step 2: Add Lua Detection

```javascript
detectLuaUsage(project) {
    // Check if any passage contains {{lua:}} blocks
    for (const passage of project.passages) {
        if (passage.content && passage.content.includes('{{lua:')) {
            return true;
        }
    }
    return false;
}
```

#### Step 3: Embed Player Code

```javascript
getLuaWhiskerPlayerCode() {
    // Return minified LuaWhiskerPlayer class as string
    // Could load from separate file or inline
    return `
        class LuaWhiskerPlayer {
            // ... full class code ...
        }
    `;
}

getWhiskerPlayerCode() {
    // Return standard WhiskerPlayer for non-Lua stories
    return `
        class WhiskerPlayer {
            // ... full class code ...
        }
    `;
}
```

#### Step 4: Export Options

**Add checkbox to export dialog:**
```html
<div class="export-option">
    <input type="checkbox" id="exportWithLua" checked>
    <label for="exportWithLua">
        Include Lua Runtime (required for RPG templates)
        <span class="hint">Adds ~500KB for Fengari</span>
    </label>
</div>
```

---

## Implementation Checklist

### Task 4: Main Runtime
- [ ] Add Fengari script tag to index.html
- [ ] Copy LuaWhiskerPlayer class
- [ ] Replace WhiskerPlayer usage
- [ ] Test with demo story
- [ ] Test with {{lua:}} blocks
- [ ] Verify backward compatibility

### Task 5: Editor Preview
- [ ] Add Fengari to editor index.html
- [ ] Update processLuaBlocks() to execute
- [ ] Add executeLuaInPreview() method
- [ ] Initialize Lua state on load
- [ ] Test in editor preview panel
- [ ] Handle errors gracefully

### Task 6: Export System
- [ ] Add detectLuaUsage() function
- [ ] Modify exportToStandaloneHTML()
- [ ] Embed LuaWhiskerPlayer code
- [ ] Add export option checkbox
- [ ] Test exported files
- [ ] Verify file size (~500KB increase)

---

## Testing Plan

### After Task 4
```bash
# 1. Open main runtime
open examples/web_runtime/index.html

# 2. Modify demo story to include:
content: "Test: {{lua: game_state:set('test', 123) }} Value: {{test}}"

# 3. Should see: "Test:  Value: 123"
```

### After Task 5
```bash
# 1. Open editor
open editor/web/index.html

# 2. Create passage with Lua block
# 3. Check preview - should show results
# 4. Modify code - preview updates
```

### After Task 6
```bash
# 1. Create story with {{lua:}} blocks
# 2. Export to Standalone HTML
# 3. Open exported file
# 4. Verify Lua code executes
# 5. Check file includes Fengari
```

---

## File Size Impact

| Component | Before | After | Increase |
|-----------|--------|-------|----------|
| Runtime HTML | ~27KB | ~27KB | 0 (CDN) |
| Exported HTML | ~50KB | ~550KB | ~500KB |
| Editor HTML | ~100KB | ~100KB | 0 (CDN) |

**Note:** Fengari loaded from CDN, so no bundle size increase for hosted files.

---

## Backward Compatibility

### Stories Without {{lua:}}
- ✅ Continue to work normally
- ✅ No performance impact
- ✅ Fengari loads but isn't used

### Old Exported Files
- ✅ Still work (no Lua)
- ✅ Not affected by changes

### Migration Path
1. Old stories: Work as-is
2. Add {{lua:}} blocks: Automatic Lua support
3. Re-export: Gets Lua runtime
4. No breaking changes

---

## Performance Considerations

### Load Time
- Fengari WASM: ~500KB
- First load: ~1-2 seconds
- Cached: Instant

### Runtime Performance
- Lua execution: Near-native speed
- Minimal overhead for non-Lua content
- Memory: ~5-10MB for Lua state

### Optimization
- CDN caching (1 year)
- Lazy load Fengari (only if {{lua:}} detected)
- Minify embedded player code

---

## Alternative Approaches

### Lazy Loading
```javascript
// Only load Fengari if needed
if (this.detectLuaUsage()) {
    await this.loadFengari();
}
```

### Separate Builds
- `whisker-basic.html` - No Lua (~27KB)
- `whisker-lua.html` - With Lua (~527KB)

### Transpilation
- Convert Lua to JavaScript at export time
- Smaller bundle, faster load
- More complex, less flexible

---

## Estimated Effort

| Task | Time | Difficulty |
|------|------|------------|
| Task 4: Main Runtime | 1 hour | Medium |
| Task 5: Editor Preview | 2 hours | Medium-High |
| Task 6: Export System | 1 hour | Medium |
| Testing | 1 hour | Low |
| **Total** | **5 hours** | **Medium** |

---

## Success Criteria

✅ Main runtime supports {{lua:}} blocks
✅ Editor preview executes Lua code
✅ Exported files include Lua if needed
✅ All templates work in runtime
✅ Backward compatibility maintained
✅ No breaking changes

---

## Next Steps

1. **Review this guide**
2. **Implement Task 4** (main runtime)
3. **Test thoroughly**
4. **Implement Task 5** (editor preview)
5. **Implement Task 6** (export)
6. **Final testing**
7. **Update documentation**
8. **Merge to main**

---

**Created:** 2025-10-13
**Status:** Ready to implement
**Priority:** High
**Dependencies:** None (Lua runtime complete)
