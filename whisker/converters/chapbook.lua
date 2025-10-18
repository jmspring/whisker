-- Chapbook Format Converter

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

    -- Convert {var} to $var
    content = content:gsub("{([%w_]+)}", "$%1")

    -- Convert vars section to (set: ...) macros
    local vars_section, rest = content:match("^(.-)%-%-(.*)$")
    if vars_section then
      local sets = {}
      for var, value in vars_section:gmatch("([%w_]+):%s*([^\n]+)") do
        table.insert(sets, "(set: $" .. var .. " to " .. value .. ")")
      end
      content = table.concat(sets, "\n") .. "\n" .. rest
    end

    -- Convert [if cond]body to (if: cond)[body]
    content = content:gsub("%[if%s+(.-)%](.-)%[continued%]", "(if: $%1)[%2]")

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

function M.to_sugarcube(parsed_story)
  local result = {}

  for _, passage in ipairs(parsed_story.passages) do
    local header = ":: " .. passage.name
    if passage.tags and #passage.tags > 0 then
      header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
    end
    table.insert(result, header)

    local content = passage.content

    -- Convert vars section to <<set>> macros
    local vars_section, rest = content:match("^(.-)%-%-(.*)$")
    if vars_section then
      local sets = {}
      for var, value in vars_section:gmatch("([%w_]+):%s*([^\n]+)") do
        table.insert(sets, "<<set $" .. var .. " to " .. value .. ">>")
      end
      content = table.concat(sets, "\n") .. "\n" .. rest
    end

    -- Convert {var} to $var
    content = content:gsub("{([%w_]+)}", "$%1")

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

return M
