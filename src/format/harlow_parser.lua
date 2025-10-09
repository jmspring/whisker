-- Harlowe Format Parser
-- Parses Harlowe syntax and converts to Whisker format

local HarloweParser = {}
HarloweParser.__index = HarloweParser

function HarloweParser:new()
    local instance = setmetatable({}, self)
    return instance
end

-- ============================================================================
-- MAIN PARSING FUNCTION
-- ============================================================================

function HarloweParser:parse_to_whisker(text)
    if not text then return "" end

    -- Parse in specific order to avoid conflicts
    text = self:parse_comments(text)
    text = self:parse_set_macros(text)
    text = self:parse_put_macros(text)
    text = self:parse_conditionals(text)
    text = self:parse_loops(text)
    text = self:parse_print_macros(text)
    text = self:parse_inline_variables(text)
    text = self:parse_links(text)

    return text
end

-- ============================================================================
-- COMMENT PARSING
-- ============================================================================

function HarloweParser:parse_comments(text)
    -- Remove Harlowe comments: <!-- comment -->
    text = text:gsub("<!%-%-(.-)%-%->", "")
    return text
end

-- ============================================================================
-- VARIABLE ASSIGNMENT
-- ============================================================================

function HarloweParser:parse_set_macros(text)
    -- Pattern: (set: $var to value)
    -- Convert to: {{var = value}}
    text = text:gsub("%(%s*set:%s*%$([%w_]+)%s+to%s+(.-)%)", function(var, value)
        value = self:convert_harlowe_value(value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    return text
end

function HarloweParser:parse_put_macros(text)
    -- Pattern: (put: value into $var)
    -- Convert to: {{var = value}}
    text = text:gsub("%(%s*put:%s+(.-)%s+into%s+%$([%w_]+)%)", function(value, var)
        value = self:convert_harlowe_value(value)
        return "{{" .. var .. " = " .. value .. "}}"
    end)

    return text
end

-- ============================================================================
-- CONDITIONALS
-- ============================================================================

function HarloweParser:parse_conditionals(text)
    -- Parse if-elseif-else chains
    -- Pattern: (if: cond1)[A](else-if: cond2)[B](else:)[C]

    -- Complex if-elseif-else
    text = text:gsub("%(%s*if:%s*(.-)%)%[(.-)%](%(%s*else%-if:.-%)%[.-%])+(%(%s*else:%)%[.-%])",
        function(cond1, body1, elseifs, else_part)
            local result = "{{if " .. self:convert_condition(cond1) .. " then}}" .. body1

            -- Parse elseif chains
            for elseif_cond, elseif_body in elseifs:gmatch("%(%s*else%-if:%s*(.-)%)%[(.-)%]") do
                result = result .. "{{elseif " .. self:convert_condition(elseif_cond) .. " then}}" .. elseif_body
            end

            -- Parse else
            local else_body = else_part:match("%(%s*else:%)%[(.-)%]")
            if else_body then
                result = result .. "{{else}}" .. else_body
            end

            result = result .. "{{end}}"
            return result
        end)

    -- If with else-if (no final else)
    text = text:gsub("%(%s*if:%s*(.-)%)%[(.-)%](%(%s*else%-if:.-%)%[.-%])+", function(cond1, body1, elseifs)
        local result = "{{if " .. self:convert_condition(cond1) .. " then}}" .. body1

        for elseif_cond, elseif_body in elseifs:gmatch("%(%s*else%-if:%s*(.-)%)%[(.-)%]") do
            result = result .. "{{elseif " .. self:convert_condition(elseif_cond) .. " then}}" .. elseif_body
        end

        result = result .. "{{end}}"
        return result
    end)

    -- Simple if-else
    text = text:gsub("%(%s*if:%s*(.-)%)%[(.-)%]%(%s*else:%)%[(.-)%]", function(cond, if_body, else_body)
        return "{{if " .. self:convert_condition(cond) .. " then}}" .. if_body ..
               "{{else}}" .. else_body .. "{{end}}"
    end)

    -- Simple if
    text = text:gsub("%(%s*if:%s*(.-)%)%[(.-)%]", function(cond, body)
        return "{{if " .. self:convert_condition(cond) .. " then}}" .. body .. "{{end}}"
    end)

    -- Unless (inverted if)
    text = text:gsub("%(%s*unless:%s*(.-)%)%[(.-)%]", function(cond, body)
        return "{{if not (" .. self:convert_condition(cond) .. ") then}}" .. body .. "{{end}}"
    end)

    return text
end

-- ============================================================================
-- LOOPS
-- ============================================================================

function HarloweParser:parse_loops(text)
    -- For each loop: (for: each _item in $array)[body]
    text = text:gsub("%(%s*for:%s*each%s+_([%w_]+)%s+in%s+%$([%w_]+)%)%[(.-)%]",
        function(loop_var, array, body)
            -- Replace _loopvar with loopvar in body
            body = body:gsub("_" .. loop_var, loop_var)
            return "{{for " .. loop_var .. " in " .. array .. " do}}" .. body .. "{{end}}"
        end)

    -- For range loop: (for: each _i in (range: 1, 10))[body]
    text = text:gsub("%(%s*for:%s*each%s+_([%w_]+)%s+in%s+%(range:%s*(%d+),%s*(%d+)%)%)%[(.-)%]",
        function(loop_var, start, finish, body)
            body = body:gsub("_" .. loop_var, loop_var)
            return "{{for " .. loop_var .. " = " .. start .. ", " .. finish .. " do}}" .. body .. "{{end}}"
        end)

    return text
end

-- ============================================================================
-- OUTPUT EXPRESSIONS
-- ============================================================================

function HarloweParser:parse_print_macros(text)
    -- (print: $var) or (print: expression)
    text = text:gsub("%(%s*print:%s*%$([%w_]+)%)", function(var)
        return "{{" .. var .. "}}"
    end)

    -- (print: expression)
    text = text:gsub("%(%s*print:%s+(.-)%)", function(expr)
        expr = self:convert_harlowe_expression(expr)
        return "{{" .. expr .. "}}"
    end)

    return text
end

function HarloweParser:parse_inline_variables(text)
    -- Inline variables: $variable
    -- Don't replace if inside macros or already in {{}}
    text = text:gsub("([^{%(%$])%$([%w_]+)([^}%)])", function(before, var, after)
        return before .. "{{" .. var .. "}}" .. after
    end)

    -- Handle at start of line
    text = text:gsub("^%$([%w_]+)([^}%)])", function(var, after)
        return "{{" .. var .. "}}" .. after
    end)

    return text
end

-- ============================================================================
-- LINKS
-- ============================================================================

function HarloweParser:parse_links(text)
    -- Harlowe uses standard Twine links, so these are already compatible
    -- [[Text]] and [[Text|Target]] work in both formats

    -- However, convert link macros:
    -- (link-goto: 'Text', 'Target') → [[Text|Target]]
    text = text:gsub("%(%s*link%-goto:%s*['\"](.-)['\"],[%s]*['\"](.-)['\"[%)%)%]", function(link_text, target)
        return "[[" .. link_text .. "|" .. target .. "]]"
    end)

    -- (link-goto: 'Text', 'Target') with action
    text = text:gsub("%(%s*link%-goto:%s*['\"](.-)['\"],[%s]*['\"](.-)['\"%)%)%[(.-)%]",
        function(link_text, target, action)
            -- Action before link
            return self:parse_to_whisker(action) .. "[[" .. link_text .. "|" .. target .. "]]"
        end)

    return text
end

-- ============================================================================
-- VALUE CONVERSION
-- ============================================================================

function HarloweParser:convert_harlowe_value(value)
    value = value:trim()

    -- Remove $ prefix from variables
    value = value:gsub("%$([%w_]+)", "%1")

    -- Convert Harlowe array syntax: (a: 1, 2, 3) → {1, 2, 3}
    value = value:gsub("%(%s*a:%s*(.-)%)", function(items)
        return "{" .. items .. "}"
    end)

    -- Convert Harlowe datamap syntax: (dm: 'key', value) → {key = value}
    value = value:gsub("%(%s*dm:%s*(.-)%)", function(pairs)
        -- This is simplified; proper implementation would parse key-value pairs
        return "{" .. pairs .. "}"
    end)

    -- Convert string concatenation: + → ..
    if value:match("%+") and (value:match("'") or value:match('"')) then
        value = value:gsub("%+", "..")
    end

    return value
end

function HarloweParser:convert_harlowe_expression(expr)
    expr = expr:trim()

    -- Remove $ prefix from variables
    expr = expr:gsub("%$([%w_]+)", "%1")

    -- Remove _ prefix from temporary variables
    expr = expr:gsub("_([%w_]+)", "%1")

    -- Convert array access: $array's 1st → array[1]
    expr = expr:gsub("([%w_]+)'s%s+1st", "%1[1]")
    expr = expr:gsub("([%w_]+)'s%s+2nd", "%1[2]")
    expr = expr:gsub("([%w_]+)'s%s+3rd", "%1[3]")
    expr = expr:gsub("([%w_]+)'s%s+(%d+)th", "%1[%2]")
    expr = expr:gsub("([%w_]+)'s%s+last", "%1[#%1]")

    -- Convert array length: $array's length → #array
    expr = expr:gsub("([%w_]+)'s%s+length", "#%1")

    -- Convert contains: $array contains item → contains(array, item)
    expr = expr:gsub("([%w_]+)%s+contains%s+(.+)", "contains(%1, %2)")

    return expr
end

function HarloweParser:convert_condition(cond)
    cond = cond:trim()

    -- Remove $ prefix from variables
    cond = cond:gsub("%$([%w_]+)", "%1")

    -- Remove _ prefix from temporary variables
    cond = cond:gsub("_([%w_]+)", "%1")

    -- Convert Harlowe operators
    cond = cond:gsub("%s+is%s+", " == ")
    cond = cond:gsub("%s+is%s+not%s+", " ~= ")
    cond = cond:gsub("%s+contains%s+", ":contains(")

    -- Array access conversions
    cond = cond:gsub("([%w_]+)'s%s+1st", "%1[1]")
    cond = cond:gsub("([%w_]+)'s%s+length", "#%1")

    -- Logical operators (and, or, not) are already compatible with Lua

    return cond
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function string:trim()
    return self:match("^%s*(.-)%s*$")
end

return HarloweParser