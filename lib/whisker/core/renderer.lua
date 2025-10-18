-- whisker Text Renderer
-- Handles passage content rendering with formatting, variables, and platform-specific output
-- Supports markdown-style formatting and Lua expression evaluation

local Renderer = {}
Renderer.__index = Renderer

-- Formatting tokens
Renderer.FormatTokens = {
    BOLD_START = "**",
    BOLD_END = "**",
    ITALIC_START = "*",
    ITALIC_END = "*",
    UNDERLINE_START = "__",
    UNDERLINE_END = "__",
    CODE_START = "`",
    CODE_END = "`",
    VARIABLE_START = "{{",
    VARIABLE_END = "}}"
}

-- Platform-specific tags
local PlatformTags = {
    console = {
        bold = { open = "\027[1m", close = "\027[0m" },
        italic = { open = "\027[3m", close = "\027[0m" },
        underline = { open = "\027[4m", close = "\027[0m" },
        code = { open = "", close = "" }
    },
    web = {
        bold = { open = "<strong>", close = "</strong>" },
        italic = { open = "<em>", close = "</em>" },
        underline = { open = "<u>", close = "</u>" },
        code = { open = "<code>", close = "</code>" }
    },
    love2d = {
        bold = { open = "", close = "" },
        italic = { open = "", close = "" },
        underline = { open = "", close = "" },
        code = { open = "", close = "" }
    },
    plain = {
        bold = { open = "", close = "" },
        italic = { open = "", close = "" },
        underline = { open = "", close = "" },
        code = { open = "", close = "" }
    }
}

-- Create new renderer
function Renderer.new(platform, config)
    local self = setmetatable({}, Renderer)

    platform = platform or "plain"
    config = config or {}

    -- Configuration
    self.platform = platform
    self.max_line_width = config.max_line_width or 80
    self.enable_formatting = config.enable_formatting ~= false
    self.enable_wrapping = config.enable_wrapping ~= false
    self.preserve_paragraphs = config.preserve_paragraphs ~= false

    -- Platform tags
    self.tags = PlatformTags[platform] or PlatformTags.plain

    -- Rendering state
    self.interpreter = nil -- Set externally if needed

    -- Statistics
    self.stats = {
        passages_rendered = 0,
        variables_evaluated = 0,
        formatting_applied = 0
    }

    return self
end

-- Set Lua interpreter for variable evaluation
function Renderer:set_interpreter(interpreter)
    self.interpreter = interpreter
end

-- Render passage content
function Renderer:render_passage(passage, game_state)
    local content = passage:get_content()

    -- Evaluate variables and expressions
    if self.interpreter and game_state then
        content = self:evaluate_expressions(content, game_state)
    end

    -- Apply formatting
    if self.enable_formatting then
        content = self:apply_formatting(content)
    end

    -- Apply word wrapping
    if self.enable_wrapping then
        content = self:apply_wrapping(content)
    end

    self.stats.passages_rendered = self.stats.passages_rendered + 1

    return content
end

-- Evaluate Lua expressions in text
function Renderer:evaluate_expressions(text, game_state)
    if not self.interpreter then
        return text
    end

    -- Match {{expression}}
    local result = text:gsub("{{(.-)}}",  function(expr)
        expr = expr:match("^%s*(.-)%s*$") -- Trim whitespace

        local success, value = self.interpreter:evaluate_expression(expr, game_state)

        if success then
            self.stats.variables_evaluated = self.stats.variables_evaluated + 1
            return tostring(value)
        else
            -- Return error marker or empty string
            return "[ERROR: " .. tostring(value) .. "]"
        end
    end)

    return result
end

-- Apply markdown-style formatting
function Renderer:apply_formatting(text)
    local formatted = text

    -- Bold: **text**
    formatted = self:apply_format_pattern(
        formatted,
        "%*%*(.-)%*%*",
        self.tags.bold
    )

    -- Underline: __text__
    formatted = self:apply_format_pattern(
        formatted,
        "__(.-)__",
        self.tags.underline
    )

    -- Italic: *text* (must come after bold to avoid conflicts)
    formatted = self:apply_format_pattern(
        formatted,
        "%*(.-)%*",
        self.tags.italic
    )

    -- Code: `text`
    formatted = self:apply_format_pattern(
        formatted,
        "`(.-)`",
        self.tags.code
    )

    return formatted
end

-- Apply a single format pattern
function Renderer:apply_format_pattern(text, pattern, tags)
    local result = text:gsub(pattern, function(content)
        self.stats.formatting_applied = self.stats.formatting_applied + 1
        return tags.open .. content .. tags.close
    end)

    return result
end

-- Apply word wrapping
function Renderer:apply_wrapping(text)
    if not self.enable_wrapping or self.max_line_width <= 0 then
        return text
    end

    local lines = {}

    -- Split into paragraphs
    local paragraphs = self:split_paragraphs(text)

    for i, paragraph in ipairs(paragraphs) do
        if paragraph == "" then
            -- Preserve empty lines
            table.insert(lines, "")
        else
            -- Wrap paragraph
            local wrapped = self:wrap_paragraph(paragraph)
            for _, line in ipairs(wrapped) do
                table.insert(lines, line)
            end
        end
    end

    return table.concat(lines, "\n")
end

-- Split text into paragraphs
function Renderer:split_paragraphs(text)
    local paragraphs = {}
    local current = ""

    for line in text:gmatch("[^\n]*") do
        if line:match("^%s*$") then
            -- Empty line - end current paragraph
            if current ~= "" then
                table.insert(paragraphs, current)
                current = ""
            end

            if self.preserve_paragraphs then
                table.insert(paragraphs, "")
            end
        else
            -- Add to current paragraph
            if current ~= "" then
                current = current .. " "
            end
            current = current .. line:match("^%s*(.-)%s*$")
        end
    end

    if current ~= "" then
        table.insert(paragraphs, current)
    end

    return paragraphs
end

-- Wrap a single paragraph
function Renderer:wrap_paragraph(paragraph)
    local lines = {}
    local current_line = ""
    local current_length = 0

    -- Split into words
    for word in paragraph:gmatch("%S+") do
        local word_length = self:visible_length(word)

        if current_length == 0 then
            -- First word on line
            current_line = word
            current_length = word_length
        elseif current_length + 1 + word_length <= self.max_line_width then
            -- Add word to current line
            current_line = current_line .. " " .. word
            current_length = current_length + 1 + word_length
        else
            -- Start new line
            table.insert(lines, current_line)
            current_line = word
            current_length = word_length
        end
    end

    if current_line ~= "" then
        table.insert(lines, current_line)
    end

    return lines
end

-- Calculate visible length (excluding formatting tags)
function Renderer:visible_length(text)
    -- Remove platform-specific tags
    local visible = text

    if self.platform == "console" then
        -- Remove ANSI codes
        visible = visible:gsub("\027%[[%d;]*m", "")
    elseif self.platform == "web" then
        -- Remove HTML tags
        visible = visible:gsub("<[^>]+>", "")
    end

    return #visible
end

-- Render plain text (strip all formatting)
function Renderer:render_plain(text, game_state)
    -- Evaluate expressions
    if self.interpreter and game_state then
        text = self:evaluate_expressions(text, game_state)
    end

    -- Strip formatting markers
    text = text:gsub("%*%*(.-)%*%*", "%1")
    text = text:gsub("%*(.-)%*", "%1")
    text = text:gsub("__(.-)__", "%1")
    text = text:gsub("`(.-)`", "%1")

    return text
end

-- Render to specific platform
function Renderer:render_to_platform(text, target_platform, game_state)
    -- Temporarily switch platform
    local original_platform = self.platform
    local original_tags = self.tags

    self.platform = target_platform
    self.tags = PlatformTags[target_platform] or PlatformTags.plain

    -- Render
    local result = text
    if self.interpreter and game_state then
        result = self:evaluate_expressions(result, game_state)
    end
    if self.enable_formatting then
        result = self:apply_formatting(result)
    end

    -- Restore original platform
    self.platform = original_platform
    self.tags = original_tags

    return result
end

-- Render choices
function Renderer:render_choices(choices, game_state, options)
    options = options or {}
    local numbered = options.numbered ~= false
    local show_disabled = options.show_disabled ~= false

    local lines = {}
    local choice_num = 1

    for i, choice in ipairs(choices) do
        local visible = choice.visible ~= false
        local enabled = choice.enabled ~= false

        if visible and (enabled or show_disabled) then
            local text = choice:get_text()

            -- Evaluate variables in choice text
            if self.interpreter and game_state then
                text = self:evaluate_expressions(text, game_state)
            end

            -- Format choice
            local line
            if numbered then
                if enabled then
                    line = string.format("%d. %s", choice_num, text)
                else
                    line = string.format("%d. [DISABLED] %s", choice_num, text)
                end
                choice_num = choice_num + 1
            else
                if enabled then
                    line = "• " .. text
                else
                    line = "• [DISABLED] " .. text
                end
            end

            table.insert(lines, line)
        end
    end

    return table.concat(lines, "\n")
end

-- Create formatted text object (for advanced rendering)
function Renderer:create_formatted_text(text, game_state)
    -- Parse text into segments with formatting info
    local segments = {}
    local current_pos = 1

    -- This is a placeholder for more advanced parsing
    -- In a full implementation, this would parse the text
    -- into a structured format for rich rendering

    table.insert(segments, {
        text = text,
        style = {
            bold = false,
            italic = false,
            underline = false,
            color = nil
        }
    })

    return segments
end

-- Get rendering statistics
function Renderer:get_stats()
    return {
        passages_rendered = self.stats.passages_rendered,
        variables_evaluated = self.stats.variables_evaluated,
        formatting_applied = self.stats.formatting_applied
    }
end

-- Reset statistics
function Renderer:reset_stats()
    self.stats = {
        passages_rendered = 0,
        variables_evaluated = 0,
        formatting_applied = 0
    }
end

-- Utility: Escape special characters for platform
function Renderer:escape_text(text)
    if self.platform == "web" then
        -- Escape HTML entities
        text = text:gsub("&", "&amp;")
        text = text:gsub("<", "&lt;")
        text = text:gsub(">", "&gt;")
        text = text:gsub('"', "&quot;")
        text = text:gsub("'", "&#39;")
    end

    return text
end

-- Utility: Convert newlines to platform-specific format
function Renderer:convert_newlines(text)
    if self.platform == "web" then
        return text:gsub("\n", "<br>")
    end

    return text
end

return Renderer