# Repository Archive Notice

**Date**: October 2025
**Status**: ⚠️ This repository has been reorganized

## 📢 Important Notice

This repository (`jmspring/whisker`) has been split into multiple repositories under the **writewhisker** organization for better project organization and licensing clarity.

## 🏛️ New Repository Structure

The whisker project is now organized as follows:

### 1. whisker-core (MIT License)
**Repository**: https://github.com/writewhisker/whisker-core
**License**: MIT
**Contains**:
- Core Lua interactive fiction library (`lib/whisker/`)
- Command-line tools (`bin/whisker`)
- Test suite (`tests/`)
- Documentation (`docs/`)
- Example stories (`examples/`)
- Runtime players (`publisher/`)

**Use this for**:
- Embedding whisker in your applications
- Building on top of the core engine
- Command-line interactive fiction
- Integration into games or tools

### 2. whisker-editor-web (AGPLv3 License)
**Repository**: https://github.com/writewhisker/whisker-editor-web
**License**: AGPLv3
**Contains**:
- Visual web-based story editor
- Node graph interface with Svelte Flow
- Modern TypeScript/Svelte 5 codebase
- Phases 1-3 complete (data models, UI, visual graph)

**Use this for**:
- Creating interactive fiction with a visual editor
- Web-based story authoring
- Hosted story editing services (source must be disclosed per AGPLv3 Section 13)

### 3. whisker-editor-desktop (AGPLv3 License)
**Repository**: https://github.com/writewhisker/whisker-editor-desktop
**License**: AGPLv3
**Status**: Planned
**Contains**:
- Desktop editor built with Tauri
- Cross-platform (macOS, Windows, Linux)
- Native performance

### 4. whisker-implementation (Private)
**Repository**: https://github.com/writewhisker/whisker-implementation
**Status**: Private
**Contains**:
- Design documentation
- Development roadmaps
- Implementation notes
- Phase planning documents

## 🔄 Migration Guide

### If you were using whisker-core functionality:
```bash
# Old
git clone https://github.com/jmspring/whisker.git

# New
git clone https://github.com/writewhisker/whisker-core.git
```

### If you were using/developing the visual editor:
```bash
# Old
git clone https://github.com/jmspring/whisker.git
git checkout feature/visual-editor
cd editor/visual/web

# New
git clone https://github.com/writewhisker/whisker-editor-web.git
```

## 📝 Licensing Changes

### whisker-core: MIT (Unchanged)
The core library **remains MIT licensed** as it always has been. This ensures:
- ✅ Broad commercial and open-source use
- ✅ Integration into proprietary applications
- ✅ Maximum developer freedom

### whisker-editor-web: AGPLv3 (New)
The visual editor is **newly licensed under AGPLv3**. This ensures:
- ✅ Free to use and modify
- ✅ Commercial use allowed
- ⚠️ Modifications must be shared under AGPLv3
- ⚠️ **Network use requires source disclosure** (AGPLv3 Section 13)

**Important**: The visual editor code was developed on the `feature/visual-editor` branch and has **never been released under MIT license**. It was developed specifically for the visual editing interface starting in October 2025.

## 🏷️ Version History

### This Repository (jmspring/whisker)
- **v0.0.1-dev** - Last version before reorganization
- All commits through October 18, 2025 are preserved here
- Main branch contains MIT-licensed core code
- feature/visual-editor branch contains AGPLv3 visual editor code

### New Repositories
- **whisker-core**: Continues version numbering from v0.0.1-dev
- **whisker-editor-web**: Starts at v0.1.0

## 🔗 Links

- **Organization**: https://github.com/writewhisker
- **Core Library**: https://github.com/writewhisker/whisker-core
- **Web Editor**: https://github.com/writewhisker/whisker-editor-web
- **Original Repo**: https://github.com/jmspring/whisker (you are here)

## ⏰ Timeline

- **Pre-2025**: whisker development under MIT license
- **October 2025**: Visual editor development begins (feature/visual-editor branch)
- **October 18, 2025**: Repository reorganization
  - Core library moved to writewhisker/whisker-core (MIT)
  - Visual editor moved to writewhisker/whisker-editor-web (AGPLv3)
  - Implementation docs moved to writewhisker/whisker-implementation (private)

## 📧 Questions?

For questions about:
- **Core library**: Open an issue at https://github.com/writewhisker/whisker-core/issues
- **Web editor**: Open an issue at https://github.com/writewhisker/whisker-editor-web/issues
- **General questions**: Open a discussion at https://github.com/writewhisker

## 🙏 Thank You

Thank you for your interest in whisker! The reorganization allows us to:
- Better manage licensing for different use cases
- Separate core engine from authoring tools
- Provide clearer paths for contributors
- Scale development with multiple teams

Please update your bookmarks and git remotes to point to the new repositories.

---

**This repository is archived for historical reference.**
**Active development continues at https://github.com/writewhisker**
