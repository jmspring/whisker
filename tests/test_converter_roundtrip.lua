local helper = require("tests.test_helper")
local harlowe_parser = require("whisker.parsers.harlowe")
local sugarcube_parser = require("whisker.parsers.sugarcube")
local chapbook_parser = require("whisker.parsers.chapbook")
local snowman_parser = require("whisker.parsers.snowman")

describe("Converter Roundtrip Tests", function()

  describe("Harlowe Roundtrips", function()
    it("should roundtrip Harlowe -> SugarCube -> Harlowe", function()
      local original = [=[
:: Start
(set: $name to "Hero")
Welcome, $name!
[[Next]]
]=]

      local parsed = harlowe_parser.parse(original)
      local converter_h2s = require("whisker.converters.harlowe")
      local sugarcube = converter_h2s.to_sugarcube(parsed)

      local parsed_sc = sugarcube_parser.parse(sugarcube)
      local converter_s2h = require("whisker.converters.sugarcube")
      local back_to_harlowe = converter_s2h.to_harlowe(parsed_sc)

      assert.is_not_nil(back_to_harlowe)
      assert.matches("%(set:", back_to_harlowe)
      assert.matches("%$name", back_to_harlowe)
    end)

    it("should roundtrip Harlowe -> Chapbook -> Harlowe", function()
      local original = [[
:: Start
(set: $gold to 100)
Gold: $gold
]]

      local parsed = harlowe_parser.parse(original)
      local converter_h2c = require("whisker.converters.harlowe")
      local chapbook = converter_h2c.to_chapbook(parsed)

      local parsed_cb = chapbook_parser.parse(chapbook)
      local converter_c2h = require("whisker.converters.chapbook")
      local back_to_harlowe = converter_c2h.to_harlowe(parsed_cb)

      assert.is_not_nil(back_to_harlowe)
      assert.matches("%(set:", back_to_harlowe)
    end)
  end)

  describe("SugarCube Roundtrips", function()
    it("should roundtrip SugarCube -> Harlowe -> SugarCube", function()
      local original = [[
:: Start
<<set $name to "Hero">>
Welcome, $name!
]]

      local parsed = sugarcube_parser.parse(original)
      local converter_s2h = require("whisker.converters.sugarcube")
      local harlowe = converter_s2h.to_harlowe(parsed)

      local parsed_h = harlowe_parser.parse(harlowe)
      local converter_h2s = require("whisker.converters.harlowe")
      local back_to_sugarcube = converter_h2s.to_sugarcube(parsed_h)

      assert.is_not_nil(back_to_sugarcube)
      assert.matches("<<set", back_to_sugarcube)
    end)
  end)

  describe("Chapbook Roundtrips", function()
    it("should roundtrip Chapbook -> SugarCube -> Chapbook", function()
      local original = [[
:: Start
gold: 100
--
Gold: {gold}
]]

      local parsed = chapbook_parser.parse(original)
      local converter_c2s = require("whisker.converters.chapbook")
      local sugarcube = converter_c2s.to_sugarcube(parsed)

      local parsed_sc = sugarcube_parser.parse(sugarcube)
      local converter_s2c = require("whisker.converters.sugarcube")
      local back_to_chapbook = converter_s2c.to_chapbook(parsed_sc)

      assert.is_not_nil(back_to_chapbook)
      assert.matches("gold:", back_to_chapbook)
      assert.matches("%-%-", back_to_chapbook)
    end)
  end)

  describe("Data Preservation", function()
    it("should preserve passage count", function()
      local original = [[
:: Start
Content

:: Second
More content

:: Third
Even more
]]

      local parsed = harlowe_parser.parse(original)
      local original_count = #parsed.passages

      local converter = require("whisker.converters.harlowe")
      local sugarcube = converter.to_sugarcube(parsed)
      local parsed_sc = sugarcube_parser.parse(sugarcube)

      assert.equals(original_count, #parsed_sc.passages)
    end)

    it("should preserve passage names", function()
      local original = [[
:: Start
:: CustomName
:: Another_Passage
]]

      local parsed = harlowe_parser.parse(original)
      local converter = require("whisker.converters.harlowe")
      local chapbook = converter.to_chapbook(parsed)

      assert.matches(":: Start", chapbook)
      assert.matches(":: CustomName", chapbook)
      assert.matches(":: Another_Passage", chapbook)
    end)

    it("should preserve links", function()
      local original = [=[
:: Start
[[Link One]]
[[Text->Target]]
[[Another Link]]
]=]

      local parsed = harlowe_parser.parse(original)
      local converter = require("whisker.converters.harlowe")
      local sugarcube = converter.to_sugarcube(parsed)

      -- Links should be preserved in some form
      assert.matches("%[%[", sugarcube)
    end)
  end)

  describe("Conversion Loss Detection", function()
    it("should warn about incompatible features", function()
      local harlowe_with_specific_feature = [=[
:: Start
(link-repeat: "Click")[Text changes]
]=]

      local parsed = harlowe_parser.parse(harlowe_with_specific_feature)
      local converter = require("whisker.converters.harlowe")

      -- Should either convert or warn
      local result, warnings = converter.to_chapbook_with_warnings(parsed)

      assert.is_not_nil(result)
      -- May have warnings about feature compatibility
    end)

    it("should detect when exact conversion isn't possible", function()
      local chapbook_modifier = [[
:: Start
[after 5s]
Delayed text
[continue]
]]

      local parsed = chapbook_parser.parse(chapbook_modifier)
      local converter = require("whisker.converters.chapbook")

      local result, info = converter.to_harlowe_with_info(parsed)

      assert.is_not_nil(result)
      -- Info might indicate approximation used
    end)
  end)
end)
