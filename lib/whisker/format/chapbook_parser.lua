-- Chapbook Format Parser
-- Parses Chapbook syntax and converts to Whisker format

local ChapbookParser = {}
ChapbookParser.__index = ChapbookParser

function ChapbookParser.new()
    local instance = setmetatable({}, self)
    return instance
end

-- ============================================================================
-- MAIN PARSING FUNCTION
-- ============================================================================

function ChapbookParser:parse_to_whisker(text)
    if not text then return "" end

    -- Parse in specific order to avoid conflicts
    text = self:parse_comments(text)
    text = self:parse_javascript_blocks(text)
    text = self:parse_variable_assignments(text)
    text = self:parse_conditionals(text)
    text = self:parse_inline_expressions(text)
    text = self:parse_links(text)

    return text
end

-- ============================================================================
-- COMMENT PARSING
-- ============================================================================

function ChapbookParser:parse_comments(text)
    -- [note] comment [continued]
    text = text:gsub("%[note%](.-)%[continued%]", "")
    return text
end

-- ============================================================================
-- JAVASCRIPT BLOCKS
-- ============================================================================

function ChapbookParser:parse_javascript_blocks(text)
    -- [JavaScript]\ncode\n[continued]
    text = text:gsub("%[JavaScript%]%s*\n(.-)%[continued%]", function(code)
        code = self:convert_javascript_to_lua(code)
        return "{{" .. code .. "}}"
    end)

    return text
end

-- ============================================================================
-- VARIABLE ASSIGNMENTS
-- ============================================================================

function ChapbookParser:parse_variable_assignments(text)
    -- Chapbook uses: variableName: value
    -- This must be on its own line

    -- Simple assignments at start of line
    text = text:gsub("\n([%w_]+):%s*([^\n]+)", function(var, value)
        value = self:convert_chapbook_value(value)
        return "\n{{" .. var .. " = " .. value .. "}}"
    end)

    -- Handle at very start of text
    text = text:gsub("^([%w_]+):%s*([^\n]+)", function(var, value)
        value = self:convert_chapbook_value(value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    return text
end

-- ============================================================================
-- CONDITIONALS
-- ============================================================================

function ChapbookParser:parse_conditionals(text)
    -- [if condition]\ntext\n[else]\ntext\n[continued]
    text = text:gsub("%[if%s+(.-)%]%s*\n(.-)%[else%]%s*\n(.-)%[continued%]",
        function(cond, if_body, else_body)
            return "{{if " .. self:convert_condition(cond) .. " then}}\n" .. if_body ..
                   "{{else}}\n" .. else_body .. "{{end}}"
        end)

    -- [if condition]\ntext\n[continued]
    text = text:gsub("%[if%s+(.-)%]%s*\n(.-)%[continued%]", function(cond, body)
        return "{{if " .. self:convert_condition(cond) .. " then}}\n" .. body .. "{{end}}"
    end)

    -- [unless condition]\ntext\n[continued]
    text = text:gsub("%[unless%s+(.-)%]%s*\n(.-)%[continued%]", function(cond, body)
        return "{{if not (" .. self:convert_condition(cond) .. ") then}}\n" .. body .. "{{end}}"
    end)

    -- Inline conditionals: [if condition; text]
    text = text:gsub("%[if%s+([^;]+);%s*([^%]]+)%]", function(cond, body)
        return "{{if " .. self:convert_condition(cond) .. " then}}" .. body .. "{{end}}"
    end)

    return text
end

-- ============================================================================
-- INLINE EXPRESSIONS
-- ============================================================================

function ChapbookParser:parse_inline_expressions(text)
    -- {variable} or {expression}
    text = text:gsub("{([^}]+)}", function(expr)
        -- Check if it's a simple variable or expression
        if expr:match("^[%w_]+$") then
            -- Simple variable
            return "{{" .. expr .. "}}"
        else
            -- Expression - convert it
            expr = self:convert_chapbook_expression(expr)
            return "{{" .. expr .. "}}"
        end
    end)

    return text
end

-- ============================================================================
-- LINKS
-- ============================================================================

function ChapbookParser:parse_links(text)
    -- Chapbook uses: [[Text->Target]]
    -- Convert to Whisker: [[Text|Target]]
    text = text:gsub("%[%[(.-)%->(.-)%]%]", function(link_text, target)
        return "[[" .. link_text .. "|" .. target .. "]]"
    end)

    -- [[Text]] - already compatible

    return text
end

-- ============================================================================
-- VALUE CONVERSION
-- ============================================================================

function ChapbookParser:convert_chapbook_value(value)
    value = value:trim()

    -- Convert JavaScript literals to Lua
    if value == "true" or value == "false" then
        return value
    end

    -- Numbers
    if tonumber(value) then
        return value
    end

    -- Strings - already have quotes
    if value:match("^['\"]") then
        return value
    end

    -- Arrays: [1, 2, 3] → {1, 2, 3}
    if value:match("^%[") then
        return value:gsub("%[", "{"):gsub("%]", "}")
    end

    -- Objects: {key: value} → {key = value}
    if value:match("^{") then
        value = value:gsub("(%w+):", "%1 =")
        return value
    end

    -- Otherwise it's probably an expression or variable
    return value
end

function ChapbookParser:convert_chapbook_expression(expr)
    expr = expr:trim()

    -- Convert array/string length: expr.length → #expr
    expr = expr:gsub("([%w_]+)%.length", "#%1")

    -- Convert .includes() → string.find() or table contains
    expr = expr:gsub("([%w_]+)%.includes%((.-)%)", "contains(%1, %2)")

    -- Convert .toUpperCase() → string.upper()
    expr = expr:gsub("([%w_]+)%.toUpperCase%(%)","string.upper(%1)")

    -- Convert .toLowerCase() → string.lower()
    expr = expr:gsub("([%w_]+)%.toLowerCase%(%)","string.lower(%1)")

    -- Convert JavaScript operators
    expr = expr:gsub("===", "==")
    expr = expr:gsub("!==", "~=")
    expr = expr:gsub("&&", " and ")
    expr = expr:gsub("||", " or ")
    expr = expr:gsub("^!", "not ")
    expr = expr:gsub("([^%w])!", "%1not ")

    return expr
end

function ChapbookParser:convert_condition(cond)
    cond = cond:trim()

    -- Convert JavaScript operators
    cond = cond:gsub("===", "==")
    cond = cond:gsub("!==", "~=")
    cond = cond:gsub("&&", " and ")
    cond = cond:gsub("||", " or ")
    cond = cond:gsub("!", "not ")

    -- Convert .length
    cond = cond:gsub("([%w_]+)%.length", "#%1")

    -- Convert .includes()
    cond = cond:gsub("([%w_]+)%.includes%((.-)%)", "contains(%1, %2)")

    return cond
end

function ChapbookParser:convert_javascript_to_lua(code)
    code = code:trim()

    -- Convert variable declarations
    code = code:gsub("let%s+([%w_]+)%s*=%s*(.-)[\n;]", "%1 = %2\n")
    code = code:gsub("const%s+([%w_]+)%s*=%s*(.-)[\n;]", "%1 = %2\n")
    code = code:gsub("var%s+([%w_]+)%s*=%s*(.-)[\n;]", "%1 = %2\n")

    -- Convert operators
    code = code:gsub("===", "==")
    code = code:gsub("!==", "~=")
    code = code:gsub("&&", " and ")
    code = code:gsub("||", " or ")
    code = code:gsub("!", "not ")

    -- Convert .length
    code = code:gsub("([%w_]+)%.length", "#%1")

    -- Convert .push()
    code = code:gsub("([%w_]+)%.push%((.-)%)", "table.insert(%1, %2)")

    -- Convert .pop()
    code = code:gsub("([%w_]+)%.pop%(%)", "table.remove(%1)")

    -- Convert for loops: for (let i = 0; i < n; i++)
    code = code:gsub("for%s*%(%s*let%s+([%w_]+)%s*=%s*(%d+)%s*;%s*[%w_]+%s*<%s*([%w_]+)%s*;%s*[%w_]+%+%+%s*%)",
        "for %1 = %2, %3 - 1 do")

    -- Convert forEach: array.forEach(item => { })
    code = code:gsub("([%w_]+)%.forEach%(%s*([%w_]+)%s*=>%s*{", "for _, %2 in ipairs(%1) do")

    -- Convert closing braces to end
    code = code:gsub("}", "end")

    return code
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function string:trim()
    return self:match("^%s*(.-)%s*$")
end

return ChapbookParser