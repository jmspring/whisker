-- whisker Runtime Debugger
-- Provides step-through debugging, breakpoints, variable inspection, and call stack visualization
-- for interactive story development and testing

local Debugger = {}
Debugger.__index = Debugger

-- Debug modes
Debugger.DebugMode = {
    OFF = "off",
    STEP = "step",           -- Step through each passage
    BREAKPOINT = "breakpoint", -- Stop at breakpoints
    TRACE = "trace"          -- Trace all execution
}

-- Breakpoint types
Debugger.BreakpointType = {
    PASSAGE = "passage",     -- Break when entering passage
    VARIABLE = "variable",   -- Break when variable changes
    CHOICE = "choice",       -- Break before choice execution
    CONDITION = "condition"  -- Break when condition met
}

-- Create new debugger instance
function Debugger.new(engine, game_state)
    local self = setmetatable({}, Debugger)

    self.engine = engine
    self.game_state = game_state

    -- Debug state
    self.mode = Debugger.DebugMode.OFF
    self.paused = false
    self.step_mode = false

    -- Breakpoints
    self.breakpoints = {}
    self.breakpoint_counter = 0

    -- Execution tracking
    self.call_stack = {}
    self.execution_history = {}
    self.max_history = 1000

    -- Watch expressions
    self.watches = {}

    -- Statistics
    self.stats = {
        passages_visited = 0,
        breakpoints_hit = 0,
        variables_watched = 0,
        total_pauses = 0
    }

    -- Callbacks
    self.on_breakpoint = nil
    self.on_step = nil
    self.on_variable_change = nil

    return self
end

-- Enable debugging
function Debugger:enable(mode)
    self.mode = mode or Debugger.DebugMode.STEP
    self:log("Debugger enabled in " .. self.mode .. " mode")

    -- Hook into engine events
    self:setup_hooks()
end

-- Disable debugging
function Debugger:disable()
    self.mode = Debugger.DebugMode.OFF
    self.paused = false
    self:remove_hooks()
    self:log("Debugger disabled")
end

-- Setup engine hooks
function Debugger:setup_hooks()
    -- Store original engine methods
    self.original_navigate = self.engine.navigate_to_passage
    self.original_make_choice = self.engine.make_choice

    -- Override with debug versions
    local debugger = self

    self.engine.navigate_to_passage = function(engine, passage_id)
        debugger:on_passage_enter(passage_id)
        return debugger.original_navigate(engine, passage_id)
    end

    self.engine.make_choice = function(engine, choice_index)
        debugger:on_choice_made(choice_index)
        return debugger.original_make_choice(engine, choice_index)
    end

    -- Hook variable changes if game_state supports it
    if self.game_state.set_variable then
        self.original_set_variable = self.game_state.set_variable

        self.game_state.set_variable = function(state, name, value)
            local old_value = state:get_variable(name)
            debugger:on_variable_changed(name, old_value, value)
            return debugger.original_set_variable(state, name, value)
        end
    end
end

-- Remove engine hooks
function Debugger:remove_hooks()
    if self.original_navigate then
        self.engine.navigate_to_passage = self.original_navigate
    end

    if self.original_make_choice then
        self.engine.make_choice = self.original_make_choice
    end

    if self.original_set_variable then
        self.game_state.set_variable = self.original_set_variable
    end
end

-- Event handlers
function Debugger:on_passage_enter(passage_id)
    self.stats.passages_visited = self.stats.passages_visited + 1

    -- Add to call stack
    table.insert(self.call_stack, {
        type = "passage",
        id = passage_id,
        timestamp = os.time(),
        variables = self:capture_variables()
    })

    -- Check for breakpoints
    if self:should_break_at_passage(passage_id) then
        self:break_at_passage(passage_id)
    end

    -- Step mode
    if self.mode == Debugger.DebugMode.STEP then
        self:pause_execution("Stepped to passage: " .. passage_id)
    end

    -- Add to execution history
    self:add_to_history({
        type = "passage_enter",
        passage_id = passage_id,
        timestamp = os.time()
    })
end

function Debugger:on_choice_made(choice_index)
    local current_passage = self.game_state:get_current_passage()

    -- Check for choice breakpoints
    if self:should_break_at_choice(current_passage, choice_index) then
        self:break_at_choice(current_passage, choice_index)
    end

    -- Add to execution history
    self:add_to_history({
        type = "choice_made",
        passage_id = current_passage,
        choice_index = choice_index,
        timestamp = os.time()
    })
end

function Debugger:on_variable_changed(name, old_value, new_value)
    -- Check for variable watches
    if self:is_watched(name) then
        self:break_at_variable(name, old_value, new_value)
        self.stats.variables_watched = self.stats.variables_watched + 1
    end

    -- Add to execution history
    self:add_to_history({
        type = "variable_change",
        variable = name,
        old_value = old_value,
        new_value = new_value,
        timestamp = os.time()
    })

    -- Call callback if registered
    if self.on_variable_change then
        self.on_variable_change(name, old_value, new_value)
    end
end

-- Breakpoint management
function Debugger:add_breakpoint(type, target, condition)
    self.breakpoint_counter = self.breakpoint_counter + 1

    local breakpoint = {
        id = self.breakpoint_counter,
        type = type,
        target = target,
        condition = condition,
        enabled = true,
        hit_count = 0,
        created_at = os.time()
    }

    table.insert(self.breakpoints, breakpoint)

    self:log("Breakpoint #" .. breakpoint.id .. " added: " .. type .. " at " .. tostring(target))

    return breakpoint.id
end

function Debugger:remove_breakpoint(breakpoint_id)
    for i, bp in ipairs(self.breakpoints) do
        if bp.id == breakpoint_id then
            table.remove(self.breakpoints, i)
            self:log("Breakpoint #" .. breakpoint_id .. " removed")
            return true
        end
    end
    return false
end

function Debugger:enable_breakpoint(breakpoint_id)
    local bp = self:get_breakpoint(breakpoint_id)
    if bp then
        bp.enabled = true
        return true
    end
    return false
end

function Debugger:disable_breakpoint(breakpoint_id)
    local bp = self:get_breakpoint(breakpoint_id)
    if bp then
        bp.enabled = false
        return true
    end
    return false
end

function Debugger:get_breakpoint(breakpoint_id)
    for _, bp in ipairs(self.breakpoints) do
        if bp.id == breakpoint_id then
            return bp
        end
    end
    return nil
end

function Debugger:list_breakpoints()
    return self.breakpoints
end

function Debugger:clear_breakpoints()
    self.breakpoints = {}
    self:log("All breakpoints cleared")
end

-- Breakpoint checking
function Debugger:should_break_at_passage(passage_id)
    for _, bp in ipairs(self.breakpoints) do
        if bp.enabled and bp.type == Debugger.BreakpointType.PASSAGE then
            if bp.target == passage_id or bp.target == "*" then
                if self:evaluate_condition(bp.condition) then
                    bp.hit_count = bp.hit_count + 1
                    return true
                end
            end
        end
    end
    return false
end

function Debugger:should_break_at_choice(passage_id, choice_index)
    for _, bp in ipairs(self.breakpoints) do
        if bp.enabled and bp.type == Debugger.BreakpointType.CHOICE then
            if bp.target == passage_id or bp.target == "*" then
                if self:evaluate_condition(bp.condition) then
                    bp.hit_count = bp.hit_count + 1
                    return true
                end
            end
        end
    end
    return false
end

function Debugger:is_watched(variable_name)
    for _, watch in ipairs(self.watches) do
        if watch.variable == variable_name and watch.enabled then
            return true
        end
    end
    return false
end

-- Breaking execution
function Debugger:break_at_passage(passage_id)
    self.stats.breakpoints_hit = self.stats.breakpoints_hit + 1
    self:pause_execution("Breakpoint hit at passage: " .. passage_id)
end

function Debugger:break_at_choice(passage_id, choice_index)
    self.stats.breakpoints_hit = self.stats.breakpoints_hit + 1
    self:pause_execution("Breakpoint hit before choice " .. choice_index .. " in passage: " .. passage_id)
end

function Debugger:break_at_variable(name, old_value, new_value)
    self.stats.breakpoints_hit = self.stats.breakpoints_hit + 1
    local msg = string.format("Variable watch triggered: %s changed from %s to %s",
                             name, tostring(old_value), tostring(new_value))
    self:pause_execution(msg)
end

-- Execution control
function Debugger:pause_execution(reason)
    self.paused = true
    self.stats.total_pauses = self.stats.total_pauses + 1

    self:log("PAUSED: " .. reason)

    if self.on_breakpoint then
        self.on_breakpoint(reason, self:get_debug_context())
    end

    -- In a real implementation, this would wait for user input
    -- For now, we'll just return
end

function Debugger:continue()
    if self.paused then
        self.paused = false
        self.step_mode = false
        self:log("Continuing execution...")
    end
end

function Debugger:step()
    if self.paused then
        self.step_mode = true
        self.paused = false
        self:log("Stepping to next passage...")
    end
end

function Debugger:step_over()
    -- Step over the current operation without going into details
    self:step()
end

function Debugger:step_into()
    -- Step into the current operation (e.g., into Lua code)
    self.mode = Debugger.DebugMode.TRACE
    self:step()
end

-- Variable watching
function Debugger:add_watch(variable_name, condition)
    table.insert(self.watches, {
        variable = variable_name,
        condition = condition,
        enabled = true,
        hit_count = 0
    })

    self:log("Added watch for variable: " .. variable_name)
end

function Debugger:remove_watch(variable_name)
    for i, watch in ipairs(self.watches) do
        if watch.variable == variable_name then
            table.remove(self.watches, i)
            self:log("Removed watch for variable: " .. variable_name)
            return true
        end
    end
    return false
end

function Debugger:list_watches()
    return self.watches
end

-- Inspection
function Debugger:get_call_stack()
    return self.call_stack
end

function Debugger:get_current_context()
    if #self.call_stack > 0 then
        return self.call_stack[#self.call_stack]
    end
    return nil
end

function Debugger:get_debug_context()
    return {
        current_passage = self.game_state:get_current_passage(),
        variables = self:capture_variables(),
        call_stack = self.call_stack,
        breakpoints = self.breakpoints,
        watches = self.watches,
        mode = self.mode,
        paused = self.paused
    }
end

function Debugger:inspect_variable(name)
    return self.game_state:get_variable(name)
end

function Debugger:inspect_all_variables()
    return self.game_state:get_all_variables()
end

-- Execution history
function Debugger:add_to_history(entry)
    table.insert(self.execution_history, entry)

    -- Limit history size
    while #self.execution_history > self.max_history do
        table.remove(self.execution_history, 1)
    end
end

function Debugger:get_history(count)
    count = count or 10
    local start = math.max(1, #self.execution_history - count + 1)
    local result = {}

    for i = start, #self.execution_history do
        table.insert(result, self.execution_history[i])
    end

    return result
end

function Debugger:clear_history()
    self.execution_history = {}
end

-- Utilities
function Debugger:capture_variables()
    local vars = {}
    local all_vars = self.game_state:get_all_variables()

    for name, value in pairs(all_vars) do
        vars[name] = value
    end

    return vars
end

function Debugger:evaluate_condition(condition)
    if not condition then
        return true
    end

    -- Evaluate condition using interpreter
    if self.engine.interpreter then
        local success, result = self.engine.interpreter:evaluate_expression(condition, self.game_state)
        return success and result
    end

    return true
end

function Debugger:log(message)
    if self.mode ~= Debugger.DebugMode.OFF then
        print("[DEBUGGER] " .. message)
    end
end

-- Statistics
function Debugger:get_stats()
    return {
        passages_visited = self.stats.passages_visited,
        breakpoints_hit = self.stats.breakpoints_hit,
        variables_watched = self.stats.variables_watched,
        total_pauses = self.stats.total_pauses,
        active_breakpoints = #self.breakpoints,
        active_watches = #self.watches,
        history_size = #self.execution_history
    }
end

function Debugger:reset_stats()
    self.stats = {
        passages_visited = 0,
        breakpoints_hit = 0,
        variables_watched = 0,
        total_pauses = 0
    }
end

-- Report generation
function Debugger:generate_report()
    local report = {
        "=== Debug Session Report ===",
        "",
        "Statistics:",
        "  Passages Visited: " .. self.stats.passages_visited,
        "  Breakpoints Hit: " .. self.stats.breakpoints_hit,
        "  Variables Watched: " .. self.stats.variables_watched,
        "  Total Pauses: " .. self.stats.total_pauses,
        "",
        "Active Breakpoints: " .. #self.breakpoints,
        "Active Watches: " .. #self.watches,
        "History Size: " .. #self.execution_history,
        "",
        "Current State:",
        "  Mode: " .. self.mode,
        "  Paused: " .. tostring(self.paused),
        "  Current Passage: " .. tostring(self.game_state:get_current_passage())
    }

    return table.concat(report, "\n")
end

return Debugger