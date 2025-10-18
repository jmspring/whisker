local helper = require("tests.test_helper")
local harlowe_parser = require("whisker.format.parsers.harlowe")
local converter = require("whisker.format.converters.harlowe")

describe("Harlowe Converter", function()

  describe("Harlowe to SugarCube", function()
    it("should convert basic story structure", function()
      local harlowe_story = [=[
:: Start
(set: $name to "Hero")
(set: $gold to 100)

Welcome, $name!

[[Next Passage->Shop]]
]=]

      local parsed = harlowe_parser.parse(harlowe_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.is_not_nil(sugarcube)
      assert.matches("<<set %$name to", sugarcube)
      assert.matches("<<set %$gold to", sugarcube)
    end)

    it("should convert set macro to SugarCube", function()
      local harlowe = "(set: $var to 5)"
      local result = converter.convert_macro_to_sugarcube(harlowe)

      assert.equals("<<set $var to 5>>", result)
    end)

    it("should convert if macro to SugarCube", function()
      local harlowe = "(if: $gold >= 50)[You can afford it]"
      local result = converter.convert_macro_to_sugarcube(harlowe)

      assert.matches("<<if %$gold >= 50>>", result)
      assert.matches("<</if>>", result)
    end)

    it("should convert arrays from (a:) to []", function()
      local harlowe = "(set: $inventory to (a: 'sword', 'potion'))"
      local result = converter.convert_macro_to_sugarcube(harlowe)

      assert.matches("%[", result)
      assert.matches("%]", result)
      assert.not_matches("%(a:", result)
    end)

    it("should convert datamaps from (dm:) to {}", function()
      local harlowe = '(set: $player to (dm: "name", "Hero", "hp", 100))'
      local result = converter.convert_macro_to_sugarcube(harlowe)

      assert.matches("{", result)
      assert.matches("}", result)
      assert.not_matches("%(dm:", result)
    end)

    it("should convert link syntax", function()
      local harlowe = [=[[[Next->Passage]]]=]
      local result = converter.convert_link_to_sugarcube(harlowe)

      assert.matches("%[%[Next%|Passage%]%]", result)
    end)

    it("should convert 'it' keyword to variable reference", function()
      local harlowe = "(set: $gold to it - 50)"
      local result = converter.convert_macro_to_sugarcube(harlowe)

      assert.matches("%$gold %- 50", result)
      assert.not_matches("it", result)
    end)

    it("should convert random function", function()
      local harlowe = "(random: 1, 10)"
      local result = converter.convert_function_to_sugarcube(harlowe)

      assert.matches("random%(1, 10%)", result)
    end)

    it("should preserve passage names", function()
      local harlowe_story = [[
:: Start
Content here

:: Another Passage
More content
]]

      local parsed = harlowe_parser.parse(harlowe_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.matches(":: Start", sugarcube)
      assert.matches(":: Another Passage", sugarcube)
    end)
  end)

  describe("Harlowe to Chapbook", function()
    it("should convert basic story to Chapbook", function()
      local harlowe_story = [[
:: Start
(set: $name to "Hero")
(set: $gold to 100)

Welcome, $name!
]]

      local parsed = harlowe_parser.parse(harlowe_story)
      local chapbook = converter.to_chapbook(parsed)

      assert.is_not_nil(chapbook)
      assert.matches('name: "Hero"', chapbook)
      assert.matches("gold: 100", chapbook)
      assert.matches("%-%-", chapbook) -- vars separator
    end)

    it("should convert variables to vars section", function()
      local harlowe = [[
(set: $x to 5)
(set: $y to 10)
Some text here
]]

      local result = converter.convert_to_chapbook_passage(harlowe)

      assert.matches("x: 5", result)
      assert.matches("y: 10", result)
      assert.matches("%-%-", result)
    end)

    it("should convert if to modifier", function()
      local harlowe = "(if: $gold >= 50)[You can afford it]"
      local result = converter.convert_macro_to_chapbook(harlowe)

      assert.matches("%[if gold >= 50%]", result)
      assert.not_matches("%$", result) -- Chapbook doesn't use $
    end)

    it("should convert arrays to JavaScript arrays", function()
      local harlowe = "(a: 'red', 'blue', 'green')"
      local result = converter.convert_datastructure_to_chapbook(harlowe)

      assert.matches("%['red', 'blue', 'green'%]", result)
    end)

    it("should convert datamaps to JavaScript objects", function()
      local harlowe = '(dm: "name", "Hero", "hp", 100)'
      local result = converter.convert_datastructure_to_chapbook(harlowe)

      assert.matches("{", result)
      assert.matches("name:", result)
      assert.matches("hp:", result)
    end)

    it("should remove $ from variables", function()
      local harlowe = "Welcome, $name! You have $gold gold."
      local result = converter.convert_text_to_chapbook(harlowe)

      assert.matches("{name}", result)
      assert.matches("{gold}", result)
      assert.not_matches("%$", result)
    end)
  end)

  describe("Harlowe to Snowman", function()
    it("should convert to Snowman format", function()
      local harlowe_story = [[
:: Start
(set: $name to "Hero")

Welcome, $name!
]]

      local parsed = harlowe_parser.parse(harlowe_story)
      local snowman = converter.to_snowman(parsed)

      assert.is_not_nil(snowman)
      assert.matches("<%%", snowman)
      assert.matches("s%.name", snowman)
      assert.matches("= \"Hero\"", snowman)  -- verify assignment is present
    end)

    it("should convert variables to state object", function()
      local harlowe = "(set: $player to 'Hero')"
      local result = converter.convert_to_snowman_code(harlowe)

      assert.matches("s%.player = 'Hero'", result)
    end)

    it("should wrap variable declarations in code blocks", function()
      local harlowe = "(set: $x to 5)"
      local result = converter.convert_to_snowman_passage(harlowe)

      assert.matches("<%%", result)
      assert.matches("s%.x = 5", result)  -- verify code block contains assignment
    end)

    it("should convert interpolation to print blocks", function()
      local harlowe = "Hello, $name!"
      local result = converter.convert_text_to_snowman(harlowe)

      assert.matches("<%%= s%.name %%>", result)
    end)

    it("should convert links to Markdown", function()
      local harlowe = [=[[[Next->Shop]]]=]
      local result = converter.convert_link_to_snowman(harlowe)

      assert.matches("%[Next%]%(Shop%)", result)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle empty passages", function()
      local harlowe_story = [[
:: Empty

:: Start
Content
]]

      local parsed = harlowe_parser.parse(harlowe_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.is_not_nil(sugarcube)
      assert.matches(":: Empty", sugarcube)
    end)

    it("should handle passages without variables", function()
      local harlowe_story = [=[
:: Start
Just plain text here.
[[Next]]
]=]

      local parsed = harlowe_parser.parse(harlowe_story)
      local chapbook = converter.to_chapbook(parsed)

      assert.is_not_nil(chapbook)
      assert.matches("Just plain text", chapbook)
    end)

    it("should handle complex nested structures", function()
      local harlowe = "(if: $x > 0)[(set: $y to it + 1)]"
      local result = converter.convert_macro_to_sugarcube(harlowe)

      assert.is_not_nil(result)
      assert.matches("<<if", result)
      assert.matches("<<set", result)
    end)

    it("should preserve passage tags", function()
      local harlowe_story = [[
:: Start [tag1 tag2]
Content
]]

      local parsed = harlowe_parser.parse(harlowe_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.matches("%[tag1 tag2%]", sugarcube)
    end)

    it("should handle special characters in text", function()
      local harlowe = 'Text with "quotes" and $symbols'
      local result = converter.convert_text_to_chapbook(harlowe)

      assert.matches('"quotes"', result)
    end)
  end)
end)
