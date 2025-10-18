local helper = require("tests.test_helper")
local sugarcube_parser = require("whisker.parsers.sugarcube")
local converter = require("whisker.converters.sugarcube")

describe("SugarCube Converter", function()

  describe("SugarCube to Harlowe", function()
    it("should convert basic story structure", function()
      local sugarcube_story = [=[
:: Start
<<set $name to "Hero">>
<<set $gold to 100>>

Welcome, $name!

[[Next|Shop]]
]=]

      local parsed = sugarcube_parser.parse(sugarcube_story)
      local harlowe = converter.to_harlowe(parsed)

      assert.is_not_nil(harlowe)
      assert.matches("%(set: %$name to", harlowe)
      assert.matches("%(set: %$gold to", harlowe)
    end)

    it("should convert set macro to Harlowe", function()
      local sugarcube = "<<set $var to 5>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.equals("(set: $var to 5)", result)
    end)

    it("should convert if/endif to Harlowe", function()
      local sugarcube = "<<if $gold >= 50>>You can afford it<</if>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.matches("%(if: %$gold >= 50%)", result)
      assert.matches("%[You can afford it%]", result)
    end)

    it("should convert JavaScript arrays to (a:)", function()
      local sugarcube = "<<set $inventory to ['sword', 'potion']>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.matches("%(a:", result)
      assert.not_matches("%[", result)
    end)

    it("should convert JavaScript objects to (dm:)", function()
      local sugarcube = "<<set $player to {name: 'Hero', hp: 100}>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.matches("%(dm:", result)
      assert.not_matches("{", result)
    end)

    it("should convert link syntax", function()
      local sugarcube = [=[[[Next|Passage]]]=]
      local result = converter.convert_link_to_harlowe(sugarcube)

      assert.matches("%[%[Next%->Passage%]%]", result)
    end)

    it("should convert for loops", function()
      local sugarcube = "<<for $i to 0; $i lt 10; $i++>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      -- Harlowe doesn't have direct for loop equivalent
      assert.is_not_nil(result)
    end)

    it("should convert run macro to set", function()
      local sugarcube = "<<run $x += 5>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.matches("%(set:", result)
    end)
  end)

  describe("SugarCube to Chapbook", function()
    it("should convert basic story to Chapbook", function()
      local sugarcube_story = [[
:: Start
<<set $name to "Hero">>
<<set $gold to 100>>

Welcome, $name!
]]

      local parsed = sugarcube_parser.parse(sugarcube_story)
      local chapbook = converter.to_chapbook(parsed)

      assert.is_not_nil(chapbook)
      assert.matches('name: "Hero"', chapbook)
      assert.matches("gold: 100", chapbook)
      assert.matches("%-%-", chapbook)
    end)

    it("should convert set macros to vars section", function()
      local sugarcube = [[
<<set $x to 5>>
<<set $y to 10>>
Text content
]]

      local result = converter.convert_to_chapbook_passage(sugarcube)

      assert.matches("x: 5", result)
      assert.matches("y: 10", result)
      assert.matches("%-%-", result)
    end)

    it("should convert if/endif to modifier", function()
      local sugarcube = "<<if $gold >= 50>>You can afford it<</if>>"
      local result = converter.convert_macro_to_chapbook(sugarcube)

      assert.matches("%[if gold >= 50%]", result)
      assert.matches("%[continue%]", result)
    end)

    it("should remove $ from variables", function()
      local sugarcube = "Hello, $name! Gold: $gold"
      local result = converter.convert_text_to_chapbook(sugarcube)

      assert.matches("{name}", result)
      assert.matches("{gold}", result)
      assert.not_matches("%$", result)
    end)

    it("should convert link macro to standard links", function()
      local sugarcube = "<<link 'Next' 'Shop'>><</link>>"
      local result = converter.convert_macro_to_chapbook(sugarcube)

      assert.matches("Next", result)
      assert.matches("Shop", result)
    end)
  end)

  describe("SugarCube to Snowman", function()
    it("should convert to Snowman format", function()
      local sugarcube_story = [[
:: Start
<<set $name to "Hero">>

Welcome, $name!
]]

      local parsed = sugarcube_parser.parse(sugarcube_story)
      local snowman = converter.to_snowman(parsed)

      assert.is_not_nil(snowman)
      assert.matches("<%%", snowman)
      assert.matches("s%.name", snowman)
    end)

    it("should convert variables to state object", function()
      local sugarcube = "<<set $player to 'Hero'>>"
      local result = converter.convert_to_snowman_code(sugarcube)

      assert.matches("s%.player = 'Hero'", result)
    end)

    it("should preserve JavaScript expressions", function()
      local sugarcube = "<<set $x to Math.random()>>"
      local result = converter.convert_to_snowman_code(sugarcube)

      assert.matches("Math%.random%(%)", result)
    end)

    it("should convert widget to function", function()
      local sugarcube = [[
<<widget "test">>
Content
<</widget>>
]]

      local result = converter.convert_widget_to_snowman(sugarcube)

      assert.matches("window%.test = function", result)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle elseif correctly", function()
      local sugarcube = [[
<<if $x > 10>>
  High
<<elseif $x > 5>>
  Medium
<<else>>
  Low
<</if>>
]]

      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.is_not_nil(result)
      assert.matches("%(if:", result)
    end)

    it("should handle nested macros", function()
      local sugarcube = "<<if $x>><<set $y to 5>><</if>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.is_not_nil(result)
    end)

    it("should preserve HTML", function()
      local sugarcube = "<div class='test'>Content</div>"
      local harlowe = converter.convert_to_harlowe_passage(sugarcube)

      assert.matches("<div", harlowe)
    end)

    it("should handle temporary variables", function()
      local sugarcube = "<<set _temp to 5>>"
      local result = converter.convert_to_chapbook_passage(sugarcube)

      -- Temporary variables handled appropriately
      assert.is_not_nil(result)
    end)

    it("should handle print macro", function()
      local sugarcube = "<<print $variable>>"
      local result = converter.convert_macro_to_harlowe(sugarcube)

      assert.matches("%$variable", result)
    end)
  end)
end)
