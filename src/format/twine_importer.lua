-- Twine Story Importer
-- Imports stories from Twine formats (Harlowe, SugarCube, Chapbook)
-- Converts to whisker format

local TwineImporter = {}

-- Supported Twine story formats
TwineImporter.SupportedFormats = {
    HARLOWE = "harlowe",
    SUGARCUBE = "sugarcube",
    CHAPBOOK = "chapbook",
    SNOWMAN = "snowman"
}

-- Create new importer instance
function TwineImporter.new(whisker_format)
    local self = setmetatable({}, {__index = TwineImporter})
    self.format = whisker_format or require("src.format.whisker_format")
    return self
end

-- Import from Twine HTML file
function TwineImporter:import_from_html(html_content)
    -- Check if this looks like valid Twine HTML
    if not html_content:match('<tw%-storydata') then
        return nil, "Not a valid Twine HTML file"
    end

    -- Parse the Twine HTML structure
    local story_data = self:parse_twine_html(html_content)

    if not story_data or not story_data.title then
        return nil, "Failed to parse Twine HTML"
    end

    -- Check if we got any passages
    if #story_data.passages == 0 then
        return nil, "No passages found in Twine HTML"
    end

    -- Detect story format
    local story_format = self:detect_format(story_data)

    -- Convert to Whisker format
    local whisker_doc = self:convert_to_whisker(story_data, story_format)

    return whisker_doc, nil
end

-- Import from Twee notation
function TwineImporter:import_from_twee(twee_content)
    local story_data = self:parse_twee(twee_content)

    if not story_data then
        return nil, "Failed to parse Twee notation"
    end

    -- Detect format from content
    local story_format = self:detect_format(story_data)

    -- Convert to Whisker format
    local whisker_doc = self:convert_to_whisker(story_data, story_format)

    return whisker_doc, nil
end

-- Parse Twine HTML format
function TwineImporter:parse_twine_html(html)
    local story_data = {
        title = "",
        author = "",
        ifid = "",
        format = "",
        formatVersion = "",
        startNode = "",
        passages = {}
    }

    -- Extract story metadata
    story_data.title = html:match('<tw%-storydata[^>]*name="([^"]*)"') or "Untitled"
    story_data.ifid = html:match('<tw%-storydata[^>]*ifid="([^"]*)"') or ""
    story_data.format = html:match('<tw%-storydata[^>]*format="([^"]*)"') or ""
    story_data.formatVersion = html:match('<tw%-storydata[^>]*format%-version="([^"]*)"') or ""
    story_data.startNode = html:match('<tw%-storydata[^>]*startnode="([^"]*)"') or ""

    -- Extract passages
    for passage_block in html:gmatch('<tw%-passagedata[^>]*>.-</tw%-passagedata>') do
        local passage = self:parse_passage_html(passage_block)
        if passage then
            table.insert(story_data.passages, passage)
        end
    end

    return story_data
end

-- Parse individual passage from HTML
function TwineImporter:parse_passage_html(passage_html)
    local passage = {}

    passage.pid = passage_html:match('pid="([^"]*)"') or ""
    passage.name = passage_html:match('name="([^"]*)"') or ""
    passage.tags = passage_html:match('tags="([^"]*)"') or ""
    passage.position = passage_html:match('position="([^"]*)"') or ""
    passage.size = passage_html:match('size="([^"]*)"') or ""

    -- Extract passage text
    local text = passage_html:match('>(.+)</tw%-passagedata>')
    if text then
        -- Decode HTML entities
        text = self:decode_html_entities(text)
        passage.text = text
    end

    -- Parse tags
    if passage.tags ~= "" then
        local tag_list = {}
        for tag in passage.tags:gmatch("[^%s]+") do
            table.insert(tag_list, tag)
        end
        passage.tags = tag_list
    else
        passage.tags = {}
    end

    -- Parse position
    if passage.position ~= "" then
        local x, y = passage.position:match("([^,]+),([^,]+)")
        passage.position = {x = tonumber(x) or 0, y = tonumber(y) or 0}
    else
        passage.position = {x = 0, y = 0}
    end

    -- Parse size
    if passage.size ~= "" then
        local w, h = passage.size:match("([^,]+),([^,]+)")
        passage.size = {width = tonumber(w) or 100, height = tonumber(h) or 100}
    else
        passage.size = {width = 100, height = 100}
    end

    return passage
end

-- Parse Twee notation
function TwineImporter:parse_twee(twee_content)
    local story_data = {
        title = "",
        author = "",
        ifid = "",
        format = "",
        formatVersion = "",
        startNode = "",
        passages = {}
    }

    -- Extract story title - look for :: StoryTitle followed by the title on next line
    local title_section = twee_content:match("::%s*StoryTitle%s*\n([^\n:]+)")
    if title_section then
        story_data.title = title_section:match("^%s*(.-)%s*$")
    end

    -- If title still empty, try without the :: prefix
    if story_data.title == "" then
        local title_line = twee_content:match("StoryTitle%s*\n([^\n:]+)")
        if title_line then
            story_data.title = title_line:match("^%s*(.-)%s*$")
        end
    end

    -- Extract StoryData
    local story_data_block = twee_content:match("::StoryData%s*\n(.-)::") or twee_content:match("::StoryData%s*\n(.+)")
    if story_data_block then
        -- Parse JSON (simplified)
        story_data.ifid = story_data_block:match('"ifid"%s*:%s*"([^"]*)"') or ""
        story_data.format = story_data_block:match('"format"%s*:%s*"([^"]*)"') or ""
    end

    -- Extract passages - improved approach
    -- Split content by :: to find all passages
    local passage_sections = {}
    local current_pos = 1

    -- Find all passage starts
    while true do
        local start_pos, end_pos, header = twee_content:find("::%s*([^\n]+)\n", current_pos)
        if not start_pos then break end

        -- Get content until next :: or end of string
        local content_start = end_pos + 1
        local next_passage = twee_content:find("\n::", content_start)
        local content_end = next_passage and (next_passage - 1) or #twee_content
        local content = twee_content:sub(content_start, content_end)

        table.insert(passage_sections, {header = header, content = content})
        current_pos = end_pos + 1
    end

    -- Parse each passage section
    for _, section in ipairs(passage_sections) do
        local header = section.header
        local content = section.content:match("^%s*(.-)%s*$") -- Trim whitespace

        -- Skip special passages
        if not header:match("^StoryTitle") and not header:match("^StoryData") then
            local passage = self:parse_passage_twee(header, content)
            if passage and passage.name then
                table.insert(story_data.passages, passage)
            end
        end
    end

    return story_data
end

-- Parse individual Twee passage
function TwineImporter:parse_passage_twee(header, text)
    local passage = {}

    -- Remove leading/trailing whitespace and :: if present
    header = header:gsub("^%s*::", ""):match("^%s*(.-)%s*$")

    -- Parse header: PassageName [tags] {position}
    local name = header:match("^([^%[{]+)")
    if name then
        passage.name = name:match("^%s*(.-)%s*$")
    else
        return nil  -- Invalid passage, no name
    end

    passage.text = text or ""
    passage.tags = {}
    passage.position = {x = 0, y = 0}
    passage.size = {width = 100, height = 100}
    passage.pid = "p" .. math.random(100000, 999999)

    -- Parse tags
    local tags = header:match("%[([^%]]+)%]")
    if tags then
        for tag in tags:gmatch("[^%s]+") do
            table.insert(passage.tags, tag)
        end
    end

    -- Parse position
    local position = header:match("{([^}]+)}")
    if position then
        local x, y = position:match("([^,]+),([^,]+)")
        passage.position = {x = tonumber(x) or 0, y = tonumber(y) or 0}
    end

    return passage
end

-- Detect Twine story format
function TwineImporter:detect_format(story_data)
    local format_lower = story_data.format:lower()

    if format_lower:match("harlowe") then
        return TwineImporter.SupportedFormats.HARLOWE
    elseif format_lower:match("sugarcube") then
        return TwineImporter.SupportedFormats.SUGARCUBE
    elseif format_lower:match("chapbook") then
        return TwineImporter.SupportedFormats.CHAPBOOK
    elseif format_lower:match("snowman") then
        return TwineImporter.SupportedFormats.SNOWMAN
    end

    -- Try to detect from passage content
    for _, passage in ipairs(story_data.passages) do
        local text = passage.text

        -- Harlowe detection
        if text:match("%(%s*set:") or text:match("%(%s*if:") then
            return TwineImporter.SupportedFormats.HARLOWE
        end

        -- SugarCube detection
        if text:match("<<set") or text:match("<<if") then
            return TwineImporter.SupportedFormats.SUGARCUBE
        end

        -- Chapbook detection
        if text:match("%[%s*if%s+") or text:match("%[continued%]") then
            return TwineImporter.SupportedFormats.CHAPBOOK
        end
    end

    return "unknown"
end

-- Convert to Whisker format
function TwineImporter:convert_to_whisker(story_data, story_format)
    -- Create base Whisker document
    local doc = self.format.create_document(story_data.title, story_data.author)

    -- Update metadata
    if story_data.ifid and story_data.ifid ~= "" then
        doc.metadata.ifid = story_data.ifid
    end

    -- Find start passage
    local start_passage = nil
    if story_data.startNode and story_data.startNode ~= "" then
        for _, passage in ipairs(story_data.passages) do
            if passage.pid == story_data.startNode then
                start_passage = passage.name
                break
            end
        end
    end

    -- Fallback to common start passage names
    if not start_passage then
        for _, passage in ipairs(story_data.passages) do
            local name_lower = passage.name:lower()
            if name_lower == "start" or name_lower == "begin" or name_lower == "intro" then
                start_passage = passage.name
                break
            end
        end
    end

    if start_passage then
        doc.settings.startPassage = start_passage
    end

    -- Convert passages
    for _, twine_passage in ipairs(story_data.passages) do
        local whisker_passage = self:convert_passage(twine_passage, story_format)
        table.insert(doc.passages, whisker_passage)
    end

    return doc
end

-- Convert individual passage
function TwineImporter:convert_passage(twine_passage, story_format)
    local passage = self.format.create_passage(
        twine_passage.pid,
        twine_passage.name,
        twine_passage.text
    )

    passage.tags = twine_passage.tags or {}
    passage.position = twine_passage.position or {x = 0, y = 0}
    passage.size = twine_passage.size or {width = 100, height = 100}

    -- Convert passage text based on format
    passage.text = self:convert_passage_text(twine_passage.text, story_format)

    return passage
end

-- Convert passage text from Twine format to whisker format
function TwineImporter:convert_passage_text(text, story_format)
    if story_format == TwineImporter.SupportedFormats.HARLOWE then
        return self:convert_from_harlowe(text)
    elseif story_format == TwineImporter.SupportedFormats.SUGARCUBE then
        return self:convert_from_sugarcube(text)
    elseif story_format == TwineImporter.SupportedFormats.CHAPBOOK then
        return self:convert_from_chapbook(text)
    end

    return text
end

-- Convert from Harlowe syntax
function TwineImporter:convert_from_harlowe(text)
    -- Convert (set: $var to value) -> {{var = value}}
    text = text:gsub("%(%s*set:%s*%$([%w_]+)%s+to%s+([^%)]+)%)", function(var, value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    -- Convert (if: condition)[text] -> {{if condition then}}text{{end}}
    text = text:gsub("%(%s*if:%s*([^%)]+)%)%[([^%]]+)%]", function(cond, body)
        return "{{if " .. cond .. " then}}" .. body .. "{{end}}"
    end)

    -- Convert [[link]] (already compatible)
    -- Convert [[text|passage]] (already compatible)

    -- Convert (print: $var) -> {{var}}
    text = text:gsub("%(%s*print:%s*%$([%w_]+)%)", function(var)
        return "{{" .. var .. "}}"
    end)

    return text
end

-- Convert from SugarCube syntax
function TwineImporter:convert_from_sugarcube(text)
    -- Convert <<set $var to value>> -> {{var = value}}
    text = text:gsub("<<set%s+%$([%w_]+)%s+to%s+([^>]+)>>", function(var, value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    -- Convert <<if condition>>text<<endif>> -> {{if condition then}}text{{end}}
    text = text:gsub("<<if%s+([^>]+)>>(.-)<</?endif>>", function(cond, body)
        return "{{if " .. cond .. " then}}" .. body .. "{{end}}"
    end)

    -- Convert <<print $var>> -> {{var}}
    text = text:gsub("<<print%s+%$([%w_]+)>>", function(var)
        return "{{" .. var .. "}}"
    end)

    -- Convert $var -> {{var}}
    text = text:gsub("%$([%w_]+)", function(var)
        return "{{" .. var .. "}}"
    end)

    return text
end

-- Convert from Chapbook syntax
function TwineImporter:convert_from_chapbook(text)
    -- Convert [if condition] -> {{if condition then}}
    text = text:gsub("%[if%s+([^%]]+)%]", function(cond)
        return "{{if " .. cond .. " then}}"
    end)

    -- Convert [continued] -> {{end}}
    text = text:gsub("%[continued%]", "{{end}}")

    -- Convert variable.name = value -> {{variable.name = value}}
    text = text:gsub("([%w_%.]+)%s*=%s*([^\n]+)", function(var, value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    return text
end

-- Decode HTML entities
function TwineImporter:decode_html_entities(text)
    local entities = {
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&quot;"] = '"',
        ["&apos;"] = "'",
        ["&amp;"] = "&",
        ["&#39;"] = "'",
        ["&#x27;"] = "'"
    }

    for entity, char in pairs(entities) do
        text = text:gsub(entity, char)
    end

    return text
end

-- Extract links from passage text
function TwineImporter:extract_links(text)
    local links = {}
    local seen = {}

    -- First pass: Match [[text->target]] pattern
    for display, target in text:gmatch("%[%[([^%]]+)->([^%]]+)%]%]") do
        local display_trim = display:match("^%s*(.-)%s*$")
        local target_trim = target:match("^%s*(.-)%s*$")
        local key = display_trim .. "->" .. target_trim
        if not seen[key] then
            table.insert(links, {
                text = display_trim,
                target = target_trim
            })
            seen[key] = true
        end
    end

    -- Second pass: Match [[target]] pattern (text and target are the same)
    -- But exclude any that have -> in them (already handled above)
    for match in text:gmatch("%[%[([^%]]+)%]%]") do
        if not match:match("->") then  -- Exclude arrow patterns
            local trimmed = match:match("^%s*(.-)%s*$")
            local key = trimmed .. "->" .. trimmed
            if not seen[key] then
                table.insert(links, {
                    text = trimmed,
                    target = trimmed
                })
                seen[key] = true
            end
        end
    end

    return links
end

-- Extract variables from passage text
function TwineImporter:extract_variables(text)
    local variables = {}
    local seen = {}

    -- Extract from Harlowe (set: $var to value)
    for var in text:gmatch("%(%s*set:%s*%$([%w_]+)") do
        if not seen[var] then
            table.insert(variables, var)
            seen[var] = true
        end
    end

    -- Extract from Harlowe (print: $var)
    for var in text:gmatch("%(%s*print:%s*%$([%w_]+)") do
        if not seen[var] then
            table.insert(variables, var)
            seen[var] = true
        end
    end

    -- Extract from Harlowe (if: $var)
    for var in text:gmatch("%(%s*if:%s*%$([%w_]+)") do
        if not seen[var] then
            table.insert(variables, var)
            seen[var] = true
        end
    end

    -- Extract from SugarCube <<set $var>>
    for var in text:gmatch("<<set%s+%$([%w_]+)") do
        if not seen[var] then
            table.insert(variables, var)
            seen[var] = true
        end
    end

    -- Extract from SugarCube $var usage
    for var in text:gmatch("%$([%w_]+)") do
        if not seen[var] then
            table.insert(variables, var)
            seen[var] = true
        end
    end

    return variables
end

return TwineImporter
