# Snowman Format Support

whisker now includes full support for converting between Snowman and whisker formats. Snowman is a minimal, JavaScript-based Twine story format that provides direct DOM access and uses Underscore.js for utilities.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Format Specifications](#format-specifications)
- [Conversion Examples](#conversion-examples)
- [API Reference](#api-reference)
- [Syntax Mappings](#syntax-mappings)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

### What is Snowman?

Snowman is one of the default story formats for Twine 2. It's designed for authors who want:
- Direct JavaScript access
- Minimal abstractions
- Full control over the DOM
- jQuery and Underscore.js integration
- A simple, template-based syntax

### Conversion Capabilities

whisker can:
- ✅ Import Snowman stories to whisker format
- ✅ Export whisker stories to Snowman format
- ✅ Convert between Snowman and other Twine formats (Harlowe, SugarCube)
- ✅ Preserve story structure, variables, and logic
- ✅ Handle complex conditionals and code blocks

## Quick Start

### Converting Snowman to whisker

```lua
local FormatConverter = require("format.format_converter")

-- Initialize converter
local converter = FormatConverter:new()

-- Load Snowman story (from Twine HTML export)
local snowman_data = load_twine_html("story.html")

-- Convert to whisker
local whisker_data = converter:import_snowman(snowman_data)

-- Save as whisker JSON
save_json("story.whisker", whisker_data)
```

### Converting whisker to Snowman

```lua
local FormatConverter = require("format.format_converter")

-- Initialize converter
local converter = FormatConverter:new()

-- Load whisker story
local whisker_data = load_json("story.whisker")

-- Convert to Snowman
local snowman_data = converter:export_snowman(whisker_data)

-- Export as Twine HTML
save_twine_html("story_snowman.html", snowman_data)
```

### Converting Between Formats

```lua
-- Harlowe to Snowman
local snowman = converter:convert_harlowe_to_snowman(harlowe_data)

-- Snowman to SugarCube
local sugarcube = converter:convert_snowman_to_sugarcube(snowman_data)
```

## Format Specifications

### Snowman Syntax

#### Variables
```javascript
// Setting variables (in code blocks)
<% s.playerName = "Hero"; %>
<% s.health = 100; %>
<% s.inventory = []; %>

// Accessing variables (in output)
<%= s.playerName %>
<%= s.health %>
```

#### Links
```
// Basic link
[[Continue]]

// Link with custom text
[[Click here|TargetPassage]]

// Conditional link
<% if (s.hasKey) { %>
  [[Unlock door|Inside]]
<% } %>
```

#### Conditionals
```javascript
<% if (s.health > 50) { %>
  You feel strong.
<% } else { %>
  You feel weak.
<% } %>

// Complex conditionals
<% if (s.gold >= 100 && s.inventory.includes('sword')) { %>
  [[Buy potion|Shop]]
<% } %>
```

#### Code Blocks
```javascript
// Execute JavaScript
<%
  s.gold += 10;
  s.visited = (s.visited || 0) + 1;
%>

// Loop example
<% _.times(3, function(i) { %>
  Option <%= i + 1 %>
<% }) %>
```

### whisker Equivalent

#### Variables
```lua
-- Setting variables
{% set('playerName', 'Hero') %}
{% set('health', 100) %}
{% set('inventory', {}) %}

-- Accessing variables
{{playerName}}
{{health}}
```

#### Links
```lua
-- Choices in passage definition
choices = {
  {text = "Continue", target = "Next"},
  {text = "Click here", target = "TargetPassage"},
  {
    text = "Unlock door",
    target = "Inside",
    condition = "get('hasKey')"
  }
}
```

#### Conditionals
```lua
{% if get('health') > 50 then %}
  You feel strong.
{% else %}
  You feel weak.
{% end %}

-- Complex conditionals
{% if get('gold') >= 100 and inventory_contains('sword') then %}
  -- Available action
{% end %}
```

## Conversion Examples

### Example 1: Simple Story

**Snowman Input:**
```html
<tw-passagedata pid="1" name="Start">
You are in a dark room.

<% s.roomsVisited = 1; %>

[[Look around|Explore]]
[[Leave|Exit]]
</tw-passagedata>
```

**whisker Output:**
```json
{
  "id": "start",
  "title": "Start",
  "content": "You are in a dark room.",
  "code": ["set('roomsVisited', 1)"],
  "choices": [
    {"text": "Look around", "target": "Explore"},
    {"text": "Leave", "target": "Exit"}
  ]
}
```

### Example 2: Conditional Content

**Snowman Input:**
```html
<tw-passagedata pid="2" name="Shop">
Gold: <%= s.gold %>

<% if (s.gold >= 50) { %>
  [[Buy sword (50g)|BuySword]]
<% } else { %>
  You don't have enough gold for a sword.
<% } %>

[[Leave|Town]]
</tw-passagedata>
```

**whisker Output:**
```json
{
  "id": "shop",
  "title": "Shop",
  "content": "Gold: {{gold}}",
  "choices": [
    {
      "text": "Buy sword (50g)",
      "target": "BuySword",
      "condition": "get('gold') >= 50"
    },
    {
      "text": "Leave",
      "target": "Town"
    }
  ]
}
```

### Example 3: State Initialization

**Snowman StoryInit:**
```html
<tw-passagedata pid="0" name="StoryInit">
<%
  s.playerName = "Hero";
  s.health = 100;
  s.maxHealth = 100;
  s.gold = 50;
  s.inventory = [];
  s.stats = {
    strength: 10,
    agility: 8
  };
%>
</tw-passagedata>
```

**whisker Variables:**
```json
{
  "variables": {
    "playerName": "Hero",
    "health": 100,
    "maxHealth": 100,
    "gold": 50,
    "inventory": []
  }
}
```

## API Reference

### SnowmanConverter Class

#### Methods

##### `snowman_to_whisker(twine_data)`
Converts a Snowman story to whisker format.

**Parameters:**
- `twine_data` (table): Parsed Twine story data

**Returns:**
- `whisker_data` (table): Converted whisker format

**Example:**
```lua
local converter = SnowmanConverter:new()
local result = converter:snowman_to_whisker(snowman_data)
```

##### `whisker_to_snowman(whisker_data)`
Converts a whisker story to Snowman format.

**Parameters:**
- `whisker_data` (table): whisker format data

**Returns:**
- `snowman_data` (table): Twine-compatible Snowman format

**Example:**
```lua
local converter = SnowmanConverter:new()
local result = converter:whisker_to_snowman(whisker_data)
```

##### `javascript_to_lua(js_code)`
Converts JavaScript code to Lua equivalent.

**Parameters:**
- `js_code` (string): JavaScript code snippet

**Returns:**
- `lua_code` (string): Lua code equivalent

**Example:**
```lua
local lua = converter:javascript_to_lua("s.health = 100")
-- Returns: "set('health', 100)"
```

##### `lua_to_javascript(lua_code)`
Converts Lua code to JavaScript equivalent.

**Parameters:**
- `lua_code` (string): Lua code snippet

**Returns:**
- `js_code` (string): JavaScript code equivalent

**Example:**
```lua
local js = converter:lua_to_javascript("set('health', 100)")
-- Returns: "s.health = 100"
```

### FormatConverter Integration

The SnowmanConverter is integrated into the main FormatConverter class:

```lua
local converter = FormatConverter:new()

-- Import
local whisker = converter:import_snowman(snowman_data)

-- Export
local snowman = converter:export_snowman(whisker_data)

-- Cross-format conversion
local snowman = converter:convert_harlowe_to_snowman(harlowe_data)
local sugarcube = converter:convert_snowman_to_sugarcube(snowman_data)
```

## Syntax Mappings

### State Variables

| Snowman | whisker |
|---------|----------|
| `s.variable` | `get('variable')` |
| `s.variable = value` | `set('variable', value)` |
| `s.count++` | `increment('count')` |
| `s.count--` | `decrement('count')` |

### Operators

| Snowman | whisker |
|---------|----------|
| `&&` | `and` |
| `\|\|` | `or` |
| `!` | `not` |
| `+` (string) | `..` |

### Arrays

| Snowman | whisker |
|---------|----------|
| `arr.length` | `#arr` |
| `arr.push(item)` | `table.insert(arr, item)` |
| `arr.includes(item)` | Custom function |
| `arr[i]` | `arr[i+1]` (1-indexed) |

### Functions

| Snowman | whisker |
|---------|----------|
| `window.story.render(passage)` | `goto('passage')` |
| `window.story.checkpoint()` | `checkpoint()` |
| `window.story.restore()` | `restore()` |

## Best Practices

### 1. Variable Initialization

Always initialize variables in the StoryInit passage:

```javascript
// Snowman StoryInit
<%
  s.health = 100;
  s.inventory = [];
  s.flags = {};
%>
```

### 2. State Management

Use descriptive variable names and organize state logically:

```javascript
// Good
s.player = {
  name: "Hero",
  health: 100,
  level: 1
};

// Better for conversion
s.playerName = "Hero";
s.playerHealth = 100;
s.playerLevel = 1;
```

### 3. Conditional Links

Keep conditional logic simple for better conversion:

```javascript
// Simple condition - converts well
<% if (s.hasKey) { %>
  [[Open door|Inside]]
<% } %>

// Complex condition - may need manual review
<% if (s.keys.includes('golden') && s.doors.castle.locked) { %>
  [[Unlock castle|Castle]]
<% } %>
```

### 4. Code Organization

Separate logic from content:

```javascript
// Good - separate code block
<%
  s.gold += 10;
  s.itemsFound++;
%>

You found 10 gold!

// Avoid inline complex logic
You found <%= (s.lastGold = Math.random() * 20) %> gold!
```

### 5. Testing Conversions

Always test converted stories:

```lua
-- Validate after conversion
local validation = converter:validate_conversion(
    original_data,
    converted_data,
    "snowman",
    "whisker"
)

if not validation.valid then
    for _, error in ipairs(validation.errors) do
        print("Error: " .. error)
    end
end
```

## Troubleshooting

### Common Issues

#### 1. Variable Not Converting

**Problem:** `s.variable` not converting to `get('variable')`

**Solution:** Check for proper spacing and syntax:
```javascript
// Correct
<% s.health = 100; %>

// May not parse correctly
<%s . health=100;%>
```

#### 2. Conditional Links Missing

**Problem:** Conditional links not appearing in whisker

**Solution:** Ensure conditionals are on the same line as links:
```javascript
// Works
<% if (s.hasKey) { %>[[Open door|Inside]]<% } %>

// May not parse correctly
<% if (s.hasKey) { %>
[[Open door|Inside]]
<% } %>
```

#### 3. Complex JavaScript Not Converting

**Problem:** Advanced JavaScript features don't convert

**Solution:** Simplify or use manual conversion for:
- Arrow functions
- Template literals
- ES6+ features
- Complex array methods

#### 4. Lost Special Passages

**Problem:** PassageHeader/PassageFooter disappear

**Solution:** These are intentionally filtered. Re-implement as:
- Passage templates in whisker
- Renderer hooks
- Custom UI components

### Testing Your Conversion

Run the test suite to verify conversion:

```bash
lua tests/test_snowman_converter.lua
```

Expected output:
```
==================================================
SNOWMAN CONVERTER TEST SUITE
==================================================

Test 1: Initialize Snowman Converter
✓ Converter created

Test 2: Snowman to whisker Conversion
✓ Conversion result exists
✓ Title preserved
...

Tests: 20 passed, 0 failed
==================================================
```

## Additional Resources

- [Snowman Documentation](https://github.com/klembot/snowman)
- [Twine Wiki](https://twinery.org/wiki/)
- [whisker Format Specification](FORMAT_SPECIFICATION.md)
- [Format Converter API](API_REFERENCE.md#format-converter)

## Support

If you encounter issues with Snowman conversion:

1. Check this documentation for common issues
2. Run the test suite to identify problems
3. Review the conversion validation output
4. Report bugs with example story files

## License

The Snowman converter is part of whisker and uses the same license as the main project.