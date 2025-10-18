local helper = require("tests.test_helper")
local parser = require("engine.format.parsers.snowman")

describe("Snowman Parser", function()

  describe("Basic Parsing", function()
    it("should parse simple Snowman passage", function()
      local twee = [=[
:: Start
<% s.name = "Hero"; %>
Welcome, <%= s.name %>!
]=]

      local result = parser.parse(twee)

      assert.is_not_nil(result)
      assert.equals(1, #result.passages)
      assert.equals("Start", result.passages[1].name)
      assert.matches("<%%", result.passages[1].content)
    end)

    it("should parse multiple passages with Snowman syntax", function()
      local twee = [=[
:: Start
<% s.gold = 100; %>
You have <%= s.gold %> gold.

[[Shop]]

:: Shop
<% if (s.gold >= 50) { %>
  [Buy Item](Purchase)
<% } %>
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)
      assert.matches("<%%", result.passages[1].content)
      assert.matches("<%%=", result.passages[1].content)
      assert.matches("if %(s%.gold", result.passages[2].content)
    end)
  end)

  describe("Snowman-Specific Content", function()
    it("should preserve code blocks", function()
      local twee = [=[
:: Test
<% s.health = 100; %>
<% s.gold += 10; %>
<% s.inventory.push('sword'); %>
]=]

      local result = parser.parse(twee)

      assert.matches("s%.health = 100", result.passages[1].content)
      assert.matches("s%.gold %+= 10", result.passages[1].content)
      assert.matches("s%.inventory%.push", result.passages[1].content)
    end)

    it("should preserve print blocks", function()
      local twee = [=[
:: Start
Name: <%= s.name %>
Health: <%= s.health %>
Gold: <%= s.gold %>
]=]

      local result = parser.parse(twee)

      assert.matches("<%%= s%.name %%>", result.passages[1].content)
      assert.matches("<%%= s%.health %%>", result.passages[1].content)
      assert.matches("<%%= s%.gold %%>", result.passages[1].content)
    end)

    it("should preserve conditionals", function()
      local twee = [=[
:: Test
<% if (s.health > 50) { %>
  Healthy!
<% } else { %>
  Low health!
<% } %>

<% if (s.gold >= 100 && s.level > 5) { %>
  Rich and experienced!
<% } %>
]=]

      local result = parser.parse(twee)

      assert.matches("<%%[%s]*if %(s%.health > 50%)", result.passages[1].content)
      assert.matches("} else {", result.passages[1].content)
      assert.matches("s%.gold >= 100 && s%.level > 5", result.passages[1].content)
    end)

    it("should preserve Markdown-style links", function()
      local twee = [=[
:: Start
[Next Passage](Next)
[Go to Shop](Shop)
[Display Text](Target)
]=]

      local result = parser.parse(twee)

      assert.matches("%[Next Passage%]%(Next%)", result.passages[1].content)
      assert.matches("%[Go to Shop%]%(Shop%)", result.passages[1].content)
      assert.matches("%[Display Text%]%(Target%)", result.passages[1].content)
    end)

    it("should preserve JavaScript expressions", function()
      local twee = [=[
:: Test
<% s.random = Math.random(); %>
<% s.items = []; %>
<% s.player = {name: 'Hero', hp: 100}; %>
<%= s.items.length %>
]=]

      local result = parser.parse(twee)

      assert.matches("Math%.random%(%)", result.passages[1].content)
      assert.matches("s%.items = %[%]", result.passages[1].content)
      assert.matches("s%.player = {", result.passages[1].content)
      assert.matches("s%.items%.length", result.passages[1].content)
    end)
  end)

  describe("Tags", function()
    it("should parse Snowman tags", function()
      local twee = [=[
:: StoryInit [init]
<% s.health = 100; %>

:: Inventory [sidebar]
<%= s.inventory.join(', ') %>
]=]

      local result = parser.parse(twee)

      assert.equals(2, #result.passages)
      assert.equals(1, #result.passages[1].tags)
      assert.equals("init", result.passages[1].tags[1])
      assert.equals(1, #result.passages[2].tags)
      assert.equals("sidebar", result.passages[2].tags[1])
    end)
  end)

  describe("Complex Content", function()
    it("should handle loops", function()
      local twee = [=[
:: Test
<% for (let i = 0; i < 10; i++) { %>
  Item <%= i %>
<% } %>

<% s.inventory.forEach(function(item) { %>
  - <%= item %>
<% }); %>
]=]

      local result = parser.parse(twee)

      assert.matches("for %(let i = 0", result.passages[1].content)
      assert.matches("s%.inventory%.forEach", result.passages[1].content)
    end)

    it("should handle complex state operations", function()
      local twee = [=[
:: Test
<%
  s.player = {
    name: 'Hero',
    stats: {
      hp: 100,
      mp: 50
    },
    inventory: ['sword', 'potion']
  };
%>

<% s.calculateDamage = function(atk, def) {
  return Math.max(1, atk - def);
}; %>
]=]

      local result = parser.parse(twee)

      assert.matches("s%.player = {", result.passages[1].content)
      assert.matches("s%.calculateDamage = function", result.passages[1].content)
    end)

    it("should preserve ternary operators", function()
      local twee = [=[
:: Test
<%= s.health > 50 ? 'Healthy' : 'Wounded' %>
<% s.message = s.gold >= 100 ? 'Rich' : 'Poor'; %>
]=]

      local result = parser.parse(twee)

      assert.matches("s%.health > 50 %? 'Healthy' : 'Wounded'", result.passages[1].content)
      assert.matches("s%.gold >= 100 %?", result.passages[1].content)
    end)
  end)
end)
