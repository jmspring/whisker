local helper = require("tests.test_helper")
local CompactConverter = require("src.format.compact_converter")

describe("Compact Format Converter", function()

  -- Test data creators
  local function create_verbose_story()
    return {
      format = "whisker",
      formatVersion = "1.0",
      metadata = {
        title = "Test Story",
        name = "Test Story",
        ifid = "TEST-001",
        author = "Test Author",
        created = "2025-01-01T00:00:00",
        modified = "2025-01-01T00:00:00",
        description = "A test story",
        format = "whisker",
        format_version = "1.0",
        version = "1.0"
      },
      assets = {},
      scripts = {},
      stylesheets = {},
      variables = {},
      passages = {
        {
          id = "start",
          name = "Start",
          pid = "p1",
          content = "Welcome to the test story.",
          text = "Welcome to the test story.",
          metadata = {},
          tags = {},
          position = {x = 0, y = 0},
          size = {width = 100, height = 100},
          choices = {
            {
              text = "Go to room",
              target_passage = "room",
              metadata = {}
            }
          }
        },
        {
          id = "room",
          name = "Room",
          pid = "p2",
          content = "You are in a room.",
          text = "You are in a room.",
          metadata = {},
          tags = {},
          position = {x = 0, y = 0},
          size = {width = 100, height = 100},
          choices = {}
        }
      },
      settings = {
        autoSave = true,
        scriptingLanguage = "lua",
        startPassage = "start",
        theme = "default",
        undoLimit = 50
      }
    }
  end

  local function create_compact_story()
    return {
      format = "whisker",
      formatVersion = "2.0",
      metadata = {
        title = "Test Story",
        ifid = "TEST-001",
        author = "Test Author",
        created = "2025-01-01T00:00:00",
        modified = "2025-01-01T00:00:00",
        description = "A test story"
      },
      passages = {
        {
          id = "start",
          name = "Start",
          pid = "p1",
          text = "Welcome to the test story.",
          choices = {
            {
              text = "Go to room",
              target = "room"
            }
          }
        },
        {
          id = "room",
          name = "Room",
          pid = "p2",
          text = "You are in a room."
        }
      },
      settings = {
        autoSave = true,
        scriptingLanguage = "lua",
        startPassage = "start",
        theme = "default",
        undoLimit = 50
      }
    }
  end

  local function create_verbose_story_with_non_defaults()
    return {
      format = "whisker",
      formatVersion = "1.0",
      metadata = {
        title = "Custom Story",
        ifid = "CUSTOM-001",
        author = "Custom Author"
      },
      assets = {"asset1.png"},
      passages = {
        {
          id = "start",
          name = "Start",
          pid = "p1",
          text = "Start here",
          content = "Start here",
          tags = {"important", "start"},
          metadata = {"key", "value"},
          position = {x = 100, y = 200},
          size = {width = 150, height = 200},
          choices = {}
        }
      },
      settings = {
        startPassage = "start"
      }
    }
  end

  describe("Converter Instance", function()
    it("should create converter instance", function()
      local converter = CompactConverter.new()
      assert.is_not_nil(converter)
    end)
  end)

  describe("Verbose to Compact Conversion", function()
    it("should convert verbose to compact - basic", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.is_nil(err)
      assert.is_not_nil(compact)
      assert.equals("2.0", compact.formatVersion)
    end)

    it("should remove duplicate text field", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.is_not_nil(compact.passages[1].text)
      assert.is_nil(compact.passages[1].content)
    end)

    it("should remove empty arrays", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.is_nil(compact.assets)
      assert.is_nil(compact.scripts)
      assert.is_nil(compact.stylesheets)
      assert.is_nil(compact.variables)
      assert.is_nil(compact.passages[1].tags)
      assert.is_nil(compact.passages[1].metadata)
    end)

    it("should remove default position", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.is_nil(compact.passages[1].position)
    end)

    it("should remove default size", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.is_nil(compact.passages[1].size)
    end)

    it("should shorten choice field names", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.is_not_nil(compact.passages[1].choices[1].target)
      assert.equals("room", compact.passages[1].choices[1].target)
    end)

    it("should remove duplicate metadata fields", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()
      local compact, err = converter:to_compact(verbose)

      assert.equals("Test Story", compact.metadata.title)
      assert.is_nil(compact.metadata.name)
      assert.is_nil(compact.metadata.format)
      assert.is_nil(compact.metadata.format_version)
    end)

    it("should preserve non-empty arrays", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story_with_non_defaults()
      local compact, err = converter:to_compact(verbose)

      assert.is_not_nil(compact.assets)
      assert.equals(1, #compact.assets)
      assert.is_not_nil(compact.passages[1].tags)
      assert.equals(2, #compact.passages[1].tags)
    end)

    it("should preserve non-default position", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story_with_non_defaults()
      local compact, err = converter:to_compact(verbose)

      assert.is_not_nil(compact.passages[1].position)
      assert.equals(100, compact.passages[1].position.x)
      assert.equals(200, compact.passages[1].position.y)
    end)

    it("should preserve non-default size", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story_with_non_defaults()
      local compact, err = converter:to_compact(verbose)

      assert.is_not_nil(compact.passages[1].size)
      assert.equals(150, compact.passages[1].size.width)
      assert.equals(200, compact.passages[1].size.height)
    end)
  end)

  describe("Compact to Verbose Conversion", function()
    it("should convert compact to verbose - basic", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.is_nil(err)
      assert.is_not_nil(verbose)
      assert.equals("1.0", verbose.formatVersion)
    end)

    it("should restore duplicate text field", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.is_not_nil(verbose.passages[1].text)
      assert.is_not_nil(verbose.passages[1].content)
      assert.equals(verbose.passages[1].text, verbose.passages[1].content)
    end)

    it("should restore empty arrays", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.is_not_nil(verbose.assets)
      assert.equals(0, #verbose.assets)
      assert.is_not_nil(verbose.passages[1].metadata)
      assert.equals(0, #verbose.passages[1].metadata)
    end)

    it("should restore default position", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.is_not_nil(verbose.passages[1].position)
      assert.equals(0, verbose.passages[1].position.x)
      assert.equals(0, verbose.passages[1].position.y)
    end)

    it("should restore default size", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.is_not_nil(verbose.passages[1].size)
      assert.equals(100, verbose.passages[1].size.width)
      assert.equals(100, verbose.passages[1].size.height)
    end)

    it("should restore full choice field names", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.is_not_nil(verbose.passages[1].choices[1].target_passage)
      assert.equals("room", verbose.passages[1].choices[1].target_passage)
    end)

    it("should restore duplicate metadata fields", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()
      local verbose, err = converter:to_verbose(compact)

      assert.equals("Test Story", verbose.metadata.title)
      assert.equals("Test Story", verbose.metadata.name)
      assert.equals("whisker", verbose.metadata.format)
      assert.equals("1.0", verbose.metadata.format_version)
    end)
  end)

  describe("Round-Trip Tests", function()
    it("should preserve data in verbose → compact → verbose", function()
      local converter = CompactConverter.new()
      local original = create_verbose_story()

      local compact, err = converter:to_compact(original)
      assert.is_nil(err)

      local restored, err = converter:to_verbose(compact)
      assert.is_nil(err)

      assert.equals(#original.passages, #restored.passages)
      assert.equals(original.passages[1].id, restored.passages[1].id)
      assert.equals(original.passages[1].name, restored.passages[1].name)
      assert.equals(original.passages[1].text, restored.passages[1].text)
      assert.equals(#original.passages[1].choices, #restored.passages[1].choices)
      assert.equals(original.passages[1].choices[1].text, restored.passages[1].choices[1].text)
    end)

    it("should preserve data in compact → verbose → compact", function()
      local converter = CompactConverter.new()
      local original = create_compact_story()

      local verbose, err = converter:to_verbose(original)
      assert.is_nil(err)

      local restored, err = converter:to_compact(verbose)
      assert.is_nil(err)

      assert.equals(#original.passages, #restored.passages)
      assert.equals(original.passages[1].id, restored.passages[1].id)
      assert.equals(original.passages[1].name, restored.passages[1].name)
      assert.equals(original.passages[1].text, restored.passages[1].text)
      assert.is_nil(restored.passages[1].position)
      assert.is_nil(restored.passages[1].size)
    end)

    it("should validate round-trip helper function", function()
      local converter = CompactConverter.new()
      local original = create_verbose_story()

      local success, err = converter:validate_round_trip(original)
      assert.is_true(success, err)
    end)
  end)

  describe("Utility Functions", function()
    it("should get format version - verbose", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()

      local version = converter:get_format_version(verbose)
      assert.equals("1.0", version)
    end)

    it("should get format version - compact", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()

      local version = converter:get_format_version(compact)
      assert.equals("2.0", version)
    end)

    it("should detect compact format with is_compact", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()

      assert.is_true(converter:is_compact(compact))
    end)

    it("should detect non-compact format with is_compact", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()

      assert.is_false(converter:is_compact(verbose))
    end)

    it("should detect verbose format with is_verbose", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()

      assert.is_true(converter:is_verbose(verbose))
    end)

    it("should detect non-verbose format with is_verbose", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()

      assert.is_false(converter:is_verbose(compact))
    end)

    it("should return unchanged when converting already compact document", function()
      local converter = CompactConverter.new()
      local compact = create_compact_story()

      local result, err = converter:to_compact(compact)
      assert.is_nil(err)
      assert.equals("2.0", result.formatVersion)
    end)

    it("should return unchanged when converting already verbose document", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()

      local result, err = converter:to_verbose(verbose)
      assert.is_nil(err)
      assert.equals("1.0", result.formatVersion)
    end)
  end)

  describe("Edge Cases", function()
    it("should handle empty passage list", function()
      local converter = CompactConverter.new()
      local doc = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {title = "Empty", ifid = "EMPTY-001"},
        passages = {},
        settings = {}
      }

      local compact, err = converter:to_compact(doc)
      assert.is_nil(err)
      assert.equals(0, #compact.passages)
    end)

    it("should handle passage with no choices", function()
      local converter = CompactConverter.new()
      local verbose = create_verbose_story()

      local compact, err = converter:to_compact(verbose)
      assert.is_nil(err)
      assert.is_nil(compact.passages[2].choices)
    end)

    it("should handle nil metadata gracefully", function()
      local converter = CompactConverter.new()
      local doc = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = nil,
        passages = {},
        settings = {}
      }

      local compact, err = converter:to_compact(doc)
      assert.is_nil(err)
      assert.is_not_nil(compact.metadata)
    end)
  end)
end)
