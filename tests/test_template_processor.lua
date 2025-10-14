-- tests/test_template_processor.lua
-- Comprehensive test suite for template processor

local template_processor = require('src.utils.template_processor')

-- Test utilities
local tests_passed = 0
local tests_failed = 0

local function assert_equal(actual, expected, test_name)
    if actual == expected then
        tests_passed = tests_passed + 1
        print("✓ " .. test_name)
        return true
    else
        tests_failed = tests_failed + 1
        print("✗ " .. test_name)
        print("  Expected: " .. tostring(expected))
        print("  Got:      " .. tostring(actual))
        return false
    end
end

local function assert_contains(actual, substring, test_name)
    if actual:find(substring, 1, true) then
        tests_passed = tests_passed + 1
        print("✓ " .. test_name)
        return true
    else
        tests_failed = tests_failed + 1
        print("✗ " .. test_name)
        print("  Expected to contain: " .. substring)
        print("  Got: " .. actual)
        return false
    end
end

local function assert_not_contains(actual, substring, test_name)
    if not actual:find(substring, 1, true) then
        tests_passed = tests_passed + 1
        print("✓ " .. test_name)
        return true
    else
        tests_failed = tests_failed + 1
        print("✗ " .. test_name)
        print("  Expected NOT to contain: " .. substring)
        print("  Got: " .. actual)
        return false
    end
end

print("=== Template Processor Test Suite ===\n")

-- Test 1: Simple variable substitution
print("--- Basic Variable Substitution ---")
local result = template_processor.process("Hello {{name}}!", {name = "World"})
assert_equal(result, "Hello World!", "Simple variable substitution")

result = template_processor.process("Count: {{count}}", {count = 42})
assert_equal(result, "Count: 42", "Number variable substitution")

result = template_processor.process("Missing: {{missing}}", {})
assert_equal(result, "Missing: ", "Undefined variable returns empty string")

-- Test 2: Simple if/else conditionals
print("\n--- Simple If/Else Conditionals ---")
result = template_processor.process("{{#if visible}}Shown{{/if}}", {visible = true})
assert_equal(result, "Shown", "If true shows content")

result = template_processor.process("{{#if visible}}Shown{{/if}}", {visible = false})
assert_equal(result, "", "If false hides content")

result = template_processor.process("{{#if visible}}Yes{{else}}No{{/if}}", {visible = true})
assert_equal(result, "Yes", "If/else true branch")

result = template_processor.process("{{#if visible}}Yes{{else}}No{{/if}}", {visible = false})
assert_equal(result, "No", "If/else false branch")

-- Test 3: Chained else if conditionals
print("\n--- Chained Else If Conditionals ---")
result = template_processor.process(
    "{{#if score >= 90}}A{{else if score >= 80}}B{{else if score >= 70}}C{{else}}F{{/if}}",
    {score = 95}
)
assert_equal(result, "A", "First condition matches")

result = template_processor.process(
    "{{#if score >= 90}}A{{else if score >= 80}}B{{else if score >= 70}}C{{else}}F{{/if}}",
    {score = 85}
)
assert_equal(result, "B", "Second condition matches")

result = template_processor.process(
    "{{#if score >= 90}}A{{else if score >= 80}}B{{else if score >= 70}}C{{else}}F{{/if}}",
    {score = 75}
)
assert_equal(result, "C", "Third condition matches")

result = template_processor.process(
    "{{#if score >= 90}}A{{else if score >= 80}}B{{else if score >= 70}}C{{else}}F{{/if}}",
    {score = 50}
)
assert_equal(result, "F", "Else clause matches")

-- Test 4: Comparison operators
print("\n--- Comparison Operators ---")
result = template_processor.process("{{#if gold == 100}}Equal{{/if}}", {gold = 100})
assert_equal(result, "Equal", "Equality operator ==")

result = template_processor.process("{{#if gold != 100}}Not equal{{/if}}", {gold = 50})
assert_equal(result, "Not equal", "Inequality operator !=")

result = template_processor.process("{{#if gold >= 100}}Pass{{/if}}", {gold = 150})
assert_equal(result, "Pass", "Greater than or equal >=")

result = template_processor.process("{{#if gold <= 100}}Pass{{/if}}", {gold = 50})
assert_equal(result, "Pass", "Less than or equal <=")

result = template_processor.process("{{#if gold > 100}}Pass{{/if}}", {gold = 150})
assert_equal(result, "Pass", "Greater than >")

result = template_processor.process("{{#if gold < 100}}Pass{{/if}}", {gold = 50})
assert_equal(result, "Pass", "Less than <")

-- Test 5: Logical operators
print("\n--- Logical Operators ---")
result = template_processor.process(
    "{{#if has_key and has_sword}}Ready{{/if}}",
    {has_key = true, has_sword = true}
)
assert_equal(result, "Ready", "AND operator - both true")

result = template_processor.process(
    "{{#if has_key and has_sword}}Ready{{/if}}",
    {has_key = true, has_sword = false}
)
assert_equal(result, "", "AND operator - one false")

result = template_processor.process(
    "{{#if has_key or has_sword}}Armed{{/if}}",
    {has_key = false, has_sword = true}
)
assert_equal(result, "Armed", "OR operator - one true")

result = template_processor.process(
    "{{#if has_key or has_sword}}Armed{{/if}}",
    {has_key = false, has_sword = false}
)
assert_equal(result, "", "OR operator - both false")

result = template_processor.process(
    "{{#if not locked}}Open{{/if}}",
    {locked = false}
)
assert_equal(result, "Open", "NOT operator - negates false to true")

result = template_processor.process(
    "{{#if not locked}}Open{{/if}}",
    {locked = true}
)
assert_equal(result, "", "NOT operator - negates true to false")

-- Test 6: Complex expressions
print("\n--- Complex Expressions ---")
result = template_processor.process(
    "{{#if gold >= 100 and has_key}}Enter{{/if}}",
    {gold = 150, has_key = true}
)
assert_equal(result, "Enter", "Complex: comparison AND boolean")

result = template_processor.process(
    "{{#if level > 5 or has_admin}}Access{{/if}}",
    {level = 3, has_admin = true}
)
assert_equal(result, "Access", "Complex: comparison OR boolean")

-- Test 7: String comparisons
print("\n--- String Comparisons ---")
result = template_processor.process(
    "{{#if status == \"active\"}}Running{{/if}}",
    {status = "active"}
)
assert_equal(result, "Running", "String equality with quotes")

result = template_processor.process(
    "{{#if status != \"inactive\"}}Running{{/if}}",
    {status = "active"}
)
assert_equal(result, "Running", "String inequality with quotes")

-- Test 8: Unless conditionals
print("\n--- Unless Conditionals ---")
result = template_processor.process(
    "{{#unless locked}}Open{{/unless}}",
    {locked = false}
)
assert_equal(result, "Open", "Unless - false condition shows content")

result = template_processor.process(
    "{{#unless locked}}Open{{/unless}}",
    {locked = true}
)
assert_equal(result, "", "Unless - true condition hides content")

-- Test 9: Variable types
print("\n--- Variable Type Handling ---")
result = template_processor.process("{{#if flag}}Yes{{/if}}", {flag = true})
assert_equal(result, "Yes", "Boolean true is truthy")

result = template_processor.process("{{#if flag}}Yes{{/if}}", {flag = false})
assert_equal(result, "", "Boolean false is falsy")

result = template_processor.process("{{#if count}}Has count{{/if}}", {count = 0})
assert_equal(result, "", "Number 0 is falsy")

result = template_processor.process("{{#if count}}Has count{{/if}}", {count = 1})
assert_equal(result, "Has count", "Number non-zero is truthy")

result = template_processor.process("{{#if text}}Has text{{/if}}", {text = ""})
assert_equal(result, "", "Empty string is falsy")

result = template_processor.process("{{#if text}}Has text{{/if}}", {text = "hello"})
assert_equal(result, "Has text", "Non-empty string is truthy")

-- Test 10: Lua tag removal
print("\n--- Lua Tag Removal ---")
result = template_processor.process(
    "Before {{lua:gold = gold + 10}} After",
    {gold = 100}
)
assert_equal(result, "Before  After", "Lua tags are removed from output")

result = template_processor.process(
    "{{lua:if gold > 100 then gold = 100 end}}Gold: {{gold}}",
    {gold = 50}
)
assert_not_contains(result, "lua:", "Lua tags don't appear in output")

-- Test 11: Combined conditionals and variables
print("\n--- Combined Conditionals and Variables ---")
result = template_processor.process(
    "{{#if has_item}}You have {{item_name}}{{/if}}",
    {has_item = true, item_name = "sword"}
)
assert_equal(result, "You have sword", "Variable substitution inside conditional")

result = template_processor.process(
    "{{#if gold >= 100}}You have {{gold}} gold{{else}}You need {{needed}} more gold{{/if}}",
    {gold = 150, needed = 0}
)
assert_contains(result, "150", "Variable substitution in if branch")

result = template_processor.process(
    "{{#if gold >= 100}}You have {{gold}} gold{{else}}You need {{needed}} more gold{{/if}}",
    {gold = 50, needed = 50}
)
assert_contains(result, "50 more", "Variable substitution in else branch")

-- Test 12: Multiple conditionals in sequence
print("\n--- Multiple Conditionals ---")
result = template_processor.process(
    "{{#if a}}A{{/if}} {{#if b}}B{{/if}} {{#if c}}C{{/if}}",
    {a = true, b = false, c = true}
)
assert_equal(result, "A  C", "Multiple conditionals processed independently")

-- Test 13: Real-world story example (from Keep on the Borderlands)
print("\n--- Real-World Story Example ---")
local story_text = [[{{#if not castellan_quest_active}}
"Adventurer, I have a task for you."
{{else if castellan_quest_active and explored_orc_lair and not castellan_quest_complete}}
"You've returned! Tell me of your success."
{{else if castellan_quest_complete}}
"Well done again, hero."
{{else}}
"The orcs still threaten us."
{{/if}}]]

result = template_processor.process(story_text, {
    castellan_quest_active = false
})
assert_contains(result, "I have a task", "Story example - initial state")

result = template_processor.process(story_text, {
    castellan_quest_active = true,
    explored_orc_lair = true,
    castellan_quest_complete = false
})
assert_contains(result, "You've returned", "Story example - quest in progress")

result = template_processor.process(story_text, {
    castellan_quest_active = true,
    explored_orc_lair = true,
    castellan_quest_complete = true
})
assert_contains(result, "Well done again", "Story example - quest complete")

result = template_processor.process(story_text, {
    castellan_quest_active = true,
    explored_orc_lair = false,
    castellan_quest_complete = false
})
assert_contains(result, "still threaten", "Story example - else clause")

-- Test 14: Edge cases
print("\n--- Edge Cases ---")
result = template_processor.process("", {})
assert_equal(result, "", "Empty content returns empty string")

result = template_processor.process("No templates here", {})
assert_equal(result, "No templates here", "Content without templates unchanged")

result = template_processor.process("{{#if}}Empty{{/if}}", {})
assert_equal(result, "{{#if}}Empty{{/if}}", "Malformed if tag (no condition) is left unchanged")

-- Print summary
print("\n=== Test Results ===")
print(string.format("Passed: %d", tests_passed))
print(string.format("Failed: %d", tests_failed))
print(string.format("Total:  %d", tests_passed + tests_failed))

if tests_failed == 0 then
    print("\n✓ All tests passed!")
else
    print("\n✗ Some tests failed")
    error("Test failures detected")
end
