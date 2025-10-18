local helper = require("tests.test_helper")
local snowman_parser = require("whisker.format.parsers.snowman")
local converter = require("whisker.format.converters.snowman")

describe("Snowman Converter", function()

  describe("Snowman to Harlowe", function()
    it("should convert basic story structure", function()
      local snowman_story = [=[
:: Start
<% s.name = "Hero"; s.gold = 100; %>

Welcome, <%= s.name %>!

[[Next->Shop]]
]=]

      local parsed = snowman_parser.parse(snowman_story)
      local harlowe = converter.to_harlowe(parsed)

      assert.is_not_nil(harlowe)
      assert.matches("%(set: %$name to", harlowe)
      assert.matches("%(set: %$gold to", harlowe)
    end)

    it("should convert code blocks to set macros", function()
      local snowman = "<% s.var = 5; %>"
      local result = converter.convert_code_to_harlowe(snowman)

      assert.matches("%(set: %$var to 5%)", result)
    end)

    it("should convert interpolation to variables", function()
      local snowman = "Hello, <%= s.name %>!"
      local result = converter.convert_text_to_harlowe(snowman)

      assert.matches("%$name", result)
      assert.not_matches("<%%=", result)
    end)

    it("should convert link syntax", function()
      local snowman = [=[[[Next->Passage]]]=]
      local result = converter.convert_link_to_harlowe(snowman)

      assert.matches("%[%[Next%->Passage%]%]", result)
    end)

    it("should convert conditionals to if macro", function()
      local snowman = "<% if (s.gold >= 50) { %>You can afford it<% } %>"
      local result = converter.convert_conditional_to_harlowe(snowman)

      assert.matches("%(if: %$gold >= 50%)", result)
      assert.matches("%[You can afford it%]", result)
    end)

    it("should convert complete passage", function()
      local snowman = [=[
<% s.health = 100; %>
Current HP: <%= s.health %>
[[Continue->Next]]
]=]

      local result = converter.convert_to_harlowe_passage(snowman)

      assert.matches("%(set:", result)
      assert.matches("%$health", result)
      assert.matches("%[%[Continue%->Next%]%]", result)
    end)
  end)

  describe("Snowman to SugarCube", function()
    it("should convert basic story to SugarCube", function()
      local snowman_story = [[
:: Start
<% s.name = "Hero"; s.gold = 100; %>

Welcome, <%= s.name %>!
]]

      local parsed = snowman_parser.parse(snowman_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.is_not_nil(sugarcube)
      assert.matches("<<set %$name to", sugarcube)
      assert.matches("<<set %$gold to", sugarcube)
    end)

    it("should convert code blocks to set macros", function()
      local snowman = "<% s.x = 10; %>"
      local result = converter.convert_code_to_sugarcube(snowman)

      assert.matches("<<set %$x to 10>>", result)
    end)

    it("should convert interpolation to variables", function()
      local snowman = "Gold: <%= s.gold %>"
      local result = converter.convert_text_to_sugarcube(snowman)

      assert.matches("%$gold", result)
      assert.not_matches("<%%=", result)
    end)

    it("should convert link syntax", function()
      local snowman = [=[[Next](Shop)]=]
      local result = converter.convert_link_to_sugarcube(snowman)

      assert.matches("%[%[Next%|Shop%]%]", result)
    end)

    it("should convert conditionals to if macro", function()
      local snowman = "<% if (s.score > 10) { %>High score!<% } %>"
      local result = converter.convert_conditional_to_sugarcube(snowman)

      assert.matches("<<if %$score > 10>>", result)
      assert.matches("<</if>>", result)
    end)

    it("should convert complete passage", function()
      local snowman = [=[
<% s.gold = 50; %>
You have <%= s.gold %> gold.
[Shop](Store)
]=]

      local result = converter.convert_to_sugarcube_passage(snowman)

      assert.matches("<<set %$gold to 50>>", result)
      assert.matches("%$gold", result)
      assert.matches("%[%[Shop%|Store%]%]", result)
    end)
  end)

  describe("Snowman to Chapbook", function()
    it("should convert basic story to Chapbook", function()
      local snowman_story = [[
:: Start
<% s.name = "Hero"; s.gold = 100; %>

Welcome, <%= s.name %>!
]]

      local parsed = snowman_parser.parse(snowman_story)
      local chapbook = converter.to_chapbook(parsed)

      assert.is_not_nil(chapbook)
      assert.matches('name: "Hero"', chapbook)
      assert.matches("gold: 100", chapbook)
      assert.matches("%-%-", chapbook)
    end)

    it("should convert code blocks to vars section", function()
      local snowman = [[
<% s.x = 5; %>
<% s.y = 10; %>
Text content
]]

      local result = converter.convert_to_chapbook_passage(snowman)

      assert.matches("x: 5", result)
      assert.matches("y: 10", result)
      assert.matches("%-%-", result)
    end)

    it("should convert interpolation to braces", function()
      local snowman = "Hello, <%= s.name %>!"
      local result = converter.convert_text_to_chapbook(snowman)

      assert.matches("{name}", result)
      assert.not_matches("<%%=", result)
      assert.not_matches("s%.", result)
    end)

    it("should convert link syntax", function()
      local snowman = [=[[[Next->Shop]]]=]
      local result = converter.convert_link_to_chapbook(snowman)

      assert.matches("%[%[Next%->Shop%]%]", result)
    end)

    it("should convert conditionals to modifiers", function()
      local snowman = "<% if (s.gold >= 50) { %>You can afford it<% } %>"
      local result = converter.convert_conditional_to_chapbook(snowman)

      assert.matches("%[if gold >= 50%]", result)
      assert.matches("%[continue%]", result)
      assert.not_matches("s%.", result)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle empty passages", function()
      local snowman_story = [[
:: Empty

:: Start
Content
]]

      local parsed = snowman_parser.parse(snowman_story)
      local harlowe = converter.to_harlowe(parsed)

      assert.is_not_nil(harlowe)
      assert.matches(":: Empty", harlowe)
    end)

    it("should handle passages without code blocks", function()
      local snowman_story = [=[
:: Start
Just plain text here.
[[Next]]
]=]

      local parsed = snowman_parser.parse(snowman_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.is_not_nil(sugarcube)
      assert.matches("Just plain text", sugarcube)
    end)

    it("should handle multiple variable assignments", function()
      local snowman = "<% s.x = 1; s.y = 2; s.z = 3; %>"
      local result = converter.convert_code_to_harlowe(snowman)

      assert.matches("%(set: %$x to 1%)", result)
      assert.matches("%(set: %$y to 2%)", result)
      assert.matches("%(set: %$z to 3%)", result)
    end)

    it("should preserve passage tags", function()
      local snowman_story = [[
:: Start [tag1 tag2]
Content
]]

      local parsed = snowman_parser.parse(snowman_story)
      local harlowe = converter.to_harlowe(parsed)

      assert.matches("%[tag1 tag2%]", harlowe)
    end)

    it("should handle interpolation without spaces", function()
      local snowman = "Value:<%=s.var%>"
      local result = converter.convert_text_to_harlowe(snowman)

      assert.matches("%$var", result)
    end)

    it("should handle code without semicolons", function()
      local snowman = "<% s.health = 100 %>"
      local result = converter.convert_code_to_sugarcube(snowman)

      assert.matches("<<set %$health to 100>>", result)
    end)
  end)
end)
