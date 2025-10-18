local helper = require("tests.test_helper")
local parser = require("src.format.parsers.sugarcube")

describe("SugarCube Parser", function()

  describe("Basic Parsing", function()
    it("should parse simple SugarCube passage", function()
      local twee = [=[
:: Start
<<set $name to "Hero">>
Welcome, $name!
]=]

      local result = parser.parse(twee)

      assert.is_not_nil(result)
      assert.equals(1, #result.passages)
      assert.equals("Start", result.passages[1].name)
      assert.matches("<<set", result.passages[1].content)
    end)

    it("should parse multiple passages with SugarCube syntax", function()
      local twee = [=[
:: Start
<<set $gold to 100>>
You have $gold gold.

[[Shop]]

:: Shop
<<if $gold >= 50>>
  [[Buy Item]]
<</if>>
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)
      assert.matches("<<set", result.passages[1].content)
      assert.matches("<<if", result.passages[2].content)
    end)
  end)

  describe("SugarCube-Specific Content", function()
    it("should preserve SugarCube macros", function()
      local twee = [=[
:: Test
<<set $x to 5>>
<<if $x > 3>>High<</if>>
<<for $i to 0; $i lt 10; $i++>>
  Item $i
<</for>>
]=]

      local result = parser.parse(twee)

      assert.matches("<<set %$x to 5>>", result.passages[1].content)
      assert.matches("<<if", result.passages[1].content)
      assert.matches("<<for", result.passages[1].content)
    end)

    it("should preserve SugarCube link syntax", function()
      local twee = [=[
:: Start
[[Next Passage]]
[[Display Text|Target]]
<<link "Click" "Destination">><</link>>
]=]

      local result = parser.parse(twee)

      assert.matches("%[%[Next Passage%]%]", result.passages[1].content)
      assert.matches("%[%[Display Text%|Target%]%]", result.passages[1].content)
      assert.matches("<<link", result.passages[1].content)
    end)

    it("should handle SugarCube variables", function()
      local twee = [=[
:: Start
Story variable: $storyVar
Temporary variable: _tempVar
<<print $storyVar>>
]=]

      local result = parser.parse(twee)

      assert.matches("%$storyVar", result.passages[1].content)
      assert.matches("_tempVar", result.passages[1].content)
      assert.matches("<<print", result.passages[1].content)
    end)
  end)

  describe("Tags", function()
    it("should parse SugarCube special tags", function()
      local twee = [=[
:: StoryInit [script]
<<set $health to 100>>

:: Sidebar [nobr]
Status bar
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)

      local story_init = result.passages[1]
      assert.equals("StoryInit", story_init.name)
      assert.equals(1, #story_init.tags)
      assert.equals("script", story_init.tags[1])

      local sidebar = result.passages[2]
      assert.equals(1, #sidebar.tags)
      assert.equals("nobr", sidebar.tags[1])
    end)
  end)

  describe("Complex Content", function()
    it("should handle nested macros", function()
      local twee = [=[
:: Test
<<if $x > 5>>
  <<set $y to 10>>
  <<if $y > 8>>
    Nested condition
  <</if>>
<</if>>
]=]

      local result = parser.parse(twee)

      assert.matches("<<if %$x > 5>>", result.passages[1].content)
      assert.matches("<<set %$y to 10>>", result.passages[1].content)
      assert.matches("Nested condition", result.passages[1].content)
    end)

    it("should preserve widget definitions", function()
      local twee = [=[
:: Widgets [widget]
<<widget "healthbar">>
  Health: <<print $health>>
<</widget>>
]=]

      local result = parser.parse(twee)

      assert.equals(1, #result.passages[1].tags)
      assert.equals("widget", result.passages[1].tags[1])
      assert.matches("<<widget", result.passages[1].content)
    end)
  end)
end)
