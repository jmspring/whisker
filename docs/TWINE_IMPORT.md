# Twine Import Guide

Import your existing Twine 2 stories into Whisker with automatic conversion of passages, links, macros, and variables.

---

## Overview

The Twine Import feature allows you to migrate interactive fiction stories created in Twine 2 into the Whisker editor. The importer automatically converts:

- **Passages** → Whisker passages with preserved content and structure
- **Links** → Whisker choices (all Twine link formats supported)
- **Macros** → Whisker template syntax
- **Variables** → Whisker variable system
- **Passage positions** → Graph view layout
- **Story metadata** → Project metadata

---

## Supported Formats

### ✅ Fully Supported

| Format | Version | Conversion Quality |
|--------|---------|-------------------|
| **Harlowe** | 1.x, 2.x, 3.x | Excellent - most macros convert automatically |
| **SugarCube** | 2.x | Very Good - common macros convert automatically |

### ⚠️ Partial Support

| Format | Status | Notes |
|--------|--------|-------|
| **Snowman** | Basic | Links convert, macros require manual adjustment |
| **Chapbook** | Basic | Links convert, macros require manual adjustment |
| **Custom formats** | Unknown | May require significant manual adjustment |

---

## How to Import

### Step 1: Prepare Your Twine Story

1. Open your story in Twine 2
2. Click **"Publish to File"** in the Twine menu
3. Save the HTML file to your computer
4. Note: You need the published HTML file, not the Twine archive (.twee)

### Step 2: Import into Whisker

1. Open the Whisker editor in your browser
2. Click the **"📥 Import Twine"** button in the toolbar
3. Select your Twine HTML file
4. Review the import confirmation dialog showing:
   - Story title and author
   - Format detected
   - Number of passages
   - Number of variables
   - Format-specific warnings (if any)
5. Click **OK** to confirm import

### Step 3: Review and Adjust

After import:
- The graph view will display all passages with their original positions
- Variables are automatically added to the Variables panel
- Review passages for any macros that need manual adjustment
- Test your story in the Preview panel

---

## What Gets Converted

### Passages

| Twine | Whisker | Notes |
|-------|---------|-------|
| Passage name | Title and ID | ID is generated from name |
| Passage content | Content | Markdown preserved |
| Tags | Tags | All tags preserved |
| Position | Graph position | X,Y coordinates preserved |

### Links

All Twine link formats are converted to Whisker choices:

```
Twine Format              → Whisker Choice
[[Next Passage]]          → Choice: "Next Passage" → next_passage
[[Click here->Next]]      → Choice: "Click here" → next
[[Next<-Click here]]      → Choice: "Click here" → next
[[Display|Target]]        → Choice: "Display" → target
```

**Note**: Links are removed from passage content and added as choices at the bottom.

### Variables (Harlowe)

| Twine Syntax | Whisker Syntax | Notes |
|--------------|----------------|-------|
| `$health` | `{{health}}` | Variable display |
| `(set: $health to 100)` | `{{lua: game_state:set("health", 100)}}` | Variable assignment |
| `(if: $health > 50)[...]` | `{{#if health > 50}}...{{/if}}` | Conditional display |
| `(print: $name)` | `{{name}}` | Print variable |

### Variables (SugarCube)

| Twine Syntax | Whisker Syntax | Notes |
|--------------|----------------|-------|
| `$health` | `{{health}}` | Variable display |
| `<<set $health to 100>>` | `{{lua: game_state:set("health", 100)}}` | Variable assignment |
| `<<if $health > 50>>...<<endif>>` | `{{#if health > 50}}...{{/if}}` | Conditional display |
| `<<print $name>>` | `{{name}}` | Print variable |

### Metadata

| Twine Field | Whisker Field | Notes |
|-------------|---------------|-------|
| Story name | metadata.title | Preserved |
| Creator | metadata.author | Preserved |
| IFID | metadata.ifid | Preserved or generated |
| Format | metadata.twineData.format | Stored for reference |
| Start passage | settings.startPassage | Auto-detected |

---

## Known Limitations

### Macros

Not all Twine macros convert automatically. Here are common ones that need manual adjustment:

**Harlowe:**
- `(goto:)` - Replace with Whisker choices
- `(display:)` - Use passage templates or copy content
- `(live:)` - Not supported (Whisker is choice-based)
- `(transition:)` - Not supported
- `(click:)` - Replace with choices

**SugarCube:**
- `<<goto>>` - Replace with Whisker choices
- `<<include>>` - Use passage templates or copy content
- `<<timed>>` - Not supported (Whisker is choice-based)
- `<<audio>>` - Use asset system
- `<<widget>>` - Use passage templates

### JavaScript and CSS

- **JavaScript**: Twine JavaScript passages are not automatically converted. You'll need to manually adapt code to Whisker's Lua scripting.
- **CSS**: Story stylesheets are not imported. Use Whisker's theme system instead.

### Advanced Features

- **Save/load systems** - Whisker has its own save system
- **Inventory systems** - Rebuild using Whisker variables and Lua
- **Custom UIs** - Adapt to Whisker's player interface

---

## Post-Import Checklist

After importing a Twine story, review these items:

- [ ] Check all passages imported correctly
- [ ] Verify choices connect to correct passages
- [ ] Review variables in Variables panel
- [ ] Test conditional content ({{#if}})
- [ ] Check for unconverted macros (look for `(` or `<<`)
- [ ] Test story flow in Preview panel
- [ ] Verify graph layout makes sense
- [ ] Update any format-specific code
- [ ] Save your project!

---

## Examples

### Example 1: Simple Harlowe Story

**Twine (Harlowe):**
```
Passage: Start
---
You wake up with $health health points.

(set: $health to 100)
(set: $hasKey to false)

Where do you go?

[[Go north->Forest]]
[[Go south->Village]]
```

**After Import (Whisker):**
```
Title: Start
---
You wake up with {{health}} health points.

{{lua: game_state:set("health", 100)}}
{{lua: game_state:set("hasKey", false)}}

Where do you go?

Choices:
→ Go north (target: forest)
→ Go south (target: village)
```

### Example 2: SugarCube Conditionals

**Twine (SugarCube):**
```
Passage: Forest
---
You enter the dark forest.

<<if $hasKey>>
  You unlock the gate and continue.
  [[Continue->Castle]]
<<else>>
  The gate is locked. You need a key.
  [[Go back->Start]]
<<endif>>
```

**After Import (Whisker):**
```
Title: Forest
---
You enter the dark forest.

{{#if hasKey}}
  You unlock the gate and continue.
{{else}}
  The gate is locked. You need a key.
{{/if}}

Choices:
→ Continue (target: castle)
→ Go back (target: start)
```

---

## Troubleshooting

### Import Fails

**Error: "Not a valid Twine 2 HTML file"**
- Make sure you published to HTML from Twine 2 (not exported as archive)
- Twine 1 files are not supported - republish from Twine 2

**Error: "No passages found"**
- File may be corrupted or incomplete
- Try republishing from Twine

### Content Issues

**Variables show as `[object Object]`**
- This was a bug in earlier versions - update to latest Whisker

**Choices don't appear**
- Links may use unsupported format
- Check that passages exist with matching names

**Macros not converting**
- See "Known Limitations" section
- Manual conversion may be required

### Layout Issues

**Passages overlap in graph view**
- Use "Auto Layout" button (⚡) in graph controls
- Manually drag passages to better positions

**Missing passages in graph**
- Check passage list sidebar - all passages are imported
- Use "Fit All" button (⊡) to zoom out

---

## Tips for Best Results

### Before Importing

1. **Clean up your Twine story** - Remove unused passages
2. **Test in Twine** - Make sure story works before importing
3. **Document custom code** - Note any special JavaScript or CSS
4. **Backup** - Save your Twine story (just in case)

### After Importing

1. **Start small** - Test with a simple story first
2. **Check macros** - Search for `(` and `<<` to find unconverted macros
3. **Test thoroughly** - Play through your story in Preview
4. **Use validation** - Click "Validate" to find broken links
5. **Save often** - Use "Save" button to preserve your work

### Working with Large Stories

- **Import in chunks** - For very large stories, consider importing sections separately
- **Use tags** - Preserve Twine tags to organize passages
- **Graph navigation** - Use zoom and pan to navigate large graphs

---

## Format-Specific Notes

### Harlowe

- **Strengths**: Most macros convert automatically
- **Watch out for**: `(goto:)` macros - convert to choices
- **Variables**: Automatic conversion works well

### SugarCube

- **Strengths**: Common macros convert well
- **Watch out for**: Complex expressions may need adjustment
- **Variables**: Set syntax converts automatically

### Snowman / Chapbook

- **Limited conversion**: Only basic links and structure
- **Macros**: Require manual conversion
- **Best for**: Stories with minimal macro usage

---

## Migration Strategy

For complex stories, consider this migration approach:

### Phase 1: Import and Validate
1. Import story into Whisker
2. Review import log for warnings
3. Check passage count matches
4. Verify no passages missing

### Phase 2: Fix Structure
1. Fix broken links
2. Adjust passage positions
3. Organize with tags
4. Set correct start passage

### Phase 3: Convert Macros
1. List all unconverted macros
2. Convert simple macros (set, if, print)
3. Rewrite complex macros
4. Test after each conversion

### Phase 4: Test and Polish
1. Play through all paths
2. Test variable logic
3. Fix any remaining issues
4. Export and test standalone HTML

---

## Technical Details

### Parser Implementation

The Twine parser:
1. Uses DOMParser to parse HTML structure
2. Finds `<tw-storydata>` element
3. Extracts metadata from attributes
4. Parses all `<tw-passagedata>` elements
5. Converts links using regex
6. Transforms macros using format-specific rules
7. Generates Whisker-compatible IDs
8. Maps passage references

### ID Generation

Twine passage names are converted to Whisker IDs:
- Lowercase transformation
- Non-alphanumeric → underscore
- Leading/trailing underscores removed
- Length limited to 50 characters
- Collisions handled with random suffix

Example: `"The Dark Forest (Part 2)"` → `"the_dark_forest_part_2"`

---

## Future Enhancements

Planned improvements:
- [ ] Support for Twine 1 formats
- [ ] JavaScript-to-Lua converter
- [ ] CSS theme import
- [ ] Advanced macro conversion
- [ ] Twee notation import
- [ ] Story format plugins

---

## Getting Help

If you encounter issues:

1. **Check this guide** - Most common issues covered
2. **Use validation** - Click "Validate" to find problems
3. **Report bugs** - File issues on GitHub
4. **Share examples** - Provide sample Twine files

---

## Summary

✅ **Best for**: Harlowe and SugarCube stories with standard macros
⚠️ **Requires work**: Custom JavaScript, complex macros, custom formats
📝 **After import**: Review, test, and adjust converted content
💾 **Remember**: Save your work frequently!

---

**Version**: 1.0.0
**Last updated**: October 2024
**Supported Twine version**: Twine 2.x
