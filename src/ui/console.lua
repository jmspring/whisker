-- whisker Debug Console
-- Interactive debugging console for development
-- Provides REPL-like environment for inspecting game state

local Console = {}
Console.__index = Console

-- Console commands
Console.Commands = {
    -- State inspection
    INSPECT = "inspect",
    VARS = "vars",
    HISTORY = "history",
    STATE = "state",

    -- Manipulation
    SET = "set",
    GOTO = "goto",
    RESET = "reset",

    -- Information
    HELP = "help",
    PASSAGES = "passages",
    LINKS = "links",
    STATS = "stats",

    -- Execution
    EXEC = "exec",
    EVAL = "eval",

    -- Control
    EXIT = "exit",
    CLEAR = "clear"
}

-- Create new debug console
function Console.new(engine, game_state)
    local self = setmetatable({}, Console)

    self.engine = engine
    self.game_state = game_state

    -- Console state
    self.active = false
    self.command_history = {}
    self.output_buffer = {}

    -- Configuration
    self.config = {
        max_history = 100,
        max_output_lines = 1000,
        prompt = "debug> ",
        show_welcome = true,
        enable_colors = true
    }

    -- Statistics
    self.stats = {
        commands_executed = 0,
        errors = 0,
        variables_inspected = 0,
        state_changes = 0
    }

    return self
end

-- Start console session
function Console:start()
    self.active = true

    if self.config.show_welcome then
        self:print_welcome()
    end

    self:run_loop()
end

-- Stop console session
function Console:stop()
    self.active = false
    self:output("Console closed.")
end

-- Main console loop
function Console:run_loop()
    while self.active do
        -- Display prompt
        io.write(self.config.prompt)
        io.flush()

        -- Read command
        local input = io.read()

        if not input then
            break
        end

        -- Process command
        self:process_command(input)
    end
end

-- Process console command
function Console:process_command(input)
    -- Trim whitespace
    input = input:match("^%s*(.-)%s*$")

    if input == "" then
        return
    end

    -- Add to history
    table.insert(self.command_history, {
        command = input,
        timestamp = os.time()
    })

    -- Keep history size manageable
    while #self.command_history > self.config.max_history do
        table.remove(self.command_history, 1)
    end

    -- Parse command
    local cmd, args = self:parse_command(input)

    -- Execute command
    local success, result = pcall(function()
        return self:execute_command(cmd, args)
    end)

    if success then
        if result then
            self:output(result)
        end
        self.stats.commands_executed = self.stats.commands_executed + 1
    else
        self:error("Command error: " .. tostring(result))
        self.stats.errors = self.stats.errors + 1
    end
end

-- Parse command string
function Console:parse_command(input)
    local parts = {}

    for part in input:gmatch("%S+") do
        table.insert(parts, part)
    end

    local cmd = table.remove(parts, 1)
    return cmd, parts
end

-- Execute console command
function Console:execute_command(cmd, args)
    cmd = cmd:lower()

    -- Help command
    if cmd == Console.Commands.HELP or cmd == "?" then
        return self:cmd_help(args)

    -- Exit command
    elseif cmd == Console.Commands.EXIT or cmd == "quit" then
        self:stop()
        return "Exiting console..."

    -- Clear command
    elseif cmd == Console.Commands.CLEAR or cmd == "cls" then
        self:clear_screen()
        return nil

    -- Variables command
    elseif cmd == Console.Commands.VARS or cmd == "variables" then
        return self:cmd_show_variables(args)

    -- Inspect command
    elseif cmd == Console.Commands.INSPECT or cmd == "i" then
        return self:cmd_inspect(args)

    -- History command
    elseif cmd == Console.Commands.HISTORY or cmd == "h" then
        return self:cmd_show_history(args)

    -- State command
    elseif cmd == Console.Commands.STATE then
        return self:cmd_show_state(args)

    -- Set command
    elseif cmd == Console.Commands.SET then
        return self:cmd_set_variable(args)

    -- Goto command
    elseif cmd == Console.Commands.GOTO then
        return self:cmd_goto_passage(args)

    -- Reset command
    elseif cmd == Console.Commands.RESET then
        return self:cmd_reset_state(args)

    -- Passages command
    elseif cmd == Console.Commands.PASSAGES or cmd == "p" then
        return self:cmd_list_passages(args)

    -- Links command
    elseif cmd == Console.Commands.LINKS or cmd == "l" then
        return self:cmd_show_links(args)

    -- Stats command
    elseif cmd == Console.Commands.STATS then
        return self:cmd_show_stats(args)

    -- Eval command
    elseif cmd == Console.Commands.EVAL or cmd == "e" then
        return self:cmd_eval_lua(args)

    -- Exec command
    elseif cmd == Console.Commands.EXEC then
        return self:cmd_exec_lua(args)

    else
        return "Unknown command: " .. cmd .. " (type 'help' for commands)"
    end
end

-- Command implementations
function Console:cmd_help(args)
    local help_text = [[
=== Debug Console Commands ===

State Inspection:
  vars              - List all variables
  inspect <var>     - Inspect variable value
  history           - Show passage history
  state             - Show current state

Manipulation:
  set <var> <val>   - Set variable value
  goto <passage>    - Jump to passage
  reset             - Reset game state

Information:
  passages          - List all passages
  links             - Show links from current passage
  stats             - Show console statistics

Execution:
  eval <expr>       - Evaluate Lua expression
  exec <code>       - Execute Lua code

Control:
  help, ?           - Show this help
  clear, cls        - Clear screen
  exit, quit        - Exit console
]]
    return help_text
end

function Console:cmd_show_variables(args)
    local vars = self.game_state:get_all_variables()

    if not vars or not next(vars) then
        return "No variables set"
    end

    local output = "=== Variables ===\n"
    for key, value in pairs(vars) do
        output = output .. string.format("%s = %s\n", key, self:format_value(value))
    end

    return output
end

function Console:cmd_inspect(args)
    if #args < 1 then
        return "Usage: inspect <variable>"
    end

    local var_name = args[1]
    local value = self.game_state:get_variable(var_name)

    self.stats.variables_inspected = self.stats.variables_inspected + 1

    if value == nil then
        return "Variable '" .. var_name .. "' is not set"
    end

    return string.format("%s = %s (%s)", var_name, self:format_value(value), type(value))
end

function Console:cmd_show_history(args)
    local history = self.game_state:get_passage_history()

    if not history or #history == 0 then
        return "No passage history"
    end

    local output = "=== Passage History ===\n"
    for i, passage_id in ipairs(history) do
        output = output .. string.format("%d. %s\n", i, passage_id)
    end

    return output
end

function Console:cmd_show_state(args)
    local current = self.game_state:get_current_passage()
    local vars = self.game_state:get_all_variables()
    local history_count = #self.game_state:get_passage_history()

    local output = "=== Game State ===\n"
    output = output .. "Current Passage: " .. tostring(current) .. "\n"
    output = output .. "Variables: " .. self:count_table(vars) .. "\n"
    output = output .. "History Length: " .. history_count .. "\n"
    output = output .. "Can Undo: " .. tostring(self.game_state:can_undo()) .. "\n"

    return output
end

function Console:cmd_set_variable(args)
    if #args < 2 then
        return "Usage: set <variable> <value>"
    end

    local var_name = args[1]
    local value_str = table.concat(args, " ", 2)

    -- Try to parse value
    local value = self:parse_value(value_str)

    self.game_state:set_variable(var_name, value)
    self.stats.state_changes = self.stats.state_changes + 1

    return string.format("Set %s = %s", var_name, self:format_value(value))
end

function Console:cmd_goto_passage(args)
    if #args < 1 then
        return "Usage: goto <passage>"
    end

    local passage_id = args[1]

    -- Check if passage exists
    local passage = self.engine.current_story:get_passage(passage_id)
    if not passage then
        return "Passage not found: " .. passage_id
    end

    -- Navigate to passage
    self.engine:navigate_to_passage(passage_id)
    self.stats.state_changes = self.stats.state_changes + 1

    return "Jumped to passage: " .. passage_id
end

function Console:cmd_reset_state(args)
    self.game_state:reset()
    self.stats.state_changes = self.stats.state_changes + 1

    return "Game state reset"
end

function Console:cmd_list_passages(args)
    local passages = self.engine.current_story:get_all_passages()

    if not passages or #passages == 0 then
        return "No passages found"
    end

    local output = "=== Passages ===\n"
    for i, passage in ipairs(passages) do
        local visited = self.game_state:get_visit_count(passage.id) > 0
        local marker = visited and "[✓]" or "[ ]"
        output = output .. string.format("%s %s\n", marker, passage.id)
    end

    return output
end

function Console:cmd_show_links(args)
    local current = self.game_state:get_current_passage()
    local passage = self.engine.current_story:get_passage(current)

    if not passage then
        return "No current passage"
    end

    local choices = passage:get_choices()

    if not choices or #choices == 0 then
        return "No links from current passage"
    end

    local output = "=== Links ===\n"
    for i, choice in ipairs(choices) do
        output = output .. string.format("%d. %s → %s\n", i, choice:get_text(), choice:get_target())
    end

    return output
end

function Console:cmd_show_stats(args)
    local output = "=== Console Statistics ===\n"
    output = output .. "Commands Executed: " .. self.stats.commands_executed .. "\n"
    output = output .. "Errors: " .. self.stats.errors .. "\n"
    output = output .. "Variables Inspected: " .. self.stats.variables_inspected .. "\n"
    output = output .. "State Changes: " .. self.stats.state_changes .. "\n"
    output = output .. "Command History Size: " .. #self.command_history .. "\n"

    return output
end

function Console:cmd_eval_lua(args)
    if #args < 1 then
        return "Usage: eval <expression>"
    end

    local expr = table.concat(args, " ")

    -- Evaluate expression
    local success, result = self.engine.interpreter:evaluate_expression(expr, self.game_state)

    if success then
        return "Result: " .. self:format_value(result)
    else
        return "Error: " .. tostring(result)
    end
end

function Console:cmd_exec_lua(args)
    if #args < 1 then
        return "Usage: exec <code>"
    end

    local code = table.concat(args, " ")

    -- Execute code
    local success, result = self.engine.interpreter:execute_code(code, self.game_state)

    if success then
        return result and ("Result: " .. self:format_value(result)) or "Code executed successfully"
    else
        return "Error: " .. tostring(result)
    end
end

-- Helper functions
function Console:print_welcome()
    self:output([[
=================================
    whisker Debug Console
=================================
Type 'help' for commands
Type 'exit' to quit
]])
end

function Console:output(message)
    print(message)

    table.insert(self.output_buffer, {
        message = message,
        timestamp = os.time()
    })

    while #self.output_buffer > self.config.max_output_lines do
        table.remove(self.output_buffer, 1)
    end
end

function Console:error(message)
    self:output("[ERROR] " .. message)
end

function Console:clear_screen()
    -- ANSI escape code to clear screen
    if self.config.enable_colors then
        io.write("\027[2J\027[H")
    else
        -- Fallback: print newlines
        for i = 1, 50 do
            print()
        end
    end
end

function Console:format_value(value)
    local t = type(value)

    if t == "string" then
        return '"' .. value .. '"'
    elseif t == "table" then
        return self:format_table(value)
    elseif t == "nil" then
        return "nil"
    else
        return tostring(value)
    end
end

function Console:format_table(tbl, indent)
    indent = indent or 0
    local output = "{\n"

    for key, value in pairs(tbl) do
        output = output .. string.rep("  ", indent + 1)
        output = output .. tostring(key) .. " = "

        if type(value) == "table" then
            output = output .. self:format_table(value, indent + 1)
        else
            output = output .. self:format_value(value)
        end

        output = output .. "\n"
    end

    output = output .. string.rep("  ", indent) .. "}"
    return output
end

function Console:parse_value(str)
    -- Try to parse as number
    local num = tonumber(str)
    if num then
        return num
    end

    -- Try to parse as boolean
    if str == "true" then
        return true
    elseif str == "false" then
        return false
    elseif str == "nil" then
        return nil
    end

    -- Return as string
    return str
end

function Console:count_table(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return Console