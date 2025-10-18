-- web_runtime.lua - Whisker Web Player Runtime
-- Complete implementation for browser-based interactive fiction player

local WebRuntime = {}
WebRuntime.__index = WebRuntime

-- Dependencies
local Engine = require('whisker')
local json = require('json') -- Assuming JSON library available
local template_processor = require('whisker.utils.template_processor')

-- Constructor
function WebRuntime.new(container_id, config)
    local instance = {
        engine = nil,
        container_id = container_id or "whisker-container",
        config = config or {},
        dom_elements = {},
        event_listeners = {},
        current_theme = "default",
        ui_state = {
            sidebar_visible = true,
            font_size = 1.0,
            animations_enabled = true,
            auto_save_enabled = true
        },
        notification_queue = {},
        save_slots = 5,
        auto_save_interval = 30000, -- 30 seconds
        auto_save_timer = nil
    }
    setmetatable(instance, self)
    return instance
end

-- Initialization
function WebRuntime:initialize()
    -- Initialize engine
    self.engine = Engine.new()
    local success, err = self.engine:initialize({
        debug = self.config.debug or false
    })

    if not success then
        self:show_error("Failed to initialize engine: " .. tostring(err))
        return false
    end

    -- Set up DOM structure
    self:create_dom()

    -- Set up event handlers
    self:setup_event_handlers()

    -- Load settings from localStorage
    self:load_settings()

    -- Apply theme
    self:apply_theme(self.current_theme)

    -- Set up auto-save
    if self.ui_state.auto_save_enabled then
        self:start_auto_save()
    end

    -- Register engine callbacks
    self:register_engine_callbacks()

    return true
end

-- DOM Creation
function WebRuntime:create_dom()
    local container = js.global.document:getElementById(self.container_id)

    if not container then
        error("Container element not found: " .. self.container_id)
    end

    container.innerHTML = [[
        <div class="whisker-app">
            <header class="whisker-header">
                <div class="whisker-title-section">
                    <h1 class="whisker-title" id="whisker-story-title">Whisker Story</h1>
                    <div class="whisker-subtitle" id="whisker-story-author"></div>
                </div>
                <div class="whisker-controls">
                    <button class="whisker-btn whisker-undo-btn" id="whisker-undo" title="Undo (Ctrl+Z)">
                        <span class="whisker-icon">↶</span>
                        <span class="whisker-btn-text">Undo</span>
                    </button>
                    <button class="whisker-btn whisker-save-btn" id="whisker-save" title="Save (Ctrl+S)">
                        <span class="whisker-icon">💾</span>
                        <span class="whisker-btn-text">Save</span>
                    </button>
                    <button class="whisker-btn whisker-load-btn" id="whisker-load" title="Load">
                        <span class="whisker-icon">📁</span>
                        <span class="whisker-btn-text">Load</span>
                    </button>
                    <button class="whisker-btn whisker-restart-btn" id="whisker-restart" title="Restart">
                        <span class="whisker-icon">🔄</span>
                        <span class="whisker-btn-text">Restart</span>
                    </button>
                    <button class="whisker-btn whisker-settings-btn" id="whisker-settings" title="Settings">
                        <span class="whisker-icon">⚙️</span>
                        <span class="whisker-btn-text">Settings</span>
                    </button>
                </div>
            </header>

            <div class="whisker-progress-bar">
                <div class="whisker-progress-fill" id="whisker-progress"></div>
            </div>

            <div class="whisker-main">
                <div class="whisker-content">
                    <div class="whisker-passage" id="whisker-passage">
                        <h2 class="whisker-passage-title" id="whisker-passage-title"></h2>
                        <div class="whisker-passage-content" id="whisker-passage-content"></div>
                        <div class="whisker-choices" id="whisker-choices"></div>
                    </div>
                </div>

                <aside class="whisker-sidebar" id="whisker-sidebar">
                    <div class="whisker-sidebar-section">
                        <h3 class="whisker-sidebar-heading">Variables</h3>
                        <div class="whisker-stats" id="whisker-stats"></div>
                    </div>

                    <div class="whisker-sidebar-section">
                        <h3 class="whisker-sidebar-heading">History</h3>
                        <div class="whisker-history" id="whisker-history"></div>
                    </div>

                    <div class="whisker-sidebar-section">
                        <h3 class="whisker-sidebar-heading">Progress</h3>
                        <div class="whisker-progress-info" id="whisker-progress-info">
                            <div class="whisker-stat-row">
                                <span class="whisker-stat-label">Passages Visited:</span>
                                <span class="whisker-stat-value" id="whisker-passages-visited">0</span>
                            </div>
                            <div class="whisker-stat-row">
                                <span class="whisker-stat-label">Total Passages:</span>
                                <span class="whisker-stat-value" id="whisker-passages-total">0</span>
                            </div>
                            <div class="whisker-stat-row">
                                <span class="whisker-stat-label">Choices Made:</span>
                                <span class="whisker-stat-value" id="whisker-choices-made">0</span>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>

            <div class="whisker-notifications" id="whisker-notifications"></div>
        </div>

        <!-- Save Modal -->
        <div class="whisker-modal" id="whisker-save-modal">
            <div class="whisker-modal-overlay"></div>
            <div class="whisker-modal-content">
                <div class="whisker-modal-header">
                    <h2 class="whisker-modal-title">Save Game</h2>
                    <button class="whisker-modal-close" id="whisker-save-modal-close">&times;</button>
                </div>
                <div class="whisker-modal-body" id="whisker-save-slots"></div>
            </div>
        </div>

        <!-- Load Modal -->
        <div class="whisker-modal" id="whisker-load-modal">
            <div class="whisker-modal-overlay"></div>
            <div class="whisker-modal-content">
                <div class="whisker-modal-header">
                    <h2 class="whisker-modal-title">Load Game</h2>
                    <button class="whisker-modal-close" id="whisker-load-modal-close">&times;</button>
                </div>
                <div class="whisker-modal-body" id="whisker-load-slots"></div>
            </div>
        </div>

        <!-- Settings Modal -->
        <div class="whisker-modal" id="whisker-settings-modal">
            <div class="whisker-modal-overlay"></div>
            <div class="whisker-modal-content">
                <div class="whisker-modal-header">
                    <h2 class="whisker-modal-title">Settings</h2>
                    <button class="whisker-modal-close" id="whisker-settings-modal-close">&times;</button>
                </div>
                <div class="whisker-modal-body">
                    <div class="whisker-setting-group">
                        <label class="whisker-setting-label">Theme</label>
                        <select class="whisker-setting-select" id="whisker-theme-select">
                            <option value="default">Default</option>
                            <option value="dark">Dark</option>
                            <option value="light">Light</option>
                            <option value="sepia">Sepia</option>
                        </select>
                    </div>

                    <div class="whisker-setting-group">
                        <label class="whisker-setting-label">Font Size</label>
                        <input type="range" class="whisker-setting-range" id="whisker-font-size" 
                               min="0.8" max="1.5" step="0.1" value="1.0">
                        <span class="whisker-setting-value" id="whisker-font-size-value">100%</span>
                    </div>

                    <div class="whisker-setting-group">
                        <label class="whisker-setting-checkbox">
                            <input type="checkbox" id="whisker-auto-save" checked>
                            <span>Enable Auto-Save</span>
                        </label>
                    </div>

                    <div class="whisker-setting-group">
                        <label class="whisker-setting-checkbox">
                            <input type="checkbox" id="whisker-animations" checked>
                            <span>Enable Animations</span>
                        </label>
                    </div>
                </div>
            </div>
        </div>
    ]]

    -- Store DOM element references
    self.dom_elements = {
        story_title = js.global.document:getElementById("whisker-story-title"),
        story_author = js.global.document:getElementById("whisker-story-author"),
        passage_title = js.global.document:getElementById("whisker-passage-title"),
        passage_content = js.global.document:getElementById("whisker-passage-content"),
        choices = js.global.document:getElementById("whisker-choices"),
        stats = js.global.document:getElementById("whisker-stats"),
        history = js.global.document:getElementById("whisker-history"),
        progress = js.global.document:getElementById("whisker-progress"),
        passages_visited = js.global.document:getElementById("whisker-passages-visited"),
        passages_total = js.global.document:getElementById("whisker-passages-total"),
        choices_made = js.global.document:getElementById("whisker-choices-made"),
        notifications = js.global.document:getElementById("whisker-notifications"),
        sidebar = js.global.document:getElementById("whisker-sidebar")
    }
end

-- Event Handlers
function WebRuntime:setup_event_handlers()
    local doc = js.global.document

    -- Control buttons
    doc:getElementById("whisker-undo").onclick = function() self:undo() end
    doc:getElementById("whisker-save").onclick = function() self:show_save_modal() end
    doc:getElementById("whisker-load").onclick = function() self:show_load_modal() end
    doc:getElementById("whisker-restart").onclick = function() self:restart() end
    doc:getElementById("whisker-settings").onclick = function() self:show_settings_modal() end

    -- Modal close buttons
    doc:getElementById("whisker-save-modal-close").onclick = function() 
        self:close_modal("whisker-save-modal") 
    end
    doc:getElementById("whisker-load-modal-close").onclick = function() 
        self:close_modal("whisker-load-modal") 
    end
    doc:getElementById("whisker-settings-modal-close").onclick = function() 
        self:close_modal("whisker-settings-modal") 
    end

    -- Settings controls
    doc:getElementById("whisker-theme-select").onchange = function(event)
        self:apply_theme(event.target.value)
    end

    doc:getElementById("whisker-font-size").oninput = function(event)
        local value = tonumber(event.target.value)
        self:set_font_size(value)
    end

    doc:getElementById("whisker-auto-save").onchange = function(event)
        self.ui_state.auto_save_enabled = event.target.checked
        if event.target.checked then
            self:start_auto_save()
        else
            self:stop_auto_save()
        end
        self:save_settings()
    end

    doc:getElementById("whisker-animations").onchange = function(event)
        self.ui_state.animations_enabled = event.target.checked
        self:save_settings()
    end

    -- Keyboard shortcuts
    js.global.document.onkeydown = function(event)
        if event.ctrlKey or event.metaKey then
            if event.key == "s" then
                event:preventDefault()
                self:show_save_modal()
            elseif event.key == "z" then
                event:preventDefault()
                self:undo()
            elseif event.key == "l" then
                event:preventDefault()
                self:show_load_modal()
            end
        end
    end

    -- Close modals when clicking overlay
    local modals = {"whisker-save-modal", "whisker-load-modal", "whisker-settings-modal"}
    for _, modal_id in ipairs(modals) do
        local modal = doc:getElementById(modal_id)
        modal:querySelector(".whisker-modal-overlay").onclick = function()
            self:close_modal(modal_id)
        end
    end
end

-- Engine Callbacks
function WebRuntime:register_engine_callbacks()
    -- Passage entered callback
    self.engine:on("passage_entered", function(passage_id)
        self:render_current_passage()
        self:update_progress()
        self:update_history()
    end)

    -- Choice made callback
    self.engine:on("choice_made", function(choice_index)
        self:update_progress()
    end)

    -- Variable changed callback
    self.engine:on("variable_changed", function(key, value)
        self:update_stats()
    end)

    -- Game saved callback
    self.engine:on("game_saved", function()
        self:show_notification("Game saved", "success")
    end)

    -- Game loaded callback
    self.engine:on("game_loaded", function()
        self:show_notification("Game loaded", "success")
        self:render_current_passage()
        self:update_all()
    end)
end

-- Story Management
function WebRuntime:load_story(story_data)
    local success, err = self.engine:load_story(story_data)

    if not success then
        self:show_error("Failed to load story: " .. tostring(err))
        return false
    end

    -- Update UI with story info
    self.dom_elements.story_title.textContent = story_data.title or "Untitled Story"
    if story_data.author then
        self.dom_elements.story_author.textContent = "by " .. story_data.author
        self.dom_elements.story_author.style.display = "block"
    end

    -- Update total passages count
    self.dom_elements.passages_total.textContent = tostring(#story_data.passages or 0)

    return true
end

function WebRuntime:start_story()
    local success, err = self.engine:start()

    if not success then
        self:show_error("Failed to start story: " .. tostring(err))
        return false
    end

    self:render_current_passage()
    self:update_all()

    return true
end

-- Rendering
function WebRuntime:render_current_passage()
    local passage = self.engine:get_current_passage()

    if not passage then
        return
    end

    -- Render title
    self.dom_elements.passage_title.textContent = passage.title or ""

    -- Process and render content
    local content = self:process_content(passage.content or "")
    self.dom_elements.passage_content.innerHTML = content

    -- Render choices
    self:render_choices(passage.choices or {})

    -- Update stats
    self:update_stats()

    -- Animate passage if enabled
    if self.ui_state.animations_enabled then
        self.dom_elements.passage_title.classList:add("whisker-fade-in")
        self.dom_elements.passage_content.classList:add("whisker-fade-in")
    end
end

function WebRuntime:render_choices(choices)
    self.dom_elements.choices.innerHTML = ""

    for i, choice in ipairs(choices) do
        -- Check if choice condition is met
        if self:evaluate_choice_condition(choice) then
            local button = js.global.document:createElement("button")
            button.className = "whisker-choice-btn"
            button.innerHTML = self:process_inline(choice.text)

            button.onclick = function()
                self.engine:make_choice(i)
            end

            self.dom_elements.choices:appendChild(button)
        end
    end
end

function WebRuntime:process_content(content)
    -- Get all variables from the engine
    local variables = self.engine:get_all_variables() or {}

    -- Process template with conditionals and variables
    content = template_processor.process(content, variables)

    -- Process markdown-style formatting
    content = content:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")
    content = content:gsub("%*(.-)%*", "<em>%1</em>")
    content = content:gsub("__(.-)__", "<u>%1</u>")

    -- Convert double line breaks to paragraphs
    local paragraphs = {}
    for para in content:gmatch("[^\n\n]+") do
        if para:match("%S") then
            table.insert(paragraphs, "<p>" .. para:gsub("\n", "<br>") .. "</p>")
        end
    end

    return table.concat(paragraphs, "\n")
end

function WebRuntime:process_inline(content)
    -- Same as process_content but without paragraph wrapping
    local variables = self.engine:get_all_variables() or {}

    -- Process template with conditionals and variables
    content = template_processor.process(content, variables)

    -- Process markdown-style formatting
    content = content:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")
    content = content:gsub("%*(.-)%*", "<em>%1</em>")

    return content
end

function WebRuntime:evaluate_choice_condition(choice)
    if not choice.condition then
        return true
    end

    return self.engine:evaluate_condition(choice.condition)
end

-- UI Updates
function WebRuntime:update_stats()
    local variables = self.engine:get_all_variables()
    self.dom_elements.stats.innerHTML = ""

    for key, value in pairs(variables) do
        local stat_row = js.global.document:createElement("div")
        stat_row.className = "whisker-stat-row"
        stat_row.innerHTML = string.format([[
            <span class="whisker-stat-label">%s:</span>
            <span class="whisker-stat-value">%s</span>
        ]], key, tostring(value))
        self.dom_elements.stats:appendChild(stat_row)
    end
end

function WebRuntime:update_history()
    local history = self.engine:get_history()
    self.dom_elements.history.innerHTML = ""

    -- Show last 5 passages
    local recent = {}
    for i = math.max(1, #history - 4), #history do
        table.insert(recent, history[i])
    end

    for i = #recent, 1, -1 do
        local passage_id = recent[i]
        local passage = self.engine:get_passage(passage_id)

        if passage then
            local item = js.global.document:createElement("div")
            item.className = "whisker-history-item"
            item.textContent = passage.title or passage_id
            self.dom_elements.history:appendChild(item)
        end
    end
end

function WebRuntime:update_progress()
    local visited_count = self.engine:get_visited_count()
    local total_count = self.engine:get_total_passages()
    local choices_made = self.engine:get_choices_made_count()

    self.dom_elements.passages_visited.textContent = tostring(visited_count)
    self.dom_elements.passages_total.textContent = tostring(total_count)
    self.dom_elements.choices_made.textContent = tostring(choices_made)

    local percentage = total_count > 0 and (visited_count / total_count * 100) or 0
    self.dom_elements.progress.style.width = string.format("%.1f%%", percentage)
end

function WebRuntime:update_all()
    self:update_stats()
    self:update_history()
    self:update_progress()
end

-- Game Actions
function WebRuntime:undo()
    local success = self.engine:undo()

    if success then
        self:render_current_passage()
        self:update_all()
        self:show_notification("Action undone", "info")
    else
        self:show_notification("Nothing to undo", "info")
    end
end

function WebRuntime:restart()
    if js.global:confirm("Are you sure you want to restart the story?") then
        self.engine:restart()
        self:render_current_passage()
        self:update_all()
        self:show_notification("Story restarted", "info")
    end
end

-- Save/Load System
function WebRuntime:show_save_modal()
    self:open_modal("whisker-save-modal")
    self:render_save_slots()
end

function WebRuntime:show_load_modal()
    self:open_modal("whisker-load-modal")
    self:render_load_slots()
end

function WebRuntime:render_save_slots()
    local container = js.global.document:getElementById("whisker-save-slots")
    container.innerHTML = ""

    for slot = 1, self.save_slots do
        local save_data = self:get_save_data(slot)
        local slot_elem = js.global.document:createElement("div")
        slot_elem.className = "whisker-save-slot"

        if save_data then
            slot_elem.innerHTML = string.format([[
                <div class="whisker-save-slot-header">
                    <span class="whisker-save-slot-number">Slot %d</span>
                    <span class="whisker-save-slot-date">%s</span>
                </div>
                <div class="whisker-save-slot-info">%s</div>
            ]], slot, save_data.date, save_data.passage_title)
        else
            slot_elem.classList:add("whisker-save-slot-empty")
            slot_elem.innerHTML = string.format([[
                <div class="whisker-save-slot-header">
                    <span class="whisker-save-slot-number">Slot %d</span>
                </div>
                <div class="whisker-save-slot-info">Empty Slot</div>
            ]], slot)
        end

        slot_elem.onclick = function() self:save_game(slot) end
        container:appendChild(slot_elem)
    end
end

function WebRuntime:render_load_slots()
    local container = js.global.document:getElementById("whisker-load-slots")
    container.innerHTML = ""

    for slot = 1, self.save_slots do
        local save_data = self:get_save_data(slot)
        local slot_elem = js.global.document:createElement("div")
        slot_elem.className = "whisker-save-slot"

        if save_data then
            slot_elem.innerHTML = string.format([[
                <div class="whisker-save-slot-header">
                    <span class="whisker-save-slot-number">Slot %d</span>
                    <span class="whisker-save-slot-date">%s</span>
                </div>
                <div class="whisker-save-slot-info">%s</div>
            ]], slot, save_data.date, save_data.passage_title)
            slot_elem.onclick = function() self:load_game(slot) end
        else
            slot_elem.classList:add("whisker-save-slot-empty")
            slot_elem.innerHTML = string.format([[
                <div class="whisker-save-slot-header">
                    <span class="whisker-save-slot-number">Slot %d</span>
                </div>
                <div class="whisker-save-slot-info">Empty Slot</div>
            ]], slot)
            slot_elem.style.cursor = "not-allowed"
        end

        container:appendChild(slot_elem)
    end
end

function WebRuntime:save_game(slot)
    local save_data = self.engine:save_game()

    if save_data then
        local passage = self.engine:get_current_passage()
        save_data.passage_title = passage.title or "Unknown"
        save_data.date = os.date("%Y-%m-%d %H:%M:%S")

        js.global.localStorage:setItem(
            "whisker_save_" .. slot,
            json.encode(save_data)
        )

        self:close_modal("whisker-save-modal")
        self:show_notification("Game saved to slot " .. slot, "success")
    else
        self:show_error("Failed to save game")
    end
end

function WebRuntime:load_game(slot)
    local save_json = js.global.localStorage:getItem("whisker_save_" .. slot)

    if not save_json then
        self:show_error("No save data in slot " .. slot)
        return
    end

    local save_data = json.decode(save_json)
    local success = self.engine:load_game(save_data)

    if success then
        self:close_modal("whisker-load-modal")
        self:render_current_passage()
        self:update_all()
        self:show_notification("Game loaded from slot " .. slot, "success")
    else
        self:show_error("Failed to load game")
    end
end

function WebRuntime:get_save_data(slot)
    local save_json = js.global.localStorage:getItem("whisker_save_" .. slot)

    if save_json then
        return json.decode(save_json)
    end

    return nil
end

-- Auto-save
function WebRuntime:start_auto_save()
    if self.auto_save_timer then
        return
    end

    self.auto_save_timer = js.global:setInterval(function()
        local save_data = self.engine:save_game()
        if save_data then
            js.global.localStorage:setItem("whisker_autosave", json.encode(save_data))
        end
    end, self.auto_save_interval)
end

function WebRuntime:stop_auto_save()
    if self.auto_save_timer then
        js.global:clearInterval(self.auto_save_timer)
        self.auto_save_timer = nil
    end
end

-- Settings
function WebRuntime:show_settings_modal()
    self:open_modal("whisker-settings-modal")

    -- Update settings UI
    local doc = js.global.document
    doc:getElementById("whisker-theme-select").value = self.current_theme
    doc:getElementById("whisker-font-size").value = tostring(self.ui_state.font_size)
    doc:getElementById("whisker-font-size-value").textContent = 
        string.format("%.0f%%", self.ui_state.font_size * 100)
    doc:getElementById("whisker-auto-save").checked = self.ui_state.auto_save_enabled
    doc:getElementById("whisker-animations").checked = self.ui_state.animations_enabled
end

function WebRuntime:apply_theme(theme_name)
    self.current_theme = theme_name
    local app = js.global.document:querySelector(".whisker-app")

    -- Remove all theme classes
    app.classList:remove("whisker-theme-default")
    app.classList:remove("whisker-theme-dark")
    app.classList:remove("whisker-theme-light")
    app.classList:remove("whisker-theme-sepia")

    -- Add new theme class
    app.classList:add("whisker-theme-" .. theme_name)

    self:save_settings()
end

function WebRuntime:set_font_size(size)
    self.ui_state.font_size = size
    local content = js.global.document:querySelector(".whisker-content")
    content.style.fontSize = string.format("%.2frem", size)

    js.global.document:getElementById("whisker-font-size-value").textContent = 
        string.format("%.0f%%", size * 100)

    self:save_settings()
end

function WebRuntime:save_settings()
    local settings = {
        theme = self.current_theme,
        font_size = self.ui_state.font_size,
        auto_save = self.ui_state.auto_save_enabled,
        animations = self.ui_state.animations_enabled
    }

    js.global.localStorage:setItem("whisker_settings", json.encode(settings))
end

function WebRuntime:load_settings()
    local settings_json = js.global.localStorage:getItem("whisker_settings")

    if settings_json then
        local settings = json.decode(settings_json)
        self.current_theme = settings.theme or "default"
        self.ui_state.font_size = settings.font_size or 1.0
        self.ui_state.auto_save_enabled = settings.auto_save ~= false
        self.ui_state.animations_enabled = settings.animations ~= false

        self:apply_theme(self.current_theme)
        self:set_font_size(self.ui_state.font_size)
    end
end

-- Modal Management
function WebRuntime:open_modal(modal_id)
    local modal = js.global.document:getElementById(modal_id)
    modal.classList:add("whisker-modal-active")
end

function WebRuntime:close_modal(modal_id)
    local modal = js.global.document:getElementById(modal_id)
    modal.classList:remove("whisker-modal-active")
end

-- Notifications
function WebRuntime:show_notification(message, type)
    type = type or "info"

    local notification = js.global.document:createElement("div")
    notification.className = "whisker-notification whisker-notification-" .. type
    notification.textContent = message

    self.dom_elements.notifications:appendChild(notification)

    js.global:setTimeout(function()
        notification.classList:add("whisker-notification-fadeout")
        js.global:setTimeout(function()
            notification:remove()
        end, 300)
    end, 3000)
end

function WebRuntime:show_error(message)
    self:show_notification(message, "error")
end

return WebRuntime