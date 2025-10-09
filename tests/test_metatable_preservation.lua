-- tests/test_metatable_preservation.lua
-- Test metatable preservation across modules

local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")
local Engine = require("src.core.engine")
local SaveSystem = require("src.infrastructure.save_system")
local json = require("src.utils.json")

-- Helper function to check if object has methods
local function has_methods(obj, expected_methods)
    for _, method_name in ipairs(expected_methods) do
        if type(obj[method_name]) ~= "function" then
            return false, "Missing method: " .. method_name
        end
    end
    return true
end

-- Test 1: Story metatable preservation
print("Test 1: Story metatable preservation")
local story1 = Story:new({
    title = "Test Story",
    author = "Test Author"
})

-- Add a passage with choices
local passage1 = Passage:new({
    id = "start",
    name = "Start",
    content = "Welcome to the test story!"
})

local choice1 = Choice:new({
    text = "Continue",
    target = "next"
})

passage1:add_choice(choice1)
story1:add_passage(passage1)
story1:set_start_passage("start")

-- Verify initial methods work
assert(story1:get_metadata("name") == "Test Story", "Story method failed before serialization")
assert(passage1:get_content() == "Welcome to the test story!", "Passage method failed before serialization")
assert(choice1:get_text() == "Continue", "Choice method failed before serialization")
print("  ✓ All methods work before serialization")

-- Test 2: Serialize and restore via Story.restore_metatable
print("\nTest 2: Serialize and restore via Story.restore_metatable")
local serialized = story1:serialize()

-- Verify serialized data lost metatable
assert(getmetatable(serialized) == nil, "Serialized data should not have metatable")
print("  ✓ Serialization removes metatable as expected")

-- Restore metatable
local restored1 = Story.restore_metatable(serialized)

-- Verify methods work after restoration
assert(type(restored1.get_metadata) == "function", "Story method missing after restore_metatable")
assert(restored1:get_metadata("name") == "Test Story", "Story method failed after restore_metatable")

-- Check nested passage has metatable
local restored_passage = restored1:get_passage("start")
assert(restored_passage ~= nil, "Passage not found after restore")
assert(type(restored_passage.get_content) == "function", "Passage method missing after restore_metatable")
assert(restored_passage:get_content() == "Welcome to the test story!", "Passage method failed after restore_metatable")

-- Check nested choice has metatable
local restored_choices = restored_passage:get_choices()
assert(#restored_choices > 0, "Choices not found after restore")
assert(type(restored_choices[1].get_text) == "function", "Choice method missing after restore_metatable")
assert(restored_choices[1]:get_text() == "Continue", "Choice method failed after restore_metatable")
print("  ✓ All methods work after restore_metatable (including nested objects)")

-- Test 3: Serialize and restore via Story.from_table
print("\nTest 3: Serialize and restore via Story.from_table")
local restored2 = Story.from_table(serialized)

-- Verify methods work
assert(type(restored2.get_metadata) == "function", "Story method missing after from_table")
assert(restored2:get_metadata("name") == "Test Story", "Story method failed after from_table")

local restored_passage2 = restored2:get_passage("start")
assert(restored_passage2 ~= nil, "Passage not found after from_table")
assert(type(restored_passage2.get_content) == "function", "Passage method missing after from_table")

local restored_choices2 = restored_passage2:get_choices()
assert(#restored_choices2 > 0, "Choices not found after from_table")
assert(type(restored_choices2[1].get_text) == "function", "Choice method missing after from_table")
print("  ✓ All methods work after from_table (including nested objects)")

-- Test 4: JSON serialization/deserialization cycle
print("\nTest 4: JSON serialization/deserialization cycle")
local json_string = json.encode(serialized)
local from_json = json.decode(json_string)

-- Verify plain table from JSON has no metatable
assert(getmetatable(from_json) == nil, "JSON decoded data should not have metatable")

-- Restore via from_table
local restored3 = Story.from_table(from_json)

-- Verify methods work after JSON round-trip
assert(type(restored3.get_metadata) == "function", "Story method missing after JSON round-trip")
assert(restored3:get_metadata("name") == "Test Story", "Story method failed after JSON round-trip")

local restored_passage3 = restored3:get_passage("start")
assert(type(restored_passage3.get_content) == "function", "Passage method missing after JSON round-trip")
print("  ✓ All methods work after JSON round-trip")

-- Test 5: Engine integration
print("\nTest 5: Engine integration with deserialized story")
local engine = Engine:new()

-- Load a deserialized story (simulating loading from save)
engine:load_story(from_json)  -- Load plain table without metatable

-- Engine should auto-restore metatable
assert(engine.current_story ~= nil, "Story not loaded in engine")
assert(type(engine.current_story.get_start_passage) == "function", "Story methods not available in engine")

-- Try to start the story (this will fail because we only have one passage, but it should work up to that point)
local success, err = pcall(function()
    return engine:start_story()
end)

-- We expect this to fail with "Passage not found: next" since we don't have a full story
-- But if it fails with a method call error, that means metatable wasn't restored
if not success then
    -- Check if error is about missing passage (expected) vs method call (bad)
    if err:match("attempt to call") or err:match("attempt to index") then
        error("Engine failed to restore story methods: " .. tostring(err))
    else
        print("  ✓ Engine correctly handles deserialized story (expected passage error: " .. tostring(err) .. ")")
    end
else
    print("  ✓ Engine correctly handles deserialized story")
end

-- Test 6: Individual object restoration
print("\nTest 6: Individual Passage and Choice restoration")

-- Test Passage restoration
local plain_passage = {
    id = "test",
    name = "Test Passage",
    content = "Test content",
    choices = {}
}
local restored_passage_only = Passage.restore_metatable(plain_passage)
assert(type(restored_passage_only.get_content) == "function", "Passage.restore_metatable failed")
assert(restored_passage_only:get_content() == "Test content", "Restored passage method call failed")
print("  ✓ Passage.restore_metatable works")

local restored_passage_from_table = Passage.from_table(plain_passage)
assert(type(restored_passage_from_table.get_content) == "function", "Passage.from_table failed")
assert(restored_passage_from_table:get_content() == "Test content", "Passage.from_table method call failed")
print("  ✓ Passage.from_table works")

-- Test Choice restoration
local plain_choice = {
    text = "Test choice",
    target_passage = "target",
    condition = nil,
    action = nil
}
local restored_choice_only = Choice.restore_metatable(plain_choice)
assert(type(restored_choice_only.get_text) == "function", "Choice.restore_metatable failed")
assert(restored_choice_only:get_text() == "Test choice", "Restored choice method call failed")
print("  ✓ Choice.restore_metatable works")

local restored_choice_from_table = Choice.from_table(plain_choice)
assert(type(restored_choice_from_table.get_text) == "function", "Choice.from_table failed")
assert(restored_choice_from_table:get_text() == "Test choice", "Choice.from_table method call failed")
print("  ✓ Choice.from_table works")

-- Test 7: Deep nesting verification
print("\nTest 7: Deep nesting verification")
local complex_story = Story:new({
    title = "Complex Story"
})

-- Create multiple passages with multiple choices
for i = 1, 3 do
    local passage = Passage:new({
        id = "passage" .. i,
        name = "Passage " .. i,
        content = "Content " .. i
    })

    for j = 1, 2 do
        local choice = Choice:new({
            text = "Choice " .. j,
            target = "passage" .. ((i % 3) + 1)
        })
        passage:add_choice(choice)
    end

    complex_story:add_passage(passage)
end

complex_story:set_start_passage("passage1")

-- Serialize and restore
local complex_serialized = complex_story:serialize()
local complex_restored = Story.from_table(complex_serialized)

-- Verify all nested objects have methods
for i = 1, 3 do
    local p = complex_restored:get_passage("passage" .. i)
    assert(p ~= nil, "Passage " .. i .. " not found")
    assert(type(p.get_content) == "function", "Passage " .. i .. " missing methods")

    local choices = p:get_choices()
    assert(#choices == 2, "Passage " .. i .. " should have 2 choices")

    for j = 1, 2 do
        assert(type(choices[j].get_text) == "function", "Choice " .. j .. " in passage " .. i .. " missing methods")
    end
end
print("  ✓ All nested objects preserve methods through serialization")

-- Test 8: Metatable idempotency
print("\nTest 8: Metatable restoration is idempotent")
local story_with_metatable = Story:new({title = "Test"})
local restored_again = Story.restore_metatable(story_with_metatable)

-- Should return the same object since it already has the right metatable
assert(restored_again == story_with_metatable, "restore_metatable should return same object if metatable is already correct")
print("  ✓ Restoring metatable on object that already has it returns same object")

print("\n" .. string.rep("=", 60))
print("ALL METATABLE PRESERVATION TESTS PASSED!")
print(string.rep("=", 60))
