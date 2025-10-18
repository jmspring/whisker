-- tests/test_save_system.lua
-- Test save/load functionality

local SaveSystem = require("src.infrastructure.save_system")
local GameState = require("src.core.game_state")
local Story = require("src.core.story")
local Passage = require("src.core.passage")

print("=== Save System Test Suite ===\n")

-- Create test story
local story = Story.new({
    title = "Save Test Story",
    author = "Test Suite",
    ifid = "TEST-SAVE-001"
})

local p1 = Passage.new({id = "start", content = "Start passage"})
story:add_passage(p1)
story:set_start_passage("start")

-- Test 1: Initialize Save System
print("Test 1: Initialize Save System")
local save_system = SaveSystem.new({
    save_directory = "tests/saves"
})
print("✅ Save system initialized\n")

-- Test 2: Create and save game state
print("Test 2: Save Game State")
local game_state = GameState.new()
game_state:set_current_passage("start")
game_state:set_variable("player_name", "TestPlayer")
game_state:set_variable("score", 100)
game_state:set_variable("inventory", {"sword", "shield"})

local save_success = save_system:save_game(
    game_state,
    story,
    1,  -- Slot 1
    "Test Save"
)

assert(save_success, "Save failed")
print("✅ Game state saved successfully\n")

-- Test 3: List saved games
print("Test 3: List Saved Games")
local saves = save_system:list_saves()
print("Found " .. #saves .. " save(s)")
for _, save in ipairs(saves) do
    print(string.format("  Slot %d: %s (%s)",
        save.slot,
        save.save_name,
        save.story_title
    ))
end
assert(#saves > 0, "No saves found")
print("✅ Save listing works\n")

-- Test 4: Load saved game
print("Test 4: Load Saved Game")
local loaded_state, loaded_story = save_system:load_game(1)

assert(loaded_state, "Load failed")
assert(loaded_state:get_variable("player_name") == "TestPlayer", "Player name mismatch")
assert(loaded_state:get_variable("score") == 100, "Score mismatch")
assert(loaded_state:get_current_passage() == "start", "Passage mismatch")

print("Loaded state:")
print("  Player: " .. loaded_state:get_variable("player_name"))
print("  Score: " .. loaded_state:get_variable("score"))
print("  Passage: " .. loaded_state:get_current_passage())
print("✅ Game state loaded successfully\n")

-- Test 5: Quick save/load
print("Test 5: Quick Save/Load")
local game_state2 = GameState.new()
game_state2:set_variable("quick_test", "value")

local quick_save_success = save_system:quick_save(game_state2, story)
assert(quick_save_success, "Quick save failed")
print("✅ Quick save successful")

local quick_loaded = save_system:quick_load()
assert(quick_loaded, "Quick load failed")
assert(quick_loaded:get_variable("quick_test") == "value", "Quick load data mismatch")
print("✅ Quick load successful\n")

-- Test 6: Delete save
print("Test 6: Delete Save")
local delete_success = save_system:delete_save(1)
assert(delete_success, "Delete failed")
print("✅ Save deleted successfully\n")

-- Test 7: Autosave
print("Test 7: Autosave")
local game_state3 = GameState.new()
game_state3:set_variable("auto_test", "autosaved")

local autosave_success = save_system:autosave(game_state3, story)
assert(autosave_success, "Autosave failed")
print("✅ Autosave successful")

local autosave_loaded = save_system:load_autosave()
assert(autosave_loaded, "Autosave load failed")
print("✅ Autosave load successful\n")

-- Test 8: Check if save exists
print("Test 8: Check Save Existence")
local exists = save_system:has_save(1)
print("Slot 1 exists: " .. tostring(exists))
print("✅ Save existence check works\n")

-- Test 9: Get save info
print("Test 9: Get Save Info")
if save_system:has_autosave() then
    local info = save_system:get_save_info("autosave")
    if info then
        print("Autosave info:")
        print("  Story: " .. info.story_title)
        print("  Timestamp: " .. info.timestamp)
        print("✅ Save info retrieval works\n")
    end
end

-- Cleanup
print("Cleaning up test saves...")
save_system:delete_save(1)
save_system:delete_autosave()

print("=== All Save System Tests Passed! ===")
return true
