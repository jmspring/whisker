-- Snowman Format Converter

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

    -- Convert <% s.var = value; %> to (set: $var to value)
    content = content:gsub("<%[%s=]?%s*s%.([%w_]+)%s*=%s*(.-)%s*;?%s*%%>", "(set: $%1 to %2)")

    -- Convert <%= s.var %> to $var
    content = content:gsub("<%%=%s*s%.([%w_]+)%s*%%>", "$%1")

    -- Convert [Text](Target) to [[Text->Target]]
    content = content:gsub("%[(.-)%]%((.-)%)", "[[%1->%2]]")

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

    -- Convert <% s.var = value %> to <<set $var to value>>
    content = content:gsub("<%[%s=]?%s*s%.([%w_]+)%s*=%s*(.-)%s*;?%s*%%>", "<<set $%1 to %2>>")

    -- Convert <%= s.var %> to $var
    content = content:gsub("<%%=%s*s%.([%w_]+)%s*%%>", "$%1")

    -- Convert [Text](Target) to [[Text|Target]]
    content = content:gsub("%[(.-)%]%((.-)%)", "[[%1|%2]]")

    table.insert(result, content)
    table.insert(result, "")
  end

  return table.concat(result, "\n")
end

return M
