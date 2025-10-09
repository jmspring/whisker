-- Enhanced test helper functions

local M = {}

-- Load a fixture file
function M.load_fixture(relative_path)
  local full_path = "tests/fixtures/" .. relative_path
  local file = io.open(full_path, "r")

  if not file then
    error("Could not open fixture file: " .. full_path)
  end

  local content = file:read("*all")
  file:close()

  return content
end

-- Find a passage by name
function M.find_passage(parsed, name)
  if not parsed or not parsed.passages then
    return nil
  end

  for _, passage in ipairs(parsed.passages) do
    if passage.name == name then
      return passage
    end
  end

  return nil
end

-- Find first passage matching a pattern
function M.find_passage_with_pattern(parsed, pattern)
  if not parsed or not parsed.passages then
    return nil
  end

  for _, passage in ipairs(parsed.passages) do
    if passage.content and passage.content:match(pattern) then
      return passage
    end
  end

  return nil
end

-- Find all passages matching a pattern
function M.find_passages_with_pattern(parsed, pattern)
  local matches = {}

  if not parsed or not parsed.passages then
    return matches
  end

  for _, passage in ipairs(parsed.passages) do
    if passage.content and passage.content:match(pattern) then
      table.insert(matches, passage)
    end
  end

  return matches
end

-- Count occurrences of a pattern
function M.count_pattern(str, pattern)
  local count = 0
  for _ in string.gmatch(str, pattern) do
    count = count + 1
  end
  return count
end

-- Find Harlowe links
function M.find_harlowe_links(content)
  local links = {}

  -- Match [[text->target]] or [[target]]
  for text, target in content:gmatch("%[%[(.-)%->(.-)%]%]") do
    table.insert(links, {text = text, target = target})
  end

  for target in content:gmatch("%[%[(.-)%]%]") do
    if not target:match("->") then
      table.insert(links, {text = target, target = target})
    end
  end

  return links
end

-- Verify passage structure
function M.verify_passage_structure(passage)
  assert(passage.name, "Passage must have name")
  assert(passage.content ~= nil, "Passage must have content")
  assert(type(passage.tags or {}) == "table", "Passage tags must be table")
end

-- Extract Chapbook vars section
function M.extract_chapbook_vars_section(content)
  local vars_end = content:find("%-%-")
  if not vars_end then
    return nil
  end
  return content:sub(1, vars_end - 1)
end

-- Find standard [[link]] or [[text->target]] links
function M.find_standard_links(content)
  local links = {}

  -- Match [[text->target]]
  for text, target in content:gmatch("%[%[(.-)%->(.-)%]%]") do
    table.insert(links, {text = text, target = target})
  end

  -- Match [[target]]
  for target in content:gmatch("%[%[([^%]%->]+)%]%]") do
    if not target:match("->") then
      table.insert(links, {text = target, target = target})
    end
  end

  return links
end

-- Find Chapbook inserts
function M.find_chapbook_inserts(content)
  local inserts = {}

  for insert in content:gmatch("{[^}]+}") do
    table.insert(inserts, insert)
  end

  return inserts
end

-- Find Chapbook modifiers
function M.find_chapbook_modifiers(content)
  local modifiers = {}

  for modifier in content:gmatch("%[%w+[^%]]*%]") do
    table.insert(modifiers, modifier)
  end

  return modifiers
end

-- Check if content has Chapbook vars section
function M.has_vars_section(content)
  return content:match("^[^%-]*%-%-") ~= nil
end

-- Parse Chapbook variable assignments
function M.parse_chapbook_vars(vars_section)
  local vars = {}

  for var_name, value in vars_section:gmatch("(%w+):%s*([^\n]+)") do
    vars[var_name] = value
  end

  return vars
end

-- Add these converter-specific helper functions

-- Compare two parsed stories for structural similarity
function M.stories_structurally_equal(story1, story2)
  if #story1.passages ~= #story2.passages then
    return false
  end

  local names1 = {}
  local names2 = {}

  for _, p in ipairs(story1.passages) do
    names1[p.name] = true
  end

  for _, p in ipairs(story2.passages) do
    names2[p.name] = true
  end

  for name, _ in pairs(names1) do
    if not names2[name] then
      return false
    end
  end

  return true
end

-- Extract variable names from content
function M.extract_variable_names(content, format)
  local vars = {}

  if format == "harlowe" or format == "sugarcube" then
    for var in content:gmatch("%$([%w_]+)") do
      vars[var] = true
    end
  elseif format == "chapbook" then
    for var in content:gmatch("{([%w_]+)}") do
      vars[var] = true
    end
  elseif format == "snowman" then
    for var in content:gmatch("s%.([%w_]+)") do
      vars[var] = true
    end
  end

  return vars
end

-- Check if conversion preserved variables
function M.variables_preserved(original_content, converted_content, from_format, to_format)
  local original_vars = M.extract_variable_names(original_content, from_format)
  local converted_vars = M.extract_variable_names(converted_content, to_format)

  for var, _ in pairs(original_vars) do
    if not converted_vars[var] then
      return false, "Missing variable: " .. var
    end
  end

  return true
end

-- Count macros/inserts/modifiers
function M.count_constructs(content, format)
  local count = 0

  if format == "harlowe" then
    count = M.count_pattern(content, "%([%w%-]+:")
  elseif format == "sugarcube" then
    count = M.count_pattern(content, "<<%w+")
  elseif format == "chapbook" then
    local inserts = M.count_pattern(content, "{[%w%s]+:")
    local modifiers = M.count_pattern(content, "%[%w+%s")
    count = inserts + modifiers
  elseif format == "snowman" then
    count = M.count_pattern(content, "<%[%s=]?")
  end

  return count
end

return M