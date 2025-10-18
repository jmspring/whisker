local helper = require("tests.test_helper")
local parser = require("src.format.parsers.harlowe")

describe("Harlowe Parser", function()

  describe("Basic Parsing", function()
    it("should parse a simple passage", function()
      local twee = [=[
:: Start
Hello, world!
]=]

      local result = parser.parse(twee)

      assert.is_not_nil(result)
      assert.is_not_nil(result.passages)
      assert.equals(1, #result.passages)
      assert.equals("Start", result.passages[1].name)
      assert.matches("Hello, world!", result.passages[1].content)
    end)

    it("should parse multiple passages", function()
      local twee = [=[
:: Start
First passage

:: Second
Second passage

:: Third
Third passage
]=]

      local result = parser.parse(twee)

      assert.equals(3, #result.passages)
      assert.equals("Start", result.passages[1].name)
      assert.equals("Second", result.passages[2].name)
      assert.equals("Third", result.passages[3].name)
    end)

    it("should handle empty passages", function()
      local twee = [=[
:: Empty

:: NotEmpty
Content here
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)
      assert.equals("Empty", result.passages[1].name)
      assert.equals("", result.passages[1].content:match("^%s*(.-)%s*$"))
    end)

    it("should parse passage with leading/trailing whitespace in name", function()
      local twee = "::   Spaced Name   \nContent"

      local result = parser.parse(twee)

      assert.equals(1, #result.passages)
      assert.equals("Spaced Name", result.passages[1].name)
    end)
  end)

  describe("Tags Parsing", function()
    it("should parse single tag", function()
      local twee = [=[
:: Start [intro]
Content
]=]

      local result = parser.parse(twee)

      assert.equals(1, #result.passages)
      assert.is_not_nil(result.passages[1].tags)
      assert.equals(1, #result.passages[1].tags)
      assert.equals("intro", result.passages[1].tags[1])
    end)

    it("should parse multiple tags", function()
      local twee = [=[
:: Start [intro important special]
Content
]=]

      local result = parser.parse(twee)

      assert.equals(3, #result.passages[1].tags)
      assert.equals("intro", result.passages[1].tags[1])
      assert.equals("important", result.passages[1].tags[2])
      assert.equals("special", result.passages[1].tags[3])
    end)

    it("should handle passages without tags", function()
      local twee = [=[
:: Start
Content
]=]

      local result = parser.parse(twee)

      assert.is_not_nil(result.passages[1].tags)
      assert.equals(0, #result.passages[1].tags)
    end)

    it("should handle empty tag brackets", function()
      local twee = [=[
:: Start []
Content
]=]

      local result = parser.parse(twee)

      assert.equals(0, #result.passages[1].tags)
    end)
  end)

  describe("Content Parsing", function()
    it("should preserve multiline content", function()
      local twee = [=[
:: Start
Line 1
Line 2
Line 3
]=]

      local result = parser.parse(twee)

      assert.matches("Line 1", result.passages[1].content)
      assert.matches("Line 2", result.passages[1].content)
      assert.matches("Line 3", result.passages[1].content)
    end)

    it("should preserve Harlowe macros", function()
      local twee = [=[
:: Start
(set: $var to 5)
You have $var gold.
]=]

      local result = parser.parse(twee)

      assert.matches("%(set: %$var to 5%)", result.passages[1].content)
      assert.matches("%$var", result.passages[1].content)
    end)

    it("should preserve links", function()
      local twee = [=[
:: Start
[[Next Passage]]
[[Display->Target]]
]=]

      local result = parser.parse(twee)

      assert.matches("%[%[Next Passage%]%]", result.passages[1].content)
      assert.matches("%[%[Display%->Target%]%]", result.passages[1].content)
    end)

    it("should handle content with :: not at line start", function()
      local twee = [=[
:: Start
This :: is not a passage marker
Neither is this: :: test
]=]

      local result = parser.parse(twee)

      assert.equals(1, #result.passages)
      assert.matches("This :: is not a passage marker", result.passages[1].content)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle empty input", function()
      local result = parser.parse("")

      assert.is_not_nil(result)
      assert.equals(0, #result.passages)
    end)

    it("should handle text before first passage", function()
      local twee = [=[
This is ignored text
:: Start
Content
]=]

      local result = parser.parse(twee)

      assert.equals(1, #result.passages)
      assert.equals("Start", result.passages[1].name)
    end)

    it("should handle passages with special characters in names", function()
      local twee = [=[
:: Test-Passage_123
Content
]=]

      local result = parser.parse(twee)

      assert.equals("Test-Passage_123", result.passages[1].name)
    end)

    it("should handle consecutive empty lines", function()
      local twee = [=[
:: Start


Content with gaps


More content
]=]

      local result = parser.parse(twee)

      assert.equals(1, #result.passages)
      assert.matches("Content with gaps", result.passages[1].content)
      assert.matches("More content", result.passages[1].content)
    end)

    it("should handle passage names with special characters", function()
      local twee = [=[
:: Test-Passage_2 [tag1 tag2]
Content
]=]

      local result = parser.parse(twee)

      assert.equals("Test-Passage_2", result.passages[1].name)
      assert.equals(2, #result.passages[1].tags)
      assert.equals("tag1", result.passages[1].tags[1])
      assert.equals("tag2", result.passages[1].tags[2])
    end)
  end)

  describe("Complex Stories", function()
    it("should parse complete story with metadata", function()
      local twee = [=[
:: StoryTitle
My Adventure

:: StoryData
{
  "ifid": "12345"
}

:: Start [intro]
(set: $health to 100)
Welcome to the game!

[[Begin->Chapter1]]

:: Chapter1
The adventure begins...
]=]

      local result = parser.parse(twee)

      assert.equals(4, #result.passages)

      -- Find specific passages
      local start_passage = nil
      for _, p in ipairs(result.passages) do
        if p.name == "Start" then
          start_passage = p
          break
        end
      end

      assert.is_not_nil(start_passage)
      assert.equals(1, #start_passage.tags)
      assert.equals("intro", start_passage.tags[1])
    end)

    it("should handle passages with complex macros", function()
      local twee = [=[
:: Start
(if: $x > 10)[
  You have lots!
](else:)[
  You have few.
]

(for: each _item, ...$inventory)[
  - _item
]
]=]

      local result = parser.parse(twee)

      assert.equals(1, #result.passages)
      assert.matches("%(if:", result.passages[1].content)
      assert.matches("%(for:", result.passages[1].content)
    end)
  end)
end)
