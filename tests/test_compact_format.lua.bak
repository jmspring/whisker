-- Test Compact Format Conversion
-- Tests the CompactConverter module for format conversion between verbose 1.0 and compact 2.0

package.path = package.path .. ";./src/?.lua"

local CompactConverter = require("src.format.compact_converter")

-- Test counters
local tests_passed = 0
local tests_failed = 0
local current_test = ""

-- Test helpers
local function test(name, func)
    current_test = name
    io.write("Testing: " .. name .. " ... ")
    local success, err = pcall(func)
    if success then
        io.write("✓ PASSED\n")
        tests_passed = tests_passed + 1
    else
        io.write("✗ FAILED\n")
        io.write("  Error: " .. tostring(err) .. "\n")
        tests_failed = tests_failed + 1
    end
end

local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s",
            message or "Values not equal", tostring(expected), tostring(actual)))
    end
end

local function assert_not_equal(actual, expected, message)
    if actual == expected then
        error(string.format("%s\nExpected not: %s\nActual: %s",
            message or "Values should not be equal", tostring(expected), tostring(actual)))
    end
end

local function assert_true(value, message)
    if not value then
        error(message or "Expected true, got false")
    end
end

local function assert_false(value, message)
    if value then
        error(message or "Expected false, got true")
    end
end

local function assert_nil(value, message)
    if value ~= nil then
        error(string.format("%s\nExpected nil, got: %s", message or "Value should be nil", tostring(value)))
    end
end

local function assert_not_nil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

local function assert_table_size(tbl, expected_size, message)
    local actual_size = #tbl
    if actual_size ~= expected_size then
        error(string.format("%s\nExpected size: %d\nActual size: %d",
            message or "Table size mismatch", expected_size, actual_size))
    end
end

--------------------------------------------------------------------------------
-- TEST DATA CREATORS
--------------------------------------------------------------------------------

local function create_verbose_story()
    return {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {
            title = "Test Story",
            name = "Test Story",  -- duplicate
            ifid = "TEST-001",
            author = "Test Author",
            created = "2025-01-01T00:00:00",
            modified = "2025-01-01T00:00:00",
            description = "A test story",
            format = "whisker",  -- duplicate
            format_version = "1.0",  -- duplicate
            version = "1.0"
        },
        assets = {},
        scripts = {},
        stylesheets = {},
        variables = {},
        passages = {
            {
                id = "start",
                name = "Start",
                pid = "p1",
                content = "Welcome to the test story.",  -- duplicate
                text = "Welcome to the test story.",
                metadata = {},
                tags = {},
                position = {x = 0, y = 0},
                size = {width = 100, height = 100},
                choices = {
                    {
                        text = "Go to room",
                        target_passage = "room",
                        metadata = {}
                    }
                }
            },
            {
                id = "room",
                name = "Room",
                pid = "p2",
                content = "You are in a room.",
                text = "You are in a room.",
                metadata = {},
                tags = {},
                position = {x = 0, y = 0},
                size = {width = 100, height = 100},
                choices = {}
            }
        },
        settings = {
            autoSave = true,
            scriptingLanguage = "lua",
            startPassage = "start",
            theme = "default",
            undoLimit = 50
        }
    }
end

local function create_compact_story()
    return {
        format = "whisker",
        formatVersion = "2.0",
        metadata = {
            title = "Test Story",
            ifid = "TEST-001",
            author = "Test Author",
            created = "2025-01-01T00:00:00",
            modified = "2025-01-01T00:00:00",
            description = "A test story"
        },
        passages = {
            {
                id = "start",
                name = "Start",
                pid = "p1",
                text = "Welcome to the test story.",
                choices = {
                    {
                        text = "Go to room",
                        target = "room"
                    }
                }
            },
            {
                id = "room",
                name = "Room",
                pid = "p2",
                text = "You are in a room."
            }
        },
        settings = {
            autoSave = true,
            scriptingLanguage = "lua",
            startPassage = "start",
            theme = "default",
            undoLimit = 50
        }
    }
end

local function create_verbose_story_with_non_defaults()
    return {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {
            title = "Custom Story",
            ifid = "CUSTOM-001",
            author = "Custom Author"
        },
        assets = {"asset1.png"},  -- Non-empty
        passages = {
            {
                id = "start",
                name = "Start",
                pid = "p1",
                text = "Start here",
                content = "Start here",
                tags = {"important", "start"},  -- Non-empty
                metadata = {"key", "value"},  -- Non-empty
                position = {x = 100, y = 200},  -- Non-default
                size = {width = 150, height = 200},  -- Non-default
                choices = {}
            }
        },
        settings = {
            startPassage = "start"
        }
    }
end

--------------------------------------------------------------------------------
-- CONVERSION TESTS
--------------------------------------------------------------------------------

test("Create converter instance", function()
    local converter = CompactConverter.new()
    assert_not_nil(converter, "Converter should be created")
end)

test("Convert verbose to compact - basic", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_nil(err, "Should not have error: " .. tostring(err))
    assert_not_nil(compact, "Compact format should be returned")
    assert_equal(compact.formatVersion, "2.0", "Should have version 2.0")
end)

test("Compact format removes duplicate text field", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_not_nil(compact.passages[1].text, "Should have text field")
    assert_nil(compact.passages[1].content, "Should not have content field")
end)

test("Compact format removes empty arrays", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_nil(compact.assets, "Should not include empty assets array")
    assert_nil(compact.scripts, "Should not include empty scripts array")
    assert_nil(compact.stylesheets, "Should not include empty stylesheets array")
    assert_nil(compact.variables, "Should not include empty variables array")
    assert_nil(compact.passages[1].tags, "Should not include empty tags array")
    assert_nil(compact.passages[1].metadata, "Should not include empty metadata array")
end)

test("Compact format removes default position", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_nil(compact.passages[1].position, "Should not include default position {0,0}")
end)

test("Compact format removes default size", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_nil(compact.passages[1].size, "Should not include default size {100,100}")
end)

test("Compact format shortens choice field names", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_not_nil(compact.passages[1].choices[1].target, "Should have 'target' field")
    assert_equal(compact.passages[1].choices[1].target, "room", "Target should be preserved")
end)

test("Compact format removes duplicate metadata fields", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()
    local compact, err = converter:to_compact(verbose)

    assert_equal(compact.metadata.title, "Test Story", "Should have title")
    assert_nil(compact.metadata.name, "Should not have duplicate name")
    assert_nil(compact.metadata.format, "Should not have duplicate format")
    assert_nil(compact.metadata.format_version, "Should not have duplicate format_version")
end)

test("Compact format preserves non-empty arrays", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story_with_non_defaults()
    local compact, err = converter:to_compact(verbose)

    assert_not_nil(compact.assets, "Should preserve non-empty assets")
    assert_table_size(compact.assets, 1, "Should have 1 asset")
    assert_not_nil(compact.passages[1].tags, "Should preserve non-empty tags")
    assert_table_size(compact.passages[1].tags, 2, "Should have 2 tags")
end)

test("Compact format preserves non-default position", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story_with_non_defaults()
    local compact, err = converter:to_compact(verbose)

    assert_not_nil(compact.passages[1].position, "Should preserve non-default position")
    assert_equal(compact.passages[1].position.x, 100, "X position should be preserved")
    assert_equal(compact.passages[1].position.y, 200, "Y position should be preserved")
end)

test("Compact format preserves non-default size", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story_with_non_defaults()
    local compact, err = converter:to_compact(verbose)

    assert_not_nil(compact.passages[1].size, "Should preserve non-default size")
    assert_equal(compact.passages[1].size.width, 150, "Width should be preserved")
    assert_equal(compact.passages[1].size.height, 200, "Height should be preserved")
end)

--------------------------------------------------------------------------------
-- EXPANSION TESTS
--------------------------------------------------------------------------------

test("Convert compact to verbose - basic", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_nil(err, "Should not have error: " .. tostring(err))
    assert_not_nil(verbose, "Verbose format should be returned")
    assert_equal(verbose.formatVersion, "1.0", "Should have version 1.0")
end)

test("Verbose format restores duplicate text field", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_not_nil(verbose.passages[1].text, "Should have text field")
    assert_not_nil(verbose.passages[1].content, "Should have content field")
    assert_equal(verbose.passages[1].text, verbose.passages[1].content, "Text and content should match")
end)

test("Verbose format restores empty arrays", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_not_nil(verbose.assets, "Should have assets array")
    assert_table_size(verbose.assets, 0, "Assets should be empty")
    assert_not_nil(verbose.passages[1].metadata, "Should have metadata array")
    assert_table_size(verbose.passages[1].metadata, 0, "Metadata should be empty")
end)

test("Verbose format restores default position", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_not_nil(verbose.passages[1].position, "Should have position")
    assert_equal(verbose.passages[1].position.x, 0, "X should be 0")
    assert_equal(verbose.passages[1].position.y, 0, "Y should be 0")
end)

test("Verbose format restores default size", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_not_nil(verbose.passages[1].size, "Should have size")
    assert_equal(verbose.passages[1].size.width, 100, "Width should be 100")
    assert_equal(verbose.passages[1].size.height, 100, "Height should be 100")
end)

test("Verbose format restores full choice field names", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_not_nil(verbose.passages[1].choices[1].target_passage, "Should have 'target_passage' field")
    assert_equal(verbose.passages[1].choices[1].target_passage, "room", "Target passage should be preserved")
end)

test("Verbose format restores duplicate metadata fields", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()
    local verbose, err = converter:to_verbose(compact)

    assert_equal(verbose.metadata.title, "Test Story", "Should have title")
    assert_equal(verbose.metadata.name, "Test Story", "Should have name matching title")
    assert_equal(verbose.metadata.format, "whisker", "Should have format")
    assert_equal(verbose.metadata.format_version, "1.0", "Should have format_version")
end)

--------------------------------------------------------------------------------
-- ROUND-TRIP TESTS
--------------------------------------------------------------------------------

test("Round-trip: verbose → compact → verbose preserves data", function()
    local converter = CompactConverter.new()
    local original = create_verbose_story()

    local compact, err = converter:to_compact(original)
    assert_nil(err, "Compact conversion should succeed")

    local restored, err = converter:to_verbose(compact)
    assert_nil(err, "Verbose conversion should succeed")

    -- Check passages
    assert_equal(#restored.passages, #original.passages, "Passage count should match")

    -- Check first passage
    assert_equal(restored.passages[1].id, original.passages[1].id, "Passage ID should match")
    assert_equal(restored.passages[1].name, original.passages[1].name, "Passage name should match")
    assert_equal(restored.passages[1].text, original.passages[1].text, "Passage text should match")

    -- Check choices
    assert_equal(#restored.passages[1].choices, #original.passages[1].choices, "Choice count should match")
    assert_equal(restored.passages[1].choices[1].text, original.passages[1].choices[1].text, "Choice text should match")
end)

test("Round-trip: compact → verbose → compact preserves data", function()
    local converter = CompactConverter.new()
    local original = create_compact_story()

    local verbose, err = converter:to_verbose(original)
    assert_nil(err, "Verbose conversion should succeed")

    local restored, err = converter:to_compact(verbose)
    assert_nil(err, "Compact conversion should succeed")

    -- Check passages
    assert_equal(#restored.passages, #original.passages, "Passage count should match")

    -- Check first passage
    assert_equal(restored.passages[1].id, original.passages[1].id, "Passage ID should match")
    assert_equal(restored.passages[1].name, original.passages[1].name, "Passage name should match")
    assert_equal(restored.passages[1].text, original.passages[1].text, "Passage text should match")

    -- Check that compact format is maintained
    assert_nil(restored.passages[1].position, "Position should remain omitted")
    assert_nil(restored.passages[1].size, "Size should remain omitted")
end)

test("Validate round-trip helper function", function()
    local converter = CompactConverter.new()
    local original = create_verbose_story()

    local success, err = converter:validate_round_trip(original)
    assert_true(success, "Round-trip validation should pass: " .. tostring(err))
end)

--------------------------------------------------------------------------------
-- UTILITY TESTS
--------------------------------------------------------------------------------

test("Get format version - verbose", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()

    local version = converter:get_format_version(verbose)
    assert_equal(version, "1.0", "Should detect version 1.0")
end)

test("Get format version - compact", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()

    local version = converter:get_format_version(compact)
    assert_equal(version, "2.0", "Should detect version 2.0")
end)

test("Is compact - returns true for compact format", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()

    assert_true(converter:is_compact(compact), "Should detect compact format")
end)

test("Is compact - returns false for verbose format", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()

    assert_false(converter:is_compact(verbose), "Should detect verbose format")
end)

test("Is verbose - returns true for verbose format", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()

    assert_true(converter:is_verbose(verbose), "Should detect verbose format")
end)

test("Is verbose - returns false for compact format", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()

    assert_false(converter:is_verbose(compact), "Should detect compact format")
end)

test("Converting already compact document returns unchanged", function()
    local converter = CompactConverter.new()
    local compact = create_compact_story()

    local result, err = converter:to_compact(compact)
    assert_nil(err, "Should not have error")
    assert_equal(result.formatVersion, "2.0", "Should remain version 2.0")
end)

test("Converting already verbose document returns unchanged", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()

    local result, err = converter:to_verbose(verbose)
    assert_nil(err, "Should not have error")
    assert_equal(result.formatVersion, "1.0", "Should remain version 1.0")
end)

--------------------------------------------------------------------------------
-- EDGE CASE TESTS
--------------------------------------------------------------------------------

test("Handle empty passage list", function()
    local converter = CompactConverter.new()
    local doc = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {title = "Empty", ifid = "EMPTY-001"},
        passages = {},
        settings = {}
    }

    local compact, err = converter:to_compact(doc)
    assert_nil(err, "Should handle empty passages")
    assert_table_size(compact.passages, 0, "Should have 0 passages")
end)

test("Handle passage with no choices", function()
    local converter = CompactConverter.new()
    local verbose = create_verbose_story()

    local compact, err = converter:to_compact(verbose)
    assert_nil(err, "Should handle passage with no choices")
    assert_nil(compact.passages[2].choices, "Empty choices should be omitted")
end)

test("Handle nil metadata gracefully", function()
    local converter = CompactConverter.new()
    local doc = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = nil,
        passages = {},
        settings = {}
    }

    local compact, err = converter:to_compact(doc)
    assert_nil(err, "Should handle nil metadata")
    assert_not_nil(compact.metadata, "Should create empty metadata")
end)

--------------------------------------------------------------------------------
-- PRINT RESULTS
--------------------------------------------------------------------------------

print("\n" .. string.rep("=", 70))
print("TEST RESULTS")
print(string.rep("=", 70))
print("Passed: " .. tests_passed)
print("Failed: " .. tests_failed)
print("Total:  " .. (tests_passed + tests_failed))
print(string.rep("=", 70))

if tests_failed > 0 then
    print("SOME TESTS FAILED")
    os.exit(1)
else
    print("ALL TESTS PASSED ✓")
    os.exit(0)
end
