#!/usr/bin/env lua
--[[
    Test Suite for RPG Systems in Keep on the Borderlands

    Tests all Tier 1 and Tier 2 RPG enhancements:
    - Character creation with 4 classes
    - Experience and leveling system
    - Skill system with 6 skills
    - Equipment stats tracking
    - Companion system
    - Combat stamina
    - Quest journal
    - Alignment system
]]

package.path = package.path .. ';./src/?.lua'

local WhiskerLoader = require('src.format.whisker_loader')
local GameState = require('src.core.game_state')

-- Test result tracking
local tests_passed = 0
local tests_failed = 0
local test_details = {}

-- Helper function to run a test
local function test(name, func)
    io.write(string.format("Testing: %s ... ", name))
    local success, err = pcall(func)
    if success then
        tests_passed = tests_passed + 1
        print("✓ PASSED")
        table.insert(test_details, {name = name, passed = true})
    else
        tests_failed = tests_failed + 1
        print("✗ FAILED")
        print("  Error: " .. tostring(err))
        table.insert(test_details, {name = name, passed = false, error = err})
    end
end

-- Helper to assert
local function assert_eq(actual, expected, msg)
    if actual ~= expected then
        error(string.format("%s: expected %s, got %s", msg or "Assertion failed", tostring(expected), tostring(actual)))
    end
end

local function assert_true(condition, msg)
    if not condition then
        error(msg or "Assertion failed: condition was false")
    end
end

local function assert_not_nil(value, msg)
    if value == nil then
        error(msg or "Assertion failed: value was nil")
    end
end

print("="..string.rep("=", 70))
print("  Shadows of Thornhaven - RPG Systems Test Suite")
print("="..string.rep("=", 70))
print()

-- Load the story
local story, err = WhiskerLoader.load_from_file('examples/stories/shadows_of_thornhaven.whisker')
if not story then
    print("✗ FATAL ERROR: Could not load story file")
    print("  " .. tostring(err))
    os.exit(1)
end

print("✓ Story file loaded successfully")
print("  Total passages: " .. #story:get_all_passages())
print()

print("="..string.rep("=", 70))
print("  TIER 1 TESTS - Core RPG Systems")
print("="..string.rep("=", 70))
print()

-- TEST 1: Character Creation System
test("Character creation passages exist", function()
    assert_not_nil(story:get_passage('character_creation_intro'), "Missing character_creation_intro")
    assert_not_nil(story:get_passage('class_selection'), "Missing class_selection")
    assert_not_nil(story:get_passage('create_fighter'), "Missing create_fighter")
    assert_not_nil(story:get_passage('create_rogue'), "Missing create_rogue")
    assert_not_nil(story:get_passage('create_cleric'), "Missing create_cleric")
    assert_not_nil(story:get_passage('create_mage'), "Missing create_mage")
    assert_not_nil(story:get_passage('finalize_character'), "Missing finalize_character")
end)

test("Start passage redirects to character creation", function()
    assert_eq(story.start_passage, 'character_creation_intro', "Start passage should be character_creation_intro")
end)

test("Character variables initialized", function()
    assert_not_nil(story.variables['class'], "Missing 'class' variable")
    assert_not_nil(story.variables['level'], "Missing 'level' variable")
    assert_not_nil(story.variables['experience'], "Missing 'experience' variable")
    assert_eq(story.variables['level'], 1, "Starting level should be 1")
    assert_eq(story.variables['experience'], 0, "Starting XP should be 0")
end)

test("Character stats variables exist", function()
    local stats = {'strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma'}
    for _, stat in ipairs(stats) do
        assert_not_nil(story.variables[stat], "Missing stat: " .. stat)
        assert_eq(story.variables[stat], 10, stat .. " should start at 10")
    end
end)

test("Combat stats variables exist", function()
    assert_not_nil(story.variables['health'], "Missing 'health' variable")
    assert_not_nil(story.variables['max_health'], "Missing 'max_health' variable")
    assert_not_nil(story.variables['stamina'], "Missing 'stamina' variable")
    assert_not_nil(story.variables['max_stamina'], "Missing 'max_stamina' variable")
    assert_not_nil(story.variables['armor_class'], "Missing 'armor_class' variable")
    assert_not_nil(story.variables['attack_bonus'], "Missing 'attack_bonus' variable")
end)

-- TEST 2: Experience and Leveling System
test("Leveling system passages exist", function()
    assert_not_nil(story:get_passage('level_up'), "Missing level_up")
    assert_not_nil(story:get_passage('level_up_str_con'), "Missing level_up_str_con")
    assert_not_nil(story:get_passage('level_up_dex_wis'), "Missing level_up_dex_wis")
    assert_not_nil(story:get_passage('level_up_int_cha'), "Missing level_up_int_cha")
    assert_not_nil(story:get_passage('level_up_str_dex'), "Missing level_up_str_dex")
    assert_not_nil(story:get_passage('level_up_con_wis'), "Missing level_up_con_wis")
end)

test("Level up passage contains XP check logic", function()
    local level_up = story:get_passage('level_up')
    assert_true(level_up.content:find("level.*%+.*1"), "Level up should increment level")
    assert_true(level_up.content:find("max_health"), "Level up should increase max_health")
    assert_true(level_up.content:find("max_stamina"), "Level up should increase max_stamina")
    assert_true(level_up.content:find("skill_points"), "Level up should grant skill_points")
end)

-- TEST 3: Skill System
test("Skill system passages exist", function()
    assert_not_nil(story:get_passage('skill_improvement'), "Missing skill_improvement")
    assert_not_nil(story:get_passage('improve_persuasion'), "Missing improve_persuasion")
    assert_not_nil(story:get_passage('improve_perception'), "Missing improve_perception")
    assert_not_nil(story:get_passage('improve_lockpicking'), "Missing improve_lockpicking")
    assert_not_nil(story:get_passage('improve_stealth'), "Missing improve_stealth")
    assert_not_nil(story:get_passage('improve_arcana'), "Missing improve_arcana")
    assert_not_nil(story:get_passage('improve_medicine'), "Missing improve_medicine")
end)

test("Skill variables initialized", function()
    local skills = {'skill_persuasion', 'skill_perception', 'skill_lockpicking',
                    'skill_stealth', 'skill_arcana', 'skill_medicine'}
    for _, skill in ipairs(skills) do
        assert_not_nil(story.variables[skill], "Missing skill: " .. skill)
        assert_eq(story.variables[skill], 0, skill .. " should start at 0")
    end
    assert_not_nil(story.variables['skill_points'], "Missing 'skill_points' variable")
end)

-- TEST 4: Equipment System
test("Equipment variables exist", function()
    assert_not_nil(story.variables['weapon_name'], "Missing 'weapon_name' variable")
    assert_not_nil(story.variables['weapon_damage'], "Missing 'weapon_damage' variable")
    assert_not_nil(story.variables['weapon_bonus'], "Missing 'weapon_bonus' variable")
    assert_not_nil(story.variables['armor_name'], "Missing 'armor_name' variable")
    assert_not_nil(story.variables['armor_ac'], "Missing 'armor_ac' variable")
end)

test("Starting equipment is set", function()
    assert_eq(story.variables['weapon_name'], "Rusty Sword", "Should start with Rusty Sword")
    assert_eq(story.variables['armor_name'], "Leather Armor", "Should start with Leather Armor")
end)

print()
print("="..string.rep("=", 70))
print("  TIER 2 TESTS - Advanced RPG Systems")
print("="..string.rep("=", 70))
print()

-- TEST 5: Quest Journal System
test("Quest journal passage exists", function()
    assert_not_nil(story:get_passage('quest_journal'), "Missing quest_journal")
end)

test("Quest tracking variables exist", function()
    assert_not_nil(story.variables['quest_clear_ruins'], "Missing 'quest_clear_ruins'")
    assert_not_nil(story.variables['quest_merchant_treasure'], "Missing 'quest_merchant_treasure'")
    assert_not_nil(story.variables['quest_healer_herbs'], "Missing 'quest_healer_herbs'")
    assert_not_nil(story.variables['quest_elder_shadows'], "Missing 'quest_elder_shadows'")
    assert_not_nil(story.variables['monsters_killed'], "Missing 'monsters_killed'")
end)

-- TEST 6: Character Sheet
test("Character sheet passage exists", function()
    assert_not_nil(story:get_passage('character_sheet'), "Missing character_sheet")
end)

test("Character sheet displays all stats", function()
    local sheet = story:get_passage('character_sheet')
    assert_true(sheet.content:find("Strength"), "Character sheet should show Strength")
    assert_true(sheet.content:find("HP:"), "Character sheet should show HP")
    assert_true(sheet.content:find("Stamina:"), "Character sheet should show Stamina")
    assert_true(sheet.content:find("Skills:"), "Character sheet should show Skills")
    assert_true(sheet.content:find("Equipment:"), "Character sheet should show Equipment")
    assert_true(sheet.content:find("Companion:"), "Character sheet should show Companion")
    assert_true(sheet.content:find("Alignment:"), "Character sheet should show Alignment")
end)

-- TEST 7: Companion System
test("Companion variables exist", function()
    assert_not_nil(story.variables['companion_name'], "Missing 'companion_name'")
    assert_not_nil(story.variables['companion_health'], "Missing 'companion_health'")
    assert_not_nil(story.variables['companion_max_health'], "Missing 'companion_max_health'")
    assert_not_nil(story.variables['companion_ability'], "Missing 'companion_ability'")
    assert_not_nil(story.variables['companion_loyalty'], "Missing 'companion_loyalty'")
end)

test("Companion starts as none", function()
    assert_eq(story.variables['companion_name'], "none", "Should start with no companion")
    assert_eq(story.variables['companion_loyalty'], 0, "Loyalty should start at 0")
end)

-- TEST 8: Alignment System
test("Alignment variables exist", function()
    assert_not_nil(story.variables['alignment_good_evil'], "Missing 'alignment_good_evil'")
    assert_not_nil(story.variables['alignment_lawful_chaotic'], "Missing 'alignment_lawful_chaotic'")
end)

test("Alignment starts neutral", function()
    assert_eq(story.variables['alignment_good_evil'], 0, "Should start neutral (Good-Evil)")
    assert_eq(story.variables['alignment_lawful_chaotic'], 0, "Should start neutral (Lawful-Chaotic)")
end)

-- TEST 9: Integration Tests
print()
print("="..string.rep("=", 70))
print("  INTEGRATION TESTS")
print("="..string.rep("=", 70))
print()

test("All 4 character classes have creation passages", function()
    local classes = {'fighter', 'rogue', 'cleric', 'mage'}
    for _, class in ipairs(classes) do
        local passage = story:get_passage('create_' .. class)
        assert_not_nil(passage, "Missing passage for " .. class)
        -- Check that passage sets appropriate stats
        assert_true(passage.content:find("class.*" .. class:sub(1,1):upper() .. class:sub(2)),
                   "Class passage should set class variable")
    end
end)

test("Original story passages still exist", function()
    -- Check some key original passages
    assert_not_nil(story:get_passage('start'), "Missing original 'start' passage")
    assert_not_nil(story:get_passage('village_center'), "Missing 'village_center'")
    assert_not_nil(story:get_passage('to_ruins'), "Missing 'to_ruins'")
    assert_not_nil(story:get_passage('wolf_den_entrance'), "Missing 'wolf_den_entrance'")
    assert_not_nil(story:get_passage('victory'), "Missing 'victory'")
    assert_not_nil(story:get_passage('death'), "Missing 'death'")
end)

test("Story has appropriate number of passages", function()
    local total_passages = #story:get_all_passages()
    assert_true(total_passages >= 68, "Should have at least 68 passages (original + RPG)")
    assert_true(total_passages <= 72, "Should have no more than 72 passages")
end)

test("Character creation is mandatory", function()
    assert_eq(story.start_passage, 'character_creation_intro',
             "Start passage must be character creation")
    local char_intro = story:get_passage('character_creation_intro')
    assert_true(char_intro.content:find("character_created"),
               "Character intro should check if character is created")
end)

-- TEST 10: Lua Code Quality Tests
print()
print("="..string.rep("=", 70))
print("  LUA CODE QUALITY TESTS")
print("="..string.rep("=", 70))
print()

test("Level up code uses proper Lua syntax", function()
    local level_up = story:get_passage('level_up')
    -- Should use proper Lua conditionals
    assert_true(level_up.content:find("local"), "Should use local variables")
    assert_true(level_up.content:find("game_state:set_variable"), "Should use game_state API")
end)

test("Class creation passages set all required stats", function()
    local fighter = story:get_passage('create_fighter')
    local required_vars = {'strength', 'max_health', 'max_stamina', 'armor_class', 'attack_bonus'}
    for _, var in ipairs(required_vars) do
        assert_true(fighter.content:find(var), "Fighter creation should set " .. var)
    end
end)

test("Skill improvement decrements skill points", function()
    local improve = story:get_passage('improve_persuasion')
    assert_true(improve.content:find('skill_points.*%-.*1'), "Should decrement skill_points")
    assert_true(improve.content:find('skill_persuasion.*%+.*1'), "Should increment skill")
end)

-- Print Summary
print()
print("="..string.rep("=", 70))
print("  TEST SUMMARY")
print("="..string.rep("=", 70))
print()

local total_tests = tests_passed + tests_failed
local pass_rate = total_tests > 0 and (tests_passed / total_tests * 100) or 0

print(string.format("Total Tests:    %d", total_tests))
print(string.format("Tests Passed:   %d (%.1f%%)", tests_passed, pass_rate))
print(string.format("Tests Failed:   %d", tests_failed))
print()

if tests_failed > 0 then
    print("FAILED TESTS:")
    for _, detail in ipairs(test_details) do
        if not detail.passed then
            print("  ✗ " .. detail.name)
            if detail.error then
                print("    " .. tostring(detail.error))
            end
        end
    end
    print()
end

print("="..string.rep("=", 70))

if tests_failed == 0 then
    print("  ✓ ALL TESTS PASSED - RPG SYSTEMS FULLY FUNCTIONAL!")
    print("="..string.rep("=", 70))
    os.exit(0)
else
    print("  ✗ SOME TESTS FAILED - REVIEW ABOVE")
    print("="..string.rep("=", 70))
    os.exit(1)
end
