local helper = require("tests.test_helper")
local chapbook_parser = require("src.format.parsers.chapbook")
local converter = require("src.format.converters.chapbook")

describe("Chapbook Converter", function()

  describe("Chapbook to Harlowe", function()
    it("should convert basic story structure", function()
      local chapbook_story = [==[
:: Start
name: "Hero"
gold: 100
--
Welcome, {name}!

[[Next->Shop]]
]==]

      local parsed = chapbook_parser.parse(chapbook_story)
      local harlowe = converter.to_harlowe(parsed)

      assert.is_not_nil(harlowe)
      assert.matches("%(set: %$name to", harlowe)
      assert.matches("%(set: %$gold to", harlowe)
    end)

    it("should convert vars section to set macros", function()
      local chapbook = [[
x: 5
y: 10
--
Content
]]

      local result = converter.convert_to_harlowe_passage(chapbook)

      assert.matches("%(set: %$x to 5%)", result)
      assert.matches("%(set: %$y to 10%)", result)
      assert.not_matches("%-%-", result)
    end)

    it("should convert if modifier to if macro", function()
      local chapbook = [[
[if gold >= 50]
You can afford it
[continue]
]]

      local result = converter.convert_modifier_to_harlowe(chapbook)

      assert.matches("%(if: %$gold >= 50%)", result)
      assert.matches("You can afford it", result)
    end)

    it("should add $ to variables", function()
      local chapbook = "Hello, {name}! Gold: {gold}"
      local result = converter.convert_text_to_harlowe(chapbook)

      assert.matches("%$name", result)
      assert.matches("%$gold", result)
      assert.not_matches("{", result)
    end)

    it("should convert arrays to (a:)", function()
      local chapbook = "inventory: ['sword', 'potion']"
      local result = converter.convert_var_to_harlowe(chapbook)

      assert.matches("%(a:", result)
    end)

    it("should convert objects to (dm:)", function()
      local chapbook = "player: {name: 'Hero', hp: 100}"
      local result = converter.convert_var_to_harlowe(chapbook)

      assert.matches("%(dm:", result)
    end)

    it("should convert cycling link to link-repeat", function()
      local chapbook = "{cycling link for: 'color', choices: ['Red', 'Blue']}"
      local result = converter.convert_insert_to_harlowe(chapbook)

      assert.matches("%(link%-repeat:", result)
    end)

    it("should convert text input", function()
      local chapbook = "{text input for: 'playerName'}"
      local result = converter.convert_insert_to_harlowe(chapbook)

      assert.matches("%(input%-box:", result)
    end)
  end)

  describe("Chapbook to SugarCube", function()
    it("should convert basic story to SugarCube", function()
      local chapbook_story = [[
:: Start
name: "Hero"
gold: 100
--
Welcome, {name}!
]]

      local parsed = chapbook_parser.parse(chapbook_story)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.is_not_nil(sugarcube)
      assert.matches("<<set %$name to", sugarcube)
      assert.matches("<<set %$gold to", sugarcube)
    end)

    it("should convert vars section to set macros", function()
      local chapbook = [[
x: 5
y: 10
--
Content
]]

      local result = converter.convert_to_sugarcube_passage(chapbook)

      assert.matches("<<set %$x to 5>>", result)
      assert.matches("<<set %$y to 10>>", result)
    end)

    it("should convert if modifier to if macro", function()
      local chapbook = [[
[if gold >= 50]
You can afford it
[continue]
]]

      local result = converter.convert_modifier_to_sugarcube(chapbook)

      assert.matches("<<if %$gold >= 50>>", result)
      assert.matches("<</if>>", result)
    end)

    it("should add $ to variables", function()
      local chapbook = "Hello, {name}!"
      local result = converter.convert_text_to_sugarcube(chapbook)

      assert.matches("%$name", result)
    end)

    it("should convert cycling link to listbox", function()
      local chapbook = "{cycling link for: 'color', choices: ['Red', 'Blue']}"
      local result = converter.convert_insert_to_sugarcube(chapbook)

      assert.matches("<<listbox", result)
    end)

    it("should convert text input to textbox", function()
      local chapbook = "{text input for: 'playerName'}"
      local result = converter.convert_insert_to_sugarcube(chapbook)

      assert.matches("<<textbox", result)
    end)
  end)

  describe("Chapbook to Snowman", function()
    it("should convert to Snowman format", function()
      local chapbook_story = [[
:: Start
name: "Hero"
--
Welcome, {name}!
]]

      local parsed = chapbook_parser.parse(chapbook_story)
      local snowman = converter.to_snowman(parsed)

      assert.is_not_nil(snowman)
      assert.matches("<%%", snowman)
      assert.matches("s%.name", snowman)
    end)

    it("should convert vars to state object", function()
      local chapbook = [[
x: 5
y: "test"
--
]]

      local result = converter.convert_to_snowman_passage(chapbook)

      assert.matches("s%.x = 5", result)
      assert.matches("s%.y = \"test\"", result)
    end)

    it("should convert interpolation to print blocks", function()
      local chapbook = "Hello, {name}!"
      local result = converter.convert_text_to_snowman(chapbook)

      assert.matches("<%%= s%.name %%>", result)
    end)

    it("should convert if modifier to JavaScript", function()
      local chapbook = [[
[if score > 10]
High score!
[continue]
]]

      local result = converter.convert_modifier_to_snowman(chapbook)

      assert.matches("<%%", result)
      assert.matches("s%.score > 10", result)
    end)

    it("should convert arrays directly", function()
      local chapbook = "items: ['a', 'b', 'c']"
      local result = converter.convert_var_to_snowman(chapbook)

      assert.matches("s%.items = %['a', 'b', 'c'%]", result)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle empty vars section", function()
      local chapbook = [[
:: Start
--
Just text
]]

      local parsed = chapbook_parser.parse(chapbook)
      local harlowe = converter.to_harlowe(parsed)

      assert.is_not_nil(harlowe)
      assert.matches("Just text", harlowe)
    end)

    it("should handle passages without vars", function()
      local chapbook = [[
:: Start
Plain text, no variables.
]]

      local parsed = chapbook_parser.parse(chapbook)
      local sugarcube = converter.to_sugarcube(parsed)

      assert.is_not_nil(sugarcube)
    end)

    it("should handle modifiers correctly", function()
      local chapbook = [[
[align center]
Centered text
[continue]
]]

      local result = converter.convert_to_harlowe_passage(chapbook)

      -- Alignment might be converted to CSS or maintained
      assert.is_not_nil(result)
    end)

    it("should handle after modifier", function()
      local chapbook = [[
[after 2s]
Delayed text
[continue]
]]

      local result = converter.convert_modifier_to_harlowe(chapbook)

      assert.matches("%(live:", result)
    end)

    it("should handle nested objects", function()
      local chapbook = "player: {stats: {hp: 100, mp: 50}}"
      local result = converter.convert_var_to_harlowe(chapbook)

      assert.matches("%(dm:", result)
    end)
  end)
end)
