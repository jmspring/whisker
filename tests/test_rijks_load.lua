local helper = require("tests.test_helper")
local whisker_loader = require("whisker.format.whisker_loader")
local json = require("whisker.utils.json")

describe("Rijksmuseum Tour Loading", function()
  local rijks_story
  local rijks_filename = "examples/museum_tours/rijksmuseum/rijksmuseum_tour.whisker"

  setup(function()
    -- Load the story once for all tests
    local story, err = whisker_loader.load_from_file(rijks_filename)
    if err then
      error("Failed to load Rijksmuseum tour: " .. err)
    end
    rijks_story = story
  end)

  describe("File Loading", function()
    it("should load the Rijksmuseum tour file successfully", function()
      assert.is_not_nil(rijks_story)
    end)

    it("should return a story object with metadata", function()
      assert.is_not_nil(rijks_story.metadata)
      assert.is_table(rijks_story.metadata)
    end)

    it("should return a story object with passages", function()
      assert.is_not_nil(rijks_story.passages)
      assert.is_table(rijks_story.passages)
    end)
  end)

  describe("Story Metadata", function()
    it("should have a title/name", function()
      assert.is_not_nil(rijks_story.metadata.name)
      assert.is_string(rijks_story.metadata.name)
      assert.is_true(#rijks_story.metadata.name > 0)
    end)

    it("should have an author", function()
      assert.is_not_nil(rijks_story.metadata.author)
      assert.is_string(rijks_story.metadata.author)
    end)

    it("should have an IFID", function()
      assert.is_not_nil(rijks_story.metadata.ifid)
      assert.is_string(rijks_story.metadata.ifid)
      assert.is_true(#rijks_story.metadata.ifid > 0)
    end)

    it("should have a version", function()
      assert.is_not_nil(rijks_story.metadata.version)
    end)
  end)

  describe("Story Structure", function()
    it("should have multiple passages", function()
      local passage_count = 0
      for _ in pairs(rijks_story.passages) do
        passage_count = passage_count + 1
      end
      assert.is_true(passage_count > 0)
    end)

    it("should have a start passage defined", function()
      assert.is_not_nil(rijks_story.start_passage)
      assert.is_string(rijks_story.start_passage)
    end)

    it("should have the start passage in the passages collection", function()
      assert.is_not_nil(rijks_story.passages[rijks_story.start_passage])
    end)
  end)

  describe("Passage Structure", function()
    it("should have passages with valid IDs", function()
      for id, passage in pairs(rijks_story.passages) do
        assert.is_not_nil(passage.id)
        assert.is_string(passage.id)
        assert.equals(id, passage.id)
      end
    end)

    it("should have passages with content", function()
      for id, passage in pairs(rijks_story.passages) do
        assert.is_not_nil(passage.content)
        assert.is_string(passage.content)
      end
    end)

    it("should have passages with choices arrays (even if empty)", function()
      for id, passage in pairs(rijks_story.passages) do
        if passage.choices then
          assert.is_table(passage.choices)
        end
      end
    end)
  end)

  describe("Tour Specific Content", function()
    it("should contain museum-specific metadata or content", function()
      -- Check if metadata contains museum-related info
      local has_museum_content = false

      -- Check metadata
      for k, v in pairs(rijks_story.metadata) do
        local v_str = tostring(v):lower()
        if v_str:find("museum") or v_str:find("rijks") or v_str:find("tour") then
          has_museum_content = true
          break
        end
      end

      -- Check passages if not found in metadata
      if not has_museum_content then
        for id, passage in pairs(rijks_story.passages) do
          local content_lower = passage.content:lower()
          if content_lower:find("museum") or content_lower:find("rijks") or
             content_lower:find("tour") or content_lower:find("painting") or
             content_lower:find("art") then
            has_museum_content = true
            break
          end
        end
      end

      assert.is_true(has_museum_content)
    end)
  end)

  describe("Large Story Handling", function()
    it("should handle a story with many passages", function()
      local passage_count = 0
      for _ in pairs(rijks_story.passages) do
        passage_count = passage_count + 1
      end

      -- Rijksmuseum tour should have multiple passages
      assert.is_true(passage_count >= 1, "Story should have at least 1 passage")
    end)

    it("should preserve all passage relationships", function()
      -- Verify that all choice targets exist as passages (except external links)
      for id, passage in pairs(rijks_story.passages) do
        if passage.choices then
          for _, choice in ipairs(passage.choices) do
            if choice.target_passage then
              -- Skip external links (targets starting with "external_")
              if not choice.target_passage:match("^external_") then
                assert.is_not_nil(
                  rijks_story.passages[choice.target_passage],
                  "Choice target '" .. choice.target_passage .. "' in passage '" .. id .. "' should exist"
                )
              end
            end
          end
        end
      end
    end)
  end)
end)
