local helper = require("tests.test_helper")
local template_processor = require('engine.utils.template_processor')

describe("Template Processor", function()

  describe("Variable Substitution", function()
    it("should substitute simple variables", function()
      local result = template_processor.process("Hello {{name}}!", {name = "World"})
      assert.equals("Hello World!", result)
    end)

    it("should substitute number variables", function()
      local result = template_processor.process("Count: {{count}}", {count = 42})
      assert.equals("Count: 42", result)
    end)

    it("should handle undefined variables", function()
      local result = template_processor.process("Missing: {{missing}}", {})
      assert.equals("Missing: ", result)
    end)
  end)

  describe("If/Else Conditionals", function()
    it("should show content when condition is true", function()
      local result = template_processor.process("{{#if visible}}Shown{{/if}}", {visible = true})
      assert.equals("Shown", result)
    end)

    it("should hide content when condition is false", function()
      local result = template_processor.process("{{#if visible}}Shown{{/if}}", {visible = false})
      assert.equals("", result)
    end)

    it("should handle if/else branches", function()
      local result = template_processor.process("{{#if visible}}Yes{{else}}No{{/if}}", {visible = true})
      assert.equals("Yes", result)

      result = template_processor.process("{{#if visible}}Yes{{else}}No{{/if}}", {visible = false})
      assert.equals("No", result)
    end)
  end)

  describe("Chained Conditionals", function()
    local template = "{{#if score >= 90}}A{{else if score >= 80}}B{{else if score >= 70}}C{{else}}F{{/if}}"

    it("should match first condition", function()
      local result = template_processor.process(template, {score = 95})
      assert.equals("A", result)
    end)

    it("should match second condition", function()
      local result = template_processor.process(template, {score = 85})
      assert.equals("B", result)
    end)

    it("should match third condition", function()
      local result = template_processor.process(template, {score = 75})
      assert.equals("C", result)
    end)

    it("should match else clause", function()
      local result = template_processor.process(template, {score = 50})
      assert.equals("F", result)
    end)
  end)

  describe("Comparison Operators", function()
    it("should handle equality operator", function()
      local result = template_processor.process("{{#if gold == 100}}Equal{{/if}}", {gold = 100})
      assert.equals("Equal", result)
    end)

    it("should handle inequality operator", function()
      local result = template_processor.process("{{#if gold != 100}}Not equal{{/if}}", {gold = 50})
      assert.equals("Not equal", result)
    end)

    it("should handle greater than or equal", function()
      local result = template_processor.process("{{#if gold >= 100}}Pass{{/if}}", {gold = 150})
      assert.equals("Pass", result)
    end)

    it("should handle less than or equal", function()
      local result = template_processor.process("{{#if gold <= 100}}Pass{{/if}}", {gold = 50})
      assert.equals("Pass", result)
    end)
  end)

  describe("Logical Operators", function()
    it("should handle AND operator", function()
      local result = template_processor.process(
        "{{#if has_key and has_sword}}Ready{{/if}}",
        {has_key = true, has_sword = true}
      )
      assert.equals("Ready", result)

      result = template_processor.process(
        "{{#if has_key and has_sword}}Ready{{/if}}",
        {has_key = true, has_sword = false}
      )
      assert.equals("", result)
    end)

    it("should handle OR operator", function()
      local result = template_processor.process(
        "{{#if has_key or has_sword}}Armed{{/if}}",
        {has_key = false, has_sword = true}
      )
      assert.equals("Armed", result)

      result = template_processor.process(
        "{{#if has_key or has_sword}}Armed{{/if}}",
        {has_key = false, has_sword = false}
      )
      assert.equals("", result)
    end)

    it("should handle NOT operator", function()
      local result = template_processor.process(
        "{{#if not locked}}Open{{/if}}",
        {locked = false}
      )
      assert.equals("Open", result)

      result = template_processor.process(
        "{{#if not locked}}Open{{/if}}",
        {locked = true}
      )
      assert.equals("", result)
    end)
  end)

  describe("Complex Expressions", function()
    it("should handle comparison AND boolean", function()
      local result = template_processor.process(
        "{{#if gold >= 100 and has_key}}Enter{{/if}}",
        {gold = 150, has_key = true}
      )
      assert.equals("Enter", result)
    end)

    it("should handle comparison OR boolean", function()
      local result = template_processor.process(
        "{{#if level > 5 or has_admin}}Access{{/if}}",
        {level = 3, has_admin = true}
      )
      assert.equals("Access", result)
    end)
  end)

  describe("String Comparisons", function()
    it("should handle string equality", function()
      local result = template_processor.process(
        '{{#if status == "active"}}Running{{/if}}',
        {status = "active"}
      )
      assert.equals("Running", result)
    end)

    it("should handle string inequality", function()
      local result = template_processor.process(
        '{{#if status != "inactive"}}Running{{/if}}',
        {status = "active"}
      )
      assert.equals("Running", result)
    end)
  end)

  describe("Unless Conditionals", function()
    it("should show content when condition is false", function()
      local result = template_processor.process(
        "{{#unless locked}}Open{{/unless}}",
        {locked = false}
      )
      assert.equals("Open", result)
    end)

    it("should hide content when condition is true", function()
      local result = template_processor.process(
        "{{#unless locked}}Open{{/unless}}",
        {locked = true}
      )
      assert.equals("", result)
    end)
  end)

  describe("Variable Types", function()
    it("should treat boolean true as truthy", function()
      local result = template_processor.process("{{#if flag}}Yes{{/if}}", {flag = true})
      assert.equals("Yes", result)
    end)

    it("should treat boolean false as falsy", function()
      local result = template_processor.process("{{#if flag}}Yes{{/if}}", {flag = false})
      assert.equals("", result)
    end)

    it("should treat zero as falsy", function()
      local result = template_processor.process("{{#if count}}Has count{{/if}}", {count = 0})
      assert.equals("", result)
    end)

    it("should treat non-zero numbers as truthy", function()
      local result = template_processor.process("{{#if count}}Has count{{/if}}", {count = 1})
      assert.equals("Has count", result)
    end)
  end)

  describe("Combined Conditionals and Variables", function()
    it("should substitute variables inside conditionals", function()
      local result = template_processor.process(
        "{{#if has_item}}You have {{item_name}}{{/if}}",
        {has_item = true, item_name = "sword"}
      )
      assert.equals("You have sword", result)
    end)

    it("should substitute variables in if branch", function()
      local result = template_processor.process(
        "{{#if gold >= 100}}You have {{gold}} gold{{else}}Not enough{{/if}}",
        {gold = 150}
      )
      assert.is_not_nil(result:match("150"))
    end)

    it("should substitute variables in else branch", function()
      local result = template_processor.process(
        "{{#if gold >= 100}}Enough{{else}}You need {{needed}} more{{/if}}",
        {gold = 50, needed = 50}
      )
      assert.is_not_nil(result:match("50"))
    end)
  end)

  describe("Edge Cases", function()
    it("should handle empty content", function()
      local result = template_processor.process("", {})
      assert.equals("", result)
    end)

    it("should return content without templates unchanged", function()
      local result = template_processor.process("No templates here", {})
      assert.equals("No templates here", result)
    end)
  end)
end)
