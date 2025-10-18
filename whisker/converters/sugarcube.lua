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

return M
