# Twine Import Testing Guide

Test the Twine import functionality with provided sample files.

---

## Test Files

Two sample Twine stories are provided:

### 1. `sample-twine-harlowe.html`
- **Format**: Harlowe 3.2.3
- **Story**: "Test Adventure" - Simple dungeon crawler
- **Features tested**:
  - Variable initialization: `(set: $var to value)`
  - Variable display: `$health`, `$gold`, `$hasKey`
  - Conditionals: `(if: $hasKey)[...]` and `(else:)[...]`
  - Link formats: `[[Text->Target]]`, `[[Text]]`
  - Print macro: `(print: ...)`
  - Math operations: `$gold + 100`, `$health - 10`
  - Passage tags: `danger`, `menu`, `ending`
  - 8 passages with graph positions

### 2. `sample-twine-sugarcube.html`
- **Format**: SugarCube 2.36.1
- **Story**: "Space Adventure" - Sci-fi exploration
- **Features tested**:
  - Variable initialization: `<<set $var to value>>`
  - Variable display: `$fuel`, `$crew`, `$hasShield`
  - Conditionals: `<<if $condition>>...<<else>>...<<endif>>`
  - Link formats: `[[Text|Target]]`, `[[Text]]`
  - Print macro: `<<print ...>>`
  - Math operations: `$fuel - 20`, `$crew + 1`
  - Comparison operators: `$crew > 1`, `$fuel < 30`
  - Passage tags: `danger`, `menu`, `ending`
  - 8 passages with graph positions

---

## Running Tests

### Manual Testing

1. **Start the Whisker editor**:
   ```bash
   cd editor/web
   python3 -m http.server 8000
   # or
   npx http-server -p 8000
   ```
   Open http://localhost:8000 in your browser

2. **Test Harlowe Import**:
   - Click "📥 Import Twine" button
   - Select `test/sample-twine-harlowe.html`
   - Verify confirmation dialog shows:
     - Title: "Test Adventure"
     - Format: "harlowe 3.2.3"
     - Creator: "Test Creator"
     - Passages: 8
     - Variables: 3 (health, hasKey, gold)
   - Click OK to import
   - Verify graph view shows 8 passages
   - Check Variables panel has: health (100), hasKey (false), gold (50)

3. **Test SugarCube Import**:
   - Refresh page (or create new project)
   - Click "📥 Import Twine" button
   - Select `test/sample-twine-sugarcube.html`
   - Verify confirmation dialog shows:
     - Title: "Space Adventure"
     - Format: "sugarcube 2.36.1"
     - Creator: "Test Creator"
     - Passages: 8
     - Variables: 3 (fuel, crew, hasShield)
   - Click OK to import
   - Verify graph view shows 8 passages
   - Check Variables panel has: fuel (100), crew (5), hasShield (false)

---

## Test Checklist

### Import Process

- [ ] **File selection dialog opens**
- [ ] **Large file warning** (not triggered by test files, they're small)
- [ ] **Confirmation dialog shows** with correct metadata
- [ ] **Format detection** works (Harlowe/SugarCube)
- [ ] **Progress indication** ("📥 Importing from Twine...")
- [ ] **Success notification** appears after import
- [ ] **Warning for existing project** (test by importing twice)

### Passage Conversion

- [ ] **All 8 passages imported** (check passage count in status bar)
- [ ] **Passage titles** preserved
- [ ] **Passage IDs** generated (lowercase, underscores)
- [ ] **Passage content** preserved
- [ ] **Passage tags** preserved (visible in passage metadata)
- [ ] **Passage positions** preserved in graph view

### Link Conversion

#### Harlowe Test Cases
- [ ] `[[Open the red door->Red Room]]` → Choice: "Open the red door"
- [ ] `[[Open the blue door->Blue Room]]` → Choice: "Open the blue door"
- [ ] `[[Take the key]]` → Choice: "Take the key" (same as target)
- [ ] `[[Check your inventory->Inventory]]` → Choice: "Check your inventory"
- [ ] Links removed from passage content
- [ ] All choices point to correct passage IDs

#### SugarCube Test Cases
- [ ] `[[Explore the asteroid field|Asteroids]]` → Choice: "Explore the asteroid field"
- [ ] `[[Visit the space station|Station]]` → Choice: "Visit the space station"
- [ ] `[[Check ship status|Status]]` → Choice: "Check ship status"
- [ ] Links removed from passage content
- [ ] All choices point to correct passage IDs

### Variable Conversion

#### Harlowe Variables
- [ ] `(set: $health to 100)` → `{{lua: game_state:set("health", 100)}}`
- [ ] `(set: $hasKey to false)` → `{{lua: game_state:set("hasKey", false)}}`
- [ ] `$health` → `{{health}}`
- [ ] `$gold` → `{{gold}}`
- [ ] Variables panel populated: health (100), hasKey (false), gold (50)

#### SugarCube Variables
- [ ] `<<set $fuel to 100>>` → `{{lua: game_state:set("fuel", 100)}}`
- [ ] `<<set $hasShield to false>>` → `{{lua: game_state:set("hasShield", false)}}`
- [ ] `$fuel` → `{{fuel}}`
- [ ] `$crew` → `{{crew}}`
- [ ] Variables panel populated: fuel (100), crew (5), hasShield (false)

### Conditional Conversion

#### Harlowe Conditionals
- [ ] `(if: $hasKey)[...]` → `{{#if hasKey}}...{{/if}}`
- [ ] `(else:)[...]` → `{{else}}...`
- [ ] `(if: $health <= 0)[...]` → `{{#if health <= 0}}...{{/if}}`

#### SugarCube Conditionals
- [ ] `<<if $hasShield>>...<<endif>>` → `{{#if hasShield}}...{{/if}}`
- [ ] `<<else>>...` → `{{else}}...`
- [ ] `<<if $crew > 1>>...<<endif>>` → `{{#if crew > 1}}...{{/if}}`

### Macro Conversion

#### Harlowe
- [ ] `(print: ...)` → `{{...}}` or text replacement

#### SugarCube
- [ ] `<<print ...>>` → `{{...}}` or text replacement

### Graph View

- [ ] **Passages positioned correctly** (not all at origin)
- [ ] **Start passage** identified (should be "Start" or "Launch")
- [ ] **Zoom controls work** after import
- [ ] **Auto-layout button** (⚡) works
- [ ] **Connections visible** between linked passages

### Editor Integration

- [ ] **Passage list** shows all passages
- [ ] **Clicking passage** in list opens editor
- [ ] **Variables panel** populated
- [ ] **Validation** finds no critical errors (some warnings OK for unconverted macros)
- [ ] **Preview** works with imported story
- [ ] **Undo/Redo** recorded import action
- [ ] **Save/Load** preserves imported story

### Error Handling

Test error conditions:

- [ ] **Invalid file** (try importing a text file) - should show error
- [ ] **Empty file** - should show error
- [ ] **Corrupted HTML** - should show error message
- [ ] **Cancel during file selection** - should do nothing
- [ ] **Cancel at confirmation dialog** - should not import

---

## Expected Results

### Harlowe Story After Import

**Passages**: 8
- start (Start passage)
- red_room
- blue_room
- take_the_key
- find_key
- inventory
- victory
- game_over

**Variables**: 3
```json
{
  "health": { "initial": 100, "type": "number" },
  "hasKey": { "initial": false, "type": "boolean" },
  "gold": { "initial": 50, "type": "number" }
}
```

**Sample Converted Content** (Start passage):
```
You wake up in a mysterious room. Your health is at {{health}}.

{{lua: game_state:set("health", 100)}}
{{lua: game_state:set("hasKey", false)}}
{{lua: game_state:set("gold", 50)}}

There are two doors in front of you.

Choices:
→ Open the red door (→ red_room)
→ Open the blue door (→ blue_room)
→ Check your inventory (→ inventory)
```

### SugarCube Story After Import

**Passages**: 8
- launch (Start passage)
- asteroids
- station
- refuel
- get_shields
- discovery
- status
- victory

**Variables**: 3
```json
{
  "fuel": { "initial": 100, "type": "number" },
  "crew": { "initial": 5, "type": "number" },
  "hasShield": { "initial": false, "type": "boolean" }
}
```

**Sample Converted Content** (Launch passage):
```
**Space Station Alpha**

You are the captain of a small spacecraft. Your ship has {{fuel}} fuel units remaining.

{{lua: game_state:set("fuel", 100)}}
{{lua: game_state:set("crew", 5)}}
{{lua: game_state:set("hasShield", false)}}

Mission Control gives you two options:

Choices:
→ Explore the asteroid field (→ asteroids)
→ Visit the space station (→ station)
→ Check ship status (→ status)
```

---

## Known Issues to Verify

Check if these known limitations are properly handled:

1. **Complex expressions** - Math expressions in macros may need manual review
2. **Nested conditionals** - May require adjustment
3. **String concatenation** - `(print: "text" + $var)` may not convert perfectly
4. **Comparison operators** - `>`, `<`, `>=`, `<=` should be preserved

---

## Validation Tests

After importing, run validation:

1. Click **"Validate"** button in Validation panel
2. Expected warnings (acceptable):
   - "Passage contains unconverted Twine syntax" (if any macros remain)
3. Should NOT have errors:
   - No broken links (all choices should resolve)
   - No missing passages

---

## Regression Tests

After any code changes to parser or importer:

1. **Re-run all tests** with both sample files
2. **Compare results** with expected output above
3. **Check console** for errors or warnings
4. **Test preview** - story should be playable
5. **Export and test** - exported HTML should work

---

## Performance Tests

For large story testing (optional):

- Create or find a Twine story with 50+ passages
- Verify import completes in reasonable time (< 5 seconds)
- Check memory usage doesn't spike
- Verify UI remains responsive

---

## Browser Compatibility

Test in multiple browsers:

- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari
- [ ] Mobile browsers (if applicable)

---

## Reporting Issues

If tests fail, report with:

1. **Test file used** (Harlowe or SugarCube)
2. **Test step** that failed
3. **Expected result**
4. **Actual result**
5. **Console errors** (open DevTools → Console)
6. **Screenshots** if helpful

---

## Test Script (Coming Soon)

Future: Automated test script to verify imports programmatically.

```javascript
// Planned automated test
async function testTwineImport(htmlFile) {
    const result = TwineParser.parse(htmlFile);
    assert(result.passages.length === 8);
    assert(result.variables.health.initial === 100);
    // ... more assertions
}
```

---

## Success Criteria

All tests pass when:

✅ Both sample files import without errors
✅ All passages, variables, and choices converted
✅ No broken links in validation
✅ Stories playable in preview
✅ Graph view displays correctly
✅ Exported HTML works standalone

---

**Last Updated**: October 2024
**Test Version**: 1.0.0
