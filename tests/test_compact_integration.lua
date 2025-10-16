-- Test Compact Format Integration
-- Tests that compact format files can be loaded and used by the story loader

package.path = package.path .. ";./src/?.lua"

local whisker_loader = require("src.format.whisker_loader")
local CompactConverter = require("src.format.compact_converter")
local json = require("src.utils.json")

-- Test counters
local tests_passed = 0
local tests_failed = 0

-- Test helpers
local function test(name, func)
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

local function assert_not_nil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

local function assert_true(value, message)
    if not value then
        error(message or "Expected true, got false")
    end
end

--------------------------------------------------------------------------------
-- INTEGRATION TESTS
--------------------------------------------------------------------------------

test("Load compact format file", function()
    local story, err = whisker_loader.load_from_file("examples/stories/simple_story_compact.whisker")

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))
    assert_equal(story.metadata.name, "The Cave", "Title should match")
    assert_equal(story.metadata.author, "whisker Tutorial", "Author should match")
end)

test("Compact format has correct passages", function()
    local story, err = whisker_loader.load_from_file("examples/stories/simple_story_compact.whisker")

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))

    -- Count passages
    local passage_count = 0
    for _ in pairs(story.passages) do
        passage_count = passage_count + 1
    end

    assert_equal(passage_count, 5, "Should have 5 passages")
end)

test("Compact format passages have choices", function()
    local story, err = whisker_loader.load_from_file("examples/stories/simple_story_compact.whisker")

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))

    local start = story.passages["start"]
    assert_not_nil(start, "Start passage should exist")
    assert_equal(#start.choices, 2, "Start passage should have 2 choices")
    assert_equal(start.choices[1].text, "Enter the cave", "First choice text should match")
    assert_equal(start.choices[1].target_passage, "inside_cave", "First choice target should match")
end)

test("Compact format start passage is set", function()
    local story, err = whisker_loader.load_from_file("examples/stories/simple_story_compact.whisker")

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))
    assert_equal(story.start_passage, "start", "Start passage should be 'start'")
end)

test("Compact format passage content is preserved", function()
    local story, err = whisker_loader.load_from_file("examples/stories/simple_story_compact.whisker")

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))

    local start = story.passages["start"]
    assert_not_nil(start, "Start passage should exist")
    assert_true(start.content:find("dark cave"), "Passage content should contain 'dark cave'")
end)

test("Load compact format from string", function()
    local compact_json = [[
{
  "format": "whisker",
  "formatVersion": "2.0",
  "metadata": {
    "title": "Test Story",
    "ifid": "TEST-001"
  },
  "passages": [
    {
      "id": "start",
      "name": "Start",
      "pid": "p1",
      "text": "Beginning",
      "choices": [
        {
          "text": "Next",
          "target": "next"
        }
      ]
    },
    {
      "id": "next",
      "name": "Next",
      "pid": "p2",
      "text": "The end."
    }
  ],
  "settings": {
    "startPassage": "start"
  }
}
]]

    local story, err = whisker_loader.load_from_string(compact_json)

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))
    assert_equal(story.metadata.name, "Test Story", "Title should match")

    local passage_count = 0
    for _ in pairs(story.passages) do
        passage_count = passage_count + 1
    end
    assert_equal(passage_count, 2, "Should have 2 passages")
end)

test("Compact format preserves non-default values", function()
    -- Create compact format with non-default values
    local compact_json = [[
{
  "format": "whisker",
  "formatVersion": "2.0",
  "metadata": {
    "title": "Custom Story",
    "ifid": "CUSTOM-001"
  },
  "passages": [
    {
      "id": "start",
      "name": "Start",
      "pid": "p1",
      "text": "Start",
      "position": {"x": 100, "y": 200},
      "size": {"width": 150, "height": 200},
      "tags": ["important", "start"]
    }
  ],
  "settings": {
    "startPassage": "start"
  }
}
]]

    local story, err = whisker_loader.load_from_string(compact_json)

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))

    local start = story.passages["start"]
    assert_not_nil(start, "Start passage should exist")
    assert_equal(start.position.x, 100, "X position should be preserved")
    assert_equal(start.position.y, 200, "Y position should be preserved")
    assert_equal(start.size.width, 150, "Width should be preserved")
    assert_equal(start.size.height, 200, "Height should be preserved")
    assert_equal(#start.tags, 2, "Tags should be preserved")
end)

test("Compact format with conditional choices", function()
    local compact_json = [[
{
  "format": "whisker",
  "formatVersion": "2.0",
  "metadata": {
    "title": "Conditional Story",
    "ifid": "COND-001"
  },
  "passages": [
    {
      "id": "start",
      "name": "Start",
      "pid": "p1",
      "text": "Start",
      "choices": [
        {
          "text": "Regular choice",
          "target": "next"
        },
        {
          "text": "Conditional choice",
          "target": "special",
          "condition": "has_key == true"
        }
      ]
    },
    {
      "id": "next",
      "name": "Next",
      "pid": "p2",
      "text": "Next passage"
    },
    {
      "id": "special",
      "name": "Special",
      "pid": "p3",
      "text": "Special passage"
    }
  ],
  "settings": {
    "startPassage": "start"
  }
}
]]

    local story, err = whisker_loader.load_from_string(compact_json)

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))

    local start = story.passages["start"]
    assert_equal(#start.choices, 2, "Should have 2 choices")
    assert_equal(start.choices[2].condition, "has_key == true", "Condition should be preserved")
end)

test("Compact format backwards compatible with verbose loader", function()
    -- Load the compact example and verify it works exactly like verbose format
    local story, err = whisker_loader.load_from_file("examples/stories/simple_story_compact.whisker")

    assert_not_nil(story, "Story should not be nil: " .. tostring(err))

    -- All passages should have content field after loading
    for id, passage in pairs(story.passages) do
        assert_not_nil(passage.content, "Passage " .. id .. " should have content field")
        assert_true(#passage.content > 0, "Passage " .. id .. " content should not be empty")
    end
end)

test("Mixed format detection works correctly", function()
    local converter = CompactConverter.new()

    -- Create verbose doc
    local verbose_doc = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {title = "Test"},
        passages = {}
    }

    -- Create compact doc
    local compact_doc = {
        format = "whisker",
        formatVersion = "2.0",
        metadata = {title = "Test"},
        passages = {}
    }

    assert_true(converter:is_verbose(verbose_doc), "Should detect verbose format")
    assert_true(converter:is_compact(compact_doc), "Should detect compact format")
end)

--------------------------------------------------------------------------------
-- PRINT RESULTS
--------------------------------------------------------------------------------

print("\n" .. string.rep("=", 70))
print("INTEGRATION TEST RESULTS")
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
