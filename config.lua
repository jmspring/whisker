-- config.lua
-- whisker Engine Configuration
-- Customize engine behavior, paths, and features

local config = {}

-- ============================================================================
-- Engine Configuration
-- ============================================================================

config.engine = {
    -- Story execution
    enable_undo = true,
    max_undo_steps = 50,

    -- Performance
    max_execution_time = 5000,      -- milliseconds
    max_instructions = 1000000,      -- per script execution

    -- Features
    enable_autosave = true,
    autosave_interval = 300,         -- seconds (5 minutes)

    -- Debugging
    verbose_errors = true,
    stack_traces = true
}

-- ============================================================================
-- UI Configuration
-- ============================================================================

config.ui = {
    -- Display
    max_content_width = 80,          -- characters
    clear_screen_on_passage = true,
    show_help_hint = true,

    -- Formatting
    enable_colors = true,            -- ANSI colors in console
    enable_markdown = true,
    word_wrap = true,

    -- Interaction
    numbered_choices = true,
    show_disabled_choices = false,
    choice_prompt = "> ",

    -- Messages
    show_timestamps = false,
    message_duration = 3             -- seconds for transient messages
}

-- ============================================================================
-- Save System Configuration
-- ============================================================================

config.save_system = {
    -- Paths
    save_directory = "saves",
    backup_directory = "saves/backups",

    -- Behavior
    max_save_slots = 10,
    auto_backup = true,
    compress_saves = false,

    -- Autosave
    enable_autosave = true,
    autosave_on_choice = true,
    autosave_on_passage = false,

    -- Quick save
    enable_quick_save = true,
    quick_save_key = "F5"
}

-- ============================================================================
-- Platform Configuration
-- ============================================================================

config.platform = {
    -- Asset management
    asset_cache_size = 50 * 1024 * 1024,  -- 50MB
    preload_assets = false,

    -- File system
    base_path = "./",
    story_path = "stories",
    asset_path = "assets",

    -- Input
    input_timeout = 0,               -- 0 = no timeout
    enable_shortcuts = true
}

-- ============================================================================
-- Interpreter Configuration
-- ============================================================================

config.interpreter = {
    -- Security
    sandbox_enabled = true,
    allow_file_access = false,
    allow_network_access = false,

    -- Limits
    memory_limit = 10 * 1024 * 1024, -- 10MB
    execution_timeout = 5000,         -- milliseconds
    max_stack_depth = 100,

    -- Features
    enable_require = false,           -- Allow require() in stories
    enable_debug = false,             -- Allow debug library

    -- Allowed modules (if enable_require = true)
    allowed_modules = {
        "math",
        "string",
        "table"
    }
}

-- ============================================================================
-- Validator Configuration
-- ============================================================================

config.validator = {
    -- Checks
    check_structure = true,
    check_links = true,
    check_variables = true,
    check_accessibility = true,
    check_content = true,

    -- Thresholds
    max_passage_length = 1000,       -- characters
    max_choices = 10,                -- choices per passage
    min_choice_text_length = 2,      -- characters

    -- Warnings
    warn_on_long_passages = true,
    warn_on_many_choices = true,
    warn_on_orphaned_passages = true
}

-- ============================================================================
-- Profiler Configuration
-- ============================================================================

config.profiler = {
    -- Profiling
    default_mode = "basic",          -- basic, detailed, memory, full

    -- Thresholds
    slow_passage_threshold = 100,    -- milliseconds
    memory_warning_threshold = 100,  -- kilobytes

    -- Output
    generate_report = true,
    report_format = "text",          -- text, json
    save_report = false,
    report_path = "reports"
}

-- ============================================================================
-- Debugger Configuration
-- ============================================================================

config.debugger = {
    -- Default mode
    default_mode = "off",            -- off, step, breakpoint, trace

    -- Features
    enable_watches = true,
    enable_breakpoints = true,
    track_history = true,

    -- Limits
    max_history = 1000,              -- history entries
    max_watches = 50,
    max_breakpoints = 100
}

-- ============================================================================
-- Format Converter Configuration
-- ============================================================================

config.converter = {
    -- Import
    auto_detect_format = true,
    strict_parsing = false,

    -- Export
    pretty_print = true,
    include_metadata = true,
    preserve_positions = true,

    -- Twine compatibility
    default_twine_format = "harlowe",
    convert_macros = true
}

-- ============================================================================
-- Development Configuration
-- ============================================================================

config.dev = {
    -- Debugging
    debug_mode = false,
    verbose_logging = false,
    log_file = "whisker.log",

    -- Testing
    enable_test_mode = false,
    mock_file_system = false,

    -- Hot reload
    enable_hot_reload = false,
    watch_directories = {"stories", "assets"}
}

-- ============================================================================
-- Web Platform Configuration (for web runtime)
-- ============================================================================

config.web = {
    -- Display
    container_id = "whisker-container",
    theme = "default",               -- default, dark, light, custom

    -- Features
    enable_animations = true,
    transition_duration = 300,       -- milliseconds
    enable_sound = true,

    -- UI
    show_progress_bar = true,
    show_save_ui = true,
    show_settings_ui = true,

    -- Assets
    cdn_url = "",
    lazy_load_assets = true
}

-- ============================================================================
-- Logging Configuration
-- ============================================================================

config.logging = {
    -- General
    enabled = true,
    level = "info",                  -- debug, info, warn, error

    -- Output
    log_to_file = false,
    log_to_console = true,
    log_file = "whisker.log",

    -- Format
    timestamp_format = "%Y-%m-%d %H:%M:%S",
    include_timestamps = true,
    include_level = true
}

-- ============================================================================
-- Paths Configuration
-- ============================================================================

config.paths = {
    -- Source
    engine_dir = "engine",

    -- Content
    stories_dir = "stories",
    assets_dir = "assets",
    saves_dir = "saves",

    -- Output
    output_dir = "output",
    reports_dir = "reports",
    logs_dir = "logs",

    -- Player
    player_dir = "player",

    -- Tests
    tests_dir = "tests",
    fixtures_dir = "tests/fixtures"
}

-- ============================================================================
-- Feature Flags
-- ============================================================================

config.features = {
    -- Core features
    enable_lua_scripts = true,
    enable_variables = true,
    enable_conditions = true,

    -- UI features
    enable_undo = true,
    enable_save_system = true,
    enable_help = true,

    -- Advanced features
    enable_events = true,
    enable_plugins = false,
    enable_multiplayer = false,

    -- Development features
    enable_console = true,
    enable_profiler = true,
    enable_debugger = true,
    enable_validator = true
}

-- ============================================================================
-- Performance Configuration
-- ============================================================================

config.performance = {
    -- Caching
    enable_caching = true,
    cache_passages = true,
    cache_assets = true,

    -- Optimization
    lazy_load_passages = false,
    precompile_scripts = true,
    optimize_memory = true,

    -- Limits
    max_passages_in_memory = 100,
    garbage_collect_interval = 60    -- seconds
}

-- ============================================================================
-- User Preferences (can be overridden by user)
-- ============================================================================

config.user = {
    -- Display
    font_size = 14,
    font_family = "monospace",

    -- Gameplay
    text_speed = 1.0,
    auto_advance = false,

    -- Accessibility
    high_contrast = false,
    screen_reader_mode = false,
    reduced_motion = false,

    -- Audio
    master_volume = 1.0,
    music_volume = 0.8,
    sfx_volume = 1.0
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Load user config from file (if exists)
function config.load_user_config(filename)
    filename = filename or "config.user.lua"

    local file = io.open(filename, "r")
    if not file then
        return false
    end
    file:close()

    local user_config = dofile(filename)
    if user_config then
        -- Merge user config with default config
        for category, values in pairs(user_config) do
            if config[category] then
                for key, value in pairs(values) do
                    config[category][key] = value
                end
            end
        end
    end

    return true
end

-- Save user config to file
function config.save_user_config(filename)
    filename = filename or "config.user.lua"

    local file = io.open(filename, "w")
    if not file then
        return false
    end

    file:write("-- whisker User Configuration\n")
    file:write("-- Auto-generated\n\n")
    file:write("return {\n")

    -- Save user preferences
    file:write("  user = {\n")
    for key, value in pairs(config.user) do
        local value_str = type(value) == "string" and ('"' .. value .. '"') or tostring(value)
        file:write(string.format('    %s = %s,\n', key, value_str))
    end
    file:write("  }\n")

    file:write("}\n")
    file:close()

    return true
end

-- Get config value by path (e.g., "engine.enable_undo")
function config.get(path)
    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local value = config
    for _, key in ipairs(keys) do
        value = value[key]
        if not value then
            return nil
        end
    end

    return value
end

-- Set config value by path
function config.set(path, new_value)
    local keys = {}
    for key in path:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local value = config
    for i = 1, #keys - 1 do
        value = value[keys[i]]
        if not value then
            return false
        end
    end

    value[keys[#keys]] = new_value
    return true
end

-- Validate configuration
function config.validate()
    local errors = {}

    -- Check required directories exist or can be created
    local dirs = {
        config.paths.saves_dir,
        config.paths.output_dir
    }

    for _, dir in ipairs(dirs) do
        -- Try to create directory
        os.execute("mkdir -p " .. dir)
    end

    -- Check numeric values are in valid ranges
    if config.engine.max_undo_steps < 1 then
        table.insert(errors, "engine.max_undo_steps must be >= 1")
    end

    if config.ui.max_content_width < 40 then
        table.insert(errors, "ui.max_content_width must be >= 40")
    end

    return #errors == 0, errors
end

-- Try to load user config on module load
config.load_user_config()

return config
