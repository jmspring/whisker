-- src/utils/json.lua
-- Pure Lua JSON encoder/decoder with no dependencies

local json = {}

-- JSON Encoder
function json.encode(obj, indent_level)
    indent_level = indent_level or 0
    local obj_type = type(obj)

    if obj == nil then
        return "null"
    elseif obj_type == "boolean" then
        return obj and "true" or "false"
    elseif obj_type == "number" then
        if obj ~= obj then
            return "null" -- NaN
        elseif obj == math.huge then
            return "null" -- Infinity
        elseif obj == -math.huge then
            return "null" -- -Infinity
        else
            return tostring(obj)
        end
    elseif obj_type == "string" then
        return json.encode_string(obj)
    elseif obj_type == "table" then
        return json.encode_table(obj, indent_level)
    else
        error("Cannot encode value of type: " .. obj_type)
    end
end

function json.encode_string(str)
    local escaped = str:gsub("\\", "\\\\")
                      :gsub('"', '\\"')
                      :gsub("\n", "\\n")
                      :gsub("\r", "\\r")
                      :gsub("\t", "\\t")
    return '"' .. escaped .. '"'
end

function json.encode_table(tbl, indent_level)
    indent_level = indent_level or 0

    -- Check if table is array or object
    local is_array = true
    local count = 0
    local max_index = 0

    for k, v in pairs(tbl) do
        count = count + 1
        if type(k) == "number" and k > 0 and k == math.floor(k) then
            if k > max_index then
                max_index = k
            end
        else
            is_array = false
            break
        end
    end

    if is_array and count > 0 then
        -- Verify it's a true array (no gaps)
        for i = 1, max_index do
            if tbl[i] == nil then
                is_array = false
                break
            end
        end
        is_array = is_array and max_index == count
    end

    local indent_str = string.rep("  ", indent_level)
    local next_indent_str = string.rep("  ", indent_level + 1)
    local items = {}

    if is_array then
        -- Encode as array
        for i = 1, count do
            local encoded_value = json.encode(tbl[i], indent_level + 1)
            table.insert(items, next_indent_str .. encoded_value)
        end

        if indent_level > 0 then
            return "[\n" .. table.concat(items, ",\n") .. "\n" .. indent_str .. "]"
        else
            return "[" .. table.concat(items, ",") .. "]"
        end
    else
        -- Encode as object
        local sorted_keys = {}
        for k, v in pairs(tbl) do
            if type(k) == "string" or type(k) == "number" then
                table.insert(sorted_keys, k)
            end
        end

        table.sort(sorted_keys, function(a, b)
            return tostring(a) < tostring(b)
        end)

        for _, k in ipairs(sorted_keys) do
            local key_str = type(k) == "string" and json.encode_string(k) or json.encode_string(tostring(k))
            local value_str = json.encode(tbl[k], indent_level + 1)
            table.insert(items, next_indent_str .. key_str .. ": " .. value_str)
        end

        if indent_level > 0 then
            return "{\n" .. table.concat(items, ",\n") .. "\n" .. indent_str .. "}"
        else
            return "{" .. table.concat(items, ",") .. "}"
        end
    end
end

-- JSON Decoder
function json.decode(str)
    if not str or type(str) ~= "string" then
        return nil, "Input must be a string"
    end

    local pos = 1
    local len = #str

    local function skip_whitespace()
        while pos <= len do
            local char = str:sub(pos, pos)
            if char == ' ' or char == '\t' or char == '\n' or char == '\r' then
                pos = pos + 1
            else
                break
            end
        end
    end

    local function decode_string()
        if str:sub(pos, pos) ~= '"' then
            return nil, "Expected string"
        end

        pos = pos + 1 -- Skip opening quote
        local result = ""

        while pos <= len do
            local char = str:sub(pos, pos)
            if char == '"' then
                pos = pos + 1 -- Skip closing quote
                return result
            elseif char == '\\' then
                pos = pos + 1
                if pos <= len then
                    local escaped = str:sub(pos, pos)
                    if escaped == 'n' then
                        result = result .. '\n'
                    elseif escaped == 't' then
                        result = result .. '\t'
                    elseif escaped == 'r' then
                        result = result .. '\r'
                    elseif escaped == '\\' then
                        result = result .. '\\'
                    elseif escaped == '"' then
                        result = result .. '"'
                    elseif escaped == '/' then
                        result = result .. '/'
                    else
                        result = result .. escaped
                    end
                    pos = pos + 1
                end
            else
                result = result .. char
                pos = pos + 1
            end
        end

        return nil, "Unterminated string"
    end

    local function decode_number()
        local start_pos = pos

        -- Handle negative
        if str:sub(pos, pos) == '-' then
            pos = pos + 1
        end

        -- Read integer part
        while pos <= len and str:sub(pos, pos):match("%d") do
            pos = pos + 1
        end

        -- Handle decimal
        if pos <= len and str:sub(pos, pos) == '.' then
            pos = pos + 1
            while pos <= len and str:sub(pos, pos):match("%d") do
                pos = pos + 1
            end
        end

        -- Handle exponent
        if pos <= len and str:sub(pos, pos):match("[eE]") then
            pos = pos + 1
            if pos <= len and str:sub(pos, pos):match("[+-]") then
                pos = pos + 1
            end
            while pos <= len and str:sub(pos, pos):match("%d") do
                pos = pos + 1
            end
        end

        local num_str = str:sub(start_pos, pos - 1)
        return tonumber(num_str)
    end

    local decode_value -- Forward declaration

    local function decode_array()
        if str:sub(pos, pos) ~= '[' then
            return nil, "Expected array"
        end

        pos = pos + 1
        skip_whitespace()

        local result = {}

        -- Handle empty array
        if pos <= len and str:sub(pos, pos) == ']' then
            pos = pos + 1
            return result
        end

        while pos <= len do
            local value, err = decode_value()
            if err then
                return nil, err
            end

            table.insert(result, value)
            skip_whitespace()

            if pos <= len and str:sub(pos, pos) == ',' then
                pos = pos + 1
                skip_whitespace()
            elseif pos <= len and str:sub(pos, pos) == ']' then
                pos = pos + 1
                return result
            else
                return nil, "Expected ',' or ']' in array"
            end
        end

        return nil, "Unterminated array"
    end

    local function decode_object()
        if str:sub(pos, pos) ~= '{' then
            return nil, "Expected object"
        end

        pos = pos + 1
        skip_whitespace()

        local result = {}

        -- Handle empty object
        if pos <= len and str:sub(pos, pos) == '}' then
            pos = pos + 1
            return result
        end

        while pos <= len do
            -- Get key
            skip_whitespace()
            local key, err = decode_string()
            if err then
                return nil, err
            end

            skip_whitespace()
            if pos > len or str:sub(pos, pos) ~= ':' then
                return nil, "Expected ':' after object key"
            end

            pos = pos + 1
            skip_whitespace()

            -- Get value
            local value, err2 = decode_value()
            if err2 then
                return nil, err2
            end

            result[key] = value
            skip_whitespace()

            if pos <= len and str:sub(pos, pos) == ',' then
                pos = pos + 1
                skip_whitespace()
            elseif pos <= len and str:sub(pos, pos) == '}' then
                pos = pos + 1
                return result
            else
                return nil, "Expected ',' or '}' in object"
            end
        end

        return nil, "Unterminated object"
    end

    decode_value = function()
        skip_whitespace()

        if pos > len then
            return nil, "Unexpected end of input"
        end

        local char = str:sub(pos, pos)

        if char == '"' then
            return decode_string()
        elseif char == '-' or char:match("%d") then
            return decode_number()
        elseif char == '[' then
            return decode_array()
        elseif char == '{' then
            return decode_object()
        elseif str:sub(pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif str:sub(pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif str:sub(pos, pos + 3) == "null" then
            pos = pos + 4
            return nil
        else
            return nil, "Unexpected character: " .. char
        end
    end

    local result, err = decode_value()
    if err then
        return nil, err
    end

    skip_whitespace()
    if pos <= len then
        return nil, "Extra data after JSON value"
    end

    return result
end

return json