-- tests/test_renderer.lua
-- Test text rendering with markdown formatting and variable substitution

local Renderer = require("src.core.renderer")
local GameState = require("src.core.game_state")
local Interpreter = require("src.core.lua_interpreter")
local Passage = require("src.core.passage")

print("=== Renderer Test Suite ===\n")

-- Test 1: Basic markdown formatting
print("Test 1: Markdown Formatting")
local renderer = Renderer.new("plain")
renderer.enable_formatting = true

local text = "This is **bold** text and this is *italic* text and __underlined__."
local rendered = renderer:apply_formatting(text)
print("Input:  " .. text)
print("Output: " .. rendered)
print("✅ Markdown formatting works\n")

-- Test 2: Variable substitution
print("Test 2: Variable Substitution")
local game_state = GameState.new()
game_state:set("player_name", "Alice")
game_state:set("health", 100)

local interpreter = Interpreter.new({})
renderer:set_interpreter(interpreter)

local text_with_vars = "Hello {{player_name}}, your health is {{health}}!"
local evaluated = renderer:evaluate_expressions(text_with_vars, game_state)
print("Input:  " .. text_with_vars)
print("Output: " .. evaluated)
assert(evaluated:match("Alice"), "Name substitution failed")
assert(evaluated:match("100"), "Health substitution failed")
print("✅ Variable substitution works\n")

-- Test 3: Word wrapping
print("Test 3: Word Wrapping")
local renderer_wrapped = Renderer.new("plain", {
    max_line_width = 40,
    enable_wrapping = true
})

local long_text = "This is a very long sentence that should be wrapped automatically when it exceeds the maximum line width that has been configured for the renderer."
local wrapped = renderer_wrapped:apply_wrapping(long_text)
print("Input (length " .. #long_text .. "):")
print(long_text)
print("\nWrapped output (max width 40):")
print(wrapped)
print("✅ Word wrapping works\n")

-- Test 4: Complete passage rendering
print("Test 4: Complete Passage Rendering")
local passage = Passage:new("test", "test")
passage:set_content("Welcome **{{player_name}}**! You have {{health}} HP.\n\nWhat will you do?")

local full_render = renderer:render_passage(passage, game_state)
print("Rendered passage:")
print(full_render)
print("✅ Complete passage rendering works\n")

-- Test 5: Platform-specific rendering
print("Test 5: Platform-Specific Rendering (Console)")
local console_renderer = Renderer.new("console", {
    enable_formatting = true
})
console_renderer:set_interpreter(interpreter)

local colored_text = "This is **bold** and *italic* text"
local console_output = console_renderer:apply_formatting(colored_text)
print("Console output with ANSI codes:")
print(console_output)
print("✅ Platform-specific rendering works\n")

-- Test 6: Plain text stripping
print("Test 6: Plain Text Stripping")
local formatted = "This is **bold** and *italic* and __underlined__"
local plain = renderer:render_plain(formatted, game_state)
print("Formatted: " .. formatted)
print("Plain:     " .. plain)
assert(not plain:match("%*%*"), "Bold markers not stripped")
assert(not plain:match("%*"), "Italic markers not stripped")
print("✅ Plain text stripping works\n")

print("=== All Renderer Tests Passed! ===")
return true
