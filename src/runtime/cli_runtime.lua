-- cli_runtime.lua - Whisker Command-Line Interface Runtime
-- Provides a terminal-based interface for playing Whisker stories

local CLIRuntime = {}
CLIRuntime.__index = CLIRuntime

-- Dependencies
local Engine = require('src.core.engine')
local json = require('src.utils.json')
local template_processor = require('src.utils.template_processor')

-- ANSI color codes for terminal formatting
local COLORS = {
    RESET = "\27[0m",
    BOLD = "\27[1m",
    DIM = "\27[2m",
    ITALIC = "\27[3m",
    UNDERLINE = "\27[4m",

    BLACK = "\27[30m",
    RED = "\27[31m",
    GREEN = "\27[32m",
    YELLOW = "\27[33m",
    BLUE = "\27[34m",
    MAGENTA = "\27[35m",
    CYAN = "\27[36m",
    WHITE = "\27[37m",

    BG_BLACK = "\27[40m",
    BG_RED = "\27[41m",
    BG_GREEN = "\27[42m",
    BG_YELLOW = "\27[43m",
    BG_BLUE = "\27[44m",
    BG_MAGENTA = "\27[45m",
    BG_CYAN = "\27[46m",
    BG_WHITE = "\27[47m",
}

-- Box drawing characters
local BOX = {
    TOP_LEFT = "┌",
    TOP_RIGHT = "┐",
    BOTTOM_LEFT = "└",
    BOTTOM_RIGHT = "┘",
    HORIZONTAL = "─",
    VERTICAL = "│",
    T_DOWN = "┬",
    T_UP = "┴",
    T_RIGHT = "├",
    T_LEFT = "┤",
    CROSS = "┼",
}

-- Constructor
function CLIRuntime:new(config)
    local instance = {
        engine = nil,
        config = config or {},
        terminal_width = config.width or 80,
        use_colors = config.colors ~= false,
        save_file = config.save_file or "whisker_save.json",
        history_size = config.history_size or 10,
        running = false,
        stats_visible = true,
        history_visible = true
    }
    setmetatable(instance, self)
    return instance
end

-- Initialization
function CLIRuntime:initialize()
    -- Initialize engine
    self.engine = Engine:new()
    local success, err = self.engine:initialize({
        debug = self.config.debug or false
    })

    if not success then
        self:print_error("Failed to initialize engine: " .. tostring(err))
        return false
    end

    -- Register engine callbacks
    self:register_callbacks()

    -- Clear screen and show welcome
    self:clear_screen()

    return true
end

-- Engine Callbacks
function CLIRuntime:register_callbacks()
    self.engine:on("passage_entered", function(passage_id)
        self:render_passage()
    end)

    self.engine:on("choice_made", function(choice_index)
        self:clear_screen()
    end)

    self.engine:on("game_saved", function()
        self:print_success("Game saved successfully")
    end)

    self.engine:on("game_loaded", function()
        self:print_success("Game loaded successfully")
        self:render_passage()
    end)
end

-- Story Management
function CLIRuntime:load_story(story_data)
    local success, err = self.engine:load_story(story_data)

    if not success then
        self:print_error("Failed to load story: " .. tostring(err))
        return false
    end

    return true
end

function CLIRuntime:load_story_from_file(filepath)
    local file = io.open(filepath, "r")

    if not file then
        self:print_error("Could not open story file: " .. filepath)
        return false
    end

    local content = file:read("*all")
    file:close()

    local story_data = json.decode(content)
    return self:load_story(story_data)
end

function CLIRuntime:start()
    local success, err = self.engine:start()

    if not success then
        self:print_error("Failed to start story: " .. tostring(err))
        return false
    end

    self.running = true
    self:render_passage()

    return true
end

-- Main Game Loop
function CLIRuntime:run()
    if not self.running then
        self:print_error("Story not started. Call start() first.")
        return
    end

    while self.running do
        self:handle_input()
    end
end

-- Input Handling
function CLIRuntime:handle_input()
    io.write(self:colorize("\n> ", COLORS.CYAN, COLORS.BOLD))
    io.flush()

    local input = io.read()

    if not input then
        self.running = false
        return
    end

    input = input:lower():match("^%s*(.-)%s*$") -- Trim whitespace

    -- Parse commands
    if input == "quit" or input == "exit" or input == "q" then
        self:quit()
    elseif input == "save" or input == "s" then
        self:save_game()
    elseif input == "load" or input == "l" then
        self:load_game()
    elseif input == "undo" or input == "u" then
        self:undo()
    elseif input == "restart" or input == "r" then
        self:restart()
    elseif input == "help" or input == "?" then
        self:show_help()
    elseif input == "stats" then
        self:toggle_stats()
    elseif input == "history" then
        self:toggle_history()
    elseif input == "clear" or input == "cls" then
        self:clear_screen()
        self:render_passage()
    elseif input:match("^%d+$") then
        -- Numeric input for choices
        local choice_num = tonumber(input)
        self:make_choice(choice_num)
    elseif input == "" then
        -- Empty input, do nothing
    else
        self:print_error("Unknown command. Type 'help' for available commands.")
    end
end

function CLIRuntime:make_choice(choice_num)
    local passage = self.engine:get_current_passage()

    if not passage or not passage.choices then
        self:print_error("No choices available")
        return
    end

    -- Count visible choices
    local visible_choices = {}
    for i, choice in ipairs(passage.choices) do
        if self:evaluate_choice_condition(choice) then
            table.insert(visible_choices, {index = i, choice = choice})
        end
    end

    if choice_num < 1 or choice_num > #visible_choices then
        self:print_error("Invalid choice number. Please choose 1-" .. #visible_choices)
        return
    end

    local actual_index = visible_choices[choice_num].index
    self.engine:make_choice(actual_index)
end

-- Rendering
function CLIRuntime:render_passage()
    self:clear_screen()

    local passage = self.engine:get_current_passage()

    if not passage then
        self:print_error("No current passage")
        return
    end

    -- Print header
    self:print_header(passage.title or "Untitled")

    -- Print content
    self:print_separator()
    local content = self:process_content(passage.content or "")
    self:print_wrapped(content)
    self:print_separator()

    -- Print choices
    self:render_choices(passage.choices or {})

    -- Print sidebar info if enabled
    if self.stats_visible or self.history_visible then
        self:print_separator()
        if self.stats_visible then
            self:render_stats()
        end
        if self.history_visible then
            self:render_history()
        end
    end

    -- Print commands hint
    self:print_hint()
end

function CLIRuntime:render_choices(choices)
    if #choices == 0 then
        self:print_warning("(No choices available - type 'quit' to exit)")
        return
    end

    print()
    self:print_section("Available Choices:")

    local choice_num = 1
    for i, choice in ipairs(choices) do
        if self:evaluate_choice_condition(choice) then
            local text = self:process_inline(choice.text)
            local formatted = string.format("%s[%d]%s %s", 
                self:colorize("", COLORS.GREEN, COLORS.BOLD),
                choice_num,
                COLORS.RESET,
                text
            )
            print("  " .. formatted)
            choice_num = choice_num + 1
        end
    end
end

function CLIRuntime:render_stats()
    local variables = self.engine:get_all_variables()

    if not variables or not next(variables) then
        return
    end

    print()
    self:print_section("Statistics:")

    for key, value in pairs(variables) do
        local formatted = string.format("  %s: %s%s%s",
            self:colorize(key, COLORS.CYAN),
            self:colorize("", COLORS.YELLOW, COLORS.BOLD),
            tostring(value),
            COLORS.RESET
        )
        print(formatted)
    end
end

function CLIRuntime:render_history()
    local history = self.engine:get_history()

    if not history or #history == 0 then
        return
    end

    print()
    self:print_section("Recent History:")

    local start = math.max(1, #history - self.history_size + 1)
    for i = #history, start, -1 do
        local passage_id = history[i]
        local passage = self.engine:get_passage(passage_id)
        if passage then
            print("  " .. self:colorize("• ", COLORS.DIM) .. (passage.title or passage_id))
        end
    end
end

-- Content Processing
function CLIRuntime:process_content(content)
    -- Get all variables from the engine
    local variables = self.engine:get_all_variables() or {}

    -- Process template with conditionals and variables
    content = template_processor.process(content, variables)

    -- Process markdown-style formatting
    if self.use_colors then
        content = content:gsub("%*%*(.-)%*%*", function(text)
            return self:colorize(text, COLORS.BOLD)
        end)
        content = content:gsub("%*(.-)%*", function(text)
            return self:colorize(text, COLORS.ITALIC)
        end)
        content = content:gsub("__(.-)__", function(text)
            return self:colorize(text, COLORS.UNDERLINE)
        end)
    else
        -- Remove markdown syntax if no colors
        content = content:gsub("%*%*(.-)%*%*", "%1")
        content = content:gsub("%*(.-)%*", "%1")
        content = content:gsub("__(.-)__", "%1")
    end

    return content
end

function CLIRuntime:process_inline(content)
    return self:process_content(content)
end

function CLIRuntime:evaluate_choice_condition(choice)
    if not choice.condition then
        return true
    end

    return self.engine:evaluate_condition(choice.condition)
end

-- Game Actions
function CLIRuntime:save_game()
    local save_data = self.engine:save_game()

    if not save_data then
        self:print_error("Failed to create save data")
        return
    end

    local file = io.open(self.save_file, "w")

    if not file then
        self:print_error("Could not open save file: " .. self.save_file)
        return
    end

    file:write(json.encode(save_data))
    file:close()

    self:print_success("Game saved to: " .. self.save_file)
end

function CLIRuntime:load_game()
    local file = io.open(self.save_file, "r")

    if not file then
        self:print_error("No save file found: " .. self.save_file)
        return
    end

    local content = file:read("*all")
    file:close()

    local save_data = json.decode(content)
    local success = self.engine:load_game(save_data)

    if success then
        self:clear_screen()
        self:render_passage()
    else
        self:print_error("Failed to load save file")
    end
end

function CLIRuntime:undo()
    local success = self.engine:undo()

    if success then
        self:clear_screen()
        self:render_passage()
    else
        self:print_warning("Nothing to undo")
    end
end

function CLIRuntime:restart()
    io.write("Are you sure you want to restart? (y/n): ")
    io.flush()
    local response = io.read()

    if response and response:lower():match("^y") then
        self.engine:restart()
        self:clear_screen()
        self:render_passage()
    end
end

function CLIRuntime:quit()
    print()
    self:print_section("Thanks for playing!")
    self.running = false
end

function CLIRuntime:toggle_stats()
    self.stats_visible = not self.stats_visible
    self:clear_screen()
    self:render_passage()
end

function CLIRuntime:toggle_history()
    self.history_visible = not self.history_visible
    self:clear_screen()
    self:render_passage()
end

-- UI Helpers
function CLIRuntime:clear_screen()
    -- Clear screen (works on most terminals)
    os.execute("clear || cls")
end

function CLIRuntime:print_header(title)
    local width = self.terminal_width
    local title_text = " " .. title .. " "
    local padding = math.floor((width - #title_text) / 2)

    local line = string.rep(BOX.HORIZONTAL, width)
    local title_line = string.rep(BOX.HORIZONTAL, padding) .. title_text .. 
                       string.rep(BOX.HORIZONTAL, width - padding - #title_text)

    print(self:colorize(BOX.TOP_LEFT .. line .. BOX.TOP_RIGHT, COLORS.BLUE))
    print(self:colorize(BOX.VERTICAL, COLORS.BLUE) .. 
          self:colorize(title_line, COLORS.CYAN, COLORS.BOLD) ..
          self:colorize(BOX.VERTICAL, COLORS.BLUE))
    print(self:colorize(BOX.BOTTOM_LEFT .. line .. BOX.BOTTOM_RIGHT, COLORS.BLUE))
end

function CLIRuntime:print_separator()
    print(self:colorize(string.rep(BOX.HORIZONTAL, self.terminal_width), COLORS.DIM))
end

function CLIRuntime:print_section(title)
    print(self:colorize(title, COLORS.YELLOW, COLORS.BOLD))
end

function CLIRuntime:print_hint()
    print()
    local hint = "Commands: [number] choose | help | save | load | undo | restart | quit"
    print(self:colorize(hint, COLORS.DIM))
end

function CLIRuntime:print_wrapped(text, indent)
    indent = indent or 2
    local indent_str = string.rep(" ", indent)
    local width = self.terminal_width - indent - 2

    -- Split into paragraphs
    for paragraph in text:gmatch("[^\n]+") do
        local words = {}
        for word in paragraph:gmatch("%S+") do
            table.insert(words, word)
        end

        local line = indent_str
        for _, word in ipairs(words) do
            -- Strip ANSI codes for length calculation
            local word_len = #(word:gsub("\27%[[%d;]*m", ""))
            local line_len = #(line:gsub("\27%[[%d;]*m", ""))

            if line_len + word_len + 1 > width + indent then
                print(line)
                line = indent_str .. word
            else
                if line == indent_str then
                    line = line .. word
                else
                    line = line .. " " .. word
                end
            end
        end

        if line ~= indent_str then
            print(line)
        end
        print() -- Paragraph break
    end
end

function CLIRuntime:print_success(message)
    print(self:colorize("✓ " .. message, COLORS.GREEN, COLORS.BOLD))
end

function CLIRuntime:print_error(message)
    print(self:colorize("✗ " .. message, COLORS.RED, COLORS.BOLD))
end

function CLIRuntime:print_warning(message)
    print(self:colorize("⚠ " .. message, COLORS.YELLOW))
end

function CLIRuntime:show_help()
    print()
    self:print_section("Whisker CLI Commands:")
    print()
    print("  " .. self:colorize("[number]", COLORS.GREEN) .. "  - Choose an option by its number")
    print("  " .. self:colorize("help, ?", COLORS.GREEN) .. "   - Show this help message")
    print("  " .. self:colorize("save, s", COLORS.GREEN) .. "   - Save your current game")
    print("  " .. self:colorize("load, l", COLORS.GREEN) .. "   - Load your saved game")
    print("  " .. self:colorize("undo, u", COLORS.GREEN) .. "   - Undo your last choice")
    print("  " .. self:colorize("restart, r", COLORS.GREEN) .. " - Restart the story")
    print("  " .. self:colorize("stats", COLORS.GREEN) .. "     - Toggle statistics display")
    print("  " .. self:colorize("history", COLORS.GREEN) .. "   - Toggle history display")
    print("  " .. self:colorize("clear", COLORS.GREEN) .. "    - Clear screen and redraw")
    print("  " .. self:colorize("quit, q", COLORS.GREEN) .. "   - Exit the game")
    print()
end

-- Utility
function CLIRuntime:colorize(text, ...)
    if not self.use_colors then
        return text
    end

    local codes = {...}
    local result = table.concat(codes, "") .. text .. COLORS.RESET
    return result
end

return CLIRuntime