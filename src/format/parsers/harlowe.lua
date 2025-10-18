-- Harlowe Twee Parser
-- Parses Twee notation (passage-based) into structured format

local M = {}

function M.parse(twee_text)
  local story = {
    passages = {},
    metadata = {}
  }

  -- Split by passage markers (::)
  for passage_block in twee_text:gmatch("::([^\n]+)\n([^:]*)") do
    -- This will be improved, for now just basic structure
  end

  -- Better approach: split on :: headers
  local current_name = nil
  local current_content = {}
  local current_tags = {}

  for line in (twee_text .. "\n"):gmatch("([^\n]*)\n") do
    local passage_header = line:match("^::%s*(.+)")

    if passage_header then
      -- Save previous passage if exists
      if current_name then
        table.insert(story.passages, {
          name = current_name,
          content = table.concat(current_content, "\n"),
          tags = current_tags
        })
      end

      -- Parse new passage header
      local name, tags = passage_header:match("^([^%[]+)%[(.-)%]")
      if not name then
        name = passage_header:match("^%s*(.-)%s*$")
        tags = ""
      end

      current_name = name:match("^%s*(.-)%s*$")
      current_tags = {}
      if tags and tags ~= "" then
        for tag in tags:gmatch("%S+") do
          table.insert(current_tags, tag)
        end
      end
      current_content = {}
    elseif current_name then
      table.insert(current_content, line)
    end
  end

  -- Save last passage
  if current_name then
    table.insert(story.passages, {
      name = current_name,
      content = table.concat(current_content, "\n"),
      tags = current_tags
    })
  end

  return story
end

return M
