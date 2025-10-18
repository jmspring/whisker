# Metatable Preservation in whisker

## Overview

whisker objects (Story, Passage, Choice) use Lua metatables to provide object-oriented methods. When these objects are serialized (e.g., for saving games or passing between modules), they lose their metatables and become plain tables without methods.

This document explains the metatable preservation system that ensures Story objects maintain their methods when:
- Serialized to JSON and deserialized
- Passed between modules
- Saved and loaded from disk
- Converted between formats

## The Problem

```lua
local Story = require("whisker.core.story")
local json = require("whisker.utils.json")

-- Create a story with methods
local story = Story:new({title = "My Story"})
story:get_metadata("name")  -- ✓ Works: "My Story"

-- Serialize to JSON
local json_str = json.encode(story:serialize())

-- Deserialize from JSON
local plain_table = json.decode(json_str)
plain_table:get_metadata("name")  -- ✗ Error: attempt to call method 'get_metadata'
                                  --   (a nil value)
```

The deserialized object is a plain table without the Story metatable, so it has no methods.

## The Solution

whisker provides two mechanisms to restore metatables:

### 1. `restore_metatable(data)` - In-place restoration

Restores the metatable to an existing table, recursively restoring nested objects.

```lua
local Story = require("whisker.core.story")
local json = require("whisker.utils.json")

local story = Story:new({title = "My Story"})
local json_str = json.encode(story:serialize())
local plain_table = json.decode(json_str)

-- Restore metatable in-place
local restored = Story.restore_metatable(plain_table)
restored:get_metadata("name")  -- ✓ Works: "My Story"
```

**Features:**
- Fast: modifies the table in-place
- Recursive: automatically restores nested Passage and Choice objects
- Idempotent: safe to call on objects that already have metatables
- Returns the same table reference after restoration

### 2. `from_table(data)` - Create new instance

Creates a new properly-initialized instance from a plain table.

```lua
local Story = require("whisker.core.story")

local plain_table = {
    metadata = {name = "My Story", author = "Me"},
    passages = {...},
    start_passage = "start"
}

-- Create new instance with proper initialization
local story = Story.from_table(plain_table)
story:get_metadata("name")  -- ✓ Works: "My Story"
```

**Features:**
- Proper initialization: goes through normal constructor
- Deep copying: creates new objects for nested structures
- Data validation: uses the normal object creation path
- Better for complex initialization logic

## Available Methods

All three core classes provide both restoration methods:

### Story
- `Story.restore_metatable(data)` - Restore Story metatable
- `Story.from_table(data)` - Create new Story from table

### Passage
- `Passage.restore_metatable(data)` - Restore Passage metatable
- `Passage.from_table(data)` - Create new Passage from table

### Choice
- `Choice.restore_metatable(data)` - Restore Choice metatable
- `Choice.from_table(data)` - Create new Choice from table

## Automatic Restoration

Several whisker components automatically restore metatables:

### Engine

The Engine automatically restores metatables when loading stories:

```lua
local Engine = require("whisker.core.engine")

-- Load a plain table (e.g., from JSON)
local plain_story_data = json.decode(json_string)

-- Engine automatically restores metatable
local engine = Engine:new()
engine:load_story(plain_story_data)  -- Auto-restores Story metatable

-- Now you can use story methods
engine.current_story:get_start_passage()  -- ✓ Works
```

### SaveSystem

The SaveSystem automatically restores metatables when loading saves:

```lua
local SaveSystem = require("whisker.system.save_system")

local save_system = SaveSystem:new()

-- Load game automatically restores Story metatable
local save_data = save_system:load_game("slot_1")

if save_data.story then
    save_data.story:get_metadata("name")  -- ✓ Works
end
```

### Deserialize Methods

The `deserialize()` method on Story, Passage, and Choice objects automatically restores nested object metatables:

```lua
local story = Story:new()
story:deserialize(plain_data)  -- Automatically restores Passage and Choice metatables
```

## Common Use Cases

### Use Case 1: Saving and Loading

```lua
local Story = require("whisker.core.story")
local json = require("whisker.utils.json")

-- Save
local story = Story:new({title = "My Story"})
-- ... build story ...
local save_data = json.encode(story:serialize())

-- Load
local loaded_data = json.decode(save_data)
local restored_story = Story.from_table(loaded_data)

-- Use restored story
restored_story:get_start_passage()  -- ✓ Works
```

### Use Case 2: Module Communication

```lua
-- module_a.lua
local Story = require("whisker.core.story")

function create_story()
    local story = Story:new({title = "Shared Story"})
    return story:serialize()  -- Return plain table
end

-- module_b.lua
local Story = require("whisker.core.story")

function use_story(story_data)
    -- Restore metatable
    local story = Story.restore_metatable(story_data)

    -- Use story methods
    story:get_metadata("name")  -- ✓ Works
end
```

### Use Case 3: Format Conversion

```lua
local Story = require("whisker.core.story")
local TwineImporter = require("whisker.format.twine_importer")

-- Import from Twine (returns plain table)
local importer = TwineImporter:new()
local story_data = importer:import_from_html(html_content)

-- Restore metatable
local story = Story.from_table(story_data)

-- Use story methods
story:validate()  -- ✓ Works
```

## Best Practices

### 1. Choose the Right Method

- Use `restore_metatable()` when:
  - Performance is critical (in-place modification)
  - Working with existing table references
  - You just need method access

- Use `from_table()` when:
  - You want a clean new instance
  - Complex initialization is needed
  - Data validation is important

### 2. Trust Automatic Restoration

The Engine and SaveSystem automatically restore metatables. In most cases, you don't need to manually restore:

```lua
-- ✓ Good: Let Engine handle it
engine:load_story(plain_data)

-- ✗ Unnecessary: Manual restoration not needed
local restored = Story.restore_metatable(plain_data)
engine:load_story(restored)
```

### 3. Serialize Before Sharing

Always serialize before passing objects to external systems:

```lua
-- ✓ Good: Serialize first
local data = story:serialize()
send_to_external_system(data)

-- ✗ Bad: Sending object with metatable
send_to_external_system(story)
```

### 4. Check for Nested Objects

When manually restoring, remember that `restore_metatable()` handles nested objects:

```lua
-- ✓ Good: One call restores everything
local story = Story.restore_metatable(data)
-- Passages and Choices are automatically restored

-- ✗ Bad: Manual nested restoration not needed
local story = Story.restore_metatable(data)
for id, passage in pairs(story.passages) do
    Passage.restore_metatable(passage)  -- Unnecessary
end
```

## Technical Details

### Metatable Structure

Each class uses a standard metatable pattern:

```lua
local Story = {}
Story.__index = Story

function Story:new(options)
    local instance = {...}
    setmetatable(instance, Story)
    return instance
end
```

### Restoration Process

`restore_metatable()` performs these steps:

1. Checks if data is valid and is a table
2. Checks if metatable is already correct (idempotency)
3. Sets the appropriate metatable
4. Recursively restores nested objects
5. Returns the modified table

`from_table()` performs these steps:

1. Validates input data
2. Calls the normal constructor with extracted data
3. Manually copies additional fields
4. Recursively creates new instances for nested objects
5. Returns a new instance

### Performance Considerations

- `restore_metatable()`: O(1) for the table itself, O(n) for nested objects
- `from_table()`: O(n) as it creates new instances
- Automatic restoration in Engine/SaveSystem: negligible overhead
- Metatables are lightweight: no significant memory impact

## Troubleshooting

### Problem: "attempt to call method (a nil value)"

This means the object doesn't have a metatable. Solution:

```lua
local Story = require("whisker.core.story")
local restored = Story.restore_metatable(your_data)
```

### Problem: Nested objects missing methods

If you're using manual restoration, ensure you're using the class restoration methods, not generic `setmetatable()`:

```lua
-- ✓ Good: Use class method (handles nesting)
Story.restore_metatable(data)

-- ✗ Bad: Generic setmetatable doesn't restore nested objects
setmetatable(data, Story)
```

### Problem: Methods work on parent but not children

This usually means nested objects weren't restored. The class restoration methods handle this automatically:

```lua
-- This restores Story AND all Passages AND all Choices
local story = Story.restore_metatable(data)
```

### Problem: Getting plain table from Engine

Make sure you're accessing the Engine's current_story, not re-serializing it:

```lua
-- ✓ Good
engine:load_story(data)
engine.current_story:get_metadata("name")

-- ✗ Bad
engine:load_story(data)
local serialized = engine.current_story:serialize()  -- Removes metatable
serialized:get_metadata("name")  -- Error
```

## Testing

Run the metatable preservation test suite:

```bash
lua tests/test_metatable_preservation.lua
```

This comprehensive test verifies:
- Serialization/deserialization cycles
- JSON round-trips
- Engine integration
- Deep nesting preservation
- Individual object restoration
- Idempotency

## Summary

whisker's metatable preservation system ensures objects maintain their methods through serialization, deserialization, and module boundaries. The system is:

- **Automatic**: Engine and SaveSystem handle restoration transparently
- **Comprehensive**: Works for Story, Passage, and Choice objects
- **Recursive**: Automatically handles deeply nested structures
- **Efficient**: Minimal performance overhead
- **Reliable**: Fully tested with comprehensive test suite

For most use cases, you can rely on automatic restoration. When manual restoration is needed, use the provided `restore_metatable()` or `from_table()` methods.
