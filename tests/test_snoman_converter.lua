-- Test Suite for Snowman Converter
-- Tests conversion between Snowman and whisker formats

local FormatConverter = require("format.format_converter")
local SnowmanConverter = require("format.snowman_converter")

-- Test framework
local Tests = {}
local passed = 0
local failed = 0

function Tests:assert_equal(actual, expected, message)
    if actual == expected then
        passed = passed + 1
        print("✓ " .. (message or "Test passed"))
        return true
    else
        failed = failed + 1
        print("✗ " .. (message or "Test failed"))
        print("  Expected: " .. tostring(expected))
        print("  Got: " .. tostring(actual))
        return false
    end
end

function Tests:assert_not_nil(value, message)
    if value ~= nil then
        passed = passed + 1
        print("✓ " .. (message or "Test passed"))
        return true
    else
        failed = failed + 1
        print("✗ " .. (message or "Test failed") .. " - value is nil")
        return false
    end
end

function Tests:summary()
    print("\n" .. string.rep("=", 50))
    print(string.format("Tests: %d passed, %d failed", passed, failed))
    print(string.rep("=", 50))
end

-- ============================================================================
-- TEST DATA
-- ============================================================================

local sample_snowman = {
    name = "Test Story",
    creator = "Test Author",
    format = "Snowman",
    ["format-version"] = "2.0.3",
    ifid = "12345678-1234-1234-1234-123456789012",
    startnode = "1",
    passages = {
        {
            pid = "0",
            name = "StoryInit",
            tags = {"init"},
            text = "<% s.health = 100; s.gold = 50; s.inventory = []; %>",
            position = "0,0"
        },
        {
            pid = "1",
            name = "Start",
            tags = {},
            text = [=[Welcome to the adventure!

<%= s.health %> HP remaining.

[[Begin|Next]]
[[Check inventory|Inventory]]]=],
            position = "100,100"
        },
        {
            pid = "2",
            name = "Next",
            tags = {},
            text = [=[<% s.gold += 10; %>

You found 10 gold! You now have <%= s.gold %> gold.

<% if (s.gold >= 20) { %>
  [[Rich path|Rich]]
<% } %>
[[Continue|End]]]=],
            position = "200,100"
        },
        {
            pid = "3",
            name = "Inventory",
            tags = {},
            text = [=[Inventory: <%= s.inventory.length > 0 ? s.inventory.join(', ') : 'Empty' %>

[[Back|Start]]]=],
            position = "100,200"
        },
        {
            pid = "4",
            name = "End",
            tags = {},
            text = "The End!\n\nFinal gold: <%= s.gold %>",
            position = "300,100"
        }
    }
}

local sample_whisker = {
    metadata = {
        title = "Test Story",
        author = "Test Author",
        version = "1.0.0",
        format = "whisker"
    },
    starting_passage = "Start",
    variables = {
        health = 100,
        gold = 50,
        inventory = {}
    },
    passages = {
        {
            id = "start",
            title = "Start",
            tags = {},
            content = "Welcome to the adventure!\n\n{{health}} HP remaining.",
            choices = {
                {text = "Begin", target = "Next"},
                {text = "Check inventory", target = "Inventory"}
            }
        },
        {
            id = "next",
            title = "Next",
            tags = {},
            content = "{% set('gold', get('gold') + 10) %}\n\nYou found 10 gold! You now have {{gold}} gold.",
            choices = {
                {
                    text = "Rich path",
                    target = "Rich",
                    condition = "get('gold') >= 20"
                },
                {text = "Continue", target = "End"}
            }
        }
    }
}

-- ============================================================================
-- CONVERTER TESTS
-- ============================================================================

print("\n" .. string.rep("=", 50))
print("SNOWMAN CONVERTER TEST SUITE")
print(string.rep("=", 50) .. "\n")

-- Test 1: Initialize converter
print("Test 1: Initialize Snowman Converter")
local converter = SnowmanConverter.new()
Tests:assert_not_nil(converter, "Converter created")

-- Test 2: Snowman to whisker conversion
print("\nTest 2: Snowman to whisker Conversion")
local whisker_result = converter:snowman_to_whisker(sample_snowman)
Tests:assert_not_nil(whisker_result, "Conversion result exists")
Tests:assert_equal(whisker_result.metadata.title, "Test Story", "Title preserved")
Tests:assert_equal(whisker_result.starting_passage, "1", "Starting passage set")
Tests:assert_not_nil(whisker_result.passages, "Passages converted")

-- Test 3: Variable extraction
print("\nTest 3: Variable Extraction from StoryInit")
Tests:assert_equal(whisker_result.variables.health, 100, "Health variable extracted")
Tests:assert_equal(whisker_result.variables.gold, 50, "Gold variable extracted")

-- Test 4: Passage conversion
print("\nTest 4: Passage Content Conversion")
local first_passage = whisker_result.passages[1]
Tests:assert_not_nil(first_passage, "First passage exists")
Tests:assert_equal(first_passage.title, "Start", "Passage title correct")

-- Test 5: Link extraction
print("\nTest 5: Link Extraction")
Tests:assert_not_nil(first_passage.choices, "Choices extracted")
if first_passage.choices then
    Tests:assert_equal(#first_passage.choices, 2, "Correct number of choices")
end

-- Test 6: whisker to Snowman conversion
print("\nTest 6: whisker to Snowman Conversion")
local snowman_result = converter:whisker_to_snowman(sample_whisker)
Tests:assert_not_nil(snowman_result, "Conversion result exists")
Tests:assert_equal(snowman_result.name, "Test Story", "Title preserved")
Tests:assert_equal(snowman_result.format, "Snowman", "Format set correctly")

-- Test 7: StoryInit generation
print("\nTest 7: StoryInit Generation")
local has_init = false
for _, passage in ipairs(snowman_result.passages) do
    if passage.name == "StoryInit" then
        has_init = true
        Tests:assert_not_nil(passage.text:match("s%.health"), "Health variable in init")
        Tests:assert_not_nil(passage.text:match("s%.gold"), "Gold variable in init")
        break
    end
end
Tests:assert_equal(has_init, true, "StoryInit passage created")

-- Test 8: JavaScript conversion
print("\nTest 8: JavaScript Conversion")
local js_code = "s.health = 100; s.gold += 10;"
local lua_code = converter:javascript_to_lua(js_code)
Tests:assert_not_nil(lua_code:match("get%('health'%)"), "State access converted")

-- Test 9: Lua to JavaScript conversion
print("\nTest 9: Lua to JavaScript Conversion")
local test_lua = "set('health', 100)"
local test_js = converter:lua_to_javascript(test_lua)
Tests:assert_not_nil(test_js:match("s%.health"), "Lua set converted to JS")

-- Test 10: Expression conversion
print("\nTest 10: Expression Conversion")
local js_expr = "s.gold + 10"
local lua_expr = converter:javascript_expression_to_lua(js_expr)
Tests:assert_not_nil(lua_expr, "Expression converted")

-- ============================================================================
-- FORMAT CONVERTER INTEGRATION TESTS
-- ============================================================================

print("\n" .. string.rep("=", 50))
print("FORMAT CONVERTER INTEGRATION TESTS")
print(string.rep("=", 50) .. "\n")

-- Test 11: Format detection
print("Test 11: Format Detection")
local format_converter = FormatConverter.new()
local detected = format_converter:detect_format(sample_snowman)
Tests:assert_equal(detected, "snowman", "Snowman format detected")

-- Test 12: Round-trip conversion
print("\nTest 12: Round-trip Conversion (Snowman -> whisker -> Snowman)")
local converted_to_lua = format_converter:import_snowman(sample_snowman)
local converted_back = format_converter:export_snowman(converted_to_lua)
Tests:assert_not_nil(converted_back, "Round-trip completed")
Tests:assert_equal(converted_back.name, sample_snowman.name, "Title preserved in round-trip")

-- Test 13: Convenience methods
print("\nTest 13: Convenience Methods")
local result = format_converter.convert_harlowe_to_snowman;
Tests:assert_not_nil(result, "Harlowe to Snowman method exists")

-- Test 14: Format info
print("\nTest 14: Format Information")
local info = format_converter:get_format_info("snowman")
Tests:assert_not_nil(info, "Snowman format info available")
Tests:assert_equal(info.name, "Snowman", "Format name correct")
Tests:assert_equal(info.supports_import, true, "Import supported")
Tests:assert_equal(info.supports_export, true, "Export supported")

-- Test 15: Supported conversions
print("\nTest 15: Supported Conversions List")
local conversions = format_converter:list_supported_conversions()
Tests:assert_not_nil(conversions, "Conversions list available")

local has_snowman_conversion = false
for _, conv in ipairs(conversions) do
    if conv.from == "Snowman" or conv.to == "Snowman" then
        has_snowman_conversion = true
        break
    end
end
Tests:assert_equal(has_snowman_conversion, true, "Snowman conversions listed")

-- ============================================================================
-- EDGE CASES
-- ============================================================================

print("\n" .. string.rep("=", 50))
print("EDGE CASE TESTS")
print(string.rep("=", 50) .. "\n")

-- Test 16: Empty passages
print("Test 16: Empty Passages")
local empty_snowman = {
    name = "Empty",
    format = "Snowman",
    startnode = "1",
    passages = {}
}
local empty_result = converter:snowman_to_whisker(empty_snowman)
Tests:assert_not_nil(empty_result, "Handles empty passages")
Tests:assert_equal(#empty_result.passages, 0, "No passages created")

-- Test 17: Special passages filtered
print("\nTest 17: Special Passages Filtering")
local with_special = {
    name = "Test",
    format = "Snowman",
    startnode = "1",
    passages = {
        {pid = "0", name = "StoryInit", text = "init"},
        {pid = "1", name = "Start", text = "start"},
        {pid = "2", name = "PassageHeader", text = "header"}
    }
}
local filtered_result = converter:snowman_to_whisker(with_special)
local non_special_count = 0
for _, p in ipairs(filtered_result.passages) do
    if p.title ~= "StoryInit" and p.title ~= "PassageHeader" then
        non_special_count = non_special_count + 1
    end
end
Tests:assert_equal(non_special_count, 1, "Special passages filtered")

-- Test 18: Complex conditionals
print("\nTest 18: Complex Conditionals")
local complex_passage = {
    pid = "1",
    name = "Test",
    text = [=[<% if (s.health > 50 && s.gold >= 100) { %>
You're doing well!
<% } %>]=]
}
local complex_result = converter:convert_snowman_passage_to_whisker(complex_passage)
Tests:assert_not_nil(complex_result.content, "Complex conditional converted")

-- Test 19: IFID generation
print("\nTest 19: IFID Generation")
local no_ifid = {
    metadata = {title = "Test"},
    passages = {}
}
local with_ifid = converter:whisker_to_snowman(no_ifid)
Tests:assert_not_nil(with_ifid.ifid, "IFID generated")
Tests:assert_equal(#with_ifid.ifid, 36, "IFID is UUID format")

-- Test 20: Multiple links in one passage
print("\nTest 20: Multiple Links Extraction")
local multi_link = {
    pid = "1",
    name = "Test",
    text = [=[Choose:
[[Option A|A]]
[[Option B|B]]
[[Option C|C]]]=]
}
local multi_result = converter:convert_snowman_passage_to_whisker(multi_link)
Tests:assert_equal(#multi_result.choices, 3, "All links extracted")

-- Print summary
Tests:summary()

-- Return exit code
if failed > 0 then
    error("Test failures detected")
end
