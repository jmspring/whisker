# Whisker Testing Guide

Comprehensive testing documentation for the Whisker Interactive Fiction Engine.

---

## Overview

Whisker has two comprehensive test suites:

1. **Lua Tests** - Test the core runtime and game engine (`tests/` directory) - **459 tests**
2. **JavaScript Tests** - Test the web editor, particularly Twine import (`editor/web/js/__tests__/`) - **290+ tests**

Both test suites run automatically in CI and must pass before merging.

---

## Table of Contents

### Lua Testing
- [Lua Quick Start](#lua-quick-start)
- [Lua Test Structure](#lua-test-structure)
- [Running Lua Tests](#running-lua-tests)
- [Lua Test Coverage](#lua-test-coverage)
- [Writing Lua Tests](#writing-lua-tests)
- [Lua Test Patterns](#lua-test-patterns)

### JavaScript Testing
- [JavaScript Quick Start](#javascript-quick-start)
- [JavaScript Test Structure](#javascript-test-structure)
- [JavaScript Test Coverage](#javascript-test-coverage)
- [Writing JavaScript Tests](#writing-new-tests)

---

# Lua Testing

## Lua Quick Start

### Install Lua and Dependencies

```bash
# Install Lua 5.4 (macOS with Homebrew)
brew install lua@5.4

# Install LuaRocks
brew install luarocks

# Install Busted (BDD testing framework)
luarocks install busted
```

### Run All Lua Tests

```bash
# Run all tests
busted

# Run specific test file
busted tests/test_story.lua

# Run with verbose output
busted --verbose

# Run with coverage (requires luacov)
busted --coverage
```

### Run Tests Locally (Same as CI)

```bash
# Exact command used in GitHub Actions
busted tests/test_story.lua \
       tests/test_compact_integration.lua \
       tests/test_rijks_load.lua \
       tests/test_renderer.lua \
       tests/test_validator.lua \
       tests/test_profiler.lua \
       tests/test_debugger.lua \
       tests/test_metatable_preservation.lua \
       tests/test_save_system.lua \
       tests/test_template_processor.lua \
       tests/test_harlowe_converter.lua \
       tests/test_sugarcube_converter.lua \
       tests/test_chapbook_converter.lua \
       tests/test_snowman_converter.lua \
       tests/test_format_converter.lua \
       tests/test_import.lua \
       tests/test_export.lua \
       tests/test_compact_format.lua \
       tests/test_harlowe_parser.lua \
       tests/test_sugarcube_parser.lua \
       tests/test_chapbook_parser.lua \
       tests/test_snowman_parser.lua \
       tests/test_converter_roundtrip.lua \
       tests/test_event_system.lua \
       tests/test_string_utils.lua
```

---

## Lua Test Structure

### Test Files Organization

```
tests/
├── test_helper.lua              # Shared test utilities
├── test_story.lua               # Core story integration tests
├── test_compact_integration.lua # Compact format integration
├── test_rijks_load.lua         # Large story loading tests
├── test_renderer.lua            # Text rendering and markdown
├── test_validator.lua           # Story validation
├── test_profiler.lua            # Performance profiling
├── test_debugger.lua            # Debugging features
├── test_metatable_preservation.lua # Serialization
├── test_save_system.lua         # Save/load functionality
├── test_template_processor.lua  # Template processing
├── test_event_system.lua        # Event system
├── test_string_utils.lua        # String utilities
├── test_format_converter.lua    # Format conversion
├── test_import.lua              # Twine import
├── test_export.lua              # Twine export
├── test_compact_format.lua      # Compact format conversion
├── test_harlowe_converter.lua   # Harlowe format converter
├── test_sugarcube_converter.lua # SugarCube converter
├── test_chapbook_converter.lua  # Chapbook converter
├── test_snowman_converter.lua   # Snowman converter
├── test_harlowe_parser.lua      # Harlowe parser
├── test_sugarcube_parser.lua    # SugarCube parser
├── test_chapbook_parser.lua     # Chapbook parser
├── test_snowman_parser.lua      # Snowman parser
├── test_converter_roundtrip.lua # Roundtrip conversion tests
├── fixtures/                    # Test fixtures
│   ├── harlowe/
│   ├── sugarcube/
│   ├── chapbook/
│   ├── snowman/
│   └── twine/
├── harlowe/                     # Harlowe-specific tests
├── sugarcube/                   # SugarCube-specific tests
├── chapbook/                    # Chapbook-specific tests
└── snowman/                     # Snowman-specific tests
```

### Test File Structure

All Lua tests use **Busted BDD** (Behavior-Driven Development) framework:

```lua
local helper = require("tests.test_helper")
local MyModule = require("whisker.module.my_module")

describe("MyModule", function()
  describe("method_name", function()
    it("should do something specific", function()
      -- Arrange
      local input = "test"

      -- Act
      local result = MyModule.method_name(input)

      -- Assert
      assert.equals("expected", result)
    end)
  end)
end)
```

---

## Running Lua Tests

### Run All Tests

```bash
busted
```

### Run Specific Test File

```bash
busted tests/test_story.lua
```

### Run Multiple Files

```bash
busted tests/test_story.lua tests/test_renderer.lua
```

### Run Tests Matching Pattern

```bash
busted --pattern=converter
```

### Run with Verbose Output

```bash
busted --verbose
```

### Run Single Test by Name

```bash
busted --filter="should load compact format file"
```

### Run with Coverage

```bash
# Install luacov first
luarocks install luacov

# Run with coverage
busted --coverage

# Generate coverage report
luacov

# View report
cat luacov.report.out
```

---

## Lua Test Coverage

### Test Categories

| Category | Files | Tests | Status |
|----------|-------|-------|--------|
| **Core Integration** | 3 | 39 | ✅ Passing |
| **Engine Core** | 7 | 122 | ✅ Passing |
| **Format Conversion** | 4 | 143 | ✅ Passing |
| **Format Converters** | 4 | 81 | ✅ Passing |
| **Format Parsers** | 4 | 40 | ✅ Passing |
| **Utilities** | 2 | 32 | ✅ Passing |
| **Roundtrip** | 1 | 14 | ✅ Passing (2 pending) |
| **Total** | **26** | **459** | **✅ All Passing** |

### Coverage by Component

#### Core Integration (39 tests)
- ✅ Story creation and management (13 tests)
- ✅ Compact format integration (10 tests)
- ✅ Large story loading (16 tests)

#### Engine Core (122 tests)
- ✅ Text rendering (14 tests)
- ✅ Story validation (12 tests)
- ✅ Performance profiling (7 tests)
- ✅ Debugging features (8 tests)
- ✅ Metatable preservation (15 tests)
- ✅ Save system (5 tests)
- ✅ Template processing (27 tests)
- ✅ Event system (18 tests)
- ✅ String utilities (16 tests)

#### Format Conversion (143 tests)
- ✅ Format converter (45 tests)
- ✅ Twine import (48 tests)
- ✅ Twine export (42 tests)
- ✅ Compact format conversion (8 tests)

#### Format Converters (81 tests)
- ✅ Harlowe converter (20 tests)
- ✅ SugarCube converter (21 tests)
- ✅ Chapbook converter (20 tests)
- ✅ Snowman converter (20 tests)

#### Format Parsers (40 tests)
- ✅ Harlowe parser (10 tests)
- ✅ SugarCube parser (10 tests)
- ✅ Chapbook parser (10 tests)
- ✅ Snowman parser (10 tests)

#### Roundtrip Tests (14 tests)
- ✅ Cross-format conversions (12 tests)
- ⏸️ Conversion loss detection (2 pending)

---

## Writing Lua Tests

### Step 1: Create Test File

Create a new file in `tests/` following the naming convention `test_<feature>.lua`:

```lua
local helper = require("tests.test_helper")
local MyFeature = require("whisker.module.my_feature")

describe("MyFeature", function()
  -- Tests go here
end)
```

### Step 2: Write Test Groups

Organize tests into logical groups using `describe`:

```lua
describe("MyFeature", function()
  describe("Initialization", function()
    it("should create instance with defaults", function()
      local feature = MyFeature.new()
      assert.is_not_nil(feature)
    end)
  end)

  describe("Processing", function()
    it("should process valid input", function()
      local feature = MyFeature.new()
      local result = feature:process("test")
      assert.equals("processed: test", result)
    end)
  end)
end)
```

### Step 3: Use Helper Functions

```lua
local function create_test_story()
  local story = Story.new()
  story:set_metadata("name", "Test Story")
  local start = Passage.new("start", "start")
  start:set_content("Test content")
  story:add_passage(start)
  story:set_start_passage("start")
  return story
end

describe("Story Tests", function()
  it("should work with test story", function()
    local story = create_test_story()
    assert.is_not_nil(story)
  end)
end)
```

### Step 4: Use Setup/Teardown

```lua
describe("MyFeature", function()
  local feature

  before_each(function()
    feature = MyFeature.new()
  end)

  after_each(function()
    feature = nil
  end)

  it("should use setup feature", function()
    assert.is_not_nil(feature)
  end)
end)
```

---

## Lua Test Patterns

### Testing Return Values

```lua
it("should return correct value", function()
  local result = MyModule.calculate(5, 3)
  assert.equals(8, result)
end)
```

### Testing Tables

```lua
it("should return correct table", function()
  local result = MyModule.get_data()
  assert.is_table(result)
  assert.equals("value", result.key)
end)
```

### Testing Nil/Not Nil

```lua
it("should return non-nil value", function()
  local result = MyModule.get_something()
  assert.is_not_nil(result)
end)

it("should return nil for invalid input", function()
  local result = MyModule.get_something(nil)
  assert.is_nil(result)
end)
```

### Testing Errors

```lua
it("should throw error for invalid input", function()
  assert.has_error(function()
    MyModule.process(nil)
  end)
end)

it("should throw specific error message", function()
  assert.has_error(function()
    MyModule.process(nil)
  end, "Input cannot be nil")
end)
```

### Testing String Patterns

```lua
it("should match pattern", function()
  local result = MyModule.format("test")
  assert.matches("^formatted:", result)
end)
```

### Testing with Mock Data

```lua
it("should process story correctly", function()
  local story = {
    metadata = { title = "Test" },
    passages = {
      { id = "start", content = "Hello" }
    }
  }

  local result = MyModule.process_story(story)
  assert.is_not_nil(result)
end)
```

### Pending Tests

```lua
pending("should implement feature X", function()
  -- Test will be skipped but marked as pending
end)
```

---

# JavaScript Testing

## JavaScript Quick Start

### Install Dependencies

```bash
npm install
```

### Run All Tests

```bash
npm test
```

### Run Tests in Watch Mode

```bash
npm run test:watch
```

### Run Tests with Coverage

```bash
npm run test:coverage
```

### Run Only Editor Tests

```bash
npm run test:editor
```

---

## Test Structure

### Test Files

```
editor/web/js/__tests__/
├── test-helpers.js              # Shared utilities and mocks
├── twine-parser.test.js         # TwineParser unit tests
├── twine-importer.test.js       # TwineImporter unit tests
└── twine-integration.test.js    # Full workflow integration tests
```

### Test Organization

Each test file follows the same structure:

```javascript
describe('ComponentName', () => {
    describe('methodName', () => {
        test('specific behavior', () => {
            // Arrange
            const input = 'test';

            // Act
            const result = method(input);

            // Assert
            expect(result).toBe('expected');
        });
    });
});
```

---

## Test Coverage

### TwineParser Tests (`twine-parser.test.js`)

**Coverage**: 200+ tests

**What's tested**:
- ✅ Passage ID generation (8 tests)
- ✅ IFID generation (3 tests)
- ✅ Format detection (5 tests)
- ✅ Link format parsing (5 tests)
- ✅ Link extraction (6 tests)
- ✅ Harlowe macro conversion (8 tests)
- ✅ SugarCube macro conversion (9 tests)
- ✅ Variable extraction (6 tests)
- ✅ Metadata extraction (3 tests)
- ✅ Full parse integration (7 tests)

**Example**:
```javascript
test('converts Harlowe variable display', () => {
    const content = 'Your health is $health points';
    const result = TwineParser.convertHarloweToWhisker(content);
    expect(result).toBe('Your health is {{health}} points');
});
```

### TwineImporter Tests (`twine-importer.test.js`)

**Coverage**: 50+ tests

**What's tested**:
- ✅ Initialization (2 tests)
- ✅ Import dialog flow (4 tests)
- ✅ File handling (5 tests)
- ✅ Confirmation dialog (6 tests)
- ✅ Project import (8 tests)
- ✅ Success notifications (2 tests)
- ✅ Error handling (5 tests)
- ✅ HTML escaping (7 tests)
- ✅ Full workflow integration (1 test)

**Example**:
```javascript
test('replaces editor project on import', () => {
    const mockProject = {
        metadata: { title: 'Test' },
        passages: [{ id: 'start' }],
        variables: {}
    };

    importer.importProject(mockProject);

    expect(mockEditor.project).toBe(mockProject);
});
```

### Integration Tests (`twine-integration.test.js`)

**Coverage**: 40+ tests

**What's tested**:
- ✅ Harlowe story end-to-end (15 tests)
- ✅ SugarCube story end-to-end (10 tests)
- ✅ Error scenarios (3 tests)
- ✅ Edge cases (10 tests)
- ✅ Real-world scenarios (2 tests)

**Example**:
```javascript
test('imports complete Harlowe story', () => {
    const html = createHarloweTestStory();
    const project = TwineParser.parse(html);

    assertValidWhiskerProject(project);
    assertHasPassages(project, ['Start', 'Forest', 'Village', 'Victory']);
    assertHasVariables(project, ['health', 'hasKey']);
});
```

---

## Test Helpers

The `test-helpers.js` file provides utilities for writing tests:

### Creating Test Data

```javascript
// Create minimal Twine HTML
const html = createTwineHTML({
    name: 'My Story',
    format: 'Harlowe',
    passages: [
        { pid: '1', name: 'Start', content: 'Story begins' }
    ]
});

// Create pre-built test stories
const harloweStory = createHarloweTestStory();
const sugarcubeStory = createSugarCubeTestStory();

// Create invalid HTML for error testing
const invalid = createInvalidTwineHTML();
const empty = createEmptyTwineHTML();
```

### Creating Mocks

```javascript
// Mock File object
const file = createMockFile(htmlContent, 'story.html');

// Mock Editor
const editor = createMockEditor();
editor.updateStatus('Test status');
expect(editor.updateStatus).toHaveBeenCalled();
```

### DOM Setup

```javascript
// Setup test DOM
setupTestDOM();

// Setup global mocks (window.graph, etc.)
setupGlobalMocks();

// Cleanup
cleanupAfterTest();
```

### Assertions

```javascript
// Validate project structure
assertValidWhiskerProject(project);

// Validate passage structure
assertValidWhiskerPassage(passage);

// Check for expected passages
assertHasPassages(project, ['Start', 'End']);

// Check for expected variables
assertHasVariables(project, ['health', 'gold']);

// Find passages
const passage = findPassageByTitle(project, 'Start');

// Count tags
const count = countPassagesWithTag(project, 'intro');

// Get variable names
const vars = getVariableNames(project);
```

---

## Writing New Tests

### Step 1: Choose Test File

- **Unit tests** for a specific method → Add to `twine-parser.test.js` or `twine-importer.test.js`
- **Integration tests** for full workflow → Add to `twine-integration.test.js`
- **New feature** → Create new test file `feature-name.test.js`

### Step 2: Write Test

```javascript
describe('FeatureName', () => {
    describe('methodName', () => {
        test('does something specific', () => {
            // Arrange - set up test data
            const input = 'test input';

            // Act - perform the action
            const result = methodName(input);

            // Assert - verify the result
            expect(result).toBe('expected output');
        });
    });
});
```

### Step 3: Use Helpers

```javascript
const {
    createTwineHTML,
    assertValidWhiskerProject
} = require('./test-helpers');

test('my integration test', () => {
    const html = createTwineHTML({ name: 'Test' });
    const project = TwineParser.parse(html);
    assertValidWhiskerProject(project);
});
```

### Step 4: Run Tests

```bash
npm test -- twine-parser.test.js
```

---

## Common Test Patterns

### Testing Parser Output

```javascript
test('parses passage correctly', () => {
    const html = createTwineHTML({
        passages: [{
            pid: '1',
            name: 'Test',
            content: '[[Next]]'
        }]
    });

    const project = TwineParser.parse(html);
    const passage = project.passages[0];

    expect(passage.title).toBe('Test');
    expect(passage.choices).toHaveLength(1);
    expect(passage.choices[0].text).toBe('Next');
});
```

### Testing Error Handling

```javascript
test('throws error for invalid input', () => {
    const invalidHTML = '<html>Not Twine</html>';

    expect(() => {
        TwineParser.parse(invalidHTML);
    }).toThrow('Not a valid Twine 2 HTML file');
});
```

### Testing DOM Interactions

```javascript
test('updates DOM elements', () => {
    setupTestDOM();

    const element = document.getElementById('testElement');
    element.textContent = 'Updated';

    expect(element.textContent).toBe('Updated');

    cleanupAfterTest();
});
```

### Testing Async Operations

```javascript
test('handles async file loading', async () => {
    const file = createMockFile('<html>Content</html>');

    const content = await file.text();

    expect(content).toBe('<html>Content</html>');
});
```

### Testing with Mocks

```javascript
test('calls editor methods', () => {
    const editor = createMockEditor();
    const importer = new TwineImporter(editor);

    importer.importProject(mockProject);

    expect(editor.updateStatus).toHaveBeenCalled();
    expect(editor.renderAll).toHaveBeenCalled();
});
```

---

## Debugging Tests

### Run Single Test

```bash
npm test -- --testNamePattern="converts Harlowe"
```

### Run Single File

```bash
npm test -- twine-parser.test.js
```

### Verbose Output

```bash
npm test -- --verbose
```

### Debug with Node Inspector

```bash
node --inspect-brk node_modules/.bin/jest --runInBand
```

Then open Chrome DevTools at `chrome://inspect`.

### Console Output in Tests

```javascript
test('debug test', () => {
    const result = someFunction();
    console.log('Result:', result); // Will appear in test output
    expect(result).toBeDefined();
});
```

---

## Continuous Integration

### GitHub Actions

Tests run automatically on:
- Every push to `main`
- Every pull request
- Manual workflow dispatch

### Test Requirements

Before merging:
- ✅ All tests must pass
- ✅ Coverage should not decrease
- ✅ No console errors/warnings

---

## Coverage Reports

### Generate Coverage

```bash
npm run test:coverage
```

### View Coverage

Coverage reports are generated in `coverage/` directory:
- `coverage/lcov-report/index.html` - HTML report (open in browser)
- `coverage/lcov.info` - LCOV format (for CI tools)
- `coverage/coverage-summary.json` - JSON summary

### Coverage Targets

| Component | Target | Current |
|-----------|--------|---------|
| TwineParser | 90% | 95% |
| TwineImporter | 80% | 85% |
| Overall | 85% | 90% |

---

## Best Practices

### DO

✅ Write tests for new features before implementation (TDD)
✅ Test edge cases and error conditions
✅ Use descriptive test names
✅ Keep tests focused and simple
✅ Use test helpers to reduce duplication
✅ Mock external dependencies
✅ Clean up after tests (reset DOM, clear mocks)

### DON'T

❌ Write tests that depend on other tests
❌ Use hard-coded paths or external files
❌ Skip error case testing
❌ Write tests longer than 20 lines (split them)
❌ Ignore failing tests
❌ Test implementation details (test behavior)

### Test Naming

```javascript
// ✅ Good: Describes behavior
test('converts Harlowe set macro to Whisker syntax', () => { ... });

// ❌ Bad: Describes implementation
test('calls convertHarloweToWhisker with content', () => { ... });
```

### Test Organization

```javascript
// ✅ Good: Organized by feature
describe('TwineParser', () => {
    describe('link parsing', () => {
        test('simple links', () => { ... });
        test('pipe links', () => { ... });
    });
});

// ❌ Bad: Flat structure
describe('TwineParser', () => {
    test('test1', () => { ... });
    test('test2', () => { ... });
});
```

---

## Troubleshooting

### Tests Failing Locally

```bash
# Clear Jest cache
npm test -- --clearCache

# Reinstall dependencies
rm -rf node_modules
npm install
```

### DOM Not Available

Make sure `jest.config` has:
```json
{
  "testEnvironment": "jsdom"
}
```

### Module Not Found

Check that source files exist:
```javascript
const source = fs.readFileSync(
    path.join(__dirname, '../twine-parser.js'),
    'utf8'
);
```

### Timeout Errors

Increase timeout for slow tests:
```javascript
test('slow operation', async () => {
    // test code
}, 10000); // 10 second timeout
```

---

## Resources

### Jest Documentation
- https://jestjs.io/docs/getting-started
- https://jestjs.io/docs/expect

### Testing Best Practices
- https://kentcdodds.com/blog/common-mistakes-with-react-testing-library
- https://martinfowler.com/articles/practical-test-pyramid.html

### Whisker Documentation
- `TWINE_IMPORT.md` - User guide for Twine import
- `TWINE_IMPORT_TESTS.md` - Manual testing guide
- `PHASE2_COMPLETE.md` - Phase 2 implementation details

---

## Contributing

### Adding New Tests

1. Create branch: `git checkout -b test/feature-name`
2. Write tests in appropriate file
3. Ensure tests pass: `npm test`
4. Check coverage: `npm run test:coverage`
5. Commit: `git commit -m "Add tests for feature X"`
6. Push and create PR

### Updating Tests

1. Update test file
2. Verify all related tests still pass
3. Update documentation if needed
4. Submit PR with explanation

---

## Summary

**Test Count**: 290+ tests
**Coverage**: ~90%
**Test Time**: ~5 seconds
**Frameworks**: Jest + jsdom

**Commands**:
- `npm test` - Run all tests
- `npm run test:watch` - Watch mode
- `npm run test:coverage` - Generate coverage

**Key Files**:
- `package.json` - Test configuration
- `editor/web/js/__tests__/` - Test files
- `coverage/` - Coverage reports (generated)

---

**Last Updated**: October 2024
**Maintained By**: Whisker Development Team
