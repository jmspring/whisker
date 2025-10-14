-- SugarCube Format Parser
-- Parses SugarCube syntax and converts to Whisker format

local SugarCubeParser = {}
SugarCubeParser.__index = SugarCubeParser

function SugarCubeParser.new()
    local instance = setmetatable({}, self)
    return instance
end

-- ============================================================================
-- MAIN PARSING FUNCTION
-- ============================================================================

function SugarCubeParser:parse_to_whisker(text)
    if not text then return "" end

    -- Parse in specific order to avoid conflicts
    text = self:parse_comments(text)
    text = self:parse_script_blocks(text)
    text = self:parse_run_macro(text)
    text = self:parse_set_macros(text)
    text = self:parse_unset_macros(text)
    text = self:parse_switch_statements(text)
    text = self:parse_conditionals(text)
    text = self:parse_loops(text)
    text = self:parse_link_macros(text)
    text = self:parse_print_macros(text)
    text = self:parse_inline_variables(text)
    text = self:parse_links(text)

    return text
end

-- ============================================================================
-- COMMENT PARSING
-- ============================================================================

function SugarCubeParser:parse_comments(text)
    -- SugarCube comments: /% comment %/
    text = text:gsub("/%*(.-)%*/", "")
    return text
end

-- ============================================================================
-- SCRIPT BLOCKS
-- ============================================================================

function SugarCubeParser:parse_script_blocks(text)
    -- <<script>>...<<script>> - JavaScript blocks
    -- Convert simple JavaScript to Lua where possible
    text = text:gsub("<<script>>(.-)<<script>>", function(code)
        code = self:convert_javascript_to_lua(code)
        return "{{" .. code .. "}}"
    end)

    return text
end

function SugarCubeParser:parse_run_macro(text)
    -- <<run code>> - Single line JavaScript execution
    text = text:gsub("<<run%s+(.-)>>", function(code)
        code = self:convert_javascript_to_lua(code)
        return "{{" .. code .. "}}"
    end)

    return text
end

-- ============================================================================
-- VARIABLE ASSIGNMENT
-- ============================================================================

function SugarCubeParser:parse_set_macros(text)
    -- Pattern: <<set $var to value>> or <<set $var = value>>
    -- Convert to: {{var = value}}

    -- With 'to' keyword
    text = text:gsub("<<set%s+%$([%w_]+)%s+to%s+(.-)>>", function(var, value)
        value = self:convert_sugarcube_value(value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    -- With = operator
    text = text:gsub("<<set%s+%$([%w_]+)%s*=%s*(.-)>>", function(var, value)
        value = self:convert_sugarcube_value(value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    -- Compound assignments: +=, -=, *=, /=
    text = text:gsub("<<set%s+%$([%w_]+)%s*%+=%s*(.-)>>", function(var, value)
        value = self:convert_sugarcube_value(value)
        return "{{" .. var .. " = " .. var .. " + " .. value .. "}}"
    end)

    text = text:gsub("<<set%s+%$([%w_]+)%s*%-=%s*(.-)>>", function(var, value)
        value = self:convert_sugarcube_value(value)
        return "{{" .. var .. " = " .. var .. " - " .. value .. "}}"
    end)

    text = text:gsub("<<set%s+%$([%w_]+)%s*%*=%s*(.-)>>", function(var, value)
        value = self:convert_sugarcube_value(value)
        return "{{" .. var .. " = " .. var .. " * " .. value .. "}}"
    end)

    text = text:gsub("<<set%s+%$([%w_]+)%s*/=%s*(.-)>>", function(var, value)
        value = self:convert_sugarcube_value(value)
        return "{{" .. var .. " = " .. var .. " / " .. value .. "}}"
    end)

    -- Increment/Decrement: $var++ and $var--
    text = text:gsub("<<set%s+%$([%w_]+)%+%+>>", function(var)
        return "{{" .. var .. " = " .. var .. " + 1}}"
    end)

    text = text:gsub("<<set%s+%$([%w_]+)%-%->>", function(var)
        return "{{" .. var .. " = " .. var .. " - 1}}"
    end)

    return text
end

function SugarCubeParser:parse_unset_macros(text)
    -- <<unset $var>> - Remove variable
    text = text:gsub("<<unset%s+%$([%w_]+)>>", function(var)
        return "{{" .. var .. " = nil}}"
    end)

    return text
end

-- ============================================================================
-- CONDITIONALS
-- ============================================================================

function SugarCubeParser:parse_switch_statements(text)
    -- <<switch expression>><<case val1>>A<<case val2>>B<<default>>C<<endswitch>>
    text = text:gsub("<<switch%s+(.-)>>(.-)<<endswitch>>", function(expr, cases_block)
        expr = self:convert_sugarcube_expression(expr)

        local result = {}
        local first = true

        -- Parse case statements
        for case_val, case_body in cases_block:gmatch("<<case%s+(.-)>>(.-)<<") do
            case_val = self:convert_sugarcube_value(case_val)
            if first then
                table.insert(result, "{{if " .. expr .. " == " .. case_val .. " then}}")
                first = false
            else
                table.insert(result, "{{elseif " .. expr .. " == " .. case_val .. " then}}")
            end
            table.insert(result, case_body)
        end

        -- Parse default case
        local default_body = cases_block:match("<<default>>(.-)<<")
        if default_body then
            table.insert(result, "{{else}}")
            table.insert(result, default_body)
        end

        table.insert(result, "{{end}}")
        return table.concat(result, "")
    end)

    return text
end

function SugarCubeParser:parse_conditionals(text)
    -- <<if condition>>A<<elseif condition2>>B<<else>>C<<endif>>

    -- Full if-elseif-else chain
    text = text:gsub("<<if%s+(.-)>>(.-)<<elseif%s+.->>.+<<else>>(.-)<<endif>>",
        function(cond1, body1, rest)
            local result = "{{if " .. self:convert_condition(cond1) .. " then}}" .. body1

            -- Parse all elseif branches
            local remaining = rest
            while remaining:match("^<<elseif%s+(.-)>>(.-)<<") do
                local elseif_cond, elseif_body
                remaining = remaining:gsub("^<<elseif%s+(.-)>>(.-)<<", function(c, b)
                    elseif_cond = c
                    elseif_body = b
                    return "<<"
                end, 1)

                if elseif_cond then
                    result = result .. "{{elseif " .. self:convert_condition(elseif_cond) .. " then}}" .. elseif_body
                end
            end

            -- Parse else
            local else_body = remaining:match("^else>>(.-)<<endif>>")
            if else_body then
                result = result .. "{{else}}" .. else_body
            end

            result = result .. "{{end}}"
            return result
        end)

    -- if-elseif without else
    text = text:gsub("<<if%s+(.-)>>(.-)<<elseif%s+.+<<endif>>", function(cond1, body1)
        local result = "{{if " .. self:convert_condition(cond1) .. " then}}" .. body1

        -- This is simplified; full implementation would properly parse all elseif branches
        result = result .. "{{end}}"
        return result
    end)

    -- Simple if-else
    text = text:gsub("<<if%s+(.-)>>(.-)<<else>>(.-)<<endif>>", function(cond, if_body, else_body)
        return "{{if " .. self:convert_condition(cond) .. " then}}" .. if_body ..
               "{{else}}" .. else_body .. "{{end}}"
    end)

    -- Simple if
    text = text:gsub("<<if%s+(.-)>>(.-)<<endif>>", function(cond, body)
        return "{{if " .. self:convert_condition(cond) .. " then}}" .. body .. "{{end}}"
    end)

    return text
end

-- ============================================================================
-- LOOPS
-- ============================================================================

function SugarCubeParser:parse_loops(text)
    -- <<for _i to 0; _i < 10; _i++>>body<</for>>
    text = text:gsub("<<for%s+_([%w_]+)%s+to%s+(%d+);%s*_[%w_]+%s*<%s*(%d+);%s*_[%w_]+%+%+>>(.-)<</?for>>",
        function(var, start, finish, body)
            body = body:gsub("_" .. var, var)
            return "{{for " .. var .. " = " .. start .. ", " .. (tonumber(finish) - 1) .. " do}}" .. body .. "{{end}}"
        end)

    -- <<for _i range start end>>body<</for>>
    text = text:gsub("<<for%s+_([%w_]+)%s+range%s+(%d+)%s+(%d+)>>(.-)<</?for>>",
        function(var, start, finish, body)
            body = body:gsub("_" .. var, var)
            return "{{for " .. var .. " = " .. start .. ", " .. finish .. " do}}" .. body .. "{{end}}"
        end)

    -- <<for _item in $array>>body<</for>>
    text = text:gsub("<<for%s+_([%w_]+)%s+in%s+%$([%w_]+)>>(.-)<</?for>>",
        function(loop_var, array, body)
            body = body:gsub("_" .. loop_var, loop_var)
            return "{{for _, " .. loop_var .. " in ipairs(" .. array .. ") do}}" .. body .. "{{end}}"
        end)

    -- <<break>> and <<continue>>
    text = text:gsub("<<break>>", "{{break}}")
    text = text:gsub("<<continue>>", "{{-- continue --}}")

    return text
end

-- ============================================================================
-- LINKS
-- ============================================================================

function SugarCubeParser:parse_link_macros(text)
    -- <<link 'Text' 'Target'>>actions<<link>>
    text = text:gsub("<<link%s+['\"](.-)['\"[%s]+['\"](.-)['\">>(.-)<</?link>>",
        function(link_text, target, actions)
            if actions and actions:trim() ~= "" then
                return self:parse_to_whisker(actions) .. "[[" .. link_text .. "|" .. target .. "]]"
            else
                return "[[" .. link_text .. "|" .. target .. "]]"
            end
        end)

    -- <<link 'Text'>>actions<<link>> (no target, actions only)
    text = text:gsub("<<link%s+['\"](.-)['\">>(.-)<</?link>>", function(link_text, actions)
        return "[[" .. link_text .. "]]" .. self:parse_to_whisker(actions)
    end)

    -- <<button>> macros work similarly to <<link>>
    text = text:gsub("<<button%s+['\"](.-)['\"[%s]+['\"](.-)['\">>(.-)<</?button>>",
        function(button_text, target, actions)
            if actions and actions:trim() ~= "" then
                return self:parse_to_whisker(actions) .. "[[" .. button_text .. "|" .. target .. "]]"
            else
                return "[[" .. button_text .. "|" .. target .. "]]"
            end
        end)

    return text
end

function SugarCubeParser:parse_links(text)
    -- SugarCube supports standard Twine links
    -- [[Text|Target]] - already compatible
    -- [[Text|Target][$var to value]] - link with setter
    text = text:gsub("%[%[(.-)%|(.-)%]%[%$([%w_]+)%s+to%s+(.-)%]%]",
        function(link_text, target, var, value)
            value = self:convert_sugarcube_value(value)
            return "{{" .. var .. " = " .. value .. "}}[[" .. link_text .. "|" .. target .. "]]"
        end)

    return text
end

-- ============================================================================
-- OUTPUT EXPRESSIONS
-- ============================================================================

function SugarCubeParser:parse_print_macros(text)
    -- <<print $var>> or <<= $var>>
    text = text:gsub("<<print%s+%$([%w_]+)>>", function(var)
        return "{{" .. var .. "}}"
    end)

    text = text:gsub("<<%=%s*%$([%w_]+)>>", function(var)
        return "{{" .. var .. "}}"
    end)

    -- <<print expression>>
    text = text:gsub("<<print%s+(.-)>>", function(expr)
        expr = self:convert_sugarcube_expression(expr)
        return "{{" .. expr .. "}}"
    end)

    text = text:gsub("<<%=%s*(.-)>>", function(expr)
        expr = self:convert_sugarcube_expression(expr)
        return "{{" .. expr .. "}}"
    end)

    return text
end

function SugarCubeParser:parse_inline_variables(text)
    -- Inline variables: $variable
    text = text:gsub("([^{<$])%$([%w_]+)([^}>])", function(before, var, after)
        return before .. "{{" .. var .. "}}" .. after
    end)

    -- Handle at start of line
    text = text:gsub("^%$([%w_]+)([^}>])", function(var, after)
        return "{{" .. var .. "}}" .. after
    end)

    return text
end

-- ============================================================================
-- VALUE CONVERSION
-- ============================================================================

function SugarCubeParser:convert_sugarcube_value(value)
    value = value:trim()

    -- Remove $ prefix from variables
    value = value:gsub("%$([%w_]+)", "%1")

    -- Remove _ prefix from temporary variables
    value = value:gsub("_([%w_]+)", "%1")

    -- Convert array literals: [1, 2, 3] → {1, 2, 3}
    if value:match("^%[") then
        value = value:gsub("%[", "{"):gsub("%]", "}")
    end

    -- Convert string concatenation in expressions with quotes
    if value:match("'") or value:match('"') then
        value = value:gsub("%s*%+%s*", " .. ")
    end

    return value
end

function SugarCubeParser:convert_sugarcube_expression(expr)
    expr = expr:trim()

    -- Remove $ prefix from variables
    expr = expr:gsub("%$([%w_]+)", "%1")

    -- Remove _ prefix from temporary variables
    expr = expr:gsub("_([%w_]+)", "%1")

    -- Convert array access: .length → #
    expr = expr:gsub("([%w_]+)%.length", "#%1")

    -- Convert .includes() → contains()
    expr = expr:gsub("([%w_]+)%.includes%((.-)%)", "contains(%1, %2)")

    return expr
end

function SugarCubeParser:convert_condition(cond)
    cond = cond:trim()

    -- Remove $ prefix from variables
    cond = cond:gsub("%$([%w_]+)", "%1")

    -- Remove _ prefix from temporary variables
    cond = cond:gsub("_([%w_]+)", "%1")

    -- Convert SugarCube operators
    cond = cond:gsub("%s+eq%s+", " == ")
    cond = cond:gsub("%s+is%s+", " == ")
    cond = cond:gsub("%s+neq%s+", " ~= ")
    cond = cond:gsub("%s+isnot%s+", " ~= ")
    cond = cond:gsub("%s+gt%s+", " > ")
    cond = cond:gsub("%s+lt%s+", " < ")
    cond = cond:gsub("%s+gte%s+", " >= ")
    cond = cond:gsub("%s+lte%s+", " <= ")

    -- Convert JavaScript operators to Lua
    cond = cond:gsub("===", "==")
    cond = cond:gsub("!==", "~=")
    cond = cond:gsub("&&", " and ")
    cond = cond:gsub("||", " or ")
    cond = cond:gsub("!", "not ")

    -- Convert .length
    cond = cond:gsub("([%w_]+)%.length", "#%1")

    return cond
end

function SugarCubeParser:convert_javascript_to_lua(code)
    code = code:trim()

    -- Remove State.variables prefix
    code = code:gsub("State%.variables%.([%w_]+)", "%1")

    -- Remove $ prefix
    code = code:gsub("%$([%w_]+)", "%1")

    -- Convert operators
    code = code:gsub("===", "==")
    code = code:gsub("!==", "~=")
    code = code:gsub("&&", " and ")
    code = code:gsub("||", " or ")
    code = code:gsub("!", "not ")

    -- Convert .length
    code = code:gsub("([%w_]+)%.length", "#%1")

    -- Convert .push() to table.insert()
    code = code:gsub("([%w_]+)%.push%((.-)%)", "table.insert(%1, %2)")

    return code
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function string:trim()
    return self:match("^%s*(.-)%s*$")
end

return SugarCubeParser