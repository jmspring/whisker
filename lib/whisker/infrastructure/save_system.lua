-- src/system/save_system.lua
-- Save and load functionality for game state

local SaveSystem = {}
SaveSystem.__index = SaveSystem

function SaveSystem.new(config)
    config = config or {}
    local instance = {
        config = config,
        save_dir = config.save_dir or "saves",
        max_save_slots = config.max_save_slots or 5,
        auto_save_slot = "autosave",
        quick_save_slot = "quicksave"
    }

    setmetatable(instance, SaveSystem)
    return instance
end

function SaveSystem:save_game(slot_name, game_state, story_data)
    if not slot_name or slot_name == "" then
        return false, "Slot name is required"
    end

    if not game_state then
        return false, "Game state is required"
    end

    -- Create save data
    local save_data = {
        metadata = {
            slot_name = slot_name,
            timestamp = os.time(),
            date = os.date("%Y-%m-%d %H:%M:%S"),
            version = "1.0.0"
        },

        game_state = self:serialize_game_state(game_state),

        story_info = story_data and {
            id = story_data.id,
            name = story_data.name,
            version = story_data.version
        } or {}
    }

    -- Convert to JSON
    local json = require("whisker.utils.json")
    local json_data = json.encode(save_data)

    -- Write to file (platform-specific implementation)
    local success, err = self:write_save_file(slot_name, json_data)

    if not success then
        return false, err
    end

    return true
end

function SaveSystem:load_game(slot_name)
    if not slot_name or slot_name == "" then
        return nil, "Slot name is required"
    end

    -- Read save file
    local json_data, err = self:read_save_file(slot_name)

    if not json_data then
        return nil, err
    end

    -- Parse JSON
    local json = require("whisker.utils.json")
    local save_data = json.decode(json_data)

    if not save_data then
        return nil, "Failed to parse save data"
    end

    -- Deserialize game state (with metatable restoration)
    local game_state = self:deserialize_game_state(save_data.game_state)

    -- Restore story data if present (with metatable restoration)
    local story = nil
    if save_data.story_data then
        local Story = require("whisker.core.story")
        story = Story.from_table(save_data.story_data)
    end

    return {
        game_state = game_state,
        story = story,
        metadata = save_data.metadata,
        story_info = save_data.story_info
    }
end

function SaveSystem:serialize_game_state(game_state)
    return {
        current_passage = game_state.current_passage,
        variables = game_state.variables,
        visited_passages = game_state.visited_passages,
        choice_history = game_state.choice_history,
        history_stack = game_state.history_stack,
        start_time = game_state.start_time,
        version = game_state.version
    }
end

function SaveSystem:deserialize_game_state(data)
    local GameState = require("whisker.core.game_state")
    local game_state = GameState.new()

    game_state.current_passage = data.current_passage
    game_state.variables = data.variables or {}
    game_state.visited_passages = data.visited_passages or {}
    game_state.choice_history = data.choice_history or {}
    game_state.history_stack = data.history_stack or {}
    game_state.start_time = data.start_time
    game_state.version = data.version or "1.0.0"

    return game_state
end

function SaveSystem:list_saves()
    -- Platform-specific implementation
    local saves = {}

    for i = 1, self.max_save_slots do
        local slot_name = "slot_" .. i
        local metadata = self:get_save_metadata(slot_name)

        if metadata then
            table.insert(saves, metadata)
        end
    end

    -- Check auto-save
    local auto_metadata = self:get_save_metadata(self.auto_save_slot)
    if auto_metadata then
        table.insert(saves, auto_metadata)
    end

    -- Check quick-save
    local quick_metadata = self:get_save_metadata(self.quick_save_slot)
    if quick_metadata then
        table.insert(saves, quick_metadata)
    end

    return saves
end

function SaveSystem:get_save_metadata(slot_name)
    local json_data, err = self:read_save_file(slot_name)

    if not json_data then
        return nil
    end

    local json = require("whisker.utils.json")
    local save_data = json.decode(json_data)

    if save_data and save_data.metadata then
        return save_data.metadata
    end

    return nil
end

function SaveSystem:delete_save(slot_name)
    if not slot_name or slot_name == "" then
        return false, "Slot name is required"
    end

    return self:delete_save_file(slot_name)
end

function SaveSystem:auto_save(game_state, story_data)
    return self:save_game(self.auto_save_slot, game_state, story_data)
end

function SaveSystem:quick_save(game_state, story_data)
    return self:save_game(self.quick_save_slot, game_state, story_data)
end

function SaveSystem:quick_load()
    return self:load_game(self.quick_save_slot)
end

-- Platform-specific file operations
function SaveSystem:write_save_file(slot_name, data)
    local filename = self.save_dir .. "/" .. slot_name .. ".sav"

    -- Try to use platform-specific file operations
    local file_utils = require("whisker.utils.file_utils")
    return file_utils.write_file(filename, data)
end

function SaveSystem:read_save_file(slot_name)
    local filename = self.save_dir .. "/" .. slot_name .. ".sav"

    local file_utils = require("whisker.utils.file_utils")
    return file_utils.read_file(filename)
end

function SaveSystem:delete_save_file(slot_name)
    local filename = self.save_dir .. "/" .. slot_name .. ".sav"

    local file_utils = require("whisker.utils.file_utils")
    return file_utils.delete_file(filename)
end

return SaveSystem
