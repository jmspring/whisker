-- SugarCube Format Converter

local M = {}

function M.to_harlowe(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    local content = passage.content

    -- Convert <<set $var to value>> -> (set: $var to value)
    content = content:gsub("<<%s*set%s+(%$[%w_]+)%s+to%s+(.-)%s*>>", "(set: %1 to %2)")

    -- Convert <<if cond>>body<</if>> -> (if: cond)[body]
    content = content:gsub("<<%s*if%s+(.-)%s*>>(.-)<</%s*if%s*>>", "(if: %1)[%2]")

    -- Convert <<print expr>> -> (print: expr)
    content = content:gsub("<<%s*print%s+(.-)%s*>>", "(print: %1)")

    -- Convert [[Text|Target]] -> [[Text->Target]]
    content = content:gsub("%[%[(.-)%|(.-)%]%]", "[[%1->%2]]")

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

function M.to_chapbook(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    local content = passage.content

    -- Extract variables
    local vars = {}
    content = content:gsub("<<%s*set%s+%$([%w_]+)%s+to%s+(.-)%s*>>", function(var, value)
      table.insert(vars, var .. ": " .. value)
      return ""
    end)

    if #vars > 0 then
      table.insert(result, table.concat(vars, "\n"))
      table.insert(result, "--")
    end

    -- Remove $ from variables
    content = content:gsub("%$([%w_]+)", "{%1}")

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

-- Convert SugarCube to Snowman
function M.to_snowman(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    local content = passage.content

    -- Convert <<set $var to value>> to <% s.var = value; %>
    content = content:gsub("<<%s*set%s+%$([%w_]+)%s+to%s+(.-)%s*>>", function(var, value)
      return "<% s." .. var .. " = " .. value .. "; %>"
    end)

    -- Convert $var to <%= s.var %>
    content = content:gsub("%$([%w_]+)", function(var)
      return "<%= s." .. var .. " %>"
    end)

    -- Convert <<if cond>>body<</if>> to <% if (cond) { %>body<% } %>
    content = content:gsub("<<%s*if%s+(.-)%s*>>(.-)<</%s*if%s*>>", function(cond, body)
      -- Convert $ to s. in condition
      cond = cond:gsub("%$([%w_]+)", "s.%1")
      return "<% if (" .. cond .. ") { %>" .. body .. "<% } %>"
    end)

    -- Convert [[Text|Target]] to [Text](Target)
    content = content:gsub("%[%[(.-)%|(.-)%]%]", function(text, target)
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

-- Helper conversion functions
function M.convert_macro_to_harlowe(sugarcube_text)
  local text = sugarcube_text

  -- Convert JavaScript arrays ['a', 'b'] to (a: 'a', 'b')
  text = text:gsub("%[([^%]]+)%]", function(items)
    -- Only convert if it looks like an array (contains quotes or numbers)
    if items:match("['\"]") or items:match("^%s*%d") then
      return "(a: " .. items .. ")"
    end
    return "[" .. items .. "]"
  end)

  -- Convert JavaScript objects {key: value} to (dm: "key", value)
  text = text:gsub("{([^}]+)}", function(pairs)
    local dm_items = {}
    -- Parse key: value pairs
    for key, value in pairs:gmatch("([%w_]+):%s*([^,]+)") do
      table.insert(dm_items, '"' .. key .. '", ' .. value)
    end
    if #dm_items > 0 then
      return "(dm: " .. table.concat(dm_items, ", ") .. ")"
    end
    return "{" .. pairs .. "}"
  end)

  -- Convert <<set $var to value>> to (set: $var to value)
  text = text:gsub("<<%s*set%s+(%$[%w_]+)%s+to%s+(.-)%s*>>", function(var, value)
    return "(set: " .. var .. " to " .. value .. ")"
  end)

  -- Convert <<run $x += 5>> to (set: $x to it + 5)
  text = text:gsub("<<%s*run%s+%$([%w_]+)%s*%+=%s*(.-)%s*>>", function(var, value)
    return "(set: $" .. var .. " to it + " .. value .. ")"
  end)

  -- Convert <<if cond>>body<</if>> to (if: cond)[body]
  text = text:gsub("<<%s*if%s+(.-)%s*>>(.-)<</%s*if%s*>>", function(cond, body)
    return "(if: " .. cond .. ")[" .. body .. "]"
  end)

  -- Convert <<print $var>> to $var
  text = text:gsub("<<%s*print%s+(%$[%w_]+)%s*>>", "%1")

  -- Convert <<for>> loops (keep as-is, Harlowe doesn't have direct equivalent)
  -- Leave them for manual conversion

  return text
end

function M.convert_link_to_harlowe(sugarcube_text)
  -- Convert [[Text|Target]] to [[Text->Target]]
  return sugarcube_text:gsub("%[%[(.-)%|(.-)%]%]", "[[%1->%2]]")
end

function M.convert_to_chapbook_passage(sugarcube_text)
  local vars = {}
  local content_lines = {}

  -- Extract <<set>> macros for vars section
  for line in (sugarcube_text .. "\n"):gmatch("([^\n]*)\n") do
    local var, value = line:match("<<%s*set%s+%$([%w_]+)%s+to%s+(.-)%s*>>")
    if var then
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

function M.convert_macro_to_chapbook(sugarcube_text)
  local text = sugarcube_text

  -- Convert <<if cond>>body<</if>> to [if cond]body[continue]
  text = text:gsub("<<%s*if%s+(.-)%s*>>(.-)<</%s*if%s*>>", function(cond, body)
    -- Remove $ from condition
    cond = cond:gsub("%$([%w_]+)", "%1")
    return "[if " .. cond .. "]" .. body .. "[continue]"
  end)

  -- Convert <<link 'Text' 'Target'>><</link>> to [Text](Target)
  text = text:gsub("<<%s*link%s+'([^']+)'%s+'([^']+)'%s*>>.-<</%s*link%s*>>", function(link_text, target)
    return "[" .. link_text .. "](" .. target .. ")"
  end)

  -- Remove $ from variables
  text = text:gsub("%$([%w_]+)", "{%1}")

  return text
end

function M.convert_text_to_chapbook(sugarcube_text)
  -- Remove $ from variables, replace with {}
  return sugarcube_text:gsub("%$([%w_]+)", "{%1}")
end

function M.convert_to_snowman_code(sugarcube_text)
  local text = sugarcube_text

  -- Convert <<set $var to value>> to s.var = value
  text = text:gsub("<<%s*set%s+%$([%w_]+)%s+to%s+(.-)%s*>>", function(var, value)
    return "s." .. var .. " = " .. value
  end)

  return text
end

function M.convert_widget_to_snowman(sugarcube_text)
  -- Convert <<widget "name">>content<</widget>> to window.name = function() { ... }
  return sugarcube_text:gsub("<<%s*widget%s+\"([^\"]+)\"%s*>>(.-)<</%s*widget%s*>>", function(name, content)
    return "window." .. name .. " = function() {\n" .. content .. "\n}"
  end)
end

function M.convert_to_harlowe_passage(sugarcube_text)
  local text = sugarcube_text

  -- Convert macros
  text = M.convert_macro_to_harlowe(text)

  -- Convert links
  text = M.convert_link_to_harlowe(text)

  return text
end

return M
