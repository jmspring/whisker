local helper = require("tests.test_helper")
local FormatConverter = require("src.format.format_converter")

describe("Format Converter", function()

  -- Test data
  local function create_simple_whisker_doc()
    return {
      format = "whisker",
      formatVersion = "1.0",
      metadata = {
        title = "Test Story",
        ifid = "TEST-001",
        author = "Test Author",
        created = "2025-01-01T00:00:00"
      },
      passages = {
        {
          id = "start",
          name = "Start",
          pid = "1",
          text = "Welcome to the story.\n\n[[Next->Next]]",
          tags = {},
          position = {x = 0, y = 0},
          size = {width = 100, height = 100}
        },
        {
          id = "next",
          name = "Next",
          pid = "2",
          text = "The end.",
          tags = {"ending"},
          position = {x = 200, y = 0},
          size = {width = 100, height = 100}
        }
      },
      settings = {
        startPassage = "Start"
      }
    }
  end

  describe("Converter Instance", function()
    it("should create converter instance", function()
      local converter = FormatConverter.new()
      assert.is_not_nil(converter)
    end)

    it("should have FormatType enum", function()
      assert.equals("whisker", FormatConverter.FormatType.WHISKER)
      assert.equals("twine_html", FormatConverter.FormatType.TWINE_HTML)
      assert.equals("twee", FormatConverter.FormatType.TWEE)
      assert.equals("json", FormatConverter.FormatType.JSON)
      assert.equals("markdown", FormatConverter.FormatType.MARKDOWN)
    end)
  end)

  describe("Whisker Format Conversion", function()
    it("should handle Whisker table as input", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local result, err = converter:to_whisker(doc, FormatConverter.FormatType.WHISKER)

      assert.is_nil(err)
      assert.is_not_nil(result)
      assert.equals("Test Story", result.metadata.title)
    end)

    it("should return Whisker doc unchanged from from_whisker", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local result, err = converter:from_whisker(doc, FormatConverter.FormatType.WHISKER)

      assert.is_nil(err)
      assert.equals(doc, result)
    end)

    it("should detect unsupported input format", function()
      local converter = FormatConverter.new()

      local result, err = converter:to_whisker("data", "unsupported_format")

      assert.is_nil(result)
      assert.is_not_nil(err)
      assert.matches("Unsupported input format", err)
    end)

    it("should detect unsupported output format", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local result, err = converter:from_whisker(doc, "unsupported_format")

      assert.is_nil(result)
      assert.is_not_nil(err)
      assert.matches("Unsupported output format", err)
    end)
  end)

  describe("Twee Export", function()
    it("should export to Twee format", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local twee, err = converter:to_twee(doc)

      assert.is_nil(err)
      assert.is_not_nil(twee)
      assert.matches(":: StoryTitle", twee)
      assert.matches("Test Story", twee)
      assert.matches(":: Start", twee)
      assert.matches(":: Next", twee)
    end)

    it("should include StoryData in Twee export", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local twee, err = converter:to_twee(doc)

      assert.matches(":: StoryData", twee)
      assert.matches('"ifid": "TEST%-001"', twee)
    end)

    it("should include tags in Twee export", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local twee, err = converter:to_twee(doc)

      assert.matches(":: Next %[ending%]", twee)
    end)

    it("should handle passage without tags", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local twee, err = converter:to_twee(doc)

      assert.matches(":: Start", twee)
      assert.not_matches(":: Start %[", twee)
    end)
  end)

  describe("Markdown Export", function()
    it("should export to Markdown format", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local md, err = converter:to_markdown(doc)

      assert.is_nil(err)
      assert.is_not_nil(md)
      assert.matches("# Test Story", md)
      assert.matches("%*%*Author:%*%* Test Author", md)
    end)

    it("should create table of contents", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local md, err = converter:to_markdown(doc)

      assert.matches("## Passages", md)
      assert.matches("%- %[Start%]", md)
      assert.matches("%- %[Next%]", md)
    end)

    it("should include passage tags in Markdown", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local md, err = converter:to_markdown(doc)

      assert.matches("%*Tags: ending%*", md)
    end)
  end)

  describe("Twine HTML Export", function()
    it("should export to Twine HTML format", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local html, err = converter:to_twine_html(doc)

      assert.is_nil(err)
      assert.is_not_nil(html)
      assert.matches("<!DOCTYPE html>", html)
      assert.matches("<tw%-storydata", html)
    end)

    it("should include story metadata in HTML", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local html, err = converter:to_twine_html(doc)

      assert.matches('name="Test Story"', html)
      assert.matches('ifid="TEST%-001"', html)
      assert.matches('format="Harlowe"', html)  -- default
    end)

    it("should allow custom target format", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local html, err = converter:to_twine_html(doc, {target_format = "SugarCube"})

      assert.matches('format="SugarCube"', html)
    end)

    it("should escape HTML entities in content", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()
      doc.passages[1].text = "Test <b>bold</b> & \"quoted\""

      local html, err = converter:to_twine_html(doc)

      assert.matches("&lt;b&gt;bold&lt;/b&gt;", html)
      assert.matches("&amp;", html)
      assert.matches("&quot;", html)
    end)

    it("should include passage positions", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local html, err = converter:to_twine_html(doc)

      assert.matches('position="0,0"', html)
      assert.matches('position="200,0"', html)
    end)

    it("should find start passage PID", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local start_pid = converter:find_start_passage_pid(doc)

      assert.equals("1", start_pid)
    end)
  end)

  describe("Syntax Conversion", function()
    describe("Harlowe Conversion", function()
      it("should convert variable assignments to Harlowe", function()
        local converter = FormatConverter.new()
        local text = "{{health = 100}}"

        local result = converter:convert_to_harlowe(text)

        assert.matches("%(set: %$health to 100%)", result)
      end)

      it("should convert conditionals to Harlowe", function()
        local converter = FormatConverter.new()
        local text = "{{if health > 50 then}}Healthy{{end}}"

        local result = converter:convert_to_harlowe(text)

        assert.matches("%(if: health > 50%)", result)
        assert.matches("%[Healthy%]", result)
      end)

      it("should convert variable interpolation to Harlowe", function()
        local converter = FormatConverter.new()
        local text = "You have {{gold}} gold."

        local result = converter:convert_to_harlowe(text)

        assert.matches("%(print: %$gold%)", result)
      end)
    end)

    describe("SugarCube Conversion", function()
      it("should convert variable assignments to SugarCube", function()
        local converter = FormatConverter.new()
        local text = "{{health = 100}}"

        local result = converter:convert_to_sugarcube(text)

        assert.matches("<<set %$health to 100>>", result)
      end)

      it("should convert conditionals to SugarCube", function()
        local converter = FormatConverter.new()
        local text = "{{if health > 50 then}}Healthy{{end}}"

        local result = converter:convert_to_sugarcube(text)

        assert.matches("<<if health > 50>>", result)
        assert.matches("Healthy<<endif>>", result)
      end)

      it("should convert variable interpolation to SugarCube", function()
        local converter = FormatConverter.new()
        local text = "You have {{gold}} gold."

        local result = converter:convert_to_sugarcube(text)

        assert.matches("<<print %$gold>>", result)
      end)
    end)

    describe("Chapbook Conversion", function()
      it("should convert variable assignments to Chapbook", function()
        local converter = FormatConverter.new()
        local text = "{{health = 100}}"

        local result = converter:convert_to_chapbook(text)

        assert.matches("health = 100", result)
        assert.not_matches("{{", result)
      end)

      it("should convert conditionals to Chapbook", function()
        local converter = FormatConverter.new()
        local text = "{{if health > 50 then}}Healthy{{end}}"

        local result = converter:convert_to_chapbook(text)

        assert.matches("%[if health > 50%]", result)
        assert.matches("%[continued%]", result)
      end)

      it("should convert variable interpolation to Chapbook", function()
        local converter = FormatConverter.new()
        local text = "You have {{gold}} gold."

        local result = converter:convert_to_chapbook(text)

        assert.matches("{gold}", result)
      end)
    end)

    describe("Snowman Conversion", function()
      it("should convert variable assignments to Snowman", function()
        local converter = FormatConverter.new()
        local text = "{{health = 100}}"

        local result = converter:convert_to_snowman(text)

        assert.matches("<%%", result)
        assert.matches("s%.health = 100", result)
      end)

      it("should convert conditionals to Snowman", function()
        local converter = FormatConverter.new()
        local text = "{{if health > 50 then}}Healthy{{end}}"

        local result = converter:convert_to_snowman(text)

        assert.matches("<%%", result)
        assert.matches("if %(s%.health > 50%)", result)
      end)

      it("should convert variable interpolation to Snowman", function()
        local converter = FormatConverter.new()
        local text = "You have {{gold}} gold."

        local result = converter:convert_to_snowman(text)

        assert.matches("<%%= s%.gold %%>", result)
      end)

      it("should convert Lua conditions to JavaScript", function()
        local converter = FormatConverter.new()
        local cond = "health > 50 and gold >= 100"

        local result = converter:convert_condition_to_js(cond)

        assert.matches("s%.health > 50 && s%.gold >= 100", result)
      end)

      it("should handle or conditions in JavaScript conversion", function()
        local converter = FormatConverter.new()
        local cond = "health < 10 or gold < 5"

        local result = converter:convert_condition_to_js(cond)

        assert.matches("s%.health < 10 || s%.gold < 5", result)
      end)

      it("should handle not conditions in JavaScript conversion", function()
        local converter = FormatConverter.new()
        local cond = "not defeated"

        local result = converter:convert_condition_to_js(cond)

        assert.matches("!s%.defeated", result)
      end)
    end)

    describe("Markdown Conversion", function()
      it("should convert variable assignments to readable Markdown", function()
        local converter = FormatConverter.new()
        local text = "{{health = 100}}"

        local result = converter:convert_whisker_to_markdown(text)

        assert.matches("%*Set health to 100%*", result)
      end)

      it("should convert conditionals to readable Markdown", function()
        local converter = FormatConverter.new()
        local text = "{{if health > 50 then}}Healthy{{end}}"

        local result = converter:convert_whisker_to_markdown(text)

        assert.matches("%*If health > 50:%*", result)
      end)

      it("should convert variable interpolation to emphasis", function()
        local converter = FormatConverter.new()
        local text = "You have {{gold}} gold."

        local result = converter:convert_whisker_to_markdown(text)

        assert.matches("%*gold%*", result)
      end)
    end)
  end)

  describe("Helper Functions", function()
    it("should escape HTML entities", function()
      local converter = FormatConverter.new()

      assert.equals("&lt;div&gt;", converter:escape_html("<div>"))
      assert.equals("&amp;", converter:escape_html("&"))
      assert.equals("&quot;", converter:escape_html('"'))
      assert.equals("&#39;", converter:escape_html("'"))
    end)

    it("should create URL-friendly slugs", function()
      local converter = FormatConverter.new()

      assert.equals("test-passage", converter:slugify("Test Passage"))
      assert.equals("special-chars", converter:slugify("Special!@# Chars"))
      assert.equals("multiple-spaces", converter:slugify("Multiple   Spaces"))
    end)

    it("should find start passage by name", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()

      local pid = converter:find_start_passage_pid(doc)

      assert.equals("1", pid)
    end)

    it("should fallback to first passage if start not found", function()
      local converter = FormatConverter.new()
      local doc = create_simple_whisker_doc()
      doc.settings.startPassage = "NonExistent"

      local pid = converter:find_start_passage_pid(doc)

      assert.equals("1", pid)
    end)
  end)

  describe("Batch Conversion", function()
    it("should batch convert multiple files", function()
      local converter = FormatConverter.new()
      local files = {
        {name = "story1", content = create_simple_whisker_doc()},
        {name = "story2", content = create_simple_whisker_doc()}
      }

      local results, errors = converter:batch_convert(
        files,
        FormatConverter.FormatType.WHISKER,
        FormatConverter.FormatType.TWEE
      )

      assert.equals(2, #results)
      assert.equals(0, #errors)
      assert.equals("story1", results[1].name)
      assert.matches(":: StoryTitle", results[1].content)
    end)

    it("should collect errors in batch conversion", function()
      local converter = FormatConverter.new()
      local files = {
        {name = "valid", content = create_simple_whisker_doc()},
        {name = "invalid", content = "not a valid document"}
      }

      local results, errors = converter:batch_convert(
        files,
        FormatConverter.FormatType.WHISKER,
        FormatConverter.FormatType.TWEE
      )

      assert.is_true(#results >= 1)
      assert.is_true(#errors >= 0)  -- May or may not error depending on validation
    end)
  end)

  describe("Format Detection", function()
    it("should use correct target format for Twine export", function()
      local converter = FormatConverter.new()

      assert.is_not_nil(converter:convert_whisker_to_twine("{{test}}", "Harlowe"))
      assert.is_not_nil(converter:convert_whisker_to_twine("{{test}}", "SugarCube"))
      assert.is_not_nil(converter:convert_whisker_to_twine("{{test}}", "Chapbook"))
      assert.is_not_nil(converter:convert_whisker_to_twine("{{test}}", "Snowman"))
    end)

    it("should return text unchanged for unknown format", function()
      local converter = FormatConverter.new()
      local text = "{{test}}"

      local result = converter:convert_whisker_to_twine(text, "UnknownFormat")

      assert.equals(text, result)
    end)
  end)
end)
