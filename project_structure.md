# whisker MVP - Complete Directory Structure and Files

## Project Overview
**Status**: 70% Complete MVP
**Description**: Modern Twine successor with Lua scripting + multimedia

## Directory Structure

```
whisker/
├── src/
│   ├── core/
│   │   ├── engine.lua                    ✅ 75% - Navigation done, missing visual/audio
│   │   ├── story.lua                     ✅ Complete
│   │   ├── passage.lua                   ✅ Complete
│   │   ├── game_state.lua                ✅ Complete - State + undo + inventory
│   │   └── choice.lua                    ✅ Complete
│   ├── parser/
│   │   ├── lexer.lua                     ✅ Complete
│   │   └── parser.lua                    ✅ Complete
│   ├── runtime/
│   │   ├── interpreter.lua               ✅ Complete - Sandbox + security
│   │   └── advanced_instruction_counter.lua ✅ Complete - Performance monitoring
│   ├── system/
│   │   └── save_system.lua               ✅ Complete
│   ├── platform/
│   │   ├── file_storage.lua              🟡 60% - Cross-platform file ops
│   │   ├── file_system.lua               ✅ Complete
│   │   ├── web_runtime.lua               ❌ Missing - HTML5 player
│   │   └── asset_manager.lua             🟡 40% - Asset pipeline
│   ├── format/
│   │   ├── whisker_format.lua            ✅ Complete - JSON schema
│   │   ├── twine_importer.lua            🟡 75% - Basic import working
│   │   └── format_converter.lua          🟡 75% - Harlowe/SugarCube support
│   ├── editor/
│   │   ├── visual_editor.lua             ❌ Missing - Node-based editor
│   │   ├── passage_editor.lua            ❌ Missing - Text editing
│   │   └── project_manager.lua           ❌ Missing - Project handling
│   ├── tools/
│   │   ├── debugger.lua                  ❌ New
│   │   ├── profiler.lua                  ❌ New
│   │   └── validator.lua                 ❌ New
│   ├── ui/
│   │   └── ui_framework.lua              ✅ Complete
│   └── utils/
│       ├── json.lua                      ✅ Complete - JSON parser
│       ├── file_utils.lua                ✅ Complete - File operations
│       └── string_utils.lua              ✅ Complete - Text processing
├── examples/
│   └── basic_story.lua
├── tests/
│   └── test.lua
├── docs/
│   └── specification.md                  ✅ Complete v2.0
├── .luacheckrc                           ← Configuration for LuaCheck
├── stylua.toml                           ← Configuration for StyLua
├── .gitignore
├── README.md
└── LICENSE
```

## Completed Modules (Production Ready)

### Core Modules

#### 1. `src/core/story.lua`
Story data structure and management.

#### 2. `src/core/passage.lua`
Passage representation with metadata.

#### 3. `src/core/choice.lua`
Choice handling with conditions.

#### 4. `src/core/game_state.lua`
Complete state management with undo/redo, inventory system, and serialization.

#### 5. `src/core/engine.lua` (75% complete)
Story engine with navigation. Missing: visual/audio processing.

### Runtime Modules

#### 6. `src/runtime/interpreter.lua`
Secure Lua sandbox with:
- Sandboxed execution environment
- Story API (get/set/visited/inventory)
- Instruction counting and timeout protection
- Error handling and diagnostics

#### 7. `src/runtime/advanced_instruction_counter.lua`
Advanced performance monitoring with:
- CPU-accurate instruction weighting
- Hot spot detection
- Optimization suggestions
- Function call tracking
- Loop detection

### Parser Modules

#### 8. `src/parser/lexer.lua`
Complete tokenization for whisker format.

#### 9. `src/parser/parser.lua`
Full parsing of passages, choices, and scripting.

### System Modules

#### 10. `src/system/save_system.lua`
Save/load functionality with:
- Multiple save slots
- Auto-save support
- Save metadata tracking
- Version compatibility

### Platform Modules

#### 11. `src/platform/file_system.lua`
Cross-platform file operations.

#### 12. `src/platform/file_storage.lua` (60% complete)
Platform-specific storage handling.

### Format Modules

#### 13. `src/format/whisker_format.lua`
Complete JSON schema for whisker format.

#### 14. `src/format/twine_importer.lua` (75% complete)
Twine format import (Harlowe, SugarCube).

#### 15. `src/format/format_converter.lua` (75% complete)
Format conversion utilities.

### UI Modules

#### 16. `src/ui/ui_framework.lua`
Console-based UI for desktop runtime.

### Utility Modules

#### 17. `src/utils/json.lua`
Pure Lua JSON parser/encoder.

#### 18. `src/utils/file_utils.lua`
File operation utilities.

#### 19. `src/utils/string_utils.lua`
String processing and templating.

## Missing Modules (MVP Requirements)

### Web Platform (Critical)
- `src/platform/web_runtime.lua` - HTML5 player
- `src/platform/asset_manager.lua` - Asset pipeline (40% done)

### Visual Editor (Critical)
- `src/editor/visual_editor.lua` - Node-based editor
- `src/editor/passage_editor.lua` - Text editing
- `src/editor/project_manager.lua` - Project handling

### Development Tools
- `src/tools/debugger.lua` - Debugging interface
- `src/tools/profiler.lua` - Performance profiling
- `src/tools/validator.lua` - Story validation

## Configuration Files

### `.luacheckrc`
```lua
std = "lua54"
ignore = {"211", "212", "213", "311", "411", "412", "421", "422"}

files["spec"].std = "+busted"
files["test.lua"].std = "+busted"
```

### `stylua.toml`
```toml
column_width = 100
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 4
quote_style = "AutoPreferDouble"
no_call_parentheses = false
```

## Next Steps to Complete MVP

### Phase 1: Complete Story Engine (1-2 weeks)
- Add visual content rendering
- Implement audio system
- Complete asset loading

### Phase 2: Build Web Runtime (3-4 weeks)
- HTML5 player implementation
- JavaScript bridge for browser
- Asset preloading system
- Responsive UI components

### Phase 3: Create Visual Editor (3-4 weeks)
- Node-based passage editor
- Drag-drop interface
- Real-time preview
- Asset management UI

### Phase 4: Package & Deploy (2-3 weeks)
- Build system
- Documentation
- Example stories
- Distribution packages

## Key Features Already Implemented

✅ **Advanced Instruction Counting** - CPU-accurate weighting, hot spot detection
✅ **Complete Sandbox** - Secure Lua execution with story API
✅ **Full State Management** - Variables, undo, inventory, auto-save
✅ **Multimedia Support** - JSON format for images/audio/interactive elements
✅ **Twine Compatibility** - Import/export Harlowe, SugarCube formats
✅ **Cross-Platform** - Lua 5.1-5.4 compatible, zero external dependencies

## Timeline Estimate

**Total time to MVP**: 8-12 weeks
**Current completion**: ~70%
**Remaining work**: Web platform (3-4 weeks) + Visual editor (3-4 weeks)

## Links to Related Conversations

- **Full Specification**: [Twine Successor Specification Standards](https://claude.ai/chat/e00cb8e8-4a67-4eaf-9c9d-84b8d312cadf)
- **MVP Status Discussion**: [whisker MVP Development Status](https://claude.ai/chat/4e750c33-1a9c-4dfc-9749-9a16cf278459)
- **Implementation Details**: [Twine Successor Lua Storytelling Platform](https://claude.ai/chat/a97c9585-256c-4e9c-b52f-30b1fe09828f)

---

**Note**: The actual source code for all completed modules is available in the referenced conversations. Each file is fully implemented with proper error handling, documentation, and testing support.
