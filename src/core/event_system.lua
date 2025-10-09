-- whisker Event System
-- Manages event callbacks and game events
-- Provides publish-subscribe pattern for game events

local EventSystem = {}
EventSystem.__index = EventSystem

-- Event types
EventSystem.EventType = {
    -- Passage events
    PASSAGE_ENTERED = "passage_entered",
    PASSAGE_EXITED = "passage_exited",
    PASSAGE_DISPLAYED = "passage_displayed",

    -- Choice events
    CHOICE_SELECTED = "choice_selected",
    CHOICE_AVAILABLE = "choice_available",
    CHOICE_DISABLED = "choice_disabled",

    -- State events
    VARIABLE_CHANGED = "variable_changed",
    STATE_SAVED = "state_saved",
    STATE_LOADED = "state_loaded",

    -- Game events
    GAME_STARTED = "game_started",
    GAME_ENDED = "game_ended",
    GAME_PAUSED = "game_paused",
    GAME_RESUMED = "game_resumed",

    -- System events
    ERROR_OCCURRED = "error_occurred",
    WARNING_OCCURRED = "warning_occurred",
    SCRIPT_EXECUTED = "script_executed",

    -- Custom events
    CUSTOM = "custom"
}

-- Create new event system
function EventSystem.new()
    local self = setmetatable({}, EventSystem)

    -- Event listeners storage
    self.listeners = {}

    -- Event queue for deferred processing
    self.event_queue = {}

    -- Statistics
    self.stats = {
        events_fired = 0,
        events_queued = 0,
        listeners_registered = 0,
        errors = 0
    }

    -- Configuration
    self.config = {
        max_queue_size = 1000,
        enable_logging = false,
        enable_history = true,
        history_size = 100
    }

    -- Event history
    self.event_history = {}

    return self
end

-- Register event listener
function EventSystem:on(event_type, callback, context)
    if type(callback) ~= "function" then
        error("Event callback must be a function")
    end

    -- Initialize listener array for this event type
    if not self.listeners[event_type] then
        self.listeners[event_type] = {}
    end

    -- Create listener entry
    local listener = {
        callback = callback,
        context = context,
        id = self:generate_listener_id(),
        registered_at = os.time()
    }

    table.insert(self.listeners[event_type], listener)
    self.stats.listeners_registered = self.stats.listeners_registered + 1

    return listener.id
end

-- Register one-time event listener
function EventSystem:once(event_type, callback, context)
    local listener_id

    local wrapper = function(event_data)
        -- Call the original callback
        callback(event_data)

        -- Remove this listener after execution
        self:off(event_type, listener_id)
    end

    listener_id = self:on(event_type, wrapper, context)
    return listener_id
end

-- Remove event listener
function EventSystem:off(event_type, listener_id)
    if not self.listeners[event_type] then
        return false
    end

    -- Find and remove listener
    for i, listener in ipairs(self.listeners[event_type]) do
        if listener.id == listener_id then
            table.remove(self.listeners[event_type], i)
            return true
        end
    end

    return false
end

-- Remove all listeners for an event type
function EventSystem:off_all(event_type)
    if event_type then
        self.listeners[event_type] = {}
    else
        -- Remove all listeners for all events
        self.listeners = {}
    end
end

-- Emit event immediately
function EventSystem:emit(event_type, event_data)
    self.stats.events_fired = self.stats.events_fired + 1

    -- Create event object
    local event = {
        type = event_type,
        data = event_data or {},
        timestamp = os.time(),
        propagation_stopped = false
    }

    -- Log if enabled
    if self.config.enable_logging then
        self:log_event(event)
    end

    -- Add to history
    if self.config.enable_history then
        self:add_to_history(event)
    end

    -- Call all listeners
    if self.listeners[event_type] then
        for _, listener in ipairs(self.listeners[event_type]) do
            if not event.propagation_stopped then
                self:call_listener(listener, event)
            end
        end
    end

    return event
end

-- Queue event for deferred processing
function EventSystem:queue(event_type, event_data)
    if #self.event_queue >= self.config.max_queue_size then
        -- Remove oldest event
        table.remove(self.event_queue, 1)
    end

    table.insert(self.event_queue, {
        type = event_type,
        data = event_data,
        queued_at = os.time()
    })

    self.stats.events_queued = self.stats.events_queued + 1
end

-- Process queued events
function EventSystem:process_queue(max_events)
    max_events = max_events or #self.event_queue
    local processed = 0

    while #self.event_queue > 0 and processed < max_events do
        local queued_event = table.remove(self.event_queue, 1)
        self:emit(queued_event.type, queued_event.data)
        processed = processed + 1
    end

    return processed
end

-- Call a listener safely
function EventSystem:call_listener(listener, event)
    local success, err = pcall(function()
        if listener.context then
            listener.callback(listener.context, event)
        else
            listener.callback(event)
        end
    end)

    if not success then
        self.stats.errors = self.stats.errors + 1

        -- Emit error event (but don't create infinite loop)
        if event.type ~= EventSystem.EventType.ERROR_OCCURRED then
            self:emit(EventSystem.EventType.ERROR_OCCURRED, {
                error = err,
                listener = listener.id,
                original_event = event.type
            })
        end
    end
end

-- Stop event propagation
function EventSystem:stop_propagation(event)
    if event then
        event.propagation_stopped = true
    end
end

-- Generate unique listener ID
function EventSystem:generate_listener_id()
    return string.format("listener_%d_%d", os.time(), math.random(10000, 99999))
end

-- Add event to history
function EventSystem:add_to_history(event)
    table.insert(self.event_history, event)

    -- Maintain history size limit
    while #self.event_history > self.config.history_size do
        table.remove(self.event_history, 1)
    end
end

-- Log event
function EventSystem:log_event(event)
    print(string.format("[EVENT] %s at %s", event.type, os.date("%H:%M:%S", event.timestamp)))

    if event.data and next(event.data) then
        print("  Data:")
        for k, v in pairs(event.data) do
            print(string.format("    %s = %s", k, tostring(v)))
        end
    end
end

-- Get event history
function EventSystem:get_history(event_type, limit)
    local history = {}

    for i = #self.event_history, 1, -1 do
        local event = self.event_history[i]

        if not event_type or event.type == event_type then
            table.insert(history, event)

            if limit and #history >= limit then
                break
            end
        end
    end

    return history
end

-- Get listener count for event type
function EventSystem:get_listener_count(event_type)
    if event_type then
        return self.listeners[event_type] and #self.listeners[event_type] or 0
    else
        -- Count all listeners
        local total = 0
        for _, listeners in pairs(self.listeners) do
            total = total + #listeners
        end
        return total
    end
end

-- Get statistics
function EventSystem:get_stats()
    return {
        events_fired = self.stats.events_fired,
        events_queued = self.stats.events_queued,
        queue_size = #self.event_queue,
        listeners_registered = self.stats.listeners_registered,
        active_listeners = self:get_listener_count(),
        errors = self.stats.errors,
        history_size = #self.event_history
    }
end

-- Clear event queue
function EventSystem:clear_queue()
    self.event_queue = {}
end

-- Clear event history
function EventSystem:clear_history()
    self.event_history = {}
end

-- Helper: Create event data for passage events
function EventSystem:create_passage_event_data(passage, previous_passage)
    return {
        passage = passage,
        passage_name = passage.name,
        previous_passage = previous_passage,
        timestamp = os.time()
    }
end

-- Helper: Create event data for choice events
function EventSystem:create_choice_event_data(choice, choice_index, passage)
    return {
        choice = choice,
        choice_index = choice_index,
        choice_text = choice.text,
        target = choice.target,
        passage = passage,
        timestamp = os.time()
    }
end

-- Helper: Create event data for variable events
function EventSystem:create_variable_event_data(variable_name, old_value, new_value)
    return {
        variable = variable_name,
        old_value = old_value,
        new_value = new_value,
        timestamp = os.time()
    }
end

-- Debug: Print all registered listeners
function EventSystem:debug_print_listeners()
    print("=== Event System Listeners ===")

    for event_type, listeners in pairs(self.listeners) do
        print(string.format("\n%s: %d listeners", event_type, #listeners))

        for i, listener in ipairs(listeners) do
            print(string.format("  %d. ID: %s, Registered: %s",
                i,
                listener.id,
                os.date("%H:%M:%S", listener.registered_at)))
        end
    end

    print("\n=== Statistics ===")
    local stats = self:get_stats()
    for k, v in pairs(stats) do
        print(string.format("%s: %s", k, tostring(v)))
    end
end

return EventSystem