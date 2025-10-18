local helper = require("tests.test_helper")
local Renderer = require("whisker.core.renderer")
local GameState = require("whisker.core.game_state")
local Interpreter = require("whisker.core.lua_interpreter")
local Passage = require("whisker.core.passage")

describe("Renderer", function()

  describe("Markdown Formatting", function()
    it("should apply basic markdown formatting", function()
      local renderer = Renderer.new("plain")
      renderer.enable_formatting = true

      local text = "This is **bold** text and this is *italic* text and __underlined__."
      local rendered = renderer:apply_formatting(text)

      assert.is_not_nil(rendered)
      assert.is_string(rendered)
    end)

    it("should handle bold text", function()
      local renderer = Renderer.new("plain")
      renderer.enable_formatting = true

      local text = "This is **bold** text"
      local rendered = renderer:apply_formatting(text)

      assert.is_not_nil(rendered)
    end)

    it("should handle italic text", function()
      local renderer = Renderer.new("plain")
      renderer.enable_formatting = true

      local text = "This is *italic* text"
      local rendered = renderer:apply_formatting(text)

      assert.is_not_nil(rendered)
    end)

    it("should handle underlined text", function()
      local renderer = Renderer.new("plain")
      renderer.enable_formatting = true

      local text = "This is __underlined__ text"
      local rendered = renderer:apply_formatting(text)

      assert.is_not_nil(rendered)
    end)
  end)

  describe("Variable Substitution", function()
    it("should substitute variables in text", function()
      local renderer = Renderer.new("plain")
      local game_state = GameState.new()
      game_state:set("player_name", "Alice")
      game_state:set("health", 100)

      local interpreter = Interpreter.new({})
      renderer:set_interpreter(interpreter)

      local text_with_vars = "Hello {{player_name}}, your health is {{health}}!"
      local evaluated = renderer:evaluate_expressions(text_with_vars, game_state)

      assert.is_not_nil(evaluated)
      assert.is_not_nil(evaluated:match("Alice"))
      assert.is_not_nil(evaluated:match("100"))
    end)

    it("should handle multiple variable substitutions", function()
      local renderer = Renderer.new("plain")
      local game_state = GameState.new()
      game_state:set("var1", "First")
      game_state:set("var2", "Second")
      game_state:set("var3", "Third")

      local interpreter = Interpreter.new({})
      renderer:set_interpreter(interpreter)

      local text = "{{var1}}, {{var2}}, {{var3}}"
      local evaluated = renderer:evaluate_expressions(text, game_state)

      assert.is_not_nil(evaluated:match("First"))
      assert.is_not_nil(evaluated:match("Second"))
      assert.is_not_nil(evaluated:match("Third"))
    end)
  end)

  describe("Word Wrapping", function()
    it("should wrap long text to specified width", function()
      local renderer = Renderer.new("plain", {
        max_line_width = 40,
        enable_wrapping = true
      })

      local long_text = "This is a very long sentence that should be wrapped automatically when it exceeds the maximum line width that has been configured for the renderer."
      local wrapped = renderer:apply_wrapping(long_text)

      assert.is_not_nil(wrapped)
      assert.is_string(wrapped)

      -- Check that lines are wrapped
      local lines = {}
      for line in wrapped:gmatch("[^\n]+") do
        table.insert(lines, line)
      end

      assert.is_true(#lines > 1)

      -- Check that no line exceeds max width
      for _, line in ipairs(lines) do
        assert.is_true(#line <= 40)
      end
    end)

    it("should handle short text without wrapping", function()
      local renderer = Renderer.new("plain", {
        max_line_width = 40,
        enable_wrapping = true
      })

      local short_text = "Short text"
      local wrapped = renderer:apply_wrapping(short_text)

      assert.equals(short_text, wrapped)
    end)
  end)

  describe("Complete Passage Rendering", function()
    it("should render passage with formatting and variables", function()
      local renderer = Renderer.new("plain")
      local game_state = GameState.new()
      game_state:set("player_name", "Alice")
      game_state:set("health", 100)

      local interpreter = Interpreter.new({})
      renderer:set_interpreter(interpreter)

      local passage = Passage.new("test", "test")
      passage:set_content("Welcome **{{player_name}}**! You have {{health}} HP.\n\nWhat will you do?")

      local full_render = renderer:render_passage(passage, game_state)

      assert.is_not_nil(full_render)
      assert.is_string(full_render)
    end)

    it("should handle passages without variables", function()
      local renderer = Renderer.new("plain")
      local game_state = GameState.new()
      local interpreter = Interpreter.new({})
      renderer:set_interpreter(interpreter)

      local passage = Passage.new("test", "test")
      passage:set_content("Simple passage content")

      local full_render = renderer:render_passage(passage, game_state)

      assert.is_not_nil(full_render)
      assert.is_not_nil(full_render:match("Simple passage content"))
    end)
  end)

  describe("Platform-Specific Rendering", function()
    it("should apply console formatting with ANSI codes", function()
      local console_renderer = Renderer.new("console", {
        enable_formatting = true
      })

      local interpreter = Interpreter.new({})
      console_renderer:set_interpreter(interpreter)

      local colored_text = "This is **bold** and *italic* text"
      local console_output = console_renderer:apply_formatting(colored_text)

      assert.is_not_nil(console_output)
      assert.is_string(console_output)
    end)

    it("should create renderer for different platforms", function()
      local plain_renderer = Renderer.new("plain")
      assert.is_not_nil(plain_renderer)

      local console_renderer = Renderer.new("console")
      assert.is_not_nil(console_renderer)
    end)
  end)

  describe("Plain Text Stripping", function()
    it("should strip formatting markers from text", function()
      local renderer = Renderer.new("plain")
      local game_state = GameState.new()

      local formatted = "This is **bold** and *italic* and __underlined__"
      local plain = renderer:render_plain(formatted, game_state)

      assert.is_not_nil(plain)
      assert.is_nil(plain:match("%*%*"))
      assert.is_nil(plain:match("__"))
    end)

    it("should preserve text content when stripping", function()
      local renderer = Renderer.new("plain")
      local game_state = GameState.new()

      local formatted = "Keep **this** text"
      local plain = renderer:render_plain(formatted, game_state)

      assert.is_not_nil(plain:match("Keep"))
      assert.is_not_nil(plain:match("this"))
      assert.is_not_nil(plain:match("text"))
    end)
  end)
end)
