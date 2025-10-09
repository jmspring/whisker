-- src/utils/string_utils.lua
-- String processing and templating utilities

local string_utils = {}

-- String trimming
function string_utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

function string_utils.ltrim(str)
    return str:match("^%s*(.*)$")
end

function string_utils.rtrim(str)
    return str:match("^(.-)%s*$")
end

-- String splitting
function string_utils.split(str, delimiter)
    delimiter = delimiter or "%s"
    local result = {}

    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end

    return result
end

function string_utils.lines(str)
    return string_utils.split(str, "\n")
end

-- String case conversion
function string_utils.capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

function string_utils.title_case(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- String padding
function string_utils.pad_left(str, length, char)
    char = char or " "
    return string.rep(char, length - #str) .. str
end

function string_utils.pad_right(str, length, char)
    char = char or " "
    return str .. string.rep(char, length - #str)
end

function string_utils.pad_center(str, length, char)
    char = char or " "
    local total_padding = length - #str
    local left_padding = math.floor(total_padding / 2)
    local right_padding = total_padding - left_padding

    return string.rep(char, left_padding) .. str .. string.rep(char, right_padding)
end

-- String searching
function string_utils.starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function string_utils.ends_with(str, suffix)
    return str:sub(-#suffix) == suffix
end

function string_utils.contains(str, substring)
    return str:find(substring, 1, true) ~= nil
end

-- String replacement
function string_utils.replace(str, old, new, count)
    count = count or -1
    local result = str
    local replacements = 0

    while count == -1 or replacements < count do
        local pos = result:find(old, 1, true)
        if not pos then break end

        result = result:sub(1, pos - 1) .. new .. result:sub(pos + #old)
        replacements = replacements + 1
    end

    return result
end

-- Markdown-style formatting
function string_utils.format_markdown_simple(str)
    -- Bold: **text** or __text__
    str = str:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")
    str = str:gsub("__(.-)__", "<strong>%1</strong>")

    -- Italic: *text* or _text_
    str = str:gsub("%*(.-)%*", "<em>%1</em>")
    str = str:gsub("_(.-)_", "<em>%1</em>")

    -- Code: `text`
    str = str:gsub("`(.-)`", "<code>%1</code>")

    return str
end

-- Template substitution
function string_utils.template(str, values)
    return str:gsub("{{(.-)}}", function(key)
        key = string_utils.trim(key)
        return tostring(values[key] or "")
    end)
end

function string_utils.template_advanced(str, values, default)
    default = default or ""

    return str:gsub("{{(.-)}}", function(expression)
        expression = string_utils.trim(expression)

        -- Simple variable lookup
        if values[expression] then
            return tostring(values[expression])
        end

        -- Dot notation: obj.property
        if expression:find("%.") then
            local parts = string_utils.split(expression, "%.")
            local value = values

            for _, part in ipairs(parts) do
                if type(value) == "table" and value[part] then
                    value = value[part]
                else
                    return default
                end
            end

            return tostring(value)
        end

        return default
    end)
end

-- Word wrapping
function string_utils.word_wrap(str, width)
    width = width or 80
    local result = {}
    local current_line = ""

    for word in str:gmatch("%S+") do
        if #current_line + #word + 1 > width then
            table.insert(result, current_line)
            current_line = word
        else
            if current_line ~= "" then
                current_line = current_line .. " " .. word
            else
                current_line = word
            end
        end
    end

    if current_line ~= "" then
        table.insert(result, current_line)
    end

    return table.concat(result, "\n")
end

-- String escaping
function string_utils.escape_html(str)
    local replacements = {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;"
    }

    return str:gsub("[&<>\"']", replacements)
end

function string_utils.unescape_html(str)
    local replacements = {
        ["&amp;"] = "&",
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&quot;"] = '"',
        ["&#39;"] = "'"
    }

    for entity, char in pairs(replacements) do
        str = str:gsub(entity, char)
    end

    return str
end

-- String comparison
function string_utils.levenshtein_distance(str1, str2)
    local len1, len2 = #str1, #str2
    local matrix = {}

    for i = 0, len1 do
        matrix[i] = {[0] = i}
    end

    for j = 0, len2 do
        matrix[0][j] = j
    end

    for i = 1, len1 do
        for j = 1, len2 do
            local cost = str1:sub(i, i) == str2:sub(j, j) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            )
        end
    end

    return matrix[len1][len2]
end

function string_utils.similarity(str1, str2)
    local distance = string_utils.levenshtein_distance(str1, str2)
    local max_len = math.max(#str1, #str2)

    if max_len == 0 then
        return 1.0
    end

    return 1.0 - (distance / max_len)
end

-- Random string generation
function string_utils.random_string(length, chars)
    chars = chars or "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = {}

    for i = 1, length do
        local pos = math.random(1, #chars)
        table.insert(result, chars:sub(pos, pos))
    end

    return table.concat(result)
end

-- UUID generation (simple version)
function string_utils.generate_uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

return string_utils