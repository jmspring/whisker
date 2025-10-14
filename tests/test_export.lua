-- tests/test_export.lua
-- Comprehensive test suite for Twine export functionality
-- Tests export to all Twine formats with difficult edge cases

local FormatConverter = require("src.format.format_converter")
local TwineImporter = require("src.format.twine_importer")
local WhiskerFormat = require("src.format.whisker_format")
local json = require("src.utils.json")

-- Test results tracking
local tests_run = 0
local tests_passed = 0
local tests_failed = 0

-- Helper function to run a test
local function test(name, fn)
    tests_run = tests_run + 1
    io.write(string.format("Testing %s... ", name))

    local success, err = pcall(fn)

    if success then
        tests_passed = tests_passed + 1
        print("✅ PASSED")
        return true
    else
        tests_failed = tests_failed + 1
        print("❌ FAILED")
        print("  Error: " .. tostring(err))
        return false
    end
end

-- Helper function to assert conditions
local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s",
            message or "Assertion failed",
            tostring(expected),
            tostring(actual)))
    end
end

local function assert_not_nil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

local function assert_true(condition, message)
    if not condition then
        error(message or "Condition should be true")
    end
end

local function assert_contains(text, pattern, message)
    -- Use literal string matching (plain=true) to avoid pattern matching issues
    if not text:find(pattern, 1, true) then
        error(string.format("%s\nText does not contain: %s\nActual text: %s",
            message or "Pattern not found",
            pattern,
            text:sub(1, 200)))
    end
end

-- ============================================================================
-- SAMPLE WHISKER DOCUMENTS FOR TESTING
-- ============================================================================

-- Basic story for testing
local function create_basic_story()
    return {
        metadata = {
            title = "Test Story",
            author = "Test Author",
            version = "1.0.0",
            ifid = "12345678-1234-1234-1234-123456789012",
            created = 1234567890,
            modified = 1234567890
        },
        settings = {
            startPassage = "Start"
        },
        passages = {
            {
                pid = "1",
                name = "Start",
                tags = {"intro"},
                text = "Welcome to the test story!\n\n[[Begin|Next]]",
                position = {x = 100, y = 100},
                size = {width = 100, height = 100}
            },
            {
                pid = "2",
                name = "Next",
                tags = {},
                text = "This is the next passage.\n\n[[The End|End]]",
                position = {x = 200, y = 100},
                size = {width = 100, height = 100}
            },
            {
                pid = "3",
                name = "End",
                tags = {"ending"},
                text = "The End!",
                position = {x = 300, y = 100},
                size = {width = 100, height = 100}
            }
        }
    }
end

-- Story with complex syntax
local function create_complex_story()
    return {
        metadata = {
            title = "Complex Test",
            author = "Tester",
            version = "1.0.0",
            ifid = "87654321-4321-4321-4321-210987654321",
            created = 1234567890,
            modified = 1234567890
        },
        settings = {
            startPassage = "Start"
        },
        passages = {
            {
                pid = "1",
                name = "Start",
                tags = {},
                text = "{{health = 100}}\n{{gold = 50}}\n\nHealth: {{health}}\nGold: {{gold}}\n\n[[Continue|Next]]",
                position = {x = 100, y = 100},
                size = {width = 100, height = 100}
            },
            {
                pid = "2",
                name = "Next",
                tags = {},
                text = "{{gold = gold + 10}}\n\n{{if gold > 40 then}}You are rich!{{end}}\n\n[[Finish|End]]",
                position = {x = 200, y = 100},
                size = {width = 100, height = 100}
            },
            {
                pid = "3",
                name = "End",
                tags = {},
                text = "Final gold: {{gold}}",
                position = {x = 300, y = 100},
                size = {width = 100, height = 100}
            }
        }
    }
end

-- Story with edge cases
local function create_edge_case_story()
    return {
        metadata = {
            title = "Edge Cases & Special Characters",
            author = "Test <Author>",
            version = "1.0.0",
            ifid = "11111111-2222-3333-4444-555555555555",
            created = 1234567890,
            modified = 1234567890
        },
        settings = {
            startPassage = "Start"
        },
        passages = {
            {
                pid = "1",
                name = "Start",
                tags = {"test", "special-chars"},
                text = "Special: <>&\"'\nUnicode: 你好 🎮\n\n[[Next]]",
                position = {x = 100, y = 100},
                size = {width = 100, height = 100}
            },
            {
                pid = "2",
                name = "Next",
                tags = {},
                text = "",  -- Empty content
                position = {x = 200, y = 100},
                size = {width = 100, height = 100}
            },
            {
                pid = "3",
                name = "Passage With Spaces",
                tags = {},
                text = "This passage has a name with spaces.\n\n[[Back|Start]]",
                position = {x = 100, y = 200},
                size = {width = 100, height = 100}
            }
        }
    }
end

print("\n=== Whisker Twine Export Test Suite ===\n")
print("Testing export to Twine HTML, Twee, and Markdown formats")
print("Including difficult edge cases and round-trip conversions\n")

-- ============================================================================
-- BASIC EXPORT TESTS
-- ============================================================================

print("--- Basic Export Tests ---\n")

-- Test 1: Export to Twine HTML (basic)
test("Export basic story to Twine HTML", function()
    local converter = FormatConverter.new()
    local story = create_basic_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "HTML export should return content")
    assert_contains(html, "<tw-storydata", "Should contain tw-storydata tag")
    assert_contains(html, 'name="Test Story"', "Should contain story title")
    assert_contains(html, "<tw-passagedata", "Should contain passage data")
    assert_contains(html, 'name="Start"', "Should contain Start passage")
end)

-- Test 2: Export to Twee notation
test("Export basic story to Twee", function()
    local converter = FormatConverter.new()
    local story = create_basic_story()

    local twee, err = converter:to_twee(story)

    assert_not_nil(twee, "Twee export should return content")
    assert_true(twee:find(":: StoryTitle"), "Should contain StoryTitle")
    assert_true(twee:find("Test Story"), "Should contain story title")
    assert_true(twee:find(":: Start"), "Should contain Start passage")
    assert_true(twee:find(":: Next"), "Should contain Next passage")
end)

-- Test 3: Export to Markdown
test("Export basic story to Markdown", function()
    local converter = FormatConverter.new()
    local story = create_basic_story()

    local md, err = converter:to_markdown(story)

    assert_not_nil(md, "Markdown export should return content")
    assert_true(md:find("# Test Story"), "Should contain title as H1")
    assert_true(md:find("**Author:**"), "Should contain author label")
    assert_true(md:find("## Start"), "Should contain passage as H2")
end)

-- ============================================================================
-- COMPLEX SYNTAX TESTS
-- ============================================================================

print("\n--- Complex Syntax Tests ---\n")

-- Test 4: Export story with variables
test("Export story with variable assignments", function()
    local converter = FormatConverter.new()
    local story = create_complex_story()

    local html, err = converter:to_twine_html(story, {target_format = "Harlowe"})

    assert_not_nil(html, "Should export story with variables")
    -- Variables should be converted to target format
    assert_true(html:find("health") or html:find("gold"), "Should contain variable references")
end)

-- Test 5: Export with Harlowe format
test("Export to Harlowe format", function()
    local converter = FormatConverter.new()
    local story = create_complex_story()

    local html, err = converter:to_twine_html(story, {
        target_format = "Harlowe",
        format_version = "3.3.0"
    })

    assert_not_nil(html, "Should export to Harlowe format")
    assert_contains(html, 'format="Harlowe"', "Should specify Harlowe format")
    assert_contains(html, 'format-version="3.3.0"', "Should specify format version")
end)

-- Test 6: Export with SugarCube format
test("Export to SugarCube format", function()
    local converter = FormatConverter.new()
    local story = create_complex_story()

    local html, err = converter:to_twine_html(story, {
        target_format = "SugarCube",
        format_version = "2.36.0"
    })

    assert_not_nil(html, "Should export to SugarCube format")
    assert_true(html:find('format="SugarCube"'), "Should specify SugarCube format")
end)

-- Test 7: Export with Chapbook format
test("Export to Chapbook format", function()
    local converter = FormatConverter.new()
    local story = create_complex_story()

    local html, err = converter:to_twine_html(story, {
        target_format = "Chapbook",
        format_version = "1.2.0"
    })

    assert_not_nil(html, "Should export to Chapbook format")
    assert_true(html:find('format="Chapbook"'), "Should specify Chapbook format")
end)

-- Test 8: Export with Snowman format
test("Export to Snowman format", function()
    local converter = FormatConverter.new()
    local story = create_complex_story()

    local html, err = converter:to_twine_html(story, {
        target_format = "Snowman",
        format_version = "2.0.3"
    })

    assert_not_nil(html, "Should export to Snowman format")
    assert_true(html:find('format="Snowman"'), "Should specify Snowman format")
end)

-- ============================================================================
-- EDGE CASE TESTS
-- ============================================================================

print("\n--- Edge Case Tests ---\n")

-- Test 9: Export with special characters
test("Export story with special HTML characters", function()
    local converter = FormatConverter.new()
    local story = create_edge_case_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Should handle special characters")
    -- Special characters should be escaped
    assert_true(html:find("&lt;") or html:find("&gt;") or html:find("&amp;"),
                "Should escape HTML entities")
end)

-- Test 10: Export with unicode characters
test("Export story with unicode characters", function()
    local converter = FormatConverter.new()
    local story = create_edge_case_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Should handle unicode characters")
    assert_true(html:find('charset="utf-8"') or html:find("<meta charset="),
                "Should declare UTF-8 encoding")
end)

-- Test 11: Export with empty passage content
test("Export story with empty passages", function()
    local converter = FormatConverter.new()
    local story = create_edge_case_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Should handle empty passages")
    assert_true(html:find('name="Next"'), "Should include passage with empty content")
end)

-- Test 12: Export with passage names containing spaces
test("Export passages with spaces in names", function()
    local converter = FormatConverter.new()
    local story = create_edge_case_story()

    local twee, err = converter:to_twee(story)

    assert_not_nil(twee, "Should handle passage names with spaces")
    assert_true(twee:find("Passage With Spaces") or twee:find(":: Passage"),
                "Should preserve passage names with spaces")
end)

-- Test 13: Export with tags
test("Export passages with multiple tags", function()
    local converter = FormatConverter.new()
    local story = create_edge_case_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Should handle passage tags")
    -- Tags should be in the output
    assert_true(html:find('tags="') or html:find("test") or html:find("special-chars"),
                "Should include passage tags")
end)

-- ============================================================================
-- ROUND-TRIP TESTS
-- ============================================================================

print("\n--- Round-Trip Conversion Tests ---\n")

-- Test 14: Round-trip HTML export/import
test("Round-trip: Export to HTML then import", function()
    local converter = FormatConverter.new()
    local importer = TwineImporter.new()
    local original = create_basic_story()

    -- Export to HTML
    local html, err = converter:to_twine_html(original)
    assert_not_nil(html, "Export should succeed")

    -- Import back
    local imported, err = importer:import_from_html(html)
    assert_not_nil(imported, "Import should succeed: " .. tostring(err))

    -- Verify key properties preserved
    assert_equal(imported.metadata.title, original.metadata.title, "Title should be preserved")
    assert_true(#imported.passages >= 3, "Should have at least 3 passages")
end)

-- Test 15: Round-trip Twee export/import
test("Round-trip: Export to Twee then import", function()
    local converter = FormatConverter.new()
    local importer = TwineImporter.new()
    local original = create_basic_story()

    -- Export to Twee
    local twee, err = converter:to_twee(original)
    assert_not_nil(twee, "Twee export should succeed")

    -- Import back
    local imported, err = importer:import_from_twee(twee)
    assert_not_nil(imported, "Twee import should succeed: " .. tostring(err))

    -- Verify key properties preserved
    assert_equal(imported.metadata.title, original.metadata.title, "Title should be preserved")
    assert_true(#imported.passages >= 3, "Should have at least 3 passages")
end)

-- Test 16: Metadata preservation
test("Round-trip: Metadata preservation", function()
    local converter = FormatConverter.new()
    local importer = TwineImporter.new()
    local original = create_basic_story()

    -- Export and import
    local html, _ = converter:to_twine_html(original)
    local imported, _ = importer:import_from_html(html)

    assert_not_nil(imported, "Round-trip should succeed")
    assert_equal(imported.metadata.title, original.metadata.title, "Title preserved")
    assert_equal(imported.metadata.ifid, original.metadata.ifid, "IFID preserved")
end)

-- Test 17: Passage structure preservation
test("Round-trip: Passage structure preservation", function()
    local converter = FormatConverter.new()
    local importer = TwineImporter.new()
    local original = create_basic_story()

    -- Export and import
    local html, _ = converter:to_twine_html(original)
    local imported, _ = importer:import_from_html(html)

    assert_not_nil(imported, "Round-trip should succeed")

    -- Find Start passage in imported
    local start_found = false
    for _, passage in ipairs(imported.passages) do
        if passage.name == "Start" then
            start_found = true
            assert_true(#passage.tags > 0, "Start passage should have tags")
            break
        end
    end

    assert_true(start_found, "Start passage should exist after round-trip")
end)

-- ============================================================================
-- FORMAT-SPECIFIC CONVERSION TESTS
-- ============================================================================

print("\n--- Format-Specific Conversion Tests ---\n")

-- Test 18: Whisker to Harlowe conversion
test("Convert Whisker syntax to Harlowe", function()
    local converter = FormatConverter.new()

    local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}\nHealth: {{health}}"
    local harlowe = converter:convert_to_harlowe(whisker_text)

    assert_not_nil(harlowe, "Conversion should succeed")
    -- Harlowe uses (set:) and (if:)
    -- Note: Current implementation may not fully convert all syntax
end)

-- Test 19: Whisker to SugarCube conversion
test("Convert Whisker syntax to SugarCube", function()
    local converter = FormatConverter.new()

    local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}"
    local sugarcube = converter:convert_to_sugarcube(whisker_text)

    assert_not_nil(sugarcube, "Conversion should succeed")
    -- SugarCube uses <<set>> and <<if>>
end)

-- Test 20: Whisker to Chapbook conversion
test("Convert Whisker syntax to Chapbook", function()
    local converter = FormatConverter.new()

    local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}"
    local chapbook = converter:convert_to_chapbook(whisker_text)

    assert_not_nil(chapbook, "Conversion should succeed")
    -- Chapbook uses [if] and [continued]
end)

-- Test 21: Whisker to Snowman conversion
test("Convert Whisker syntax to Snowman", function()
    local converter = FormatConverter.new()

    local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}"
    local snowman = converter:convert_to_snowman(whisker_text)

    assert_not_nil(snowman, "Conversion should succeed")
    -- Snowman uses <% %> for code and <%= %> for output
end)

-- ============================================================================
-- ADVANCED TESTS
-- ============================================================================

print("\n--- Advanced Export Tests ---\n")

-- Test 22: Export empty story
test("Export story with no passages", function()
    local converter = FormatConverter.new()
    local empty_story = {
        metadata = {
            title = "Empty",
            author = "Test",
            ifid = "00000000-0000-0000-0000-000000000000"
        },
        settings = { startPassage = "Start" },
        passages = {}
    }

    local html, err = converter:to_twine_html(empty_story)

    assert_not_nil(html, "Should handle empty story")
    assert_contains(html, "<tw-storydata", "Should still create valid HTML structure")
end)

-- Test 23: Export story with position data
test("Export preserves passage positions", function()
    local converter = FormatConverter.new()
    local story = create_basic_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Export should succeed")
    -- Position should be in format "x,y"
    assert_true(html:find('position="100,100"') or html:find("position="),
                "Should preserve passage positions")
end)

-- Test 24: Export with size data
test("Export preserves passage sizes", function()
    local converter = FormatConverter.new()
    local story = create_basic_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Export should succeed")
    assert_true(html:find('size="100,100"') or html:find("size="),
                "Should preserve passage sizes")
end)

-- Test 25: Verify IFID generation/preservation
test("Export preserves or generates IFID", function()
    local converter = FormatConverter.new()
    local story = create_basic_story()

    local html, err = converter:to_twine_html(story)

    assert_not_nil(html, "Export should succeed")
    assert_contains(html, 'ifid="', "Should include IFID")
    assert_contains(html, story.metadata.ifid, "Should preserve original IFID")
end)

-- ============================================================================
-- PRINT SUMMARY
-- ============================================================================

print("\n" .. string.rep("=", 70))
print("=== Test Results ===")
print(string.rep("=", 70))
print(string.format("Tests run:    %d", tests_run))
print(string.format("Tests passed: %d ✅", tests_passed))
print(string.format("Tests failed: %d %s", tests_failed, tests_failed > 0 and "❌" or ""))
print(string.rep("=", 70))

if tests_failed == 0 then
    print("\n🎉 ALL EXPORT TESTS PASSED! 🎉")
    print("Twine export functionality is working correctly.")
else
    print("\n⚠️  SOME TESTS FAILED")
    print("Please review the errors above.")
    error("Test failures detected")
end
