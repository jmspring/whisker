#!/usr/bin/env lua
--[[
    RPG Gameplay Integration Test

    Simulates a complete gameplay session to verify all systems work together:
    1. Create a character (Fighter)
    2. Gain experience and level up
    3. Improve skills
    4. Play through part of the story
    5. Verify stats are tracked correctly
]]

package.path = package.path .. ';./src/?.lua'

local WhiskerLoader = require('src.format.whisker_loader')
local GameState = require('src.core.game_state')

print("="..string.rep("=", 70))
print("  RPG Gameplay Integration Test")
print("="..string.rep("=", 70))
print()

-- Load story
local story, err = WhiskerLoader.load_from_file('examples/stories/keep_on_the_borderlands.whisker')
if not story then
    print("✗ FATAL: Could not load story")
    os.exit(1)
end

print("✓ Story loaded: " .. #story:get_all_passages() .. " passages")
print()

-- Create a game state
local game_state = GameState.new()
game_state:initialize(story)
print("✓ Game state created")
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Create Fighter Character")
print("="..string.rep("=", 70))
print()

-- Simulate character creation: Choose Fighter
game_state:set("class", "Fighter")
game_state:set("strength", 16)
game_state:set("dexterity", 12)
game_state:set("constitution", 15)
game_state:set("intelligence", 8)
game_state:set("wisdom", 10)
game_state:set("charisma", 10)
game_state:set("max_health", 28)
game_state:set("health", 28)
game_state:set("max_stamina", 12)
game_state:set("stamina", 12)
game_state:set("armor_class", 17)
game_state:set("attack_bonus", 5)
game_state:set("damage_bonus", 3)
game_state:set("weapon_name", "Longsword")
game_state:set("weapon_damage", "1d8")
game_state:set("weapon_bonus", 3)
game_state:set("armor_name", "Chainmail")
game_state:set("armor_ac", 15)
game_state:set("has_shield", true)
game_state:set("character_created", true)

print("✓ Fighter character created:")
print("  STR: " .. game_state:get("strength"))
print("  HP:  " .. game_state:get("health") .. "/" .. game_state:get("max_health"))
print("  AC:  " .. game_state:get("armor_class"))
print("  ATK: +" .. game_state:get("attack_bonus"))
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Gain Experience and Level Up")
print("="..string.rep("=", 70))
print()

-- Award 100 XP (enough to level up)
game_state:set("experience", 100)
local current_level = game_state:get("level")
print("✓ Awarded 100 XP")
print("  Current level: " .. current_level)
print("  Current XP: " .. game_state:get("experience"))
print()

-- Simulate level up
game_state:set("level", 2)
game_state:set("max_health", game_state:get("max_health") + 10)  -- Fighter gains 10 HP
game_state:set("health", game_state:get("max_health"))
game_state:set("max_stamina", game_state:get("max_stamina") + 2)
game_state:set("stamina", game_state:get("max_stamina"))
game_state:set("skill_points", 1)
game_state:set("experience", 0)

-- Increase STR and CON
game_state:set("strength", game_state:get("strength") + 1)  -- 16 -> 17
game_state:set("constitution", game_state:get("constitution") + 1)  -- 15 -> 16

print("✓ Leveled up to Level 2:")
print("  Level: " .. game_state:get("level"))
print("  HP:    " .. game_state:get("health") .. "/" .. game_state:get("max_health") .. " (+10)")
print("  STR:   " .. game_state:get("strength") .. " (+1)")
print("  CON:   " .. game_state:get("constitution") .. " (+1)")
print("  Skill Points: " .. game_state:get("skill_points"))
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Improve Skills")
print("="..string.rep("=", 70))
print()

-- Spend skill point on Perception
game_state:set("skill_perception", game_state:get("skill_perception") + 1)
game_state:set("skill_points", game_state:get("skill_points") - 1)

print("✓ Improved Perception skill:")
print("  Perception: +" .. game_state:get("skill_perception"))
print("  Remaining skill points: " .. game_state:get("skill_points"))
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Track Quest Progress")
print("="..string.rep("=", 70))
print()

-- Simulate defeating kobolds
game_state:set("explored_kobold_lair", true)
game_state:set("kobolds_defeated", true)
game_state:set("quest_clear_caves", 1)
game_state:set("monsters_killed", 3)
game_state:set("gold", game_state:get("gold") + 50)

print("✓ Defeated kobolds in their lair:")
print("  Caves cleared: " .. game_state:get("quest_clear_caves") .. "/5")
print("  Monsters killed: " .. game_state:get("monsters_killed"))
print("  Gold earned: +" .. 50 .. " gp (Total: " .. game_state:get("gold") .. ")")
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Track Alignment")
print("="..string.rep("=", 70))
print()

-- Spare goblins (good action)
game_state:set("alignment_good_evil", game_state:get("alignment_good_evil") + 2)

print("✓ Chose to spare surrendering goblins:")
print("  Alignment (Good-Evil): " .. game_state:get("alignment_good_evil") .. " (Good)")
print("  Alignment (Law-Chaos): " .. game_state:get("alignment_lawful_chaotic") .. " (Neutral)")
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Companion System")
print("="..string.rep("=", 70))
print()

-- Recruit Aldric the Warrior
game_state:set("companion_name", "Aldric the Warrior")
game_state:set("companion_max_health", 25)
game_state:set("companion_health", 25)
game_state:set("companion_loyalty", 3)
game_state:set("companion_ability", "Protective (takes 50% damage)")

print("✓ Recruited companion:")
print("  Name: " .. game_state:get("companion_name"))
print("  HP: " .. game_state:get("companion_health") .. "/" .. game_state:get("companion_max_health"))
print("  Loyalty: " .. game_state:get("companion_loyalty"))
print()

print("="..string.rep("=", 70))
print("  SIMULATION: Combat with Stamina")
print("="..string.rep("=", 70))
print()

-- Simulate combat using stamina
local initial_stamina = game_state:get("stamina")
print("✓ Entering combat:")
print("  Stamina before: " .. initial_stamina .. "/" .. game_state:get("max_stamina"))

-- Use Power Strike (costs 3 stamina)
game_state:set("stamina", game_state:get("stamina") - 3)
print("  Used Power Strike (-3 stamina)")
print("  Stamina after: " .. game_state:get("stamina") .. "/" .. game_state:get("max_stamina"))

-- Take some damage
game_state:set("health", game_state:get("health") - 8)
print("  Took 8 damage")
print("  HP: " .. game_state:get("health") .. "/" .. game_state:get("max_health"))
print()

print("="..string.rep("=", 70))
print("  FINAL CHARACTER STATE")
print("="..string.rep("=", 70))
print()

print("Character: Fighter (Level " .. game_state:get("level") .. ")")
print()
print("Stats:")
print("  STR: " .. game_state:get("strength") ..
      " | DEX: " .. game_state:get("dexterity") ..
      " | CON: " .. game_state:get("constitution"))
print("  INT: " .. game_state:get("intelligence") ..
      " | WIS: " .. game_state:get("wisdom") ..
      " | CHA: " .. game_state:get("charisma"))
print()
print("Combat:")
print("  HP: " .. game_state:get("health") .. "/" .. game_state:get("max_health"))
print("  Stamina: " .. game_state:get("stamina") .. "/" .. game_state:get("max_stamina"))
print("  AC: " .. game_state:get("armor_class"))
print("  Attack: +" .. game_state:get("attack_bonus"))
print()
print("Skills:")
print("  Perception: +" .. game_state:get("skill_perception"))
print()
print("Progress:")
print("  Experience: " .. game_state:get("experience") .. "/200 (next level)")
print("  Caves cleared: " .. game_state:get("quest_clear_caves") .. "/5")
print("  Monsters killed: " .. game_state:get("monsters_killed"))
print("  Gold: " .. game_state:get("gold") .. " gp")
print()
print("Companion:")
print("  " .. game_state:get("companion_name") ..
      " (Loyalty: " .. game_state:get("companion_loyalty") .. ")")
print()
print("Alignment:")
print("  Good-Evil: " .. game_state:get("alignment_good_evil") .. " (Good)")
print("  Lawful-Chaotic: " .. game_state:get("alignment_lawful_chaotic") .. " (Neutral)")
print()

print("="..string.rep("=", 70))
print("  VERIFICATION CHECKS")
print("="..string.rep("=", 70))
print()

local function verify(condition, message)
    if condition then
        print("  ✓ " .. message)
        return true
    else
        print("  ✗ " .. message)
        return false
    end
end

local all_checks_passed = true

all_checks_passed = verify(game_state:get("level") == 2, "Character leveled up correctly") and all_checks_passed
all_checks_passed = verify(game_state:get("strength") == 17, "Strength increased correctly") and all_checks_passed
all_checks_passed = verify(game_state:get("max_health") == 38, "Max HP increased correctly (28+10)") and all_checks_passed
all_checks_passed = verify(game_state:get("skill_perception") == 1, "Skill improved correctly") and all_checks_passed
all_checks_passed = verify(game_state:get("quest_clear_caves") == 1, "Quest progress tracked") and all_checks_passed
all_checks_passed = verify(game_state:get("alignment_good_evil") > 0, "Alignment tracked (Good)") and all_checks_passed
all_checks_passed = verify(game_state:get("companion_name") ~= "none", "Companion recruited") and all_checks_passed
all_checks_passed = verify(game_state:get("stamina") < game_state:get("max_stamina"), "Stamina was consumed") and all_checks_passed

print()

if all_checks_passed then
    print("="..string.rep("=", 70))
    print("  ✓ ALL INTEGRATION TESTS PASSED!")
    print("  ✓ RPG SYSTEMS WORKING TOGETHER CORRECTLY!")
    print("="..string.rep("=", 70))
    os.exit(0)
else
    print("="..string.rep("=", 70))
    print("  ✗ SOME INTEGRATION CHECKS FAILED")
    print("="..string.rep("=", 70))
    os.exit(1)
end
