-- src/utils/template_processor.lua
-- Template processor for Handlebars-style templates with conditionals

local template_processor = {}

-- Process template with variables and conditionals
function template_processor.process(content, variables)
    if not content then
        return ""
    end

    variables = variables or {}

    -- Process conditionals first ({{#if}}...{{else}}...{{/if}})
    content = template_processor.process_conditionals(content, variables)

    -- Then process simple variable substitutions ({{variable}})
    content = template_processor.process_variables(content, variables)

    return content
end

-- Process conditional blocks
function template_processor.process_conditionals(content, variables)
    -- Process {{#if condition}}...{{else if}}...{{else}}...{{/if}} blocks
    -- Handle one conditional at a time to avoid regex issues with multiple conditionals

    local max_iterations = 100  -- Prevent infinite loops
    local iteration = 0

    while content:match("{{#if%s+[^}]+}}") and iteration < max_iterations do
        iteration = iteration + 1
        local processed = false

        -- Find the first {{#if}} tag
        local if_start, if_end, condition = content:find("{{#if%s+([^}]+)}}")

        if if_start then
            -- Find the matching {{/if}} tag (not nested)
            local endif_start, endif_end = content:find("{{/if}}", if_end + 1)

            if endif_start then
                -- Extract the content between {{#if}} and {{/if}}
                local block_content = content:sub(if_end + 1, endif_start - 1)

                -- Parse the conditional blocks (if, else if, else)
                local blocks = template_processor.parse_conditional_blocks(block_content, condition)

                -- Evaluate blocks in order and use the first one that matches
                local replacement = ""
                for _, block in ipairs(blocks) do
                    if block.condition == nil then
                        -- This is the {{else}} block (no condition)
                        replacement = block.content
                        break
                    else
                        -- Evaluate the condition
                        local result = template_processor.evaluate_condition(block.condition, variables)
                        if result then
                            replacement = block.content
                            break
                        end
                    end
                end

                -- Replace this conditional block with the result
                content = content:sub(1, if_start - 1) .. replacement .. content:sub(endif_end + 1)
                processed = true
            end
        end

        -- If we didn't process anything, break to avoid infinite loop
        if not processed then
            break
        end
    end

    -- Process {{#unless condition}}...{{/unless}} blocks (inverse if)
    iteration = 0
    while content:match("{{#unless%s+[^}]+}}") and iteration < max_iterations do
        iteration = iteration + 1
        local processed = false

        local unless_start, unless_end, condition = content:find("{{#unless%s+([^}]+)}}")

        if unless_start then
            local endunless_start, endunless_end = content:find("{{/unless}}", unless_end + 1)

            if endunless_start then
                local block_content = content:sub(unless_end + 1, endunless_start - 1)
                local result = template_processor.evaluate_condition(condition, variables)
                local replacement = (not result) and block_content or ""

                content = content:sub(1, unless_start - 1) .. replacement .. content:sub(endunless_end + 1)
                processed = true
            end
        end

        if not processed then
            break
        end
    end

    return content
end

-- Parse conditional blocks from content (handles {{else if}} and {{else}})
function template_processor.parse_conditional_blocks(block_content, initial_condition)
    local blocks = {}

    -- Add the initial {{#if}} block
    table.insert(blocks, {
        condition = initial_condition,
        content = ""  -- Will be filled below
    })

    -- Find all {{else if}} and {{else}} markers
    local markers = {}
    local pos = 1

    while true do
        -- Look for {{else if condition}}
        local else_if_start, else_if_end, else_if_condition = block_content:find("{{else if%s+([^}]+)}}", pos)

        -- Look for {{else}}
        local else_start, else_end = block_content:find("{{else}}", pos)

        -- Determine which comes first
        local next_marker_start, next_marker_end, marker_type, marker_condition

        if else_if_start and (not else_start or else_if_start < else_start) then
            next_marker_start = else_if_start
            next_marker_end = else_if_end
            marker_type = "else_if"
            marker_condition = else_if_condition
        elseif else_start then
            next_marker_start = else_start
            next_marker_end = else_end
            marker_type = "else"
            marker_condition = nil
        else
            break
        end

        table.insert(markers, {
            start_pos = next_marker_start,
            end_pos = next_marker_end,
            type = marker_type,
            condition = marker_condition
        })

        pos = next_marker_end + 1
    end

    -- Extract content for each block
    local current_pos = 1

    for i, marker in ipairs(markers) do
        -- Content for the current block ends where this marker starts
        blocks[#blocks].content = block_content:sub(current_pos, marker.start_pos - 1)

        -- Add the new block
        table.insert(blocks, {
            condition = marker.condition,  -- nil for {{else}}
            content = ""  -- Will be filled on next iteration or at the end
        })

        current_pos = marker.end_pos + 1
    end

    -- The last block gets the remaining content
    blocks[#blocks].content = block_content:sub(current_pos)

    return blocks
end

-- Process simple variable substitutions
function template_processor.process_variables(content, variables)
    -- First, remove {{lua:...}} tags (these should be processed by the engine, not displayed)
    content = content:gsub("{{lua:[^}]*}}", "")

    -- Then process variable substitutions
    return content:gsub("{{([%w_]+)}}", function(var_name)
        local value = variables[var_name]
        return value ~= nil and tostring(value) or ""
    end)
end

-- Evaluate a condition expression
function template_processor.evaluate_condition(condition, variables)
    if not condition or condition == "" then
        return false
    end

    condition = condition:match("^%s*(.-)%s*$")  -- trim whitespace

    if os.getenv("DEBUG_TEMPLATE") then
        print(string.format("Evaluating condition: '%s'", condition))
    end

    -- Check for comparison operators
    -- Use (.+) for right side to match one or more characters (not empty)
    local operators = {
        {name = "==", pattern = "(.-)%s*==%s*(.+)", op = function(a, b) return a == b end},
        {name = "!=", pattern = "(.-)%s*!=%s*(.+)", op = function(a, b) return a ~= b end},
        {name = ">=", pattern = "(.-)%s*>=%s*(.+)", op = function(a, b)
            local na, nb = tonumber(a), tonumber(b)
            return na and nb and (na >= nb) or false
        end},
        {name = "<=", pattern = "(.-)%s*<=%s*(.+)", op = function(a, b)
            local na, nb = tonumber(a), tonumber(b)
            return na and nb and (na <= nb) or false
        end},
        {name = ">", pattern = "(.-)%s*>%s*(.+)", op = function(a, b)
            local na, nb = tonumber(a), tonumber(b)
            return na and nb and (na > nb) or false
        end},
        {name = "<", pattern = "(.-)%s*<%s*(.+)", op = function(a, b)
            local na, nb = tonumber(a), tonumber(b)
            return na and nb and (na < nb) or false
        end}
    }

    for _, op_info in ipairs(operators) do
        local left, right = condition:match(op_info.pattern)
        if left and right then
            if os.getenv("DEBUG_TEMPLATE") then
                print(string.format("Operator '%s' matched", op_info.name))
            end
            left = left:match("^%s*(.-)%s*$")
            right = right:match("^%s*(.-)%s*$")

            -- Debug output
            if os.getenv("DEBUG_TEMPLATE") then
                print(string.format("Pattern matched: left='%s', right='%s'", left, right))
            end

            -- Resolve variables
            left = template_processor.resolve_value(left, variables)
            right = template_processor.resolve_value(right, variables)

            if os.getenv("DEBUG_TEMPLATE") then
                print(string.format("After resolve: left='%s', right='%s'", tostring(left), tostring(right)))
            end

            return op_info.op(left, right)
        end
    end

    -- Check for logical operators
    -- Split on " and " or " or " keywords
    if condition:match("%s+and%s+") then
        -- Split on " and "
        local parts = {}
        for part in (condition .. " and "):gmatch("(.-) and ") do
            if part ~= "" then
                table.insert(parts, part)
            end
        end

        for _, part in ipairs(parts) do
            if not template_processor.evaluate_condition(part, variables) then
                return false
            end
        end
        return true
    end

    if condition:match("%s+or%s+") then
        -- Split on " or "
        local parts = {}
        for part in (condition .. " or "):gmatch("(.-) or ") do
            if part ~= "" then
                table.insert(parts, part)
            end
        end

        for _, part in ipairs(parts) do
            if template_processor.evaluate_condition(part, variables) then
                return true
            end
        end
        return false
    end

    -- Check for negation
    if condition:match("^not%s+") or condition:match("^!") then
        local inner = condition:gsub("^not%s+", ""):gsub("^!", "")
        return not template_processor.evaluate_condition(inner, variables)
    end

    -- Simple variable lookup - check if variable exists and is truthy
    local value = variables[condition]

    if value == nil then
        return false
    end

    if type(value) == "boolean" then
        return value
    end

    if type(value) == "number" then
        return value ~= 0
    end

    if type(value) == "string" then
        return value ~= ""
    end

    -- For other types (tables, functions), check if not nil
    return value ~= nil
end

-- Resolve a value from variables or return literal
function template_processor.resolve_value(str, variables)
    str = str:match("^%s*(.-)%s*$")  -- trim

    -- Check if it's a quoted string
    if str:match("^['\"](.-)[ '\"]$") then
        return str:match("^['\"](.-)[ '\"]$")
    end

    -- Check if it's a number
    local num = tonumber(str)
    if num then
        return num
    end

    -- Check if it's a boolean
    if str == "true" then return true end
    if str == "false" then return false end

    -- Otherwise, look up as variable
    return variables[str]
end

return template_processor
