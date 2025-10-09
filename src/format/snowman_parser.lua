-- Snowman Format Parser
-- Parses Snowman syntax and converts to Whisker format

local SnowmanParser = {}
SnowmanParser.__index = SnowmanParser

function SnowmanParser:new()
    local instance = setmetatable({}, self)
    return instance
end

-- ============================================================================
-- MAIN PARSING FUNCTION
-- ============================================================================

function SnowmanParser:parse_to_whisker(text)
    if not text then return "" end

    -- Parse in specific order to avoid conflicts
    text = self:parse_comments(text)
    text = self:parse_conditionals(text)
    text = self:parse_loops(text)
    text = self:parse_code_blocks(text)
    text = self:parse_output_expressions(text)
    text = self:parse_links(text)

    return text
end

-- ============================================================================
-- COMMENT PARSING
-- ============================================================================

function SnowmanParser:parse_comments(text)
    -- HTML comments: <!-- comment -->
    text = text:gsub("<!%-%-(.-)%-%->", "")

    -- JavaScript comments in code blocks are handled in code block parsing

    return text
end

-- ============================================================================
-- CONDITIONALS
-- ============================================================================

function SnowmanParser:parse_conditionals(text)
    -- Complex if-elseif-else: <% if (cond1) { %>A<% } else if (cond2) { %>B<% } else { %>C<% } %>
    text = text:gsub("<%[%s]*if%s*%((.-)%)[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*else[%s]*if.-<%[%s]*}[%s]*else[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*%%>",
        function(cond1, body1, rest)
            local result = "{{if " .. self:convert_condition(cond1) .. " then}}" .. body1

            -- Parse elseif chains
            local remaining = rest
            for elseif_cond, elseif_body in remaining:gmatch("<%[%s]*}[%s]*else[%s]*if[%s]*%((.-)%)[%s]*{[%s]*%%>(.-)<%[%s]*}") do
                result = result .. "{{elseif " .. self:convert_condition(elseif_cond) .. " then}}" .. elseif_body
            end

            -- Parse final else
            local else_body = remaining:match("<%[%s]*}[%s]*else[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*%%>$")
            if else_body then
                result = result .. "{{else}}" .. else_body
            end

            result = result .. "{{end}}"
            return result
        end)

    -- If-else: <% if (condition) { %>A<% } else { %>B<% } %>
    text = text:gsub("<%[%s]*if%s*%((.-)%)[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*else[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*%%>",
        function(cond, if_body, else_body)
            return "{{if " .. self:convert_condition(cond) .. " then}}" .. if_body ..
                   "{{else}}" .. else_body .. "{{end}}"
        end)

    -- Simple if: <% if (condition) { %>text<% } %>
    text = text:gsub("<%[%s]*if%s*%((.-)%)[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*%%>", function(cond, body)
        return "{{if " .. self:convert_condition(cond) .. " then}}" .. body .. "{{end}}"
    end)

    return text
end

-- ============================================================================
-- LOOPS
-- ============================================================================

function SnowmanParser:parse_loops(text)
    -- For loop: <% for (let i = 0; i < n; i++) { %>body<% } %>
    text = text:gsub("<%[%s]*for%s*%(%s*let%s+([%w_]+)%s*=%s*(%d+)%s*;%s*[%w_]+%s*<%s*([%w_%d]+)%s*;%s*[%w_]+%+%+%s*%)[%s]*{[%s]*%%>(.-)<%[%s]*}[%s]*%%>",
        function(var, start, finish, body)
            -- Convert s.variable references in finish if needed
            finish = finish:gsub("s%.([%w_]+)", "%1")

            -- Convert references to loop var
            body = body:gsub("<%=%s*" .. var .. "%s*%%>", "{{" .. var .. "}}")

            return "{{for " .. var .. " = " .. start .. ", " .. finish .. " - 1 do}}" .. body .. "{{end}}"
        end)

    -- forEach: <% array.forEach(function(item) { %>body<% }); %>
    text = text:gsub("<%[%s]*s%.([%w_]+)%.forEach%(%s*function%s*%(%s*([%w_]+)%s*%)[%s]*{[%s]*%%>(.-)<%[%s]*}%s*%)[%s]*;?[%s]*%%>",
        function(array, item, body)
            body = body:gsub("<%=%s*" .. item .. "%s*%%>", "{{" .. item .. "}}")
            return "{{for _, " .. item .. " in ipairs(" .. array .. ") do}}" .. body .. "{{end}}"
        end)

    -- forEach with arrow function: <% array.forEach(item => { %>body<% }); %>
    text = text:gsub("<%[%s]*s%.([%w_]+)%.forEach%(%s*([%w_]+)%s*=>%s*{[%s]*%%>(.-)<%[%s]*}%s*%)[%s]*;?[%s]*%%>",
        function(array, item, body)
            body = body:gsub("<%=%s*" .. item .. "%s*%%>", "{{" .. item .. "}}")
            return "{{for _, " .. item .. " in ipairs(" .. array .. ") do}}" .. body .. "{{end}}"
        end)

    return text
end

-- ============================================================================
-- CODE BLOCKS
-- ============================================================================

function SnowmanParser:parse_code_blocks(text)
    -- <% code %>
    text = text:gsub("<%[%s]*([^=].-)%%>", function(code)
        code = self:convert_javascript_to_lua(code)
        return "{{" .. code .. "}}"
    end)

    return text
end

-- ============================================================================
-- OUTPUT EXPRESSIONS
-- ============================================================================

function SnowmanParser:parse_output_expressions(text)
    -- <%= expression %>
    text = text:gsub("<%=[%s]*(.-)%%>", function(expr)
        expr = self:convert_expression(expr)
        return "{{" .. expr .. "}}"
    end)

    return text
end

-- ============================================================================
-- LINKS
-- ============================================================================

function SnowmanParser:parse_links(text)
    -- Snowman uses standard Twine links
    -- [[Text|Target]] - already compatible
    -- [[Text]] - already compatible

    return text
end

-- ============================================================================
-- CONVERSION FUNCTIONS
-- ============================================================================

function SnowmanParser:convert_condition(cond)
    cond = cond:trim()

    -- Remove s. prefix from state variables
    cond = cond:gsub("s%.([%w_]+)", "%1")

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

function SnowmanParser:convert_expression(expr)
    expr = expr:trim()

    -- Remove s. prefix from state variables
    expr = expr:gsub("s%.([%w_]+)", "%1")

    -- Convert .length
    expr = expr:gsub("([%w_]+)%.length", "#%1")

    -- Convert string concatenation: + → ..
    -- Only if we detect strings (quotes)
    if expr:match("'") or expr:match('"') then
        expr = expr:gsub("%s*%+%s*", " .. ")
    end

    -- Convert .toUpperCase()
    expr = expr:gsub("([%w_]+)%.toUpperCase%(%)", "string.upper(%1)")

    -- Convert .toLowerCase()
    expr = expr:gsub("([%w_]+)%.toLowerCase%(%)", "string.lower(%1)")

    -- Convert .join()
    expr = expr:gsub("([%w_]+)%.join%((.-)%)", "table.concat(%1, %2)")

    return expr
end

function SnowmanParser:convert_javascript_to_lua(code)
    code = code:trim()

    -- Remove semicolons at end
    code = code:gsub(";$", "")

    -- Remove s. prefix from state variables
    code = code:gsub("s%.([%w_]+)", "%1")

    -- Convert variable declarations
    code = code:gsub("let%s+([%w_]+)%s*=%s*(.-)$", "%1 = %2")
    code = code:gsub("const%s+([%w_]+)%s*=%s*(.-)$", "%1 = %2")
    code = code:gsub("var%s+([%w_]+)%s*=%s*(.-)$", "%1 = %2")

    -- Convert assignment operators
    code = code:gsub("([%w_]+)%s*=%s*([^=].*)", "%1 = %2")

    -- Convert +=, -=, *=, /=
    code = code:gsub("([%w_]+)%s*%+=%s*(.-)$", "%1 = %1 + %2")
    code = code:gsub("([%w_]+)%s*%-=%s*(.-)$", "%1 = %1 - %2")
    code = code:gsub("([%w_]+)%s*%*=%s*(.-)$", "%1 = %1 * %2")
    code = code:gsub("([%w_]+)%s*/=%s*(.-)$", "%1 = %1 / %2")

    -- Convert ++ and --
    code = code:gsub("([%w_]+)%+%+", "%1 = %1 + 1")
    code = code:gsub("([%w_]+)%-%-", "%1 = %1 - 1")

    -- Convert operators
    code = code:gsub("===", "==")
    code = code:gsub("!==", "~=")
    code = code:gsub("&&", " and ")
    code = code:gsub("||", " or ")
    code = code:gsub("!", "not ")

    -- Convert .length
    code = code:gsub("([%w_]+)%.length", "#%1")

    -- Convert array methods
    code = code:gsub("([%w_]+)%.push%((.-)%)", "table.insert(%1, %2)")
    code = code:gsub("([%w_]+)%.pop%(%)", "table.remove(%1)")

    -- Convert array literals
    code = code:gsub("%[(.-)%]", "{%1}")

    return code
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function string:trim()
    return self:match("^%s*(.-)%s*$")
end

return SnowmanParser