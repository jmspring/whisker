-- src/format/story_to_whisker.lua
-- Converts Story objects (from Lua stories) to Whisker JSON format

local story_to_whisker = {}

local json = require("engine.utils.json")

-- Convert a Story object to Whisker JSON document structure
function story_to_whisker.convert(story)
    if not story then
        return nil, "Story object is nil"
    end

    -- Create base document structure
    local document = {
        format = "whisker",
        formatVersion = "1.0",
        metadata = {
            name = story.metadata.name or story.title or "Untitled Story",
            title = story.metadata.name or story.title or "Untitled Story",
            author = story.metadata.author or story.author or "Unknown",
            created = story.metadata.created or os.date("%Y-%m-%dT%H:%M:%S"),
            modified = story.metadata.modified or os.date("%Y-%m-%dT%H:%M:%S"),
            ifid = story.metadata.ifid or story_to_whisker.generate_ifid(),
            version = story.metadata.version or story.version or "1.0",
            description = story.metadata.description or "",
            format = "whisker",
            format_version = "1.0"
        },
        settings = {
            startPassage = story.start_passage or "start",
            theme = "default",
            scriptingLanguage = "lua",
            undoLimit = 50,
            autoSave = true
        },
        passages = {},
        variables = story.variables or {},
        scripts = story.scripts or {},
        stylesheets = story.stylesheets or {},
        assets = {}
    }

    -- Convert passages
    local passage_id = 1
    for id, passage in pairs(story.passages or {}) do
        local whisker_passage = story_to_whisker.convert_passage(passage, passage_id)
        if whisker_passage then
            table.insert(document.passages, whisker_passage)
            passage_id = passage_id + 1
        end
    end

    return document
end

-- Convert a Passage object to Whisker passage structure
function story_to_whisker.convert_passage(passage, pid)
    if not passage then
        return nil
    end

    local whisker_passage = {
        pid = "p" .. (pid or math.random(100000, 999999)),
        id = passage.id,
        name = passage.name or passage.id,
        content = passage.content or "",
        text = passage.content or "",  -- Duplicate for compatibility
        tags = passage.tags or {},
        position = passage.position or {x = 0, y = 0},
        size = passage.size or {width = 100, height = 100},
        metadata = passage.metadata or {},
        choices = {}
    }

    -- Convert choices
    if passage.choices then
        for _, choice in ipairs(passage.choices) do
            local whisker_choice = story_to_whisker.convert_choice(choice)
            if whisker_choice then
                table.insert(whisker_passage.choices, whisker_choice)
            end
        end
    end

    return whisker_passage
end

-- Convert a Choice object to Whisker choice structure
function story_to_whisker.convert_choice(choice)
    if not choice then
        return nil
    end

    return {
        text = choice.text or "",
        target_passage = choice.target or choice.target_passage,
        condition = choice.condition,
        metadata = choice.metadata or {}
    }
end

-- Generate IFID if not present
function story_to_whisker.generate_ifid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%X", v)
    end)
end

-- Convert and serialize to JSON string
function story_to_whisker.to_json(story)
    local document = story_to_whisker.convert(story)
    if not document then
        return nil, "Failed to convert story"
    end

    local success, json_string = pcall(json.encode, document)
    if not success then
        return nil, "Failed to encode JSON: " .. tostring(json_string)
    end

    return json_string
end

return story_to_whisker
