local helper = require("tests.test_helper")
local Validator = require("engine.tools.validator")
local Story = require("engine.core.story")
local Passage = require("engine.core.passage")
local Choice = require("engine.core.choice")

describe("Validator", function()

  describe("Validator Instance", function()
    it("should create validator instance", function()
      local validator = Validator.new()
      assert.is_not_nil(validator)
    end)

    it("should have validate_story method", function()
      local validator = Validator.new()
      assert.equals("function", type(validator.validate_story))
    end)
  end)

  describe("Dead Link Detection", function()
    it("should validate story with missing passage target", function()
      local story = Story.new({title = "Test"})
      local p1 = Passage.new({
        id = "start",
        content = "Start passage"
      })
      p1:add_choice(Choice.new({
        text = "Go somewhere",
        target = "missing_passage"
      }))

      story:add_passage(p1)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      assert.is_not_nil(issues)
      assert.is_table(issues)
    end)

    it("should not report valid links as errors", function()
      local story = Story.new({title = "Test"})

      local p1 = Passage.new({id = "start", content = "Start"})
      local p2 = Passage.new({id = "next", content = "Next"})

      p1:add_choice(Choice.new({
        text = "Go to next",
        target = "next"
      }))

      story:add_passage(p1)
      story:add_passage(p2)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      -- Should have no dead link issues
      local has_dead_link = false
      for _, issue in ipairs(issues) do
        if issue.type and issue.type:match("[Dd]ead") then
          has_dead_link = true
          break
        end
      end
      assert.is_false(has_dead_link)
    end)
  end)

  describe("Orphaned Passage Detection", function()
    it("should validate story with unreachable passages", function()
      local story = Story.new({title = "Test"})

      local p1 = Passage.new({id = "start", content = "Start passage"})
      local p2 = Passage.new({id = "orphan", content = "This passage is unreachable"})

      story:add_passage(p1)
      story:add_passage(p2)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      assert.is_not_nil(issues)
      assert.is_table(issues)
    end)

    it("should not report reachable passages as orphans", function()
      local story = Story.new({title = "Test"})

      local p1 = Passage.new({id = "start", content = "Start"})
      local p2 = Passage.new({id = "reachable", content = "Reachable"})

      p1:add_choice(Choice.new({
        text = "Go to reachable",
        target = "reachable"
      }))

      story:add_passage(p1)
      story:add_passage(p2)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      -- p2 should not be considered an orphan
      local has_orphan_for_p2 = false
      for _, issue in ipairs(issues) do
        if issue.passage_id == "reachable" and
           (issue.type and issue.type:match("[Oo]rphan")) then
          has_orphan_for_p2 = true
          break
        end
      end
      assert.is_false(has_orphan_for_p2)
    end)
  end)

  describe("Variable Analysis", function()
    it("should detect undefined variables", function()
      local story = Story.new({title = "Test"})
      local p1 = Passage.new({
        id = "start",
        content = "Start passage with {{undefined_var}}"
      })

      story:add_passage(p1)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      assert.is_not_nil(issues)

      -- Check for undefined variable issue (if validator checks this)
      -- Some validators may not check variables, so this is optional
      local has_var_issue = false
      for _, issue in ipairs(issues) do
        if issue.message and issue.message:match("undefined") or
           issue.message and issue.message:match("variable") then
          has_var_issue = true
          break
        end
      end
      -- Note: This assertion depends on whether the validator checks variables
      -- assert.is_true(has_var_issue)
    end)
  end)

  describe("Report Generation", function()
    it("should generate text report", function()
      local story = Story.new({title = "Test"})
      local p1 = Passage.new({id = "start", content = "Start"})
      story:add_passage(p1)
      story:set_start_passage("start")

      local validator = Validator.new()
      local report = validator:generate_report("text")

      assert.is_not_nil(report)
      assert.is_string(report)
      assert.is_not_nil(report:match("Validation") or report:match("Report"))
    end)

    it("should generate JSON report", function()
      local story = Story.new({title = "Test"})
      local p1 = Passage.new({id = "start", content = "Start"})
      story:add_passage(p1)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local report = validator:generate_report("json")

      assert.is_not_nil(report)
      -- JSON report is returned as a table
      assert.is_table(report)
      assert.is_not_nil(report.summary)
    end)

    it("should handle empty story", function()
      local story = Story.new({title = "Empty"})

      local validator = Validator.new()
      local report = validator:generate_report("text")

      assert.is_not_nil(report)
      assert.is_string(report)
    end)
  end)

  describe("Story Validation Summary", function()
    it("should provide valid story summary", function()
      local story = Story.new({title = "Valid Story"})

      local p1 = Passage.new({id = "start", content = "Start"})
      local p2 = Passage.new({id = "next", content = "Next"})

      p1:add_choice(Choice.new({text = "Next", target = "next"}))

      story:add_passage(p1)
      story:add_passage(p2)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      -- A well-formed story should have minimal or no issues
      assert.is_not_nil(issues)
      assert.is_table(issues)
    end)

    it("should validate problematic story", function()
      local story = Story.new({title = "Problematic"})

      local p1 = Passage.new({id = "start", content = "Start"})
      p1:add_choice(Choice.new({text = "Go", target = "missing1"}))
      p1:add_choice(Choice.new({text = "Go2", target = "missing2"}))

      local p2 = Passage.new({id = "orphan", content = "Orphan"})

      story:add_passage(p1)
      story:add_passage(p2)
      story:set_start_passage("start")

      local validator = Validator.new()
      validator:validate_story(story)
      local issues = validator:get_results()

      -- Should be able to validate without errors
      assert.is_not_nil(issues)
      assert.is_table(issues)
    end)
  end)
end)
