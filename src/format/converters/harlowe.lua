-- Harlowe Format Converter
-- Converts Harlowe-format stories to other Twine formats

local M = {}

-- Convert Harlowe to SugarCube
function M.to_sugarcube(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    -- Build passage header
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    -- Convert content
    local content = passage.content

    -- Convert arrays (a: ...) -> [...] - do this BEFORE set conversion
    content = content:gsub("%(%s*a:%s*(.-)%)", function(items)
      return "[" .. items .. "]"
    end)

    -- Convert datamaps (dm: ...) -> {...} - do this BEFORE set conversion
    content = content:gsub("%(%s*dm:%s*(.-)%)", function(pairs)
      return "{" .. pairs .. "}"
    end)

    -- Convert (set: $var to value) -> <<set $var to value>>
    -- Handle 'it' keyword replacement
    content = content:gsub("%(%s*set:%s*(%$[%w_]+)%s+to%s+(.-)%)", function(var, value)
      -- Replace 'it' with the variable name
      value = value:gsub("%s*it%s*", " " .. var .. " ")
      return "<<set " .. var .. " to " .. value .. ">>"
    end)

    -- Convert (if: cond)[body] -> <<if cond>>body<</if>>
    content = content:gsub("%(%s*if:%s*(.-)%)%[(.-)%]", function(cond, body)
      return "<<if " .. cond .. ">>" .. body .. "<</if>>"
    end)

    -- Convert (print: $var) -> <<print $var>>
    content = content:gsub("%(%s*print:%s*(.-)%)", function(expr)
      return "<<print " .. expr .. ">>"
    end)

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

-- Convert Harlowe to Chapbook
function M.to_chapbook(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    -- Build passage header
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    local content = passage.content

    -- Extract variable assignments and put them in vars section
    local vars = {}
    content = content:gsub("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)", function(var, value)
      table.insert(vars, var .. ": " .. value)
      return "" -- Remove from content
    end)

    -- If we have vars, add them at the top
    if #vars > 0 then
      table.insert(result, table.concat(vars, "\n"))
      table.insert(result, "--")
    end

    -- Convert $var to {var} (Chapbook doesn't use $)
    content = content:gsub("%$([%w_]+)", function(var)
      return "{" .. var .. "}"
    end)

    -- Convert (if: cond)[body] -> [if cond]body[continued]
    content = content:gsub("%(%s*if:%s*(.-)%)%[(.-)%]", function(cond, body)
      -- Remove $ from condition
      cond = cond:gsub("%$([%w_]+)", "%1")
      return "[if " .. cond .. "]\n" .. body .. "\n[continued]"
    end)

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

-- Convert Harlowe to Snowman
function M.to_snowman(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    -- Build passage header
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    local content = passage.content

    -- Convert (set: $var to value) -> <% s.var = value; %>
    content = content:gsub("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)", function(var, value)
      return "<% s." .. var .. " = " .. value .. "; %>"
    end)

    -- Convert $var to <%= s.var %>
    content = content:gsub("%$([%w_]+)", function(var)
      return "<%= s." .. var .. " %>"
    end)

    -- Convert (if: cond)[body] -> <% if (cond) { %>body<% } %>
    content = content:gsub("%(%s*if:%s*(.-)%)%[(.-)%]", function(cond, body)
      -- Convert $ to s. in condition
      cond = cond:gsub("%$([%w_]+)", "s.%1")
      return "<% if (" .. cond .. ") { %>" .. body .. "<% } %>"
    end)

    -- Convert [[Text->Target]] to [Text](Target)
    content = content:gsub("%[%[(.-)%->(.-)%]%]", function(text, target)
      return "[" .. text .. "](" .. target .. ")"
    end)

    -- Convert [[Target]] to [Target](Target)
    content = content:gsub("%[%[(.-)%]%]", function(target)
      return "[" .. target .. "](" .. target .. ")"
    end)

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

-- Helper functions for conversion with warnings/info
function M.to_chapbook_with_warnings(parsed_story)
  local result = M.to_chapbook(parsed_story)
  local warnings = {}

  -- Check for features that may not convert well
  for _, passage in ipairs(parsed_story.passages) do
    if passage.content:match("%(link%-repeat:") then
      table.insert(warnings, "link-repeat macro may not have exact Chapbook equivalent")
    end
  end

  return result, warnings
end

function M.to_harlowe_with_info(parsed_story)
  -- This would convert from another format to Harlowe
  -- For now, just return the story as-is with info
  local result = M.reconstruct_twee(parsed_story)
  local info = { approximations_used = {} }
  return result, info
end

-- Reconstruct Twee notation from parsed story
function M.reconstruct_twee(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)
    table.insert(result, passage.content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

-- Additional conversion functions
function M.convert_macro_to_sugarcube(harlowe_text)
  -- Convert individual Harlowe macros to SugarCube
  local text = harlowe_text

  -- Convert arrays (a: ...) -> [...] - do this BEFORE set conversion
  text = text:gsub("%(%s*a:%s*(.-)%)", function(items)
    return "[" .. items .. "]"
  end)

  -- Convert datamaps (dm: ...) -> {...} - do this BEFORE set conversion
  text = text:gsub("%(%s*dm:%s*(.-)%)", function(pairs)
    return "{" .. pairs .. "}"
  end)

  -- Convert (set: $var to value) -> <<set $var to value>>
  -- Handle 'it' keyword replacement
  text = text:gsub("%(%s*set:%s*(%$[%w_]+)%s+to%s+(.-)%)", function(var, value)
    -- Replace 'it' with the variable name
    value = value:gsub("%s*it%s*", " " .. var .. " ")
    return "<<set " .. var .. " to " .. value .. ">>"
  end)

  text = text:gsub("%(%s*if:%s*(.-)%)%[(.-)%]", "<<if %1>>%2<</if>>")
  text = text:gsub("%(%s*print:%s*(.-)%)", "<<print %1>>")

  return text
end

function M.convert_macro_to_chapbook(harlowe_text)
  local text = harlowe_text

  -- Convert arrays (a: ...) -> [...] - do this BEFORE other conversions
  text = text:gsub("%(%s*a:%s*(.-)%)", function(items)
    return "[" .. items .. "]"
  end)

  -- Convert datamaps (dm: ...) -> {...} - do this BEFORE other conversions
  text = text:gsub("%(%s*dm:%s*(.-)%)", function(pairs)
    return "{" .. pairs .. "}"
  end)

  -- Convert (if: cond)[body] to [if cond]body
  text = text:gsub("%(%s*if:%s*(.-)%)%[(.-)%]", function(cond, body)
    -- Remove $ from condition
    cond = cond:gsub("%$([%w_]+)", "%1")
    return "[if " .. cond .. "]" .. body
  end)

  -- Remove $ from variables
  text = text:gsub("%$([%w_]+)", "%1")

  return text
end

function M.convert_to_snowman_code(harlowe_text)
  local text = harlowe_text

  -- Convert (set: $var to val) to s.var = val
  text = text:gsub("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)", "s.%1 = %2")

  return text
end

function M.convert_to_snowman_passage(harlowe_text)
  local text = harlowe_text

  -- Wrap variable declarations in code blocks
  text = text:gsub("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)", function(var, value)
    return "<% s." .. var .. " = " .. value .. "; %>"
  end)

  return text
end

function M.convert_text_to_snowman(harlowe_text)
  -- Convert interpolation
  return harlowe_text:gsub("%$([%w_]+)", function(var)
    return "<%= s." .. var .. " %>"
  end)
end

function M.convert_link_to_snowman(harlowe_text)
  return harlowe_text:gsub("%[%[(.-)%->(.-)%]%]", "[%1](%2)")
end

function M.convert_link_to_sugarcube(harlowe_text)
  -- Harlowe [[Text->Target]] to SugarCube [[Text|Target]]
  return harlowe_text:gsub("%[%[(.-)%->(.-)%]%]", "[[%1|%2]]")
end

function M.convert_function_to_sugarcube(harlowe_text)
  -- Convert Harlowe functions
  return harlowe_text:gsub("%(%s*random:%s*(.-)%)", "random(%1)")
end

function M.convert_datastructure_to_chapbook(harlowe_text)
  local text = harlowe_text

  -- Convert (a: ...) to [...]
  text = text:gsub("%(%s*a:%s*(.-)%)", function(items)
    return "[" .. items .. "]"
  end)

  -- Convert (dm: "key", value, "key2", value2) to {key: value, key2: value2}
  text = text:gsub("%(%s*dm:%s*(.-)%)", function(pairs)
    -- Parse pairs and convert to object notation
    local result = {}
    local items = {}

    -- Simple parsing: split by commas (not perfect but works for basic cases)
    for item in (pairs .. ","):gmatch("([^,]+),") do
      table.insert(items, item:match("^%s*(.-)%s*$"))  -- trim whitespace
    end

    -- Pair up keys and values
    for i = 1, #items, 2 do
      if items[i] and items[i+1] then
        local key = items[i]:gsub('["\']', '')  -- Remove quotes from key
        local value = items[i+1]
        table.insert(result, key .. ": " .. value)
      end
    end

    return "{" .. table.concat(result, ", ") .. "}"
  end)

  return text
end

function M.convert_text_to_chapbook(harlowe_text)
  -- Remove $ from variables
  return harlowe_text:gsub("%$([%w_]+)", "{%1}")
end

function M.convert_to_chapbook_passage(harlowe_text)
  local text = harlowe_text
  local vars = {}
  local content_lines = {}

  -- Extract variable assignments for vars section
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    local var_match = line:match("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)")
    if var_match then
      local var, value = line:match("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)")
      table.insert(vars, var .. ": " .. value)
    else
      table.insert(content_lines, line)
    end
  end

  -- Build result
  local result = {}

  if #vars > 0 then
    table.insert(result, table.concat(vars, "\n"))
    table.insert(result, "--")
  end

  -- Convert remaining content
  local content = table.concat(content_lines, "\n")
  -- Remove $ from variables
  content = content:gsub("%$([%w_]+)", "{%1}")

  table.insert(result, content)

  return table.concat(result, "\n")
end

return M
