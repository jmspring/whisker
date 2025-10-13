-- src/core/story.lua
-- Story data structure and management

local Story = {}
Story.__index = Story

function Story.new(options)
    options = options or {}
    local instance = {
        metadata = {
            uuid = options.uuid or nil,
            name = options.title or options.name or "",
            author = options.author or "",
            version = options.version or "1.0.0",
            created = options.created or nil,
            modified = options.modified or nil,
            ifid = options.ifid or nil,
            format = options.format or "whisker",
            format_version = options.format_version or "1.0.0"
        },
        variables = options.variables or {},
        passages = options.passages or {},
        start_passage = options.start_passage or nil,
        stylesheets = options.stylesheets or {},
        scripts = options.scripts or {}
    }

    setmetatable(instance, Story)
    return instance
end

function Story:set_metadata(key, value)
    self.metadata[key] = value
end

function Story:get_metadata(key)
    return self.metadata[key]
end

function Story:add_passage(passage)
    if not passage or not passage.id then
        error("Invalid passage: missing id")
    end

    self.passages[passage.id] = passage
end

function Story:get_passage(passage_id)
    return self.passages[passage_id]
end

function Story:remove_passage(passage_id)
    self.passages[passage_id] = nil
end

function Story:get_all_passages()
    local list = {}
    for id, passage in pairs(self.passages) do
        table.insert(list, passage)
    end
    return list
end

function Story:set_start_passage(passage_id)
    if not self.passages[passage_id] then
        error("Cannot set start passage: passage '" .. passage_id .. "' does not exist")
    end
    self.start_passage = passage_id
end

function Story:get_start_passage()
    if self.start_passage then
        return self.start_passage
    end
    -- Return the first passage if no start passage set
    if self.passages then
        for id, _ in pairs(self.passages) do
            return id
        end
    end
    return nil
end

function Story:set_variable(key, value)
    self.variables[key] = value
end

function Story:get_variable(key)
    return self.variables[key]
end

function Story:add_stylesheet(css_code)
    table.insert(self.stylesheets, css_code)
end

function Story:add_script(script_code)
    table.insert(self.scripts, script_code)
end

function Story:validate()
    -- Check required metadata
    if not self.metadata.name or self.metadata.name == "" then
        return false, "Story name is required"
    end

    -- Check start passage
    if not self.start_passage then
        return false, "Start passage must be set"
    end

    if not self.passages[self.start_passage] then
        return false, "Start passage does not exist"
    end

    -- Check that all passages are valid
    for id, passage in pairs(self.passages) do
        local valid, err = passage:validate()
        if not valid then
            return false, "Passage '" .. id .. "': " .. err
        end
    end

    return true
end

function Story:serialize()
    return {
        metadata = self.metadata,
        variables = self.variables,
        passages = self.passages,
        start_passage = self.start_passage,
        stylesheets = self.stylesheets,
        scripts = self.scripts
    }
end

function Story:deserialize(data)
    self.metadata = data.metadata or self.metadata
    self.variables = data.variables or {}
    self.passages = data.passages or {}
    self.start_passage = data.start_passage
    self.stylesheets = data.stylesheets or {}
    self.scripts = data.scripts or {}

    -- Restore metatables for passage objects if needed
    if self.passages then
        local Passage = require("src.core.passage")
        for id, passage in pairs(self.passages) do
            if type(passage) == "table" and not getmetatable(passage) then
                setmetatable(passage, Passage)
            end
        end
    end
end

-- Static method to restore metatable to a table
function Story.restore_metatable(data)
    if not data or type(data) ~= "table" then
        return nil
    end

    -- If already has Story metatable, return as-is
    if getmetatable(data) == Story then
        return data
    end

    -- Set the Story metatable
    setmetatable(data, Story)

    -- Restore metatables for nested objects (passages)
    if data.passages then
        local Passage = require("src.core.passage")
        for id, passage in pairs(data.passages) do
            if type(passage) == "table" and not getmetatable(passage) then
                -- Use Passage's restore method if available, otherwise set metatable directly
                if Passage.restore_metatable then
                    data.passages[id] = Passage.restore_metatable(passage)
                else
                    setmetatable(passage, Passage)
                end
            end
        end
    end

    return data
end

-- Static method to create from plain table (useful for deserialization)
function Story.from_table(data)
    if not data then
        return nil
    end

    -- Create a new instance
    local instance = Story:new({
        uuid = data.metadata and data.metadata.uuid,
        title = data.metadata and data.metadata.name,
        author = data.metadata and data.metadata.author,
        version = data.metadata and data.metadata.version,
        created = data.metadata and data.metadata.created,
        modified = data.metadata and data.metadata.modified,
        ifid = data.metadata and data.metadata.ifid,
        format = data.metadata and data.metadata.format,
        format_version = data.metadata and data.metadata.format_version
    })

    -- Copy over the rest of the data
    instance.variables = data.variables or {}
    instance.start_passage = data.start_passage
    instance.stylesheets = data.stylesheets or {}
    instance.scripts = data.scripts or {}

    -- Restore passages with proper metatables
    if data.passages then
        local Passage = require("src.core.passage")
        for id, passage_data in pairs(data.passages) do
            if type(passage_data) == "table" then
                local passage
                if Passage.from_table then
                    passage = Passage.from_table(passage_data)
                elseif Passage.restore_metatable then
                    passage = Passage.restore_metatable(passage_data)
                else
                    passage = passage_data
                    setmetatable(passage, Passage)
                end
                instance.passages[id] = passage
            end
        end
    end

    return instance
end

return Story
