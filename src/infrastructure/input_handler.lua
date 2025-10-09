-- whisker Input Handler
-- Handles user input across different platforms
-- Provides unified interface for console, web, and GUI input

local InputHandler = {}
InputHandler.__index = InputHandler

-- Input types
InputHandler.InputType = {
    CHOICE = "choice",
    TEXT = "text",
    COMMAND = "command",
    SAVE_NAME = "save_name",
    CONFIRMATION = "confirmation"
}

-- Commands
InputHandler.Commands = {
    HELP = {"help", "h", "?"},
    SAVE = {"save", "s"},
    LOAD = {"load", "l"},
    QUIT = {"quit", "q", "exit"},
    UNDO = {"undo", "u", "back"},
    RESTART = {"restart", "r"},
    INVENTORY = {"inventory", "i", "inv"},
    STATS = {"stats", "status"}
}

-- Create new input handler
function InputHandler.new(platform, config)
    local self = setmetatable({}, InputHandler)

    self.platform = platform or "console"

    -- Configuration
    self.config = {
        enable_commands = true,
        enable_shortcuts = true,
        case_sensitive = false,
        trim_whitespace = true,
        echo_input = true,
        prompt = "> ",
        timeout = nil, -- No timeout by default
        history_size = 50
    }

    -- Override with provided config
    if config then
        for k, v in pairs(config) do
            self.config[k] = v
        end
    end

    -- Input state
    self.input_history = {}
    self.history_index = 0
    self.last_input = nil

    -- Statistics
    self.stats = {
        inputs_received = 0,
        commands_executed = 0,
        choices_made = 0,
        invalid_inputs = 0
    }

    return self
end

-- Get user input (main method)
function InputHandler:get_input(input_type, options)
    input_type = input_type or InputHandler.InputType.TEXT
    options = options or {}

    if self.platform == "console" then
        return self:get_console_input(input_type, options)
    elseif self.platform == "web" then
        return self:get_web_input(input_type, options)
    elseif self.platform == "love2d" then
        return self:get_love2d_input(input_type, options)
    else
        error("Unsupported platform: " .. self.platform)
    end
end

-- Console input
function InputHandler:get_console_input(input_type, options)
    local prompt = options.prompt or self.config.prompt

    while true do
        -- Display prompt
        io.write(prompt)
        io.flush()

        -- Read input
        local input = io.read()

        if not input then
            return nil -- EOF or error
        end

        -- Process input
        input = self:process_input(input)

        -- Handle based on input type
        if input_type == InputHandler.InputType.CHOICE then
            local result = self:parse_choice_input(input, options)
            if result then
                return result
            else
                print("Invalid choice. Please enter a number or command.")
            end

        elseif input_type == InputHandler.InputType.CONFIRMATION then
            local result = self:parse_confirmation_input(input)
            if result ~= nil then
                return result
            else
                print("Please enter 'y' for yes or 'n' for no.")
            end

        elseif input_type == InputHandler.InputType.SAVE_NAME then
            if self:validate_save_name(input) then
                return input
            else
                print("Invalid save name. Use letters, numbers, and spaces only.")
            end

        elseif input_type == InputHandler.InputType.TEXT then
            return input

        elseif input_type == InputHandler.InputType.COMMAND then
            local command = self:parse_command(input)
            if command then
                return command
            else
                print("Unknown command. Type 'help' for available commands.")
            end
        end
    end
end

-- Process raw input
function InputHandler:process_input(input)
    -- Track input
    self.stats.inputs_received = self.stats.inputs_received + 1
    self.last_input = input

    -- Trim whitespace if enabled
    if self.config.trim_whitespace then
        input = input:match("^%s*(.-)%s*$")
    end

    -- Handle case sensitivity
    if not self.config.case_sensitive then
        input = input:lower()
    end

    -- Add to history
    if input ~= "" then
        table.insert(self.input_history, {
            text = input,
            timestamp = os.time()
        })

        -- Maintain history size
        while #self.input_history > self.config.history_size do
            table.remove(self.input_history, 1)
        end
    end

    return input
end

-- Parse choice input
function InputHandler:parse_choice_input(input, options)
    local num_choices = options.num_choices or 0

    -- Check if it's a command first
    if self.config.enable_commands then
        local command = self:parse_command(input)
        if command then
            return command
        end
    end

    -- Try to parse as number
    local choice_num = tonumber(input)

    if choice_num and choice_num >= 1 and choice_num <= num_choices then
        self.stats.choices_made = self.stats.choices_made + 1
        return {
            type = "choice",
            choice = math.floor(choice_num)
        }
    end

    -- Try to match choice text (if provided)
    if options.choices then
        for i, choice in ipairs(options.choices) do
            local choice_text = choice.text or choice
            if not self.config.case_sensitive then
                choice_text = choice_text:lower()
            end

            if choice_text == input then
                self.stats.choices_made = self.stats.choices_made + 1
                return {
                    type = "choice",
                    choice = i
                }
            end
        end
    end

    self.stats.invalid_inputs = self.stats.invalid_inputs + 1
    return nil
end

-- Parse confirmation input
function InputHandler:parse_confirmation_input(input)
    local yes_words = {"y", "yes", "yeah", "yep", "true", "1"}
    local no_words = {"n", "no", "nope", "false", "0"}

    for _, word in ipairs(yes_words) do
        if input == word then
            return true
        end
    end

    for _, word in ipairs(no_words) do
        if input == word then
            return false
        end
    end

    return nil
end

-- Parse command input
function InputHandler:parse_command(input)
    if not self.config.enable_commands then
        return nil
    end

    -- Check each command type
    for command_name, aliases in pairs(InputHandler.Commands) do
        for _, alias in ipairs(aliases) do
            if input == alias or input:match("^" .. alias .. "%s") then
                self.stats.commands_executed = self.stats.commands_executed + 1

                -- Extract arguments
                local args = {}
                for arg in input:gmatch("%S+") do
                    if arg ~= alias then
                        table.insert(args, arg)
                    end
                end

                return {
                    type = "command",
                    command = command_name,
                    args = args,
                    raw = input
                }
            end
        end
    end

    return nil
end

-- Validate save name
function InputHandler:validate_save_name(name)
    if not name or name == "" then
        return false
    end

    -- Check for invalid characters
    if name:match('[<>:"/\\|?*]') then
        return false
    end

    -- Check length
    if #name > 255 then
        return false
    end

    return true
end

-- Web platform input (placeholder for JavaScript integration)
function InputHandler:get_web_input(input_type, options)
    -- This would be implemented via JavaScript bridge
    -- For now, return a placeholder
    return {
        type = "web_input",
        input_type = input_type,
        platform = "web"
    }
end

-- LÖVE2D platform input
function InputHandler:get_love2d_input(input_type, options)
    -- This would integrate with LÖVE's keyboard system
    -- For now, return a placeholder
    return {
        type = "love2d_input",
        input_type = input_type,
        platform = "love2d"
    }
end

-- Get input with timeout
function InputHandler:get_input_with_timeout(input_type, timeout_seconds, default_value)
    -- This is platform-specific and challenging in standard Lua
    -- On console, we can't easily implement timeout without OS-specific code
    -- For now, just get input normally

    local input = self:get_input(input_type)

    if input == nil and default_value then
        return default_value
    end

    return input
end

-- Wait for any key press
function InputHandler:wait_for_key()
    if self.platform == "console" then
        io.write("Press Enter to continue...")
        io.flush()
        io.read()
    end
end

-- Get confirmation
function InputHandler:confirm(message)
    if self.platform == "console" then
        print(message .. " (y/n)")
        return self:get_input(InputHandler.InputType.CONFIRMATION)
    end

    return false
end

-- Get text input with prompt
function InputHandler:get_text(prompt)
    return self:get_input(InputHandler.InputType.TEXT, {prompt = prompt})
end

-- Get choice from numbered list
function InputHandler:get_choice(num_choices, choices)
    return self:get_input(InputHandler.InputType.CHOICE, {
        num_choices = num_choices,
        choices = choices
    })
end

-- Get save name
function InputHandler:get_save_name()
    while true do
        local name = self:get_input(InputHandler.InputType.SAVE_NAME, {
            prompt = "Save name: "
        })

        if name == "cancel" then
            return nil
        end

        if self:validate_save_name(name) then
            return name
        end
    end
end

-- Show help
function InputHandler:show_help()
    print("\n=== Available Commands ===")
    print("  help, h, ?      - Show this help")
    print("  save, s         - Save game")
    print("  load, l         - Load game")
    print("  quit, q, exit   - Quit game")
    print("  undo, u, back   - Undo last choice")
    print("  restart, r      - Restart story")
    print("  inventory, i    - Show inventory")
    print("  stats           - Show statistics")
    print("\nDuring gameplay:")
    print("  [number]        - Select choice")
    print("  [Enter]         - Continue")
    print()
end

-- Get input history
function InputHandler:get_history(limit)
    limit = limit or #self.input_history

    local history = {}
    local start_index = math.max(1, #self.input_history - limit + 1)

    for i = start_index, #self.input_history do
        table.insert(history, self.input_history[i])
    end

    return history
end

-- Clear input history
function InputHandler:clear_history()
    self.input_history = {}
    self.history_index = 0
end

-- Get statistics
function InputHandler:get_stats()
    return {
        inputs_received = self.stats.inputs_received,
        commands_executed = self.stats.commands_executed,
        choices_made = self.stats.choices_made,
        invalid_inputs = self.stats.invalid_inputs,
        history_size = #self.input_history
    }
end

-- String utility helper
function string:trim()
    return self:match("^%s*(.-)%s*$")
end

return InputHandler