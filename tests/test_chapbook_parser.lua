local helper = require("tests.test_helper")
local parser = require("src.format.parsers.chapbook")

describe("Chapbook Parser", function()

  describe("Basic Parsing", function()
    it("should parse simple Chapbook passage", function()
      local twee = [=[
:: Start
name: "Hero"
--
Welcome, {name}!
]=]

      local result = parser.parse(twee)

      assert.is_not_nil(result)
      assert.equals(1, #result.passages)
      assert.equals("Start", result.passages[1].name)
      assert.matches('name: "Hero"', result.passages[1].content)
    end)

    it("should parse multiple passages with Chapbook syntax", function()
      local twee = [=[
:: Start
health: 100
gold: 50
--
You have {health} HP and {gold} gold.

[[Shop]]

:: Shop
[if gold >= 20]
You can afford items.
[continue]
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)
      assert.matches("health: 100", result.passages[1].content)
      assert.matches("%[if gold", result.passages[2].content)
    end)
  end)

  describe("Chapbook-Specific Content", function()
    it("should preserve vars section", function()
      local twee = [=[
:: Test
x: 5
y: 10
inventory: ['sword', 'potion']
--
Main content here
]=]

      local result = parser.parse(twee)

      assert.matches("x: 5", result.passages[1].content)
      assert.matches("y: 10", result.passages[1].content)
      assert.matches("inventory:", result.passages[1].content)
      assert.matches("%-%-", result.passages[1].content)
    end)

    it("should preserve variable interpolation", function()
      local twee = [=[
:: Start
name: "Alice"
--
Hello, {name}!
You have {gold} gold.
]=]

      local result = parser.parse(twee)

      assert.matches("{name}", result.passages[1].content)
      assert.matches("{gold}", result.passages[1].content)
    end)

    it("should preserve modifiers", function()
      local twee = [=[
:: Test
[if score > 10]
High score!
[continue]

[after 2s]
Delayed text
[continue]

[align center]
Centered
[continue]
]=]

      local result = parser.parse(twee)

      assert.matches("%[if score > 10%]", result.passages[1].content)
      assert.matches("%[after 2s%]", result.passages[1].content)
      assert.matches("%[align center%]", result.passages[1].content)
      assert.matches("%[continue%]", result.passages[1].content)
    end)

    it("should preserve inserts", function()
      local twee = [=[
:: Start
{text input for: 'playerName'}
{cycling link for: 'color', choices: ['Red', 'Blue', 'Green']}
{reveal link: 'Show more', text: 'Hidden content'}
]=]

      local result = parser.parse(twee)

      assert.matches("{text input for:", result.passages[1].content)
      assert.matches("{cycling link for:", result.passages[1].content)
      assert.matches("{reveal link:", result.passages[1].content)
    end)
  end)

  describe("Tags", function()
    it("should parse Chapbook tags", function()
      local twee = [=[
:: Header [header]
Header content

:: Footer [footer]
Footer content
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)
      assert.equals(1, #result.passages[1].tags)
      assert.equals("header", result.passages[1].tags[1])
      assert.equals(1, #result.passages[2].tags)
      assert.equals("footer", result.passages[2].tags[1])
    end)
  end)

  describe("Complex Content", function()
    it("should handle nested modifiers", function()
      local twee = [=[
:: Test
[if x > 5]
[if y > 10]
Both conditions true
[continue]
[continue]
]=]

      local result = parser.parse(twee)

      assert.matches("%[if x > 5%]", result.passages[1].content)
      assert.matches("%[if y > 10%]", result.passages[1].content)
    end)

    it("should handle complex variable structures", function()
      local twee = [=[
:: Start
player: {name: 'Hero', stats: {hp: 100, mp: 50}}
inventory: ['sword', 'shield', 'potion']
flags: {completed_quest_1: true, visited_town: false}
--
Content
]=]

      local result = parser.parse(twee)

      assert.matches("player: {", result.passages[1].content)
      assert.matches("inventory: %[", result.passages[1].content)
      assert.matches("flags: {", result.passages[1].content)
    end)

    it("should preserve passage without vars section", function()
      local twee = [=[
:: Simple
Just plain text, no variables.
[[Next]]
]=]

      local result = parser.parse(twee)

      assert.matches("Just plain text", result.passages[1].content)
      assert.not_matches("%-%-", result.passages[1].content)
    end)
  end)
end)
