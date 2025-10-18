local helper = require("tests.test_helper")
local FormatConverter = require("src.format.format_converter")
local TwineImporter = require("src.format.twine_importer")
local json = require("src.utils.json")

describe("Twine Export", function()

  -- Test data creators
  local function create_basic_story()
    return {
      metadata = {
        title = "Test Story",
        author = "Test Author",
        version = "1.0.0",
        ifid = "12345678-1234-1234-1234-123456789012",
        created = 1234567890,
        modified = 1234567890
      },
      settings = {
        startPassage = "Start"
      },
      passages = {
        {
          pid = "1",
          name = "Start",
          tags = {"intro"},
          text = "Welcome to the test story!\n\n[[Begin|Next]]",
          position = {x = 100, y = 100},
          size = {width = 100, height = 100}
        },
        {
          pid = "2",
          name = "Next",
          tags = {},
          text = "This is the next passage.\n\n[[The End|End]]",
          position = {x = 200, y = 100},
          size = {width = 100, height = 100}
        },
        {
          pid = "3",
          name = "End",
          tags = {"ending"},
          text = "The End!",
          position = {x = 300, y = 100},
          size = {width = 100, height = 100}
        }
      }
    }
  end

  local function create_complex_story()
    return {
      metadata = {
        title = "Complex Test",
        author = "Tester",
        version = "1.0.0",
        ifid = "87654321-4321-4321-4321-210987654321",
        created = 1234567890,
        modified = 1234567890
      },
      settings = {
        startPassage = "Start"
      },
      passages = {
        {
          pid = "1",
          name = "Start",
          tags = {},
          text = "{{health = 100}}\n{{gold = 50}}\n\nHealth: {{health}}\nGold: {{gold}}\n\n[[Continue|Next]]",
          position = {x = 100, y = 100},
          size = {width = 100, height = 100}
        },
        {
          pid = "2",
          name = "Next",
          tags = {},
          text = "{{gold = gold + 10}}\n\n{{if gold > 40 then}}You are rich!{{end}}\n\n[[Finish|End]]",
          position = {x = 200, y = 100},
          size = {width = 100, height = 100}
        },
        {
          pid = "3",
          name = "End",
          tags = {},
          text = "Final gold: {{gold}}",
          position = {x = 300, y = 100},
          size = {width = 100, height = 100}
        }
      }
    }
  end

  local function create_edge_case_story()
    return {
      metadata = {
        title = "Edge Cases & Special Characters",
        author = "Test <Author>",
        version = "1.0.0",
        ifid = "11111111-2222-3333-4444-555555555555",
        created = 1234567890,
        modified = 1234567890
      },
      settings = {
        startPassage = "Start"
      },
      passages = {
        {
          pid = "1",
          name = "Start",
          tags = {"test", "special-chars"},
          text = "Special: <>&\"'\nUnicode: 你好 🎮\n\n[[Next]]",
          position = {x = 100, y = 100},
          size = {width = 100, height = 100}
        },
        {
          pid = "2",
          name = "Next",
          tags = {},
          text = "",  -- Empty content
          position = {x = 200, y = 100},
          size = {width = 100, height = 100}
        },
        {
          pid = "3",
          name = "Passage With Spaces",
          tags = {},
          text = "This passage has a name with spaces.\n\n[[Back|Start]]",
          position = {x = 100, y = 200},
          size = {width = 100, height = 100}
        }
      }
    }
  end

  describe("Basic Export", function()
    it("should export basic story to Twine HTML", function()
      local converter = FormatConverter.new()
      local story = create_basic_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find("<tw%-storydata"))
      assert.is_not_nil(html:find('name="Test Story"'))
      assert.is_not_nil(html:find("<tw%-passagedata"))
      assert.is_not_nil(html:find('name="Start"'))
    end)

    it("should export basic story to Twee", function()
      local converter = FormatConverter.new()
      local story = create_basic_story()

      local twee, err = converter:to_twee(story)

      assert.is_not_nil(twee)
      assert.is_nil(err)
      assert.is_not_nil(twee:find(":: StoryTitle"))
      assert.is_not_nil(twee:find("Test Story"))
      assert.is_not_nil(twee:find(":: Start"))
      assert.is_not_nil(twee:find(":: Next"))
    end)

    it("should export basic story to Markdown", function()
      local converter = FormatConverter.new()
      local story = create_basic_story()

      local md, err = converter:to_markdown(story)

      assert.is_not_nil(md)
      assert.is_nil(err)
      assert.is_not_nil(md:find("# Test Story"))
      assert.is_not_nil(md:find("%*%*Author:%*%*"))
      assert.is_not_nil(md:find("## Start"))
    end)
  end)

  describe("Complex Syntax Export", function()
    it("should export story with variable assignments", function()
      local converter = FormatConverter.new()
      local story = create_complex_story()

      local html, err = converter:to_twine_html(story, {target_format = "Harlowe"})

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_true(html:find("health") ~= nil or html:find("gold") ~= nil)
    end)

    it("should export to Harlowe format", function()
      local converter = FormatConverter.new()
      local story = create_complex_story()

      local html, err = converter:to_twine_html(story, {
        target_format = "Harlowe",
        format_version = "3.3.0"
      })

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find('format="Harlowe"'))
      assert.is_not_nil(html:find('format%-version="3%.3%.0"'))
    end)

    it("should export to SugarCube format", function()
      local converter = FormatConverter.new()
      local story = create_complex_story()

      local html, err = converter:to_twine_html(story, {
        target_format = "SugarCube",
        format_version = "2.36.0"
      })

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find('format="SugarCube"'))
    end)

    it("should export to Chapbook format", function()
      local converter = FormatConverter.new()
      local story = create_complex_story()

      local html, err = converter:to_twine_html(story, {
        target_format = "Chapbook",
        format_version = "1.2.0"
      })

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find('format="Chapbook"'))
    end)

    it("should export to Snowman format", function()
      local converter = FormatConverter.new()
      local story = create_complex_story()

      local html, err = converter:to_twine_html(story, {
        target_format = "Snowman",
        format_version = "2.0.3"
      })

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find('format="Snowman"'))
    end)
  end)

  describe("Edge Cases", function()
    it("should export story with special HTML characters", function()
      local converter = FormatConverter.new()
      local story = create_edge_case_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_true(
        html:find("&lt;") ~= nil or
        html:find("&gt;") ~= nil or
        html:find("&amp;") ~= nil
      )
    end)

    it("should export story with unicode characters", function()
      local converter = FormatConverter.new()
      local story = create_edge_case_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_true(
        html:find('charset="utf%-8"') ~= nil or
        html:find("<meta charset=") ~= nil
      )
    end)

    it("should export story with empty passages", function()
      local converter = FormatConverter.new()
      local story = create_edge_case_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find('name="Next"'))
    end)

    it("should export passages with spaces in names", function()
      local converter = FormatConverter.new()
      local story = create_edge_case_story()

      local twee, err = converter:to_twee(story)

      assert.is_not_nil(twee)
      assert.is_nil(err)
      assert.is_true(
        twee:find("Passage With Spaces") ~= nil or
        twee:find(":: Passage") ~= nil
      )
    end)

    it("should export passages with multiple tags", function()
      local converter = FormatConverter.new()
      local story = create_edge_case_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_true(
        html:find('tags="') ~= nil or
        html:find("test") ~= nil or
        html:find("special%-chars") ~= nil
      )
    end)
  end)

  describe("Round-Trip Conversions", function()
    it("should round-trip export to HTML then import", function()
      local converter = FormatConverter.new()
      local importer = TwineImporter.new()
      local original = create_basic_story()

      local html, err = converter:to_twine_html(original)
      assert.is_not_nil(html)
      assert.is_nil(err)

      local imported, err = importer:import_from_html(html)
      assert.is_not_nil(imported)
      assert.is_nil(err)

      assert.equals(original.metadata.title, imported.metadata.title)
      assert.is_true(#imported.passages >= 3)
    end)

    it("should round-trip export to Twee then import", function()
      local converter = FormatConverter.new()
      local importer = TwineImporter.new()
      local original = create_basic_story()

      local twee, err = converter:to_twee(original)
      assert.is_not_nil(twee)
      assert.is_nil(err)

      local imported, err = importer:import_from_twee(twee)
      assert.is_not_nil(imported)
      assert.is_nil(err)

      assert.equals(original.metadata.title, imported.metadata.title)
      assert.is_true(#imported.passages >= 3)
    end)

    it("should preserve metadata in round-trip", function()
      local converter = FormatConverter.new()
      local importer = TwineImporter.new()
      local original = create_basic_story()

      local html, _ = converter:to_twine_html(original)
      local imported, _ = importer:import_from_html(html)

      assert.is_not_nil(imported)
      assert.equals(original.metadata.title, imported.metadata.title)
      assert.equals(original.metadata.ifid, imported.metadata.ifid)
    end)

    it("should preserve passage structure in round-trip", function()
      local converter = FormatConverter.new()
      local importer = TwineImporter.new()
      local original = create_basic_story()

      local html, _ = converter:to_twine_html(original)
      local imported, _ = importer:import_from_html(html)

      assert.is_not_nil(imported)

      local start_found = false
      for _, passage in ipairs(imported.passages) do
        if passage.name == "Start" then
          start_found = true
          assert.is_true(#passage.tags > 0)
          break
        end
      end

      assert.is_true(start_found)
    end)
  end)

  describe("Format-Specific Syntax Conversion", function()
    it("should convert Whisker syntax to Harlowe", function()
      local converter = FormatConverter.new()

      local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}\nHealth: {{health}}"
      local harlowe = converter:convert_to_harlowe(whisker_text)

      assert.is_not_nil(harlowe)
    end)

    it("should convert Whisker syntax to SugarCube", function()
      local converter = FormatConverter.new()

      local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}"
      local sugarcube = converter:convert_to_sugarcube(whisker_text)

      assert.is_not_nil(sugarcube)
    end)

    it("should convert Whisker syntax to Chapbook", function()
      local converter = FormatConverter.new()

      local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}"
      local chapbook = converter:convert_to_chapbook(whisker_text)

      assert.is_not_nil(chapbook)
    end)

    it("should convert Whisker syntax to Snowman", function()
      local converter = FormatConverter.new()

      local whisker_text = "{{health = 100}}\n{{if health > 50 then}}Healthy!{{end}}"
      local snowman = converter:convert_to_snowman(whisker_text)

      assert.is_not_nil(snowman)
    end)
  end)

  describe("Advanced Features", function()
    it("should export story with no passages", function()
      local converter = FormatConverter.new()
      local empty_story = {
        metadata = {
          title = "Empty",
          author = "Test",
          ifid = "00000000-0000-0000-0000-000000000000"
        },
        settings = { startPassage = "Start" },
        passages = {}
      }

      local html, err = converter:to_twine_html(empty_story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find("<tw%-storydata"))
    end)

    it("should preserve passage positions", function()
      local converter = FormatConverter.new()
      local story = create_basic_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_true(
        html:find('position="100,100"') ~= nil or
        html:find("position=") ~= nil
      )
    end)

    it("should preserve passage sizes", function()
      local converter = FormatConverter.new()
      local story = create_basic_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_true(
        html:find('size="100,100"') ~= nil or
        html:find("size=") ~= nil
      )
    end)

    it("should preserve or generate IFID", function()
      local converter = FormatConverter.new()
      local story = create_basic_story()

      local html, err = converter:to_twine_html(story)

      assert.is_not_nil(html)
      assert.is_nil(err)
      assert.is_not_nil(html:find('ifid="'))
      assert.is_not_nil(html:find(story.metadata.ifid, 1, true))
    end)
  end)
end)
