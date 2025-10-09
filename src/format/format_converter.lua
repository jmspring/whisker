-- Format Converter
-- Converts between different story formats
-- Supports: Whisker, Twine (HTML), Twee, JSON

local FormatConverter = {}

-- Supported format types
FormatConverter.FormatType = {
    WHISKER = "whisker",
    TWINE_HTML = "twine_html",
    TWEE = "twee",
    JSON = "json",
    MARKDOWN = "markdown"
}

-- Create new converter instance
function FormatConverter.new(whisker_format, twine_importer)
    local self = setmetatable({}, {__index = FormatConverter})
    self.format = whisker_format or require("src.format.whisker_format")
    self.importer = twine_importer or require("src.format.twine_importer").new(self.format)
    return self
end

-- Convert between formats
function FormatConverter:convert(input_data, input_format, output_format, options)
    options = options or {}

    -- First, convert input to Whisker format (canonical representation)
    local whisker_doc, err = self:to_whisker(input_data, input_format)
    if not whisker_doc then
        return nil, "Failed to convert to Whisker: " .. tostring(err)
    end

    -- Then convert from Whisker to target format
    local output, err = self:from_whisker(whisker_doc, output_format, options)
    if not output then
        return nil, "Failed to convert from Whisker: " .. tostring(err)
    end

    return output, nil
end

-- Convert input to Whisker format
function FormatConverter:to_whisker(input_data, input_format)
    if input_format == FormatConverter.FormatType.WHISKER then
        -- Already in Whisker format
        if type(input_data) == "string" then
            return self.format.from_json(input_data)
        end
        return input_data, nil

    elseif input_format == FormatConverter.FormatType.TWINE_HTML then
        return self.importer:import_from_html(input_data)

    elseif input_format == FormatConverter.FormatType.TWEE then
        return self.importer:import_from_twee(input_data)

    elseif input_format == FormatConverter.FormatType.JSON then
        -- Parse JSON and validate
        local doc = self.format.from_json(input_data)
        if not doc then
            return nil, "Invalid JSON"
        end

        local valid, errors = self.format.validate(doc)
        if not valid then
            return nil, "Validation failed: " .. table.concat(errors, "; ")
        end

        return doc, nil

    else
        return nil, "Unsupported input format: " .. tostring(input_format)
    end
end

-- Convert Whisker document to target format
function FormatConverter:from_whisker(whisker_doc, output_format, options)
    if output_format == FormatConverter.FormatType.WHISKER then
        return whisker_doc, nil

    elseif output_format == FormatConverter.FormatType.JSON then
        return self.format.to_json(whisker_doc), nil

    elseif output_format == FormatConverter.FormatType.TWINE_HTML then
        return self:to_twine_html(whisker_doc, options)

    elseif output_format == FormatConverter.FormatType.TWEE then
        return self:to_twee(whisker_doc, options)

    elseif output_format == FormatConverter.FormatType.MARKDOWN then
        return self:to_markdown(whisker_doc, options)

    else
        return nil, "Unsupported output format: " .. tostring(output_format)
    end
end

-- Export to Twine HTML format
function FormatConverter:to_twine_html(doc, options)
    options = options or {}
    local target_format = options.target_format or "Harlowe"
    local format_version = options.format_version or "3.3.0"

    local html = {}

    -- HTML header
    table.insert(html, '<!DOCTYPE html>')
    table.insert(html, '<html>')
    table.insert(html, '<head>')
    table.insert(html, '<meta charset="utf-8">')
    table.insert(html, '<title>' .. self:escape_html(doc.metadata.title) .. '</title>')
    table.insert(html, '</head>')
    table.insert(html, '<body>')

    -- Story data header
    local start_pid = self:find_start_passage_pid(doc)
    table.insert(html, string.format(
        '<tw-storydata name="%s" startnode="%s" creator="Whisker" creator-version="1.0" ifid="%s" format="%s" format-version="%s">',
        self:escape_html(doc.metadata.title),
        start_pid,
        doc.metadata.ifid,
        target_format,
        format_version
    ))

    -- Convert passages
    for _, passage in ipairs(doc.passages or {}) do
        local converted_text = self:convert_whisker_to_twine(passage.text, target_format)
        local position = string.format("%d,%d", passage.position.x, passage.position.y)
        local size = string.format("%d,%d", passage.size.width, passage.size.height)
        local tags = table.concat(passage.tags or {}, " ")

        table.insert(html, string.format(
            '<tw-passagedata pid="%s" name="%s" tags="%s" position="%s" size="%s">%s</tw-passagedata>',
            passage.pid,
            self:escape_html(passage.name),
            tags,
            position,
            size,
            self:escape_html(converted_text)
        ))
    end

    table.insert(html, '</tw-storydata>')
    table.insert(html, '</body>')
    table.insert(html, '</html>')

    return table.concat(html, "\n"), nil
end

-- Export to Twee notation
function FormatConverter:to_twee(doc, options)
    local twee = {}

    -- Story metadata
    table.insert(twee, ":: StoryTitle")
    table.insert(twee, doc.metadata.title)
    table.insert(twee, "")

    table.insert(twee, ":: StoryData")
    table.insert(twee, "{")
    table.insert(twee, '  "ifid": "' .. doc.metadata.ifid .. '",')
    table.insert(twee, '  "format": "Whisker",')
    table.insert(twee, '  "format-version": "' .. self.format.VERSION .. '"')
    table.insert(twee, "}")
    table.insert(twee, "")

    -- Convert passages
    for _, passage in ipairs(doc.passages or {}) do
        -- Passage header with tags and position
        local header = ":: " .. passage.name

        if passage.tags and #passage.tags > 0 then
            header = header .. " [" .. table.concat(passage.tags, " ") .. "]"
        end

        if passage.position then
            header = header .. string.format(" {%d,%d}", passage.position.x, passage.position.y)
        end

        table.insert(twee, header)
        table.insert(twee, passage.text or "")
        table.insert(twee, "")
    end

    return table.concat(twee, "\n"), nil
end

-- Export to Markdown format
function FormatConverter:to_markdown(doc, options)
    local md = {}

    -- Title and metadata
    table.insert(md, "# " .. doc.metadata.title)
    table.insert(md, "")
    table.insert(md, "**Author:** " .. (doc.metadata.author or "Unknown"))
    table.insert(md, "**Created:** " .. (doc.metadata.created or "Unknown"))
    table.insert(md, "")

    if doc.metadata.description and doc.metadata.description ~= "" then
        table.insert(md, doc.metadata.description)
        table.insert(md, "")
    end

    -- Table of contents
    table.insert(md, "## Passages")
    table.insert(md, "")
    for _, passage in ipairs(doc.passages or {}) do
        table.insert(md, "- [" .. passage.name .. "](#" .. self:slugify(passage.name) .. ")")
    end
    table.insert(md, "")

    -- Passages
    for _, passage in ipairs(doc.passages or {}) do
        table.insert(md, "---")
        table.insert(md, "")
        table.insert(md, "## " .. passage.name)
        table.insert(md, "")

        if passage.tags and #passage.tags > 0 then
            table.insert(md, "*Tags: " .. table.concat(passage.tags, ", ") .. "*")
            table.insert(md, "")
        end

        -- Convert Whisker text to readable markdown
        local readable_text = self:convert_whisker_to_markdown(passage.text)
        table.insert(md, readable_text)
        table.insert(md, "")
    end

    return table.concat(md, "\n"), nil
end

-- Convert Whisker syntax to Twine format
function FormatConverter:convert_whisker_to_twine(text, target_format)
    target_format = target_format or "Harlowe"

    if target_format:lower():match("harlowe") then
        return self:convert_to_harlowe(text)
    elseif target_format:lower():match("sugarcube") then
        return self:convert_to_sugarcube(text)
    elseif target_format:lower():match("chapbook") then
        return self:convert_to_chapbook(text)
    elseif target_format:lower():match("snowman") then
        return self:convert_to_snowman(text)
    end

    return text
end

-- Convert to Harlowe syntax
function FormatConverter:convert_to_harlowe(text)
    -- Convert {{var = value}} -> (set: $var to value)
    text = text:gsub("{{%s*([%w_]+)%s*=%s*([^}]+)%s*}}", function(var, value)
        return "(set: $" .. var .. " to " .. value .. ")"
    end)

    -- Convert {{if condition then}}...{{end}} -> (if: condition)[...]
    text = text:gsub("{{%s*if%s+(.-)%s+then%s*}}(.-){{%s*end%s*}}", function(cond, body)
        return "(if: " .. cond .. ")[" .. body .. "]"
    end)

    -- Convert {{var}} -> (print: $var)
    text = text:gsub("{{%s*([%w_]+)%s*}}", function(var)
        return "(print: $" .. var .. ")"
    end)

    return text
end

-- Convert to SugarCube syntax
function FormatConverter:convert_to_sugarcube(text)
    -- Convert {{var = value}} -> <<set $var to value>>
    text = text:gsub("{{%s*([%w_]+)%s*=%s*([^}]+)%s*}}", function(var, value)
        return "<<set $" .. var .. " to " .. value .. ">>"
    end)

    -- Convert {{if condition then}}...{{end}} -> <<if condition>>...<<endif>>
    text = text:gsub("{{%s*if%s+(.-)%s+then%s*}}(.-){{%s*end%s*}}", function(cond, body)
        return "<<if " .. cond .. ">>" .. body .. "<<endif>>"
    end)

    -- Convert {{var}} -> <<print $var>>
    text = text:gsub("{{%s*([%w_]+)%s*}}", function(var)
        return "<<print $" .. var .. ">>"
    end)

    return text
end

-- Convert to Chapbook syntax
function FormatConverter:convert_to_chapbook(text)
    -- Convert {{if condition then}}...{{end}} -> [if condition]...[continued]
    text = text:gsub("{{%s*if%s+(.-)%s+then%s*}}(.-){{%s*end%s*}}", function(cond, body)
        return "[if " .. cond .. "]\n" .. body .. "\n[continued]"
    end)

    -- Convert {{var = value}} -> variable = value
    text = text:gsub("{{%s*([%w_]+)%s*=%s*([^}]+)%s*}}", function(var, value)
        return var .. " = " .. value
    end)

    -- Convert {{var}} -> {var}
    text = text:gsub("{{%s*([%w_]+)%s*}}", function(var)
        return "{" .. var .. "}"
    end)

    return text
end

-- Convert to Snowman syntax
function FormatConverter:convert_to_snowman(text)
    -- Convert {{var = value}} -> <% s.var = value; %>
    text = text:gsub("{{%s*([%w_]+)%s*=%s*([^}]+)%s*}}", function(var, value)
        return "<% s." .. var .. " = " .. value .. "; %>"
    end)

    -- Convert {{if condition then}}...{{else}}...{{end}} -> <% if (condition) { %>...<% } else { %>...<% } %>
    text = text:gsub("{{%s*if%s+(.-)%s+then%s*}}(.-){{%s*else%s*}}(.-){{%s*end%s*}}", function(cond, if_body, else_body)
        local js_cond = self:convert_condition_to_js(cond)
        return "<% if (" .. js_cond .. ") { %>" .. if_body .. "<% } else { %>" .. else_body .. "<% } %>"
    end)

    -- Convert {{if condition then}}...{{end}} -> <% if (condition) { %>...<% } %>
    text = text:gsub("{{%s*if%s+(.-)%s+then%s*}}(.-){{%s*end%s*}}", function(cond, body)
        local js_cond = self:convert_condition_to_js(cond)
        return "<% if (" .. js_cond .. ") { %>" .. body .. "<% } %>"
    end)

    -- Convert {{var}} -> <%= s.var %>
    text = text:gsub("{{%s*([%w_]+)%s*}}", function(var)
        return "<%= s." .. var .. " %>"
    end)

    return text
end

-- Helper: Convert Lua-style condition to JavaScript
function FormatConverter:convert_condition_to_js(condition)
    -- Replace Lua operators with JavaScript equivalents
    local js_cond = condition

    -- Replace variable references with s.variable
    js_cond = js_cond:gsub("([%w_]+)", function(var)
        -- Don't replace keywords
        if var == "and" or var == "or" or var == "not" or var == "true" or var == "false" then
            return var
        end
        -- Check if it's a number
        if tonumber(var) then
            return var
        end
        -- Replace with s.variable
        return "s." .. var
    end)

    -- Replace Lua logical operators
    js_cond = js_cond:gsub("%s+and%s+", " && ")
    js_cond = js_cond:gsub("%s+or%s+", " || ")
    js_cond = js_cond:gsub("not%s+", "!")

    return js_cond
end

-- Convert Whisker syntax to readable Markdown
function FormatConverter:convert_whisker_to_markdown(text)
    -- Convert {{var = value}} -> *Set var to value*
    text = text:gsub("{{%s*([%w_]+)%s*=%s*([^}]+)%s*}}", function(var, value)
        return "*Set " .. var .. " to " .. value .. "*"
    end)

    -- Convert {{if condition then}}...{{end}} -> *If condition:* ...
    text = text:gsub("{{%s*if%s+(.-)%s+then%s*}}(.-){{%s*end%s*}}", function(cond, body)
        return "*If " .. cond .. ":* " .. body
    end)

    -- Convert {{var}} -> *var*
    text = text:gsub("{{%s*([%w_]+)%s*}}", function(var)
        return "*" .. var .. "*"
    end)

    -- Keep [[links]] as is (already markdown-like)

    return text
end

-- Helper: Find start passage PID
function FormatConverter:find_start_passage_pid(doc)
    local start_name = doc.settings.startPassage or "Start"

    for _, passage in ipairs(doc.passages or {}) do
        if passage.name == start_name then
            return passage.pid
        end
    end

    -- Fallback to first passage
    if doc.passages and #doc.passages > 0 then
        return doc.passages[1].pid
    end

    return "1"
end

-- Helper: Escape HTML entities
function FormatConverter:escape_html(text)
    local entities = {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;"
    }

    return (text:gsub("[&<>\"']", entities))
end

-- Helper: Create URL-friendly slug
function FormatConverter:slugify(text)
    text = text:lower()
    text = text:gsub("[^%w%s-]", "")
    text = text:gsub("%s+", "-")
    return text
end

-- Batch convert multiple files
function FormatConverter:batch_convert(files, input_format, output_format, options)
    local results = {}
    local errors = {}

    for i, file_data in ipairs(files) do
        local output, err = self:convert(file_data.content, input_format, output_format, options)

        if err then
            table.insert(errors, {
                file = file_data.name or ("file_" .. i),
                error = err
            })
        else
            table.insert(results, {
                name = file_data.name or ("file_" .. i),
                content = output
            })
        end
    end

    return results, errors
end

return FormatConverter