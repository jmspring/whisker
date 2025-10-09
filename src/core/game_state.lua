-- src/core/game_state.lua
-- Complete state management with undo/redo, inventory, and serialization

local GameState = {}
GameState.__index = GameState

function GameState:new()
    local instance = {
        -- Core state
        variables = {},
        current_passage = nil,
        visited_passages = {},
        choice_history = {},

        -- Undo system
        history_stack = {},
        max_history = 10,

        -- Metadata
        story_id = nil,
        start_time = nil,
        save_time = nil,
        version = "1.0.0"
    }

    setmetatable(instance, GameState)
    return instance
end

function GameState:initialize(story)
    self.story_id = story.metadata and story.metadata.uuid or story.metadata and story.metadata.ifid or nil
    self.start_time = os.time()
    self.variables = {}
    self.current_passage = nil
    self.visited_passages = {}
    self.choice_history = {}
    self.history_stack = {}

    -- Initialize default variables from story
    if story.variables then
        for k, v in pairs(story.variables) do
            self.variables[k] = v
        end
    end
end

function GameState:set_current_passage(passage_id)
    -- Save current state to history before changing
    if self.current_passage then
        self:push_to_history()
    end

    -- Update current passage
    self.current_passage = passage_id

    -- Track visit
    if not self.visited_passages[passage_id] then
        self.visited_passages[passage_id] = 0
    end
    self.visited_passages[passage_id] = self.visited_passages[passage_id] + 1
end

function GameState:get_current_passage()
    return self.current_passage
end

function GameState:get_visit_count(passage_id)
    return self.visited_passages[passage_id] or 0
end

function GameState:has_visited(passage_id)
    return self.visited_passages[passage_id] ~= nil
end

function GameState:set(key, value)
    local old_value = self.variables[key]
    self.variables[key] = value
    return old_value
end

function GameState:get(key, default_value)
    local value = self.variables[key]
    if value == nil then
        return default_value
    end
    return value
end

function GameState:increment(key, amount)
    amount = amount or 1
    local current = self:get(key, 0)
    if type(current) == "number" then
        self:set(key, current + amount)
        return current + amount
    end
    return nil
end

function GameState:decrement(key, amount)
    amount = amount or 1
    return self:increment(key, -amount)
end

function GameState:delete(key)
    local old_value = self.variables[key]
    self.variables[key] = nil
    return old_value
end

function GameState:has(key)
    return self.variables[key] ~= nil
end

function GameState:push_to_history()
    -- Create snapshot of current state
    local snapshot = {
        current_passage = self.current_passage,
        variables = self:clone_table(self.variables),
        visited_passages = self:clone_table(self.visited_passages),
        timestamp = os.time()
    }

    table.insert(self.history_stack, snapshot)

    -- Trim history if too large
    while #self.history_stack > self.max_history do
        table.remove(self.history_stack, 1)
    end
end

function GameState:can_undo()
    return #self.history_stack > 0
end

function GameState:undo()
    if not self:can_undo() then
        return nil
    end

    local snapshot = table.remove(self.history_stack)

    -- Restore state from snapshot
    self.current_passage = snapshot.current_passage
    self.variables = self:clone_table(snapshot.variables)
    self.visited_passages = self:clone_table(snapshot.visited_passages)

    return snapshot
end

function GameState:clone_table(original)
    if type(original) ~= "table" then
        return original
    end

    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = self:clone_table(v)
        else
            copy[k] = v
        end
    end

    return copy
end

function GameState:serialize()
    local data = {
        version = self.version,
        story_id = self.story_id,
        start_time = self.start_time,
        save_time = os.time(),
        current_passage = self.current_passage,
        variables = self.variables,
        visited_passages = self.visited_passages,
        choice_history = self.choice_history
    }

    return data
end

function GameState:deserialize(data)
    if not data or data.version ~= self.version then
        return false, "Incompatible save data version"
    end

    self.story_id = data.story_id
    self.start_time = data.start_time
    self.save_time = data.save_time
    self.current_passage = data.current_passage
    self.variables = data.variables or {}
    self.visited_passages = data.visited_passages or {}
    self.choice_history = data.choice_history or {}
    self.history_stack = {}

    return true
end

function GameState:reset()
    self.variables = {}
    self.current_passage = nil
    self.visited_passages = {}
    self.choice_history = {}
    self.history_stack = {}
    self.start_time = os.time()
end

return GameState
