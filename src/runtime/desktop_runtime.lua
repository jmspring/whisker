-- desktop_runtime.lua - Whisker Desktop Runtime for LÖVE2D
-- Provides a graphical desktop application for playing Whisker stories
-- Requires LÖVE2D (https://love2d.org/)

local DesktopRuntime = {}
DesktopRuntime.__index = DesktopRuntime

-- Dependencies
local Engine = require('src.core.engine')
local json = require('src.utils.json')

-- Constructor
function DesktopRuntime:new(config)
    local instance = {
        engine = nil,
        config = config or {},
        
        -- Window settings
        window_width = config.width or 1280,
        window_height = config.height or 720,
        
        -- UI state
        current_theme = config.theme or "default",
        font_size = config.font_size or 20,
        sidebar_visible = true,
        sidebar_width = 300,
        
        -- Fonts
        fonts = {},
        
        -- Colors (will be set by theme)
        colors = {},
        
        -- UI elements
        scroll_offset = 0,
        max_scroll = 0,
        hover_choice = nil,
        
        -- Modal state
        modal = nil, -- "save", "load", "settings", nil
        modal_selected = 1,
        
        -- Save system
        save_slots = 5,
        save_directory = love.filesystem.getSaveDirectory() .. "/saves/",
        
        -- Animations
        fade_alpha = 1.0,
        choice_hover_time = {},
        
        -- Input
        key_repeat_delay = 0.5,
        key_repeat_rate = 0.05,
        key_timers = {}
    }
    
    setmetatable(instance, self)
    return instance
end

-- LÖVE2D Callbacks
function DesktopRuntime:load()
    -- Set window properties
    love.window.setTitle("Whisker Interactive Fiction Player")
    love.window.setMode(self.window_width, self.window_height, {
        resizable = true,
        minwidth = 800,
        minheight = 600
    })
    
    -- Load fonts
    self:load_fonts()
    
    -- Apply theme
    self:apply_theme(self.current_theme)
    
    -- Initialize engine
    self.engine = Engine:new()
    local success, err = self.engine:initialize({
        debug = self.config.debug or false
    })
    
    if not success then
        error("Failed to initialize engine: " .. tostring(err))
    end
    
    -- Register callbacks
    self:register_callbacks()
    
    -- Create save directory
    love.filesystem.createDirectory("saves")
end

function DesktopRuntime:update(dt)
    -- Update animations
    self:update_animations(dt)
    
    -- Handle key repeat
    self:update_key_repeat(dt)
    
    -- Update scroll limits
    self:calculate_scroll_limits()
end

function DesktopRuntime:draw()
    love.graphics.clear(self.colors.background)
    
    -- Draw main content area
    self:draw_content()
    
    -- Draw sidebar
    if self.sidebar_visible then
        self:draw_sidebar()
    end
    
    -- Draw modal if active
    if self.modal then
        self:draw_modal()
    end
end

function DesktopRuntime:mousepressed(x, y, button)
    if button == 1 then
        if self.modal then
            self:handle_modal_click(x, y)
        else
            self:handle_click(x, y)
        end
    end
end

function DesktopRuntime:mousemoved(x, y)
    if not self.modal then
        self:update_hover(x, y)
    end
end

function DesktopRuntime:wheelmoved(x, y)
    if not self.modal then
        self.scroll_offset = math.max(0, math.min(self.scroll_offset - y * 30, self.max_scroll))
    end
end

function DesktopRuntime:keypressed(key)
    if self.modal then
        self:handle_modal_key(key)
    else
        if key == "escape" then
            love.event.quit()
        elseif key == "f1" then
            self:show_modal("settings")
        elseif key == "f5" then
            self:quick_save()
        elseif key == "f9" then
            self:quick_load()
        elseif key == "z" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            self:undo()
        elseif key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            self:restart()
        elseif key == "tab" then
            self:toggle_sidebar()
        elseif key == "up" then
            self.scroll_offset = math.max(0, self.scroll_offset - 30)
        elseif key == "down" then
            self.scroll_offset = math.min(self.max_scroll, self.scroll_offset + 30)
        elseif key == "pageup" then
            self.scroll_offset = math.max(0, self.scroll_offset - 200)
        elseif key == "pagedown" then
            self.scroll_offset = math.min(self.max_scroll, self.scroll_offset + 200)
        elseif key == "home" then
            self.scroll_offset = 0
        elseif key == "end" then
            self.scroll_offset = self.max_scroll
        end
    end
end

function DesktopRuntime:resize(w, h)
    self.window_width = w
    self.window_height = h
end

-- Engine Integration
function DesktopRuntime:register_callbacks()
    self.engine:on("passage_entered", function(passage_id)
        self.scroll_offset = 0
        self.hover_choice = nil
        self:trigger_fade_in()
    end)
    
    self.engine:on("choice_made", function(choice_index)
        self:trigger_fade_in()
    end)
end

function DesktopRuntime:load_story(story_data)
    local success, err = self.engine:load_story(story_data)
    
    if not success then
        error("Failed to load story: " .. tostring(err))
    end
    
    return true
end

function DesktopRuntime:load_story_from_file(filepath)
    local content = love.filesystem.read(filepath)
    
    if not content then
        error("Could not read story file: " .. filepath)
    end
    
    local story_data = json.decode(content)
    return self:load_story(story_data)
end

function DesktopRuntime:start()
    local success, err = self.engine:start()
    
    if not success then
        error("Failed to start story: " .. tostring(err))
    end
    
    return true
end

-- Rendering
function DesktopRuntime:draw_content()
    local content_width = self.sidebar_visible and 
                         (self.window_width - self.sidebar_width) or 
                         self.window_width
    
    -- Set scissor for content area
    love.graphics.setScissor(0, 0, content_width, self.window_height)
    
    local passage = self.engine:get_current_passage()
    
    if not passage then
        love.graphics.setScissor()
        return
    end
    
    local margin = 60
    local y = 40 - self.scroll_offset
    local max_width = content_width - margin * 2
    
    -- Draw title
    love.graphics.setFont(self.fonts.title)
    love.graphics.setColor(self.colors.title)
    local title_text = passage.title or "Untitled"
    y = self:draw_wrapped_text(title_text, margin, y, max_width) + 30
    
    -- Draw content
    love.graphics.setFont(self.fonts.content)
    love.graphics.setColor(self.colors.text)
    local content = self:process_content(passage.content or "")
    y = self:draw_wrapped_text(content, margin, y, max_width) + 40
    
    -- Draw choices
    if passage.choices then
        y = self:draw_choices(passage.choices, margin, y, max_width)
    end
    
    -- Calculate max scroll
    self.content_height = y + self.scroll_offset
    
    -- Reset scissor
    love.graphics.setScissor()
    
    -- Apply fade effect
    if self.fade_alpha < 1.0 then
        love.graphics.setColor(self.colors.background[1], self.colors.background[2], 
                              self.colors.background[3], 1.0 - self.fade_alpha)
        love.graphics.rectangle("fill", 0, 0, content_width, self.window_height)
    end
end

function DesktopRuntime:draw_choices(choices, x, y, max_width)
    local visible_choices = {}
    
    for i, choice in ipairs(choices) do
        if self:evaluate_choice_condition(choice) then
            table.insert(visible_choices, {index = i, choice = choice})
        end
    end
    
    if #visible_choices == 0 then
        return y
    end
    
    love.graphics.setFont(self.fonts.choice)
    
    for i, data in ipairs(visible_choices) do
        local choice = data.choice
        local is_hover = self.hover_choice == i
        
        -- Calculate button dimensions
        local text = self:process_inline(choice.text)
        local text_width = self.fonts.choice:getWidth(text)
        local button_width = math.min(max_width, text_width + 40)
        local button_height = 50
        
        -- Store button bounds for click detection
        if not self.choice_bounds then
            self.choice_bounds = {}
        end
        self.choice_bounds[i] = {
            x = x,
            y = y,
            width = button_width,
            height = button_height,
            choice_index = data.index
        }
        
        -- Hover animation
        local hover_offset = 0
        if is_hover then
            hover_offset = 8
            love.graphics.setColor(self.colors.choice_hover)
        else
            love.graphics.setColor(self.colors.choice_bg)
        end
        
        -- Draw button
        love.graphics.rectangle("fill", x + hover_offset, y, button_width, button_height, 8, 8)
        
        -- Draw border
        love.graphics.setColor(self.colors.choice_border)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x + hover_offset, y, button_width, button_height, 8, 8)
        
        -- Draw text
        love.graphics.setColor(is_hover and self.colors.choice_text_hover or self.colors.choice_text)
        love.graphics.print(text, x + hover_offset + 20, y + (button_height - self.fonts.choice:getHeight()) / 2)
        
        y = y + button_height + 15
    end
    
    return y
end

function DesktopRuntime:draw_sidebar()
    local sidebar_x = self.window_width - self.sidebar_width
    
    -- Draw background
    love.graphics.setColor(self.colors.sidebar_bg)
    love.graphics.rectangle("fill", sidebar_x, 0, self.sidebar_width, self.window_height)
    
    -- Draw border
    love.graphics.setColor(self.colors.sidebar_border)
    love.graphics.setLineWidth(1)
    love.graphics.line(sidebar_x, 0, sidebar_x, self.window_height)
    
    local x = sidebar_x + 20
    local y = 20
    
    -- Draw stats
    y = self:draw_sidebar_section("Statistics", x, y)
    love.graphics.setFont(self.fonts.ui)
    
    local variables = self.engine:get_all_variables()
    for key, value in pairs(variables) do
        love.graphics.setColor(self.colors.sidebar_label)
        love.graphics.print(key .. ":", x, y)
        
        love.graphics.setColor(self.colors.sidebar_value)
        love.graphics.print(tostring(value), x + 120, y)
        
        y = y + 25
    end
    
    y = y + 20
    
    -- Draw history
    y = self:draw_sidebar_section("History", x, y)
    love.graphics.setFont(self.fonts.ui)
    
    local history = self.engine:get_history()
    if history then
        for i = #history, math.max(1, #history - 5), -1 do
            local passage_id = history[i]
            local passage = self.engine:get_passage(passage_id)
            if passage then
                love.graphics.setColor(self.colors.sidebar_text)
                local text = "• " .. (passage.title or passage_id)
                love.graphics.printf(text, x, y, self.sidebar_width - 40, "left")
                y = y + 25
            end
        end
    end
    
    -- Draw controls hint at bottom
    y = self.window_height - 100
    love.graphics.setFont(self.fonts.small)
    love.graphics.setColor(self.colors.sidebar_hint)
    love.graphics.printf("F1: Settings\nF5: Quick Save\nF9: Quick Load\nTab: Toggle Sidebar\nCtrl+Z: Undo", 
                        x, y, self.sidebar_width - 40, "left")
end

function DesktopRuntime:draw_sidebar_section(title, x, y)
    love.graphics.setFont(self.fonts.heading)
    love.graphics.setColor(self.colors.sidebar_heading)
    love.graphics.print(title, x, y)
    
    love.graphics.setColor(self.colors.sidebar_border)
    love.graphics.setLineWidth(2)
    love.graphics.line(x, y + 25, x + self.sidebar_width - 40, y + 25)
    
    return y + 35
end

function DesktopRuntime:draw_modal()
    -- Draw overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.window_width, self.window_height)
    
    -- Draw modal box
    local modal_width = 600
    local modal_height = 500
    local modal_x = (self.window_width - modal_width) / 2
    local modal_y = (self.window_height - modal_height) / 2
    
    love.graphics.setColor(self.colors.modal_bg)
    love.graphics.rectangle("fill", modal_x, modal_y, modal_width, modal_height, 10, 10)
    
    love.graphics.setColor(self.colors.modal_border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", modal_x, modal_y, modal_width, modal_height, 10, 10)
    
    -- Draw modal content
    if self.modal == "save" then
        self:draw_save_modal(modal_x, modal_y, modal_width, modal_height)
    elseif self.modal == "load" then
        self:draw_load_modal(modal_x, modal_y, modal_width, modal_height)
    elseif self.modal == "settings" then
        self:draw_settings_modal(modal_x, modal_y, modal_width, modal_height)
    end
end

function DesktopRuntime:draw_save_modal(x, y, width, height)
    love.graphics.setFont(self.fonts.heading)
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Save Game", x + 20, y + 20)
    
    love.graphics.setFont(self.fonts.ui)
    local slot_y = y + 70
    
    for slot = 1, self.save_slots do
        local save_data = self:get_save_data(slot)
        local is_selected = self.modal_selected == slot
        
        -- Draw slot button
        if is_selected then
            love.graphics.setColor(self.colors.choice_hover)
        else
            love.graphics.setColor(self.colors.choice_bg)
        end
        
        love.graphics.rectangle("fill", x + 20, slot_y, width - 40, 60, 5, 5)
        
        love.graphics.setColor(self.colors.choice_border)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x + 20, slot_y, width - 40, 60, 5, 5)
        
        -- Draw slot info
        love.graphics.setColor(self.colors.text)
        love.graphics.print("Slot " .. slot, x + 35, slot_y + 10)
        
        if save_data then
            love.graphics.setFont(self.fonts.small)
            love.graphics.setColor(self.colors.sidebar_text)
            love.graphics.print(save_data.date or "Unknown date", x + 35, slot_y + 35)
        else
            love.graphics.setFont(self.fonts.small)
            love.graphics.setColor(self.colors.sidebar_hint)
            love.graphics.print("Empty Slot", x + 35, slot_y + 35)
        end
        
        love.graphics.setFont(self.fonts.ui)
        slot_y = slot_y + 75
    end
    
    -- Instructions
    love.graphics.setFont(self.fonts.small)
    love.graphics.setColor(self.colors.sidebar_hint)
    love.graphics.print("Use arrow keys to select, Enter to save, ESC to cancel", 
                       x + 20, y + height - 40)
end

function DesktopRuntime:draw_load_modal(x, y, width, height)
    love.graphics.setFont(self.fonts.heading)
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Load Game", x + 20, y + 20)
    
    love.graphics.setFont(self.fonts.ui)
    local slot_y = y + 70
    
    for slot = 1, self.save_slots do
        local save_data = self:get_save_data(slot)
        local is_selected = self.modal_selected == slot
        local can_load = save_data ~= nil
        
        -- Draw slot button
        if not can_load then
            love.graphics.setColor(self.colors.sidebar_bg)
        elseif is_selected then
            love.graphics.setColor(self.colors.choice_hover)
        else
            love.graphics.setColor(self.colors.choice_bg)
        end
        
        love.graphics.rectangle("fill", x + 20, slot_y, width - 40, 60, 5, 5)
        
        love.graphics.setColor(self.colors.choice_border)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x + 20, slot_y, width - 40, 60, 5, 5)
        
        -- Draw slot info
        love.graphics.setColor(can_load and self.colors.text or self.colors.sidebar_hint)
        love.graphics.print("Slot " .. slot, x + 35, slot_y + 10)
        
        if save_data then
            love.graphics.setFont(self.fonts.small)
            love.graphics.setColor(self.colors.sidebar_text)
            love.graphics.print(save_data.date or "Unknown date", x + 35, slot_y + 35)
        else
            love.graphics.setFont(self.fonts.small)
            love.graphics.setColor(self.colors.sidebar_hint)
            love.graphics.print("Empty Slot", x + 35, slot_y + 35)
        end
        
        love.graphics.setFont(self.fonts.ui)
        slot_y = slot_y + 75
    end
    
    -- Instructions
    love.graphics.setFont(self.fonts.small)
    love.graphics.setColor(self.colors.sidebar_hint)
    love.graphics.print("Use arrow keys to select, Enter to load, ESC to cancel", 
                       x + 20, y + height - 40)
end

function DesktopRuntime:draw_settings_modal(x, y, width, height)
    love.graphics.setFont(self.fonts.heading)
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Settings", x + 20, y + 20)
    
    love.graphics.setFont(self.fonts.ui)
    love.graphics.setColor(self.colors.text)
    
    local settings_y = y + 80
    
    love.graphics.print("Theme: " .. self.current_theme, x + 40, settings_y)
    settings_y = settings_y + 40
    
    love.graphics.print("Font Size: " .. self.font_size, x + 40, settings_y)
    settings_y = settings_y + 40
    
    love.graphics.print("Sidebar: " .. (self.sidebar_visible and "Visible" or "Hidden"), 
                       x + 40, settings_y)
    
    -- Instructions
    love.graphics.setFont(self.fonts.small)
    love.graphics.setColor(self.colors.sidebar_hint)
    love.graphics.print("Press ESC to close", x + 20, y + height - 40)
end

-- Input Handling
function DesktopRuntime:handle_click(x, y)
    if not self.choice_bounds then
        return
    end
    
    for i, bounds in ipairs(self.choice_bounds) do
        if x >= bounds.x and x <= bounds.x + bounds.width and
           y >= bounds.y and y <= bounds.y + bounds.height then
            self.engine:make_choice(bounds.choice_index)
            break
        end
    end
end

function DesktopRuntime:update_hover(x, y)
    self.hover_choice = nil
    
    if not self.choice_bounds then
        return
    end
    
    for i, bounds in ipairs(self.choice_bounds) do
        if x >= bounds.x and x <= bounds.x + bounds.width and
           y >= bounds.y + self.scroll_offset and 
           y <= bounds.y + bounds.height + self.scroll_offset then
            self.hover_choice = i
            break
        end
    end
end

function DesktopRuntime:handle_modal_key(key)
    if key == "escape" then
        self.modal = nil
        self.modal_selected = 1
    elseif key == "up" then
        self.modal_selected = math.max(1, self.modal_selected - 1)
    elseif key == "down" then
        self.modal_selected = math.min(self.save_slots, self.modal_selected + 1)
    elseif key == "return" or key == "space" then
        if self.modal == "save" then
            self:save_game(self.modal_selected)
            self.modal = nil
        elseif self.modal == "load" then
            self:load_game(self.modal_selected)
            self.modal = nil
        elseif self.modal == "settings" then
            self.modal = nil
        end
    end
end

function DesktopRuntime:handle_modal_click(x, y)
    -- Simple click handling - just close on overlay click
    local modal_width = 600
    local modal_height = 500
    local modal_x = (self.window_width - modal_width) / 2
    local modal_y = (self.window_height - modal_height) / 2
    
    if x < modal_x or x > modal_x + modal_width or
       y < modal_y or y > modal_y + modal_height then
        self.modal = nil
        self.modal_selected = 1
    end
end

-- Game Actions
function DesktopRuntime:save_game(slot)
    local save_data = self.engine:save_game()
    
    if not save_data then
        return
    end
    
    save_data.date = os.date("%Y-%m-%d %H:%M:%S")
    
    local filename = string.format("saves/slot_%d.json", slot)
    love.filesystem.write(filename, json.encode(save_data))
end

function DesktopRuntime:load_game(slot)
    local filename = string.format("saves/slot_%d.json", slot)
    local content = love.filesystem.read(filename)
    
    if not content then
        return
    end
    
    local save_data = json.decode(content)
    self.engine:load_game(save_data)
end

function DesktopRuntime:get_save_data(slot)
    local filename = string.format("saves/slot_%d.json", slot)
    local content = love.filesystem.read(filename)
    
    if content then
        return json.decode(content)
    end
    
    return nil
end

function DesktopRuntime:quick_save()
    self:save_game(1)
end

function DesktopRuntime:quick_load()
    self:load_game(1)
end

function DesktopRuntime:undo()
    self.engine:undo()
end

function DesktopRuntime:restart()
    self.engine:restart()
end

function DesktopRuntime:show_modal(modal_type)
    self.modal = modal_type
    self.modal_selected = 1
end

function DesktopRuntime:toggle_sidebar()
    self.sidebar_visible = not self.sidebar_visible
end

-- Content Processing
function DesktopRuntime:process_content(content)
    content = content:gsub("{{([%w_]+)}}", function(var_name)
        local value = self.engine:get_variable(var_name)
        return value ~= nil and tostring(value) or ""
    end)
    
    -- Remove markdown for now (could be enhanced to apply formatting)
    content = content:gsub("%*%*(.-)%*%*", "%1")
    content = content:gsub("%*(.-)%*", "%1")
    content = content:gsub("__(.-)__", "%1")
    
    return content
end

function DesktopRuntime:process_inline(content)
    return self:process_content(content)
end

function DesktopRuntime:evaluate_choice_condition(choice)
    if not choice.condition then
        return true
    end
    
    return self.engine:evaluate_condition(choice.condition)
end

-- Utilities
function DesktopRuntime:load_fonts()
    self.fonts.title = love.graphics.newFont(32)
    self.fonts.heading = love.graphics.newFont(24)
    self.fonts.content = love.graphics.newFont(self.font_size)
    self.fonts.choice = love.graphics.newFont(18)
    self.fonts.ui = love.graphics.newFont(16)
    self.fonts.small = love.graphics.newFont(14)
end

function DesktopRuntime:apply_theme(theme_name)
    self.current_theme = theme_name
    
    if theme_name == "dark" then
        self.colors = {
            background = {0.1, 0.1, 0.1},
            text = {0.9, 0.9, 0.9},
            title = {0.54, 0.62, 0.91},
            choice_bg = {0.2, 0.2, 0.2},
            choice_hover = {0.54, 0.62, 0.91},
            choice_border = {0.4, 0.4, 0.4},
            choice_text = {0.9, 0.9, 0.9},
            choice_text_hover = {1, 1, 1},
            sidebar_bg = {0.15, 0.15, 0.15},
            sidebar_border = {0.3, 0.3, 0.3},
            sidebar_heading = {0.54, 0.62, 0.91},
            sidebar_label = {0.7, 0.7, 0.7},
            sidebar_value = {0.54, 0.62, 0.91},
            sidebar_text = {0.8, 0.8, 0.8},
            sidebar_hint = {0.5, 0.5, 0.5},
            modal_bg = {0.15, 0.15, 0.15},
            modal_border = {0.54, 0.62, 0.91}
        }
    elseif theme_name == "sepia" then
        self.colors = {
            background = {0.96, 0.93, 0.85},
            text = {0.36, 0.29, 0.22},
            title = {0.54, 0.43, 0.28},
            choice_bg = {0.98, 0.95, 0.89},
            choice_hover = {0.54, 0.43, 0.28},
            choice_border = {0.83, 0.77, 0.66},
            choice_text = {0.36, 0.29, 0.22},
            choice_text_hover = {1, 1, 1},
            sidebar_bg = {0.93, 0.89, 0.78},
            sidebar_border = {0.83, 0.77, 0.66},
            sidebar_heading = {0.54, 0.43, 0.28},
            sidebar_label = {0.5, 0.4, 0.3},
            sidebar_value = {0.54, 0.43, 0.28},
            sidebar_text = {0.4, 0.32, 0.25},
            sidebar_hint = {0.6, 0.5, 0.4},
            modal_bg = {0.93, 0.89, 0.78},
            modal_border = {0.54, 0.43, 0.28}
        }
    else -- default theme
        self.colors = {
            background = {1, 1, 1},
            text = {0.2, 0.2, 0.2},
            title = {0.4, 0.49, 0.91},
            choice_bg = {0.97, 0.97, 0.97},
            choice_hover = {0.4, 0.49, 0.91},
            choice_border = {0.4, 0.49, 0.91},
            choice_text = {0.4, 0.49, 0.91},
            choice_text_hover = {1, 1, 1},
            sidebar_bg = {0.97, 0.97, 0.98},
            sidebar_border = {0.87, 0.88, 0.91},
            sidebar_heading = {0.4, 0.49, 0.91},
            sidebar_label = {0.42, 0.45, 0.51},
            sidebar_value = {0.4, 0.49, 0.91},
            sidebar_text = {0.29, 0.32, 0.35},
            sidebar_hint = {0.6, 0.6, 0.65},
            modal_bg = {0.97, 0.97, 0.98},
            modal_border = {0.4, 0.49, 0.91}
        }
    end
end

function DesktopRuntime:draw_wrapped_text(text, x, y, max_width)
    local _, wrapped_lines = self.fonts.content:getWrap(text, max_width)
    
    for _, line in ipairs(wrapped_lines) do
        love.graphics.print(line, x, y)
        y = y + self.fonts.content:getHeight() + 5
    end
    
    return y
end

function DesktopRuntime:calculate_scroll_limits()
    self.max_scroll = math.max(0, self.content_height - self.window_height + 100)
end

function DesktopRuntime:trigger_fade_in()
    self.fade_alpha = 0.0
end

function DesktopRuntime:update_animations(dt)
    if self.fade_alpha < 1.0 then
        self.fade_alpha = math.min(1.0, self.fade_alpha + dt * 3)
    end
end

function DesktopRuntime:update_key_repeat(dt)
    -- Implement key repeat for scrolling
end

return DesktopRuntime