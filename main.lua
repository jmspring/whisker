#!/usr/bin/env lua
-- main.lua
-- whisker Interactive Fiction Engine
-- Main entry point and command-line interface

-- Add engine to package path
package.path = package.path .. ";./engine/?.lua;./engine/?/init.lua"

-- Load configuration
local config = require("config")

-- Core modules
local Story = require("engine.core.story")
local Passage = require("engine.core.passage")
local Choice = require("engine.core.choice")
local Engine = require("engine.core.engine")
local GameState = require("engine.core.game_state")

-- UI and infrastructure
local UIFramework = require("engine.ui.ui_framework")
local InputHandler = require("engine.infrastructure.input_handler")

-- Format support
local TwineImporter = require("engine.format.twine_importer")
local FormatConverter = require("engine.format.format_converter")
local WhiskerLoader = require("engine.format.whisker_loader")

-- Tools (optional)
local Validator = require("engine.tools.validator")
local Profiler = require("engine.tools.profiler")
local Debugger = require("engine.tools.debugger")

-- Save system
local SaveSystem = require("engine.infrastructure.save_system")

-- Version info
local VERSION = "1.0.0"
local APP_NAME = "whisker"

-- CLI state
local cli = {
    mode = "play",           -- play, validate, convert, help
    story_file = nil,
    debug_mode = false,
    profile_mode = false,
    output_file = nil,
    verbose = false
}

-- Print help message
local function print_help()
    print(string.format([[
%s v%s - Interactive Fiction Engine

USAGE:
    lua main.lua [OPTIONS] <story_file>

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show version information
    --validate              Validate story without playing
    --convert <format>      Convert story to format (json, twee, html, md)
    --debug                 Enable debug mode with breakpoints
    --profile               Enable performance profiling
    --verbose               Show detailed output
    -o, --output <file>     Output file for conversion

EXAMPLES:
    # Play a story
    lua main.lua examples/adventure_game.lua

    # Validate a story
    lua main.lua --validate examples/simple_story.lua

    # Convert Twine HTML to JSON
    lua main.lua --convert json story.html -o story.json

    # Play with debugging
    lua main.lua --debug examples/tutorial_story.lua

    # Profile performance
    lua main.lua --profile examples/adventure_game.lua

STORY FORMATS:
    Supported input formats:
        - .lua (whisker Lua native)
        - .whisker (whisker JSON format)
        - .json (whisker JSON format)
        - .html (Twine HTML)
        - .twee (Twee notation)

    Supported output formats:
        - json, twee, html, md (markdown)

For more information, visit: https://github.com/jmspring/whisker
]], APP_NAME, VERSION))
end

-- Print version
local function print_version()
    print(string.format("%s v%s", APP_NAME, VERSION))
    print("Interactive Fiction Engine")
    print("Built with Lua " .. _VERSION)
end

-- Parse command line arguments
local function parse_args(args)
    local i = 1
    while i <= #args do
        local arg = args[i]

        if arg == "-h" or arg == "--help" then
            cli.mode = "help"
            return true

        elseif arg == "-v" or arg == "--version" then
            cli.mode = "version"
            return true

        elseif arg == "--validate" then
            cli.mode = "validate"

        elseif arg == "--convert" then
            cli.mode = "convert"
            i = i + 1
            if i <= #args then
                cli.output_format = args[i]
            else
                print("Error: --convert requires a format argument")
                return false
            end

        elseif arg == "--debug" then
            cli.debug_mode = true

        elseif arg == "--profile" then
            cli.profile_mode = true

        elseif arg == "--verbose" then
            cli.verbose = true

        elseif arg == "-o" or arg == "--output" then
            i = i + 1
            if i <= #args then
                cli.output_file = args[i]
            else
                print("Error: -o/--output requires a file argument")
                return false
            end

        elseif not arg:match("^%-") then
            -- Story file
            cli.story_file = arg

        else
            print("Error: Unknown option: " .. arg)
            return false
        end

        i = i + 1
    end

    return true
end

-- Load story from file
local function load_story(filename)
    if cli.verbose then
        print("Loading story: " .. filename)
    end

    -- Determine file type
    local ext = filename:match("%.([^%.]+)$")

    if ext == "lua" then
        -- Load Lua story
        local story_func = loadfile(filename)
        if not story_func then
            return nil, "Failed to load Lua file"
        end

        local success, story = pcall(story_func)
        if not success then
            return nil, "Error executing Lua story: " .. tostring(story)
        end

        return story, nil

    elseif ext == "html" then
        -- Import Twine HTML
        local file = io.open(filename, "r")
        if not file then
            return nil, "Failed to open file"
        end

        local html = file:read("*all")
        file:close()

        local importer = TwineImporter.new()
        local story = importer:import_from_html(html)

        if not story then
            return nil, "Failed to import Twine HTML"
        end

        return story, nil

    elseif ext == "twee" then
        -- Import Twee
        local file = io.open(filename, "r")
        if not file then
            return nil, "Failed to open file"
        end

        local twee = file:read("*all")
        file:close()

        local importer = TwineImporter.new()
        local story = importer:import_from_twee(twee)

        if not story then
            return nil, "Failed to import Twee"
        end

        return story, nil

    elseif ext == "json" or ext == "whisker" then
        -- Load Whisker JSON format
        local story, err = WhiskerLoader.load_from_file(filename)
        if not story then
            return nil, "Failed to load Whisker file: " .. (err or "unknown error")
        end

        return story, nil

    else
        return nil, "Unsupported file format: " .. (ext or "unknown")
    end
end

-- Validate story
local function validate_story(story)
    print("\n=== Story Validation ===\n")

    local validator = Validator.new()
    local results = validator:validate_story(story)

    print(validator:generate_report("text"))

    return results.summary.is_valid
end

-- Convert story
local function convert_story(story, output_format, output_file)
    print("\n=== Story Conversion ===\n")
    print("Converting to: " .. output_format)

    local converter = FormatConverter.new()
    local output, err = converter:convert(story, "whisker", output_format)

    if not output then
        print("Conversion failed: " .. (err or "unknown error"))
        return false
    end

    if output_file then
        local file = io.open(output_file, "w")
        if not file then
            print("Failed to open output file: " .. output_file)
            return false
        end

        file:write(output)
        file:close()

        print("Converted story saved to: " .. output_file)
    else
        print("\n--- Converted Story ---")
        print(output)
    end

    return true
end

-- Play story (main game loop)
local function play_story(story)
    -- Get title and author from metadata or direct properties
    local title = story.title or (story.metadata and story.metadata.name) or (story.metadata and story.metadata.title) or "Untitled Story"
    local author = story.author or (story.metadata and story.metadata.author)

    print("\n" .. string.rep("=", 60))
    print("  " .. title)
    if author then
        print("  by " .. author)
    end
    print(string.rep("=", 60) .. "\n")

    -- Create game components
    local game_state = GameState.new()
    local engine = Engine.new(story, game_state)
    local ui = UIFramework.new("console", config.ui)
    local save_system = SaveSystem.new(config.save_system)

    -- Optional: Setup profiler
    local profiler = nil
    if cli.profile_mode then
        profiler = Profiler.new(engine, game_state)
        profiler:start(Profiler.ProfileMode.FULL)
        print("[Profiling enabled]\n")
    end

    -- Optional: Setup debugger
    local debugger = nil
    if cli.debug_mode then
        debugger = Debugger.new(engine, game_state)
        debugger:enable(Debugger.DebugMode.STEP)
        print("[Debug mode enabled - type 'help' for debug commands]\n")
    end

    -- Start story
    local content = engine:start_story()
    local running = true

    -- Main game loop
    while running do
        -- Display current passage
        ui:display_passage(content, game_state)

        -- Check for game end
        if not content.choices or #content.choices == 0 then
            print("\n" .. string.rep("=", 60))
            print("  THE END")
            print(string.rep("=", 60))
            break
        end

        -- Get player input
        local input = ui:get_user_input()

        -- Handle commands
        if input.type == "command" then
            local cmd = input.command:lower()

            if cmd == "quit" or cmd == "q" or cmd == "exit" then
                if ui:confirm_action("Are you sure you want to quit?") then
                    running = false
                end

            elseif cmd == "save" or cmd == "s" then
                local save_name = ui:get_save_name()
                local slot = ui:get_save_slot()
                if save_system:save_game(game_state, story, slot, save_name) then
                    ui:show_message("Game saved!", "success")
                else
                    ui:show_message("Save failed!", "error")
                end

            elseif cmd == "load" or cmd == "l" then
                local saves = save_system:list_saves()
                local slot = ui:show_load_interface(saves)
                if slot then
                    local loaded_state, loaded_story = save_system:load_game(slot)
                    if loaded_state then
                        game_state = loaded_state
                        engine = Engine.new(story, game_state)
                        content = engine:get_current_content()
                        ui:show_message("Game loaded!", "success")
                    else
                        ui:show_message("Load failed!", "error")
                    end
                end

            elseif cmd == "undo" or cmd == "u" then
                if game_state:can_undo() then
                    content = engine:undo()
                    ui:show_message("Action undone", "info")
                else
                    ui:show_message("Nothing to undo", "warning")
                end

            elseif cmd == "restart" or cmd == "r" then
                if ui:confirm_action("Restart story? (unsaved progress will be lost)") then
                    game_state:reset()
                    content = engine:start_story()
                    ui:show_message("Story restarted", "info")
                end

            elseif cmd == "help" or cmd == "h" then
                ui:show_help()

            else
                ui:show_message("Unknown command: " .. cmd, "warning")
            end

        elseif input.type == "choice" then
            -- Make choice
            local success, new_content = pcall(function()
                return engine:make_choice(input.choice)
            end)

            if success then
                content = new_content
            else
                ui:show_message("Error: " .. tostring(new_content), "error")
            end
        end
    end

    -- Cleanup and show stats
    if profiler then
        profiler:stop()
        print("\n" .. profiler:generate_report("text"))
    end

    if debugger then
        print("\n" .. debugger:generate_report())
    end

    print("\nThanks for playing!")
end

-- Main entry point
local function main(args)
    -- Parse arguments
    if not parse_args(args) then
        print("\nUse --help for usage information")
        return 1
    end

    -- Handle special modes
    if cli.mode == "help" then
        print_help()
        return 0
    end

    if cli.mode == "version" then
        print_version()
        return 0
    end

    -- Check for story file
    if not cli.story_file then
        print("Error: No story file specified")
        print("\nUse --help for usage information")
        return 1
    end

    -- Load story
    local story, err = load_story(cli.story_file)
    if not story then
        print("Error loading story: " .. (err or "unknown error"))
        return 1
    end

    -- Execute based on mode
    if cli.mode == "validate" then
        local valid = validate_story(story)
        return valid and 0 or 1

    elseif cli.mode == "convert" then
        local success = convert_story(story, cli.output_format, cli.output_file)
        return success and 0 or 1

    else
        -- Play story
        play_story(story)
        return 0
    end
end

-- Run if called directly
if arg then
    local exit_code = main(arg)
    os.exit(exit_code)
end

-- Export for testing
return {
    main = main,
    VERSION = VERSION,
    APP_NAME = APP_NAME
}
