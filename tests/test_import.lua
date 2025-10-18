local helper = require("tests.test_helper")
local TwineImporter = require("src.format.twine_importer")
local FormatConverter = require("src.format.format_converter")
local json = require("src.utils.json")

describe("Twine Import", function()

  -- Sample Twine HTML (Harlowe format)
  local sample_twine_html = [=[
<tw-storydata name="Test Story" startnode="1" creator="Twine"
              creator-version="2.6.0" ifid="12345678-1234-1234-1234-123456789012"
              zoom="1" format="Harlowe" format-version="3.3.0">
  <style role="stylesheet" id="twine-user-stylesheet" type="text/twine-css">
    tw-story { font-family: Georgia; }
  </style>

  <tw-passagedata pid="1" name="Start" tags="intro" position="100,100">
    Welcome to the test story!

    (set: $playerName to "Hero")
    (set: $health to 100)

    [[Begin Adventure->Forest]]
  </tw-passagedata>

  <tw-passagedata pid="2" name="Forest" tags="location" position="300,100">
    You are in a dark forest.

    (if: $health > 50)[
      You feel strong.
    ]

    [[Go North->Cave]]
  </tw-passagedata>

  <tw-passagedata pid="3" name="Cave" tags="location danger" position="300,0">
    (set: $foundTreasure to true)
    You found treasure!
    [[Exit->Forest]]
  </tw-passagedata>
</tw-storydata>
]=]

  -- Sample SugarCube format HTML
  local sample_sugarcube_html = [=[
<tw-storydata name="SugarCube Test" startnode="1" creator="Twine"
              format="SugarCube" format-version="2.36.1">
  <tw-passagedata pid="1" name="Start" tags="">
    <<set $count to 0>>
    Hello!
    [[Next]]
  </tw-passagedata>

  <tw-passagedata pid="2" name="Next" tags="">
    <<set $count to $count + 1>>
    Clicked $count times.
  </tw-passagedata>
</tw-storydata>
]=]

  -- Sample Twee format
  local sample_twee = [=[
:: StoryTitle
Twee Test Story

:: StoryData
{
  "ifid": "D674C58C-DEFA-4F70-B7A2-27742230C0FC"
}

:: Start
This is the start passage.
[[Second]]

:: Second
This is the second passage.
[[back->Start]]
]=]

  describe("Twine HTML Import", function()
    it("should import Harlowe format HTML", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_twine_html)

      assert.is_nil(err)
      assert.is_not_nil(story)
      assert.is_not_nil(story.metadata)
      assert.equals("Test Story", story.metadata.title)
      assert.equals("whisker", story.format)
      assert.is_not_nil(story.settings)
      assert.equals("Start", story.settings.startPassage)
    end)

    it("should import multiple passages", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_twine_html)

      assert.is_true(#story.passages >= 3)
    end)

    it("should find Start passage with correct metadata", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_twine_html)

      local start_passage = nil
      for _, passage in ipairs(story.passages) do
        if passage.name == "Start" then
          start_passage = passage
          break
        end
      end

      assert.is_not_nil(start_passage)
      assert.is_true(#start_passage.tags > 0)
      assert.equals("intro", start_passage.tags[1])
    end)

    it("should import SugarCube format", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_sugarcube_html)

      assert.is_nil(err)
      assert.is_not_nil(story)
      assert.equals("SugarCube Test", story.metadata.title)
      assert.equals("whisker", story.format)
    end)

    it("should handle invalid HTML gracefully", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html("<invalid>Not a Twine story</invalid>")

      assert.is_nil(story)
      assert.is_not_nil(err)
    end)
  end)

  describe("Syntax Conversion", function()
    describe("Harlowe", function()
      it("should convert (set:) macro", function()
        local importer = TwineImporter.new()
        local text = "(set: $health to 100)"

        local converted = importer:convert_passage_text(text, TwineImporter.SupportedFormats.HARLOWE)

        assert.is_not_nil(converted:find("{{health = 100}}"))
      end)

      it("should convert (if:) macro", function()
        local importer = TwineImporter.new()
        local text = "(if: $health > 50)[You feel strong]"

        local converted = importer:convert_passage_text(text, TwineImporter.SupportedFormats.HARLOWE)

        assert.is_not_nil(converted:find("{{if"))
      end)

      it("should convert (print:) macro", function()
        local importer = TwineImporter.new()
        local text = "(print: $playerName)"

        local converted = importer:convert_passage_text(text, TwineImporter.SupportedFormats.HARLOWE)

        assert.is_not_nil(converted:find("{{playerName}}"))
      end)
    end)

    describe("SugarCube", function()
      it("should convert <<set>> macro", function()
        local importer = TwineImporter.new()
        local text = "<<set $count to 5>>"

        local converted = importer:convert_passage_text(text, TwineImporter.SupportedFormats.SUGARCUBE)

        assert.is_not_nil(converted:find("{{count = 5}}"))
      end)

      it("should convert $var references", function()
        local importer = TwineImporter.new()
        local text = "<<if $count > 2>>High<<endif>>"

        local converted = importer:convert_passage_text(text, TwineImporter.SupportedFormats.SUGARCUBE)

        assert.is_not_nil(converted:find("{{count}}"))
      end)
    end)
  end)

  describe("Link Extraction", function()
    it("should extract links from text", function()
      local importer = TwineImporter.new()
      local text = "You can go [[North->Cave]] or [[South->Village]]."

      local links = importer:extract_links(text)

      assert.equals(2, #links)
      assert.equals("North", links[1].text)
      assert.equals("Cave", links[1].target)
      assert.equals("South", links[2].text)
      assert.equals("Village", links[2].target)
    end)
  end)

  describe("Variable Extraction", function()
    it("should extract variables from Harlowe syntax", function()
      local importer = TwineImporter.new()
      local text = "(set: $health to 100)(set: $mana to 50)(print: $name)"

      local variables = importer:extract_variables(text)

      assert.is_true(#variables >= 3)

      local has_health = false
      local has_mana = false
      local has_name = false

      for _, var in ipairs(variables) do
        if var == "health" then has_health = true end
        if var == "mana" then has_mana = true end
        if var == "name" then has_name = true end
      end

      assert.is_true(has_health)
      assert.is_true(has_mana)
      assert.is_true(has_name)
    end)
  end)

  describe("Twee Format Import", function()
    it("should import Twee format", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_twee(sample_twee)

      assert.is_nil(err)
      assert.is_not_nil(story)
      assert.is_not_nil(story.metadata)
      assert.equals("Twee Test Story", story.metadata.title)
      assert.is_true(#story.passages >= 2)
    end)
  end)

  describe("Passage Metadata", function()
    it("should parse passage tags", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_twine_html)

      local forest_passage = nil
      for _, passage in ipairs(story.passages) do
        if passage.name == "Forest" then
          forest_passage = passage
          break
        end
      end

      assert.is_not_nil(forest_passage)
      assert.is_true(#forest_passage.tags > 0)

      local has_location_tag = false
      for _, tag in ipairs(forest_passage.tags) do
        if tag == "location" then
          has_location_tag = true
          break
        end
      end

      assert.is_true(has_location_tag)
    end)

    it("should preserve position data", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_twine_html)

      local start_passage = nil
      for _, passage in ipairs(story.passages) do
        if passage.name == "Start" then
          start_passage = passage
          break
        end
      end

      assert.is_not_nil(start_passage)
      if start_passage.position then
        assert.is_not_nil(start_passage.position.x)
        assert.is_not_nil(start_passage.position.y)
      end
    end)
  end)

  describe("Format Converter Integration", function()
    it("should convert Twine HTML to JSON via FormatConverter", function()
      local converter = FormatConverter.new()
      local story, err = converter:convert(
        sample_twine_html,
        FormatConverter.FormatType.TWINE_HTML,
        FormatConverter.FormatType.JSON
      )

      assert.is_nil(err)
      assert.is_not_nil(story)

      local story_data = json.decode(story)
      assert.is_not_nil(story_data)
      assert.is_not_nil(story_data.metadata)
      assert.is_not_nil(story_data.metadata.title)
      assert.is_not_nil(story_data.passages)
    end)

    it("should support round-trip through JSON", function()
      local importer = TwineImporter.new()
      local story, err = importer:import_from_html(sample_twine_html)
      assert.is_not_nil(story)

      local json_str = json.encode(story)
      assert.is_not_nil(json_str)

      local decoded = json.decode(json_str)
      assert.is_not_nil(decoded)
      assert.is_not_nil(decoded.metadata)
      assert.equals(story.metadata.title, decoded.metadata.title)
    end)
  end)
end)
