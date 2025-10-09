-- Snowman Format Converter for whisker
-- Handles conversion between Snowman (Twine 2) and whisker formats

local SnowmanConverter = {}
SnowmanConverter.__index = SnowmanConverter

function SnowmanConverter:new()
    local instance = setmetatable({}, self)
    return instance
end

-- ============================================================================
-- SNOWMAN TO whisker CONVERSION
-- ============================================================================

function SnowmanConverter:snowman_to_whisker(twine_data)
    local whisker_data = {
        metadata = {
            title = twine_data.name or "Untitled",
            author = twine_data.creator or "Unknown",
            version = "1.0.0",
            format = "Snowman " .. (twine_data["format-version"] or "2.0.3"),
            created = os.time(),
            modified = os.time()
        },
        starting_passage = twine_data.startnode or "Start",
        variables = {},
        passages = {}
    }

    -- Find StoryInit passage for variable initialization
    for _, passage in ipairs(twine_data.passages or {}) do
        if passage.name == "StoryInit" then
            whisker_data.variables = self:extract_init_variables(passage.text)
            break
        end
    end

    -- Convert passages
    for _, passage in ipairs(twine_data.passages or {}) do
        -- Skip special metadata passages
        if not self:is_special_passage(passage.name) then
            local whisker_passage = self:convert_snowman_passage_to_whisker(passage)
            table.insert(whisker_data.passages, whisker_passage)
        end
    end

    return whisker_data
end

function SnowmanConverter:is_special_passage(name)
    local special = {
        "StoryTitle", "StoryData", "StoryInit",
        "PassageHeader", "PassageFooter", "PassageReady"
    }
    for _, special_name in ipairs(special) do
        if name == special_name then
            return true
        end
    end
    return false
end

function SnowmanConverter:convert_snowman_passage_to_whisker(passage)
    local whisker_passage = {
        id = passage.pid or passage.name,
        title = passage.name,
        tags = passage.tags or {},
        content = "",
        choices = {},
        code = {}
    }

    local text = passage.text or ""

    -- Extract and convert code blocks first
    local code_blocks = {}
    text = text:gsub("<%([^=].-%)%>", function(code)
        local lua_code = self:javascript_to_lua(code)
        table.insert(code_blocks, lua_code)
        return "{{CODE_BLOCK_" .. #code_blocks .. "}}"
    end)

    -- Extract and convert output expressions
    local expressions = {}
    text = text:gsub("<%%=(.-)%%>", function(expr)
        local lua_expr = self:javascript_expression_to_lua(expr)
        table.insert(expressions, lua_expr)
        return "{{" .. lua_expr .. "}}"
    end)

    -- Extract links and choices
    local choices = {}
    local content_parts = {}
    local last_pos = 1

    -- Pattern: [[Link Text|Target]] or [[Target]]
    for match_start, link_text, target, match_end in text:gmatch("()%[%[([^%|%]]+)|?([^%]]-)%]%]()") do
        -- Add content before link
        if match_start > last_pos then
            table.insert(content_parts, text:sub(last_pos, match_start - 1))
        end

        -- Determine actual text and target
        local choice_text, choice_target
        if target and target ~= "" then
            choice_text = link_text
            choice_target = target
        else
            choice_text = link_text
            choice_target = link_text
        end

        table.insert(choices, {
            text = choice_text:trim(),
            target = choice_target:trim()
        })

        last_pos = match_end
    end

    -- Add remaining content
    if last_pos <= #text then
        table.insert(content_parts, text:sub(last_pos))
    end

    -- Reconstruct content with code blocks
    local content = table.concat(content_parts, "")
    for i, lua_code in ipairs(code_blocks) do
        content = content:gsub("{{CODE_BLOCK_" .. i .. "}}", "{% " .. lua_code .. " %}")
    end

    whisker_passage.content = content:trim()
    whisker_passage.choices = choices
    whisker_passage.code = code_blocks

    return whisker_passage
end

-- ============================================================================
-- whisker TO SNOWMAN CONVERSION
-- ============================================================================

function SnowmanConverter:whisker_to_snowman(whisker_data)
    local twine_data = {
        name = whisker_data.metadata.title or "Untitled",
        creator = whisker_data.metadata.author or "Unknown",
        ["format"] = "Snowman",
        ["format-version"] = "2.0.3",
        ifid = whisker_data.metadata.ifid or self:generate_ifid(),
        startnode = whisker_data.starting_passage or "Start",
        passages = {}
    }

    -- Create StoryInit passage if there are variables
    if whisker_data.variables and next(whisker_data.variables) then
        local init_text = self:create_story_init(whisker_data.variables)
        table.insert(twine_data.passages, {
            pid = "0",
            name = "StoryInit",
            tags = {"init"},
            text = init_text,
            position = "0,0"
        })
    end

    -- Convert passages
    for i, passage in ipairs(whisker_data.passages or {}) do
        local snowman_passage = self:convert_whisker_passage_to_snowman(passage, i)
        table.insert(twine_data.passages, snowman_passage)
    end

    return twine_data
end

function SnowmanConverter:convert_whisker_passage_to_snowman(passage, index)
    local snowman_passage = {
        pid = tostring(index),
        name = passage.title or passage.id,
        tags = passage.tags or {},
        text = "",
        position = passage.position or string.format("%d,%d", index * 150, index * 100)
    }

    local text_parts = {}
    local content = passage.content or ""

    -- Convert Lua code blocks to Snowman format
    content = content:gsub("{%%(.-)%%}", function(lua_code)
        local js_code = self:lua_to_javascript(lua_code)
        return "<% " .. js_code .. " %>"
    end)

    -- Convert Lua expressions to Snowman format
    content = content:gsub("{{(.-)%}}", function(lua_expr)
        local js_expr = self:lua_expression_to_javascript(lua_expr)
        return "<%= " .. js_expr .. " %>"
    end)

    table.insert(text_parts, content)

    -- Add choices as links
    if passage.choices and #passage.choices > 0 then
        table.insert(text_parts, "\n")
        for _, choice in ipairs(passage.choices) do
            local link = self:create_snowman_link(choice)
            table.insert(text_parts, link .. "\n")
        end
    end

    snowman_passage.text = table.concat(text_parts, "")
    return snowman_passage
end

function SnowmanConverter:create_snowman_link(choice)
    local text = choice.text or choice.target
    local target = choice.target

    -- If there's a condition, wrap in conditional
    if choice.condition then
        local js_condition = self:lua_expression_to_javascript(choice.condition)
        return string.format("<% if (%s) { %>[[%s|%s]]<% } %>",
            js_condition, text, target)
    end

    -- Standard link
    if text == target then
        return string.format("[[%s]]", target)
    else
        return string.format("[[%s|%s]]", text, target)
    end
end

-- ============================================================================
-- JAVASCRIPT <-> LUA CONVERSION
-- ============================================================================

function SnowmanConverter:javascript_to_lua(js_code)
    local lua_code = js_code

    -- State variable access: s.var or window.story.state.var -> get('var')
    lua_code = lua_code:gsub("s%.([%w_]+)", "get('%1')")
    lua_code = lua_code:gsub("window%.story%.state%.([%w_]+)", "get('%1')")

    -- Assignment: s.var = value -> set('var', value)
    lua_code = lua_code:gsub("s%.([%w_]+)%s*=%s*(.+)", "set('%1', %2)")

    -- Operators
    lua_code = lua_code:gsub("&&", " and ")
    lua_code = lua_code:gsub("||", " or ")
    lua_code = lua_code:gsub("!", "not ")

    -- Arrays
    lua_code = lua_code:gsub("%.length", ":len()")
    lua_code = lua_code:gsub("%.push%(", ":insert(")
    lua_code = lua_code:gsub("%.includes%(", ":contains(")

    return lua_code:trim()
end

function SnowmanConverter:lua_to_javascript(lua_code)
    local js_code = lua_code

    -- Variable access: get('var') -> s.var
    js_code = js_code:gsub("get%('([^']+)'%)", "s.%1")

    -- Assignment: set('var', value) -> s.var = value
    js_code = js_code:gsub("set%('([^']+)',%s*(.+)%)", "s.%1 = %2")

    -- Operators
    js_code = js_code:gsub(" and ", " && ")
    js_code = js_code:gsub(" or ", " || ")
    js_code = js_code:gsub("not ", "!")

    -- Arrays
    js_code = js_code:gsub(":len%(", ".length")
    js_code = js_code:gsub(":insert%(", ".push(")
    js_code = js_code:gsub(":contains%(", ".includes(")

    return js_code:trim()
end

function SnowmanConverter:javascript_expression_to_lua(js_expr)
    local lua_expr = js_expr:trim()

    -- State variables
    lua_expr = lua_expr:gsub("s%.([%w_]+)", "get('%1')")

    -- String concatenation
    lua_expr = lua_expr:gsub("%+", "..")

    return lua_expr
end

function SnowmanConverter:lua_expression_to_javascript(lua_expr)
    local js_expr = lua_expr:trim()

    -- Variable access
    js_expr = js_expr:gsub("get%('([^']+)'%)", "s.%1")

    -- String concatenation
    js_expr = js_expr:gsub("%.%.", " + ")

    return js_expr
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function SnowmanConverter:extract_init_variables(init_text)
    local variables = {}

    -- Extract variable assignments from StoryInit
    for var_name, value in init_text:gmatch("s%.([%w_]+)%s*=%s*(.-)%;") do
        -- Try to parse value as number, boolean, or string
        local parsed_value = self:parse_js_value(value)
        variables[var_name] = parsed_value
    end

    return variables
end

function SnowmanConverter:parse_js_value(value)
    value = value:trim()

    -- Number
    if tonumber(value) then
        return tonumber(value)
    end

    -- Boolean
    if value == "true" then return true end
    if value == "false" then return false end

    -- String
    if value:match("^['\"](.+)['\"]$") then
        return value:match("^['\"](.+)['\"]$")
    end

    -- Array
    if value:match("^%[.-%]$") then
        return {} -- Simplified - return empty array
    end

    -- Default to string
    return value
end

function SnowmanConverter:create_story_init(variables)
    local lines = {}

    for name, value in pairs(variables) do
        local js_value
        if type(value) == "string" then
            js_value = string.format("'%s'", value)
        elseif type(value) == "boolean" then
            js_value = tostring(value)
        else
            js_value = tostring(value)
        end

        table.insert(lines, string.format("s.%s = %s;", name, js_value))
    end

    return "<% " .. table.concat(lines, "\n") .. " %>"
end

function SnowmanConverter:generate_ifid()
    -- Generate UUID v4
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- String trim helper
function string:trim()
    return self:match("^%s*(.-)%s*$")
end

-- String contains helper
function table:contains(value)
    for _, v in ipairs(self) do
        if v == value then
            return true
        end
    end
    return false
end

return SnowmanConverter