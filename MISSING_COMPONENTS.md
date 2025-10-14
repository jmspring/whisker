# Missing Components - Whisker Enhancement Roadmap

**Analysis Date:** 2025-10-13
**Current Status:** Solid Foundation, Several Key Features Missing
**Goal:** Complete Twine Successor Feature Parity

---

## 🎯 Executive Summary

Whisker has excellent fundamentals but is missing several key features that Twine and modern IF tools provide. This document identifies gaps and prioritizes enhancements.

### Current Strengths ✅
- Solid Lua-based engine
- Web-based editor with graph view
- Multiple export formats
- Undo/redo system
- Variable management
- Validation system
- Theme support
- Asset management
- **NEW:** Passage templates (just added!)

### Missing Critical Features ⚠️
1. **Inline Lua Code Execution** - No way to run Lua snippets in passages
2. **Conditional Content** - No `{{#if}}` templating in runtime
3. **Mobile Runtime** - No mobile player
4. **Plugin/Extension System** - No way to extend functionality
5. **Collaboration Features** - Single-user only
6. **Version Control Integration** - No git integration
7. **Publishing Pipeline** - Limited deployment options
8. **Testing Framework** - No automated story testing
9. **Localization/i18n** - No multi-language support
10. **Advanced Debugging** - No passage breakpoints or stepping

---

## 📊 Priority Matrix

### 🔥 Critical (Blocks Major Use Cases)

#### 1. **Inline Lua Code Execution** ⭐⭐⭐⭐⭐
**Status:** MISSING - CRITICAL FOR RPG GAMES

**The Problem:**
- The editor creates stories with `{{lua: ... }}` syntax
- The runtime engine does NOT execute Lua code in passages
- All RPG templates use Lua code that won't work at runtime
- Variables can be displayed `{{health}}` but not modified in passages

**What's Missing:**
```whisker
<!-- This is written in the editor but doesn't work in runtime -->
{{lua:
    local roll = math.random(1,20)
    game_state:set("check_result", roll)
}}

<!-- This works (display only) -->
Your health: {{health}}/{{max_health}}

<!-- This doesn't work (modification) -->
{{lua: game_state:set("health", game_state:get("health") - 10) }}
```

**Impact:**
- ⛔ All 20+ passage templates don't work in runtime
- ⛔ RPG systems are broken at runtime
- ⛔ Combat, skill checks, leveling all non-functional
- ⛔ Story is editor-only, not playable

**Solution Needed:**
- Implement Lua sandbox in web runtime
- Use lua.vm.js or fengari (Lua in JS)
- Execute `{{lua: ... }}` blocks safely
- Expose game_state API to Lua context

**Effort:** HIGH (2-3 days)
**Value:** CRITICAL
**Priority:** #1 - MUST FIX FIRST

---

#### 2. **Conditional Content System** ⭐⭐⭐⭐⭐
**Status:** PARTIALLY IMPLEMENTED

**The Problem:**
- Editor supports `{{#if}}` syntax
- Runtime may not fully support complex conditionals
- No `{{#each}}` for loops
- Limited logical operators

**What's Missing:**
```whisker
<!-- Basic conditionals (might work) -->
{{#if health > 0}}
You are alive!
{{/if}}

<!-- Complex conditionals (probably broken) -->
{{#if health > 50 and stamina >= 10 and has_sword}}
[[Power Attack->attack]]
{{/if}}

<!-- Loops (doesn't exist) -->
{{#each inventory}}
- {{name}}: {{quantity}}
{{/each}}

<!-- Elsif chains (missing) -->
{{#if gold >= 100}}
  Rich!
{{#elsif gold >= 50}}
  Comfortable
{{#else}}
  Poor
{{/if}}
```

**Impact:**
- ⚠️ Complex branching logic hard to implement
- ⚠️ Inventory systems difficult
- ⚠️ Dynamic content limited

**Solution Needed:**
- Full Handlebars-like templating engine
- Support: if/elsif/else, each, unless, with
- Boolean operators: and, or, not, ==, !=, <, >, <=, >=
- Helper functions (custom conditionals)

**Effort:** MEDIUM (1-2 days)
**Value:** HIGH
**Priority:** #2

---

#### 3. **Mobile Runtime** ⭐⭐⭐⭐
**Status:** MISSING

**The Problem:**
- No mobile-optimized player
- No iOS/Android apps
- No PWA (Progressive Web App)
- No touch-friendly interface

**What's Missing:**
- Mobile-responsive UI
- Touch gesture support
- Offline capability
- App store distribution
- Native features (push notifications, etc.)

**Impact:**
- 📱 Can't reach mobile audience (60%+ of users)
- 📱 No offline play
- 📱 Poor UX on phones/tablets

**Solution Needed:**
- Create responsive web player
- Add PWA manifest and service worker
- Consider Cordova/Capacitor wrapper
- Touch-optimized controls

**Effort:** MEDIUM-HIGH (3-4 days)
**Value:** HIGH
**Priority:** #3

---

### 🟡 Important (Limits Growth)

#### 4. **Plugin/Extension System** ⭐⭐⭐⭐
**Status:** NOT IMPLEMENTED

**What's Missing:**
- No plugin API
- No way to add custom commands
- No macro system
- Can't extend editor or runtime

**Use Cases:**
- Custom story formats
- Integration with external APIs
- Genre-specific features (time travel, inventory, etc.)
- Community contributions

**Solution:**
- Define plugin architecture
- Hook system for editor and runtime
- Package format (JSON manifest)
- Plugin marketplace/registry

**Effort:** HIGH (4-5 days)
**Value:** MEDIUM-HIGH
**Priority:** #4

---

#### 5. **Version Control Integration** ⭐⭐⭐
**Status:** NO GIT INTEGRATION

**What's Missing:**
- No git commands in editor
- No commit/push from UI
- No branch management
- No diff viewer
- No merge conflict resolution

**Use Cases:**
- Team collaboration
- Change tracking
- Backup and recovery
- Compare versions

**Solution:**
- Git integration panel
- Commit dialog
- Visual diff tool
- Merge tools
- GitHub/GitLab integration

**Effort:** MEDIUM (2-3 days)
**Value:** MEDIUM
**Priority:** #5

---

#### 6. **Collaboration Features** ⭐⭐⭐
**Status:** SINGLE-USER ONLY

**What's Missing:**
- No real-time collaboration
- No user permissions
- No commenting system
- No review workflow
- No shared projects

**Use Cases:**
- Team writing
- Writing workshops
- Editor/writer workflow
- Large projects

**Solution:**
- Operational transformation (OT) or CRDT
- WebSocket sync server
- User presence indicators
- Comment threads
- Access control

**Effort:** VERY HIGH (1-2 weeks)
**Value:** MEDIUM
**Priority:** #6

---

#### 7. **Publishing Pipeline** ⭐⭐⭐
**Status:** BASIC EXPORT ONLY

**What's Missing:**
- No itch.io integration
- No direct upload to hosting
- No versioning for releases
- No analytics integration
- No monetization support

**Use Cases:**
- Publish to game platforms
- Track player behavior
- A/B testing
- Monetization

**Solution:**
- Platform integrations (itch.io, Steam, web hosts)
- Analytics SDK (Google Analytics, custom)
- Release management
- Payment integration

**Effort:** MEDIUM (2-3 days)
**Value:** MEDIUM
**Priority:** #7

---

### 🟢 Nice to Have (Quality of Life)

#### 8. **Automated Story Testing** ⭐⭐⭐
**Status:** NO TESTING FRAMEWORK

**What's Missing:**
- No automated passage testing
- No choice coverage analysis
- No regression testing
- No CI/CD integration

**Solution:**
- Story testing DSL
- Walkthrough recorder
- Assert system for variables
- Test coverage reports

**Effort:** MEDIUM (2-3 days)
**Value:** LOW-MEDIUM
**Priority:** #8

---

#### 9. **Localization/i18n** ⭐⭐
**Status:** NO TRANSLATION SUPPORT

**What's Missing:**
- No multi-language support
- No string extraction
- No translation workflow
- No locale switching

**Solution:**
- i18n key system
- Translation files (JSON/YAML)
- Locale selector
- RTL support

**Effort:** MEDIUM (2-3 days)
**Value:** LOW-MEDIUM
**Priority:** #9

---

#### 10. **Advanced Debugging** ⭐⭐⭐
**Status:** BASIC ONLY

**What's Missing:**
- No passage breakpoints
- No variable watches
- No step-through debugging
- No performance profiler
- No memory analysis

**Solution:**
- Debugger panel in editor
- Breakpoint system
- Call stack viewer
- Performance metrics
- Heap analysis

**Effort:** MEDIUM-HIGH (3-4 days)
**Value:** LOW-MEDIUM
**Priority:** #10

---

## 🔧 Editor-Specific Missing Features

### Already Have ✅
- [x] Graph view
- [x] Variables panel
- [x] Undo/redo
- [x] Validation
- [x] Export formats
- [x] Themes
- [x] Assets
- [x] Settings
- [x] Passage templates (NEW!)

### Missing 📋

#### 11. **Search & Replace** ⭐⭐⭐⭐
- Search across all passages
- Regex support
- Find references
- Rename refactoring

**Effort:** LOW (1 day)
**Priority:** Medium

---

#### 12. **Story Statistics** ⭐⭐⭐
- Word count per passage
- Total word count
- Average choices per passage
- Dead end analysis
- Most/least visited passages
- Complexity metrics

**Effort:** LOW (1 day)
**Priority:** Low

---

#### 13. **Story Map/Outline View** ⭐⭐⭐
- Tree outline of story structure
- Collapsible sections
- Drag to reorder
- Mark passages as sections/chapters

**Effort:** MEDIUM (2 days)
**Priority:** Medium

---

#### 14. **Snippet Library** ⭐⭐
- Save reusable code snippets
- Insert with shortcut
- Categories
- Share snippets

**Effort:** LOW (1 day)
**Priority:** Low

---

#### 15. **Macro Recording** ⭐⭐
- Record editing actions
- Replay macros
- Batch operations

**Effort:** MEDIUM (2 days)
**Priority:** Low

---

#### 16. **Import from Other Formats** ⭐⭐⭐
- Import from Ink
- Import from ChoiceScript
- Import from plain text
- Import from Yarn Spinner

**Effort:** MEDIUM (2-3 days per format)
**Priority:** Medium

---

#### 17. **Cloud Save/Sync** ⭐⭐⭐
- Save projects to cloud
- Auto-sync across devices
- Backup to cloud storage
- Share via link

**Effort:** MEDIUM-HIGH (3-4 days)
**Priority:** Medium

---

#### 18. **AI Writing Assistance** ⭐⭐
- Suggest choices
- Generate content
- Grammar/style check
- Plot suggestions

**Effort:** HIGH (4-5 days + API costs)
**Priority:** Low

---

## 🏃 Quick Wins (Low Effort, High Value)

These can be done quickly and provide immediate value:

1. **Search & Replace** (1 day) ⭐⭐⭐⭐
2. **Story Statistics** (1 day) ⭐⭐⭐
3. **Snippet Library** (1 day) ⭐⭐
4. **Keyboard Shortcut Customization** (1 day) ⭐⭐⭐
5. **Dark Mode for Runtime Player** (0.5 day) ⭐⭐
6. **Export to PDF** (1 day) ⭐⭐
7. **Print Stylesheet** (0.5 day) ⭐⭐

---

## 🎯 Recommended Implementation Order

### Phase 1: Fix Critical Blockers (1 week)
**Goal:** Make existing features actually work

1. **Inline Lua Execution** (3 days) - Priority #1
   - Integrate lua.vm.js or fengari
   - Implement game_state API
   - Test all passage templates

2. **Enhanced Conditional System** (2 days) - Priority #2
   - Full Handlebars templating
   - Boolean operators
   - Helper functions

3. **Testing & Validation** (2 days)
   - Test all RPG systems
   - Validate all templates work
   - Fix any runtime bugs

**Deliverable:** Fully functional runtime with all template features working

---

### Phase 2: Mobile & Accessibility (1 week)
**Goal:** Reach wider audience

1. **Mobile Runtime** (4 days)
   - Responsive design
   - Touch controls
   - PWA setup
   - Testing on devices

2. **Accessibility** (2 days)
   - ARIA labels
   - Screen reader support
   - Keyboard navigation
   - High contrast mode

3. **Performance Optimization** (1 day)
   - Load time improvements
   - Memory optimization
   - Asset compression

**Deliverable:** Mobile-friendly, accessible runtime

---

### Phase 3: Quick Wins (1 week)
**Goal:** Improve editor UX

1. **Search & Replace** (1 day)
2. **Story Statistics** (1 day)
3. **Story Map/Outline** (2 days)
4. **Snippet Library** (1 day)
5. **Import Improvements** (2 days)

**Deliverable:** More powerful editor

---

### Phase 4: Platform & Publishing (1-2 weeks)
**Goal:** Distribution and monetization

1. **Plugin System Architecture** (3 days)
2. **Publishing Integrations** (3 days)
3. **Analytics Integration** (2 days)
4. **Version Control UI** (3 days)

**Deliverable:** Professional publishing pipeline

---

### Phase 5: Collaboration (2-3 weeks)
**Goal:** Team features

1. **Real-time Sync** (5 days)
2. **Commenting System** (3 days)
3. **User Management** (3 days)
4. **Cloud Hosting** (4 days)

**Deliverable:** Collaborative authoring platform

---

## 💡 Innovation Opportunities

### Unique Features Whisker Could Have (That Twine Doesn't)

1. **Lua Sandbox Playground**
   - Test Lua code directly in editor
   - Interactive REPL
   - Code snippets library

2. **Story Debugger with Time Travel**
   - Replay any choice path
   - Jump to any point
   - Modify variables mid-play

3. **AI Story Analysis**
   - Plot hole detection
   - Pacing analysis
   - Character consistency checks

4. **Procedural Generation Support**
   - Built-in random generators
   - Template-based content
   - Variation system

5. **Visual Novel Mode**
   - Character sprites
   - Backgrounds
   - Animation support

6. **Voice Acting Integration**
   - Record in editor
   - Auto-generate dialogue
   - Voice selection

---

## 🎓 Learning Resources Needed

Missing documentation:

1. **Lua Scripting Guide**
   - How to use game_state API
   - Common patterns
   - Best practices
   - Examples

2. **Template Syntax Reference**
   - All available tags
   - Helper functions
   - Examples
   - Troubleshooting

3. **Video Tutorials**
   - Getting started
   - Advanced techniques
   - RPG system walkthrough

4. **Example Stories**
   - More complex examples
   - Different genres
   - Best practices

---

## 📊 Effort vs Value Summary

| Feature | Effort | Value | Priority | Phase |
|---------|--------|-------|----------|-------|
| Lua Execution | HIGH | CRITICAL | 1 | 1 |
| Conditionals | MED | HIGH | 2 | 1 |
| Mobile Runtime | MED-HIGH | HIGH | 3 | 2 |
| Search & Replace | LOW | MED-HIGH | 4 | 3 |
| Story Statistics | LOW | MEDIUM | 5 | 3 |
| Plugin System | HIGH | MED-HIGH | 6 | 4 |
| Version Control | MED | MEDIUM | 7 | 4 |
| Story Map | MED | MEDIUM | 8 | 3 |
| Publishing | MED | MEDIUM | 9 | 4 |
| Testing Framework | MED | LOW-MED | 10 | 4 |

---

## ✅ Next Steps

### Immediate (This Week)
1. **Fix Runtime Lua Execution** - Without this, templates are useless
2. **Test All Templates** - Ensure they work end-to-end
3. **Document Limitations** - Update docs with what does/doesn't work

### Short Term (This Month)
1. Implement mobile runtime
2. Add search & replace
3. Create comprehensive Lua guide
4. Build more example stories

### Medium Term (3 Months)
1. Plugin architecture
2. Publishing integrations
3. Version control UI
4. Story testing framework

### Long Term (6 Months)
1. Collaboration features
2. AI assistance
3. Visual novel mode
4. Cloud platform

---

## 🎯 Critical Path

To make Whisker production-ready for RPG stories:

1. ✅ Passage Templates - DONE
2. ⚠️ **Lua Execution in Runtime** - CRITICAL BLOCKER
3. ⚠️ **Enhanced Conditionals** - IMPORTANT
4. Mobile Support
5. Comprehensive Documentation
6. Example RPG Story (fully playable)
7. Tutorial Video Series

**Estimated Time to MVP:** 2-3 weeks of focused development

---

**Document Version:** 1.0
**Last Updated:** 2025-10-13
**Status:** Analysis Complete
**Next Action:** Implement Lua Execution in Runtime
