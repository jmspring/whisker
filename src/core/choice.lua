-- src/core/choice.lua
-- Choice handling with conditions

local Choice = {}
Choice.__index = Choice

function Choice:new(text_or_options, target)
    -- Support both old table-based and new parameter patterns
    local options = {}
    if type(text_or_options) == "table" then
        options = text_or_options
    else
        options.text = text_or_options
        options.target = target
    end

    local instance = {
        text = options.text or "",
        target_passage = options.target or options.target_passage or nil,
        condition = options.condition or nil,
        action = options.action or nil,
        metadata = options.metadata or {}
    }

    setmetatable(instance, Choice)
    return instance
end

function Choice:set_text(text)
    self.text = text
end

function Choice:get_text()
    return self.text
end

function Choice:set_target(target_passage_id)
    self.target_passage = target_passage_id
end

function Choice:get_target()
    return self.target_passage
end

function Choice:set_condition(condition_code)
    self.condition = condition_code
end

function Choice:get_condition()
    return self.condition
end

function Choice:has_condition()
    return self.condition ~= nil and self.condition ~= ""
end

function Choice:set_action(action_code)
    self.action = action_code
end

function Choice:get_action()
    return self.action
end

function Choice:has_action()
    return self.action ~= nil and self.action ~= ""
end

function Choice:set_metadata(key, value)
    self.metadata[key] = value
end

function Choice:get_metadata(key)
    return self.metadata[key]
end

function Choice:validate()
    if not self.text or self.text == "" then
        return false, "Choice text is required"
    end

    if not self.target_passage or self.target_passage == "" then
        return false, "Choice target passage is required"
    end

    return true
end

function Choice:serialize()
    return {
        text = self.text,
        target_passage = self.target_passage,
        condition = self.condition,
        action = self.action,
        metadata = self.metadata
    }
end

function Choice:deserialize(data)
    self.text = data.text or ""
    self.target_passage = data.target_passage
    self.condition = data.condition
    self.action = data.action
    self.metadata = data.metadata or {}
end

-- Static method to restore metatable to a table
function Choice.restore_metatable(data)
    if not data or type(data) ~= "table" then
        return nil
    end

    -- If already has Choice metatable, return as-is
    if getmetatable(data) == Choice then
        return data
    end

    -- Set the Choice metatable
    setmetatable(data, Choice)

    return data
end

-- Static method to create from plain table (useful for deserialization)
function Choice.from_table(data)
    if not data then
        return nil
    end

    -- Create a new instance with the data
    return Choice:new({
        text = data.text,
        target = data.target_passage,
        condition = data.condition,
        action = data.action,
        metadata = data.metadata
    })
end

return Choice
