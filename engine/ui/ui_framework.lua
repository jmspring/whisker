-- whisker UI Framework
-- Provides unified interface for displaying stories across platforms
-- Integrates rendering and input handling

local UIFramework = {}
UIFramework.__index = UIFramework

-- Create new UI framework instance
function UIFramework.new(platform, config)
    local self = setmetatable({}, UIFramework)

    self.platform = platform or "console"

    -- Configuration
    self.config = {
        max_content_width = 80,
        choice_prefix = "> ",
        selected_prefix = "* ",
        clear_screen_on_passage = true,
        show_help_hint = true,
        show_debug_info = false,
        number_choices = true,
        color_support = false,
        auto_wrap_text = true
    }

    -- Override with provided config
    if config then
        for k, v in pairs(config) do
            self.config[k] = v
        end
    end

    -- UI state
    self.current_content = nil
    self.current_choices = {}
    self.selected_choice = 1
    self.waiting_for_input = false

    -- Platform components
    self.renderer = nil
    self.input_handler = nil

    -- UI history
    self.display_history = {}

    -- Statistics
    self.stats = {
        passages_displayed = 0,
        choices_displayed = 0,
        messages_shown = 0,
        saves_performed = 0,
        loads_performed = 0
    }

    -- Initialize platform-specific components
    self:initialize_platform()

    return self
end

-- Initialize platform-specific components
function UIFramework:initialize_platform()
    if self.platform == "console" then
        self:setup_console_platform()
    elseif self.platform == "love2d" then
        self:setup_love2d_platform()
    elseif self.platform == "web" then
        self:setup_web_platform()
    else
        error("Unsupported platform: " .. self.platform)
    end
end

-- Setup console platform
function UIFramework:setup_console_platform()
    -- Create renderer callbacks
    self.renderer = {
        display_passage = function(content, choices)
            self:render_console_passage(content, choices)
        end,

        show_message = function(message, message_type)
            self:render_console_message(message, message_type)
        end,

        show_save_menu = function(saves)
            self:render_console_save_menu(saves)
        end,

        show_load_menu = function(saves)
            self:render_console_load_menu(saves)
        end,

        clear_screen = function()
            self:clear_console_screen()
        end
    }

    -- Create input handler callbacks
    self.input_handler = {
        get_user_input = function()
            return self:get_console_input()
        end,

        get_save_name = function()
            return self:get_console_save_name()
        end,

        get_load_choice = function(saves)
            return self:get_console_load_choice(saves)
        end,

        confirm_action = function(message)
            return self:get_console_confirmation(message)
        end
    }
end

-- Console rendering methods
function UIFramework:render_console_passage(content, choices)
    if self.config.clear_screen_on_passage then
        self:clear_console_screen()
    end

    -- Display passage content
    local formatted_content = self:format_content(content.content or content.text or "")
    print(formatted_content)
    print()

    -- Display choices
    if choices and #choices > 0 then
        print("What do you choose?")

        for i, choice in ipairs(choices) do
            local choice_text = choice.text or "Unnamed choice"
            local prefix = self.config.choice_prefix

            if self.config.number_choices then
                prefix = string.format("%d. ", i)
            end

            local formatted_choice = self:colorize(prefix .. choice_text, "choice")
            print(formatted_choice)
        end

        print()
        self.stats.choices_displayed = self.stats.choices_displayed + #choices
    else
        print(self:colorize("(Story complete - no choices available)", "info"))
        print()
    end

    -- Show help hint
    if self.config.show_help_hint then
        print(self:colorize("Commands: 'save', 'load', 'help', 'quit'", "hint"))
        print()
    end

    -- Debug information
    if self.config.show_debug_info then
        self:render_debug_info(content)
    end

    self.stats.passages_displayed = self.stats.passages_displayed + 1
end

function UIFramework:render_console_message(message, message_type)
    local prefix = ""
    local color = "normal"

    if message_type == "error" then
        prefix = "ERROR: "
        color = "error"
    elseif message_type == "warning" then
        prefix = "WARNING: "
        color = "warning"
    elseif message_type == "info" then
        prefix = "INFO: "
        color = "info"
    elseif message_type == "success" then
        prefix = "SUCCESS: "
        color = "success"
    end

    print(self:colorize(prefix .. message, color))
    self.stats.messages_shown = self.stats.messages_shown + 1
end

function UIFramework:render_console_save_menu(saves)
    print("=== Save Game ===")
    print()

    if saves and #saves > 0 then
        print("Existing saves:")
        for i, save in ipairs(saves) do
            local save_info = string.format(
                "%d. %s (Passage: %s, Date: %s)",
                i,
                save.name or "Unnamed",
                save.current_passage or "Unknown",
                os.date("%Y-%m-%d %H:%M", save.timestamp or 0)
            )
            print(save_info)
        end
        print()
    end

    print("Enter a new save name or type 'cancel' to return.")
end

function UIFramework:render_console_load_menu(saves)
    print("=== Load Game ===")
    print()

    if not saves or #saves == 0 then
        print("No saved games found.")
        print()
        print("Press Enter to return...")
        return
    end

    for i, save in ipairs(saves) do
        local save_info = string.format(
            "%d. %s",
            i,
            save.name or "Unnamed"
        )
        print(save_info)

        print(string.format(
            "   Passage: %s | Turns: %d | Date: %s",
            save.current_passage or "Unknown",
            save.turn_count or 0,
            os.date("%Y-%m-%d %H:%M", save.timestamp or 0)
        ))
        print()
    end

    print("Enter save number to load, or 'cancel' to return.")
end

function UIFramework:render_debug_info(content)
    print("\n--- Debug Info ---")
    print("Passage: " .. (content.name or "Unknown"))
    print("PID: " .. (content.pid or "Unknown"))
    if content.tags and #content.tags > 0 then
        print("Tags: " .. table.concat(content.tags, ", "))
    end
    print("------------------\n")
end

-- Console input methods
function UIFramework:get_console_input()
    while true do
        io.write(self.config.choice_prefix)
        io.flush()

        local input = io.read()

        if not input then
            return {type = "quit"}
        end

        input = input:match("^%s*(.-)%s*$") -- trim whitespace

        if input == "" then
            return {type = "continue"}
        end

        input = input:lower()

        -- Check for commands
        if input == "help" or input == "h" or input == "?" then
            self:show_help()

        elseif input == "save" or input == "s" then
            return {type = "save"}

        elseif input == "load" or input == "l" then
            return {type = "load"}

        elseif input == "quit" or input == "q" or input == "exit" then
            return {type = "quit"}

        elseif input == "undo" or input == "u" or input == "back" then
            return {type = "undo"}

        elseif input == "restart" or input == "r" then
            return {type = "restart"}

        else
            -- Try to parse as choice number
            local choice_num = tonumber(input)

            if choice_num and choice_num >= 1 and choice_num <= #self.current_choices then
                return {type = "choice", choice = choice_num}
            else
                print("Invalid input. Please enter a choice number (1-" .. #self.current_choices .. ") or a command.")
                print("Type 'help' for available commands.")
            end
        end
    end
end

function UIFramework:get_console_save_name()
    while true do
        io.write("Save name: ")
        io.flush()

        local input = io.read()

        if not input then
            return nil
        end

        input = input:match("^%s*(.-)%s*$") -- trim

        if input:lower() == "cancel" then
            return nil
        end

        if input == "" then
            print("Save name cannot be empty. Try again or type 'cancel'.")
        else
            -- Validate save name
            if input:match("[<>:\"/\\|?*]") then
                print("Save name contains invalid characters. Please use letters, numbers, and spaces only.")
            else
                return input
            end
        end
    end
end

function UIFramework:get_console_load_choice(saves)
    while true do
        io.write("Load save: ")
        io.flush()

        local input = io.read()

        if not input then
            return nil
        end

        input = input:match("^%s*(.-)%s*$") -- trim

        if input:lower() == "cancel" then
            return nil
        end

        local choice = tonumber(input)

        if choice and choice >= 1 and choice <= #saves then
            return saves[choice]
        else
            print("Invalid save number. Please try again or type 'cancel'.")
        end
    end
end

function UIFramework:get_console_confirmation(message)
    print(message .. " (y/n)")

    while true do
        io.write("Confirm: ")
        io.flush()

        local input = io.read()

        if not input then
            return false
        end

        input = input:match("^%s*(.-)%s*$"):lower()

        if input == "y" or input == "yes" then
            return true
        elseif input == "n" or input == "no" then
            return false
        else
            print("Please enter 'y' for yes or 'n' for no.")
        end
    end
end

-- Public interface methods
function UIFramework:display_passage(content, game_state)
    -- Store current state
    self.current_content = content
    self.current_choices = content.choices or {}
    self.selected_choice = 1

    -- Display through renderer
    self.renderer.display_passage(content, self.current_choices)
end

function UIFramework:get_user_input()
    self.waiting_for_input = true
    local input = self.input_handler.get_user_input()
    self.waiting_for_input = false

    return input
end

function UIFramework:show_save_interface()
    local saves = {} -- Placeholder - would be passed in

    self.renderer.show_save_menu(saves)

    local save_name = self.input_handler.get_save_name()
    if save_name then
        self.stats.saves_performed = self.stats.saves_performed + 1
        return {type = "save_confirmed", save_name = save_name}
    else
        return {type = "save_cancelled"}
    end
end

function UIFramework:show_load_interface(saves)
    self.renderer.show_load_menu(saves)

    if not saves or #saves == 0 then
        io.read() -- Wait for Enter
        return {type = "load_cancelled"}
    end

    local selected_save = self.input_handler.get_load_choice(saves)
    if selected_save then
        self.stats.loads_performed = self.stats.loads_performed + 1
        return {type = "load_confirmed", save = selected_save}
    else
        return {type = "load_cancelled"}
    end
end

function UIFramework:show_message(message, message_type)
    self.renderer.show_message(message, message_type or "info")
end

function UIFramework:confirm_action(message)
    return self.input_handler.confirm_action(message)
end

function UIFramework:clear_screen()
    self.renderer.clear_screen()
end

-- Helper methods
function UIFramework:format_content(text)
    if self.config.auto_wrap_text then
        return self:wrap_text(text, self.config.max_content_width)
    end
    return text
end

function UIFramework:wrap_text(text, width)
    local lines = {}
    local current_line = ""

    for word in text:gmatch("%S+") do
        if #current_line + #word + 1 > width then
            if current_line ~= "" then
                table.insert(lines, current_line)
                current_line = word
            else
                -- Word is longer than width
                table.insert(lines, word)
            end
        else
            if current_line == "" then
                current_line = word
            else
                current_line = current_line .. " " .. word
            end
        end
    end

    if current_line ~= "" then
        table.insert(lines, current_line)
    end

    return table.concat(lines, "\n")
end

function UIFramework:colorize(text, color_type)
    if not self.config.color_support then
        return text
    end

    -- ANSI color codes
    local colors = {
        normal = "\27[0m",
        error = "\27[31m",    -- Red
        warning = "\27[33m",  -- Yellow
        info = "\27[36m",     -- Cyan
        success = "\27[32m",  -- Green
        choice = "\27[37m",   -- White
        hint = "\27[90m"      -- Gray
    }

    local color_code = colors[color_type] or colors.normal
    return color_code .. text .. colors.normal
end

function UIFramework:clear_console_screen()
    -- Try Unix/Linux/Mac clear
    local success = os.execute("clear")

    if not success then
        -- Try Windows cls
        os.execute("cls")
    end

    -- If both fail, print newlines
    if not success then
        print(string.rep("\n", 50))
    end
end

function UIFramework:show_help()
    print("\n=== Available Commands ===")
    print("  help, h, ?      - Show this help")
    print("  save, s         - Save game")
    print("  load, l         - Load game")
    print("  quit, q, exit   - Quit game")
    print("  undo, u, back   - Undo last choice")
    print("  restart, r      - Restart story")
    print("\nDuring gameplay:")
    print("  [number]        - Select choice")
    print("  [Enter]         - Continue")
    print()
end

-- Setup LÖVE2D platform (placeholder)
function UIFramework:setup_love2d_platform()
    error("LÖVE2D platform not yet implemented")
end

-- Setup web platform (placeholder)
function UIFramework:setup_web_platform()
    error("Web platform not yet implemented")
end

-- Get statistics
function UIFramework:get_stats()
    return {
        passages_displayed = self.stats.passages_displayed,
        choices_displayed = self.stats.choices_displayed,
        messages_shown = self.stats.messages_shown,
        saves_performed = self.stats.saves_performed,
        loads_performed = self.stats.loads_performed
    }
end

return UIFramework