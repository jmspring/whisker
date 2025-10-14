-- src/core/passage.lua
-- Passage representation with metadata

local Passage = {}
Passage.__index = Passage

function Passage.new(id_or_options, name)
    -- Support both old table-based and new parameter patterns
    local options = {}
    if type(id_or_options) == "table" then
        options = id_or_options
    else
        options.id = id_or_options
        options.name = name
    end

    local instance = {
        id = options.id or "",
        name = options.name or options.id or "",
        tags = options.tags or {},
        content = options.content or "",
        choices = options.choices or {},
        position = options.position or {x = 0, y = 0},
        size = options.size or {width = 100, height = 100},
        metadata = options.metadata or {},
        on_enter_script = options.on_enter_script or nil,
        on_exit_script = options.on_exit_script or nil
    }

    setmetatable(instance, Passage)
    return instance
end

function Passage:set_content(content)
    self.content = content
end

function Passage:get_content()
    return self.content
end

function Passage:add_choice(choice)
    table.insert(self.choices, choice)
end

function Passage:get_choices()
    return self.choices
end

function Passage:remove_choice(index)
    table.remove(self.choices, index)
end

function Passage:add_tag(tag)
    table.insert(self.tags, tag)
end

function Passage:has_tag(tag)
    for _, t in ipairs(self.tags) do
        if t == tag then
            return true
        end
    end
    return false
end

function Passage:set_position(x, y)
    self.position.x = x
    self.position.y = y
end

function Passage:get_position()
    return self.position.x, self.position.y
end

function Passage:set_metadata(key, value)
    self.metadata[key] = value
end

function Passage:get_metadata(key)
    return self.metadata[key]
end

function Passage:set_on_enter_script(script)
    self.on_enter_script = script
end

function Passage:set_on_exit_script(script)
    self.on_exit_script = script
end

function Passage:validate()
    if not self.id or self.id == "" then
        return false, "Passage ID is required"
    end

    if not self.name or self.name == "" then
        return false, "Passage name is required"
    end

    -- Validate choices
    for i, choice in ipairs(self.choices) do
        local valid, err = choice:validate()
        if not valid then
            return false, "Choice " .. i .. ": " .. err
        end
    end

    return true
end

function Passage:serialize()
    return {
        id = self.id,
        name = self.name,
        tags = self.tags,
        content = self.content,
        choices = self.choices,
        position = self.position,
        size = self.size,
        metadata = self.metadata,
        on_enter_script = self.on_enter_script,
        on_exit_script = self.on_exit_script
    }
end

function Passage:deserialize(data)
    self.id = data.id
    self.name = data.name
    self.tags = data.tags or {}
    self.content = data.content or ""
    self.choices = data.choices or {}
    self.position = data.position or {x = 0, y = 0}
    self.size = data.size or {width = 100, height = 100}
    self.metadata = data.metadata or {}
    self.on_enter_script = data.on_enter_script
    self.on_exit_script = data.on_exit_script

    -- Restore metatables for choice objects if needed
    if self.choices then
        local Choice = require("src.core.choice")
        for i, choice in ipairs(self.choices) do
            if type(choice) == "table" and not getmetatable(choice) then
                setmetatable(choice, Choice)
            end
        end
    end
end

-- Static method to restore metatable to a table
function Passage.restore_metatable(data)
    if not data or type(data) ~= "table" then
        return nil
    end

    -- If already has Passage metatable, return as-is
    if getmetatable(data) == Passage then
        return data
    end

    -- Set the Passage metatable
    setmetatable(data, Passage)

    -- Restore metatables for nested objects (choices)
    if data.choices then
        local Choice = require("src.core.choice")
        for i, choice in ipairs(data.choices) do
            if type(choice) == "table" and not getmetatable(choice) then
                -- Use Choice's restore method if available, otherwise set metatable directly
                if Choice.restore_metatable then
                    data.choices[i] = Choice.restore_metatable(choice)
                else
                    setmetatable(choice, Choice)
                end
            end
        end
    end

    return data
end

-- Static method to create from plain table (useful for deserialization)
function Passage.from_table(data)
    if not data then
        return nil
    end

    -- Create a new instance
    local instance = Passage.new({
        id = data.id,
        name = data.name,
        tags = data.tags,
        content = data.content,
        position = data.position,
        size = data.size,
        metadata = data.metadata,
        on_enter_script = data.on_enter_script,
        on_exit_script = data.on_exit_script
    })

    -- Restore choices with proper metatables
    if data.choices then
        local Choice = require("src.core.choice")
        for _, choice_data in ipairs(data.choices) do
            if type(choice_data) == "table" then
                local choice
                if Choice.from_table then
                    choice = Choice.from_table(choice_data)
                elseif Choice.restore_metatable then
                    choice = Choice.restore_metatable(choice_data)
                else
                    choice = choice_data
                    setmetatable(choice, Choice)
                end
                table.insert(instance.choices, choice)
            end
        end
    end

    return instance
end

return Passage
