-- src/format/whisker_loader.lua
-- Loads native Whisker JSON format files and converts them to Story objects
-- Supports both verbose (1.0) and compact (2.0) formats

local whisker_loader = {}

-- Load Story, Passage, and Choice classes
local Story = require("whisker.core.story")
local Passage = require("whisker.core.passage")
local Choice = require("whisker.core.choice")

-- Load JSON parser
local json = require("whisker.utils.json")

-- Load compact format converter
local CompactConverter = require("whisker.format.compact_converter")

-- Load a .whisker file and convert to Story object
function whisker_loader.load_from_file(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil, "Failed to open file: " .. filename
    end

    local json_text = file:read("*all")
    file:close()

    return whisker_loader.load_from_string(json_text)
end

-- Parse Whisker JSON string and convert to Story object
function whisker_loader.load_from_string(json_text)
    -- Parse JSON
    local data, err = json.decode(json_text)
    if not data then
        return nil, "Failed to parse JSON: " .. (err or "unknown error")
    end

    -- Validate format - check both top-level and metadata.format
    local format = data.format or (data.metadata and data.metadata.format)
    if format ~= "whisker" then
        return nil, "Invalid format: expected 'whisker', got '" .. tostring(format) .. "'"
    end

    -- Auto-convert compact format (2.0) to verbose format (1.0) for processing
    if data.formatVersion == "2.0" then
        local converter = CompactConverter.new()
        local verbose_data, conv_err = converter:to_verbose(data)
        if conv_err then
            return nil, "Failed to convert compact format: " .. conv_err
        end
        data = verbose_data
    end

    -- Create Story object
    local story_config = {
        title = data.metadata and (data.metadata.title or data.metadata.name) or "Untitled Story",
        author = data.metadata and data.metadata.author or "Unknown",
        ifid = data.metadata and data.metadata.ifid or "",
        version = data.formatVersion or (data.metadata and data.metadata.version) or "1.0",
        description = data.metadata and data.metadata.description or ""
    }

    local story = Story.new(story_config)

    -- Initialize variables
    if data.variables then
        story.variables = {}
        for k, v in pairs(data.variables) do
            story.variables[k] = v
        end
    end

    -- Convert passages (must be done before setting start passage)
    if data.passages then
        -- Handle both array and object formats
        if type(data.passages) == "table" then
            -- Check if it's an array or object
            local is_array = #data.passages > 0

            if is_array then
                -- Array format
                for i, passage_data in ipairs(data.passages) do
                    local passage = whisker_loader.convert_passage(passage_data)
                    if passage then
                        story:add_passage(passage)
                    end
                end
            else
                -- Object format (passage_id -> passage_data)
                for passage_id, passage_data in pairs(data.passages) do
                    local passage = whisker_loader.convert_passage(passage_data)
                    if passage then
                        story:add_passage(passage)
                    end
                end
            end
        end
    end

    -- Set start passage (after passages are added)
    local start_passage = data.settings and data.settings.startPassage
    if start_passage and story.passages[start_passage] then
        story:set_start_passage(start_passage)
    elseif story.start_passage and story.passages[story.start_passage] then
        -- Use existing start passage if valid
        story:set_start_passage(story.start_passage)
    else
        -- Find first passage and use that
        for id, _ in pairs(story.passages) do
            story:set_start_passage(id)
            break
        end
    end

    return story, nil
end

-- Convert a Whisker passage to a Passage object
function whisker_loader.convert_passage(passage_data)
    -- Support both formats: {id, text} and {name, content}
    -- Prefer id over name (id is the linking key, name is display name)
    local passage_id = passage_data.id or passage_data.name
    local passage_content = passage_data.text or passage_data.content

    if not passage_id then
        return nil
    end

    -- Create options table (separate from constructor call to avoid Lua quirks)
    local options_table = {
        id = passage_id,
        content = passage_content or "",
        position = passage_data.position,
        size = passage_data.size
    }

    local passage = Passage.new(options_table)

    -- Add tags
    if passage_data.tags then
        for _, tag in ipairs(passage_data.tags) do
            passage:add_tag(tag)
        end
    end

    -- Add choices - either from choices array or extract from text
    if passage_data.choices and #passage_data.choices > 0 then
        -- Use explicit choices array
        for _, choice_data in ipairs(passage_data.choices) do
            local choice_options = {
                text = choice_data.text,
                target = choice_data.target_passage or choice_data.target,
                condition = choice_data.condition
            }
            local choice = Choice.new(choice_options)
            passage:add_choice(choice)
        end
    else
        -- Extract choices from the text using Whisker link syntax
        local choices = whisker_loader.extract_choices(passage_data.text or passage_data.content or "")
        for _, choice in ipairs(choices) do
            passage:add_choice(choice)
        end
    end

    return passage
end

-- Extract choices from passage text
-- Supports formats:
--   [[text->target]]
--   [[target]]
--   {{#if condition}}[[text->target]]{{/if}}
function whisker_loader.extract_choices(text)
    local choices = {}
    local seen_choices = {}  -- Track to avoid duplicates

    -- Match [[text->target]] or [[target]]
    for match in text:gmatch("%[%[([^%]]+)%]%]") do
        local display_text, target

        -- Check for [[text->target]] format
        if match:match("(.-)%->(.+)") then
            display_text, target = match:match("(.-)%->(.+)")
            display_text = display_text:match("^%s*(.-)%s*$")  -- trim
            target = target:match("^%s*(.-)%s*$")  -- trim
        else
            -- [[target]] format
            target = match:match("^%s*(.-)%s*$")  -- trim
            display_text = target
        end

        -- Create unique key to avoid duplicates
        local choice_key = display_text .. "|" .. target
        if not seen_choices[choice_key] then
            -- Create options table separately (avoid Lua quirks with inline tables)
            local choice_options = {
                text = display_text,
                target = target
            }
            local choice = Choice.new(choice_options)
            table.insert(choices, choice)
            seen_choices[choice_key] = true
        end
    end

    return choices
end

-- Validate a Whisker document
function whisker_loader.validate(data)
    local errors = {}

    -- Check format
    if not data.format or data.format ~= "whisker" then
        table.insert(errors, "Invalid or missing format field")
    end

    -- Check metadata
    if not data.metadata then
        table.insert(errors, "Missing metadata")
    elseif not data.metadata.title then
        table.insert(errors, "Missing title in metadata")
    end

    -- Check passages
    if not data.passages then
        table.insert(errors, "Missing passages")
    elseif type(data.passages) ~= "table" then
        table.insert(errors, "Passages must be an array")
    else
        -- Validate each passage
        local passage_ids = {}
        local passage_names = {}
        for i, passage in ipairs(data.passages) do
            -- Check for id (preferred) or name
            local passage_id = passage.id or passage.name
            if not passage_id then
                table.insert(errors, "Passage " .. i .. " missing id/name")
            elseif passage_ids[passage_id] then
                table.insert(errors, "Duplicate passage id: " .. passage_id)
            else
                passage_ids[passage_id] = true
            end

            -- Also track names for legacy support
            if passage.name then
                passage_names[passage.name] = true
            end

            -- Check for text or content
            if not passage.text and not passage.content then
                table.insert(errors, "Passage '" .. (passage_id or i) .. "' missing text/content")
            end
        end

        -- Check start passage exists (check both ids and names)
        if data.settings and data.settings.startPassage then
            if not passage_ids[data.settings.startPassage] and not passage_names[data.settings.startPassage] then
                table.insert(errors, "Start passage not found: " .. data.settings.startPassage)
            end
        end
    end

    return #errors == 0, errors
end

return whisker_loader
