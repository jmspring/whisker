-- src/utils/file_utils.lua
-- Cross-platform file operation utilities

local file_utils = {}

-- File reading
function file_utils.read_file(filepath)
    local file, err = io.open(filepath, "r")

    if not file then
        return nil, "Failed to open file: " .. (err or "unknown error")
    end

    local content = file:read("*all")
    file:close()

    return content
end

function file_utils.read_lines(filepath)
    local file, err = io.open(filepath, "r")

    if not file then
        return nil, "Failed to open file: " .. (err or "unknown error")
    end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end

    file:close()

    return lines
end

-- File writing
function file_utils.write_file(filepath, content)
    -- Ensure directory exists
    local dir = filepath:match("(.+)/[^/]+$")
    if dir then
        file_utils.ensure_directory(dir)
    end

    local file, err = io.open(filepath, "w")

    if not file then
        return false, "Failed to open file for writing: " .. (err or "unknown error")
    end

    file:write(content)
    file:close()

    return true
end

function file_utils.append_file(filepath, content)
    local file, err = io.open(filepath, "a")

    if not file then
        return false, "Failed to open file for appending: " .. (err or "unknown error")
    end

    file:write(content)
    file:close()

    return true
end

-- File operations
function file_utils.file_exists(filepath)
    local file = io.open(filepath, "r")

    if file then
        file:close()
        return true
    end

    return false
end

function file_utils.delete_file(filepath)
    local success, err = os.remove(filepath)

    if not success then
        return false, "Failed to delete file: " .. (err or "unknown error")
    end

    return true
end

function file_utils.copy_file(source, destination)
    local content, err = file_utils.read_file(source)

    if not content then
        return false, err
    end

    return file_utils.write_file(destination, content)
end

function file_utils.move_file(source, destination)
    local success, err = file_utils.copy_file(source, destination)

    if not success then
        return false, err
    end

    return file_utils.delete_file(source)
end

-- File information
function file_utils.get_file_size(filepath)
    local file = io.open(filepath, "r")

    if not file then
        return nil, "File not found"
    end

    local size = file:seek("end")
    file:close()

    return size
end

function file_utils.get_file_extension(filepath)
    return filepath:match("%.([^%.]+)$")
end

function file_utils.get_filename(filepath)
    return filepath:match("([^/\\]+)$")
end

function file_utils.get_basename(filepath)
    local filename = file_utils.get_filename(filepath)
    return filename:match("(.+)%.[^%.]+$") or filename
end

function file_utils.get_directory(filepath)
    return filepath:match("(.+)/[^/]+$") or "."
end

-- Directory operations (platform-specific - basic version)
function file_utils.ensure_directory(dirpath)
    -- Try to create directory (platform-specific)
    -- This is a simplified version - actual implementation depends on platform

    if file_utils.directory_exists(dirpath) then
        return true
    end

    -- Try to create with mkdir (Unix/Linux/Mac)
    local success = os.execute("mkdir -p " .. dirpath)

    if not success then
        -- Try Windows version
        success = os.execute("mkdir " .. dirpath)
    end

    return success
end

function file_utils.directory_exists(dirpath)
    -- Platform-specific check
    local file = io.open(dirpath .. "/.test", "w")

    if file then
        file:close()
        os.remove(dirpath .. "/.test")
        return true
    end

    return false
end

function file_utils.list_files(dirpath, pattern)
    -- Platform-specific directory listing
    -- This is a basic implementation
    local files = {}
    pattern = pattern or "*"

    -- Try Unix/Linux/Mac ls command
    local handle = io.popen("ls " .. dirpath .. "/" .. pattern .. " 2>/dev/null")

    if handle then
        for filename in handle:lines() do
            table.insert(files, filename)
        end
        handle:close()
    end

    return files
end

-- Path manipulation
function file_utils.join_path(...)
    local parts = {...}
    local separator = package.config:sub(1, 1) -- Get OS path separator

    local result = parts[1] or ""
    for i = 2, #parts do
        if parts[i] and parts[i] ~= "" then
            -- Remove trailing separator from current and leading from next
            result = result:gsub("[/\\]$", "")
            local next_part = parts[i]:gsub("^[/\\]", "")
            result = result .. separator .. next_part
        end
    end

    return result
end

function file_utils.normalize_path(filepath)
    local separator = package.config:sub(1, 1)

    -- Replace all slashes with system separator
    filepath = filepath:gsub("[/\\]", separator)

    -- Remove duplicate separators
    filepath = filepath:gsub(separator .. "+", separator)

    return filepath
end

function file_utils.is_absolute_path(filepath)
    -- Check for absolute path patterns
    return filepath:match("^/") or  -- Unix
           filepath:match("^%a:") or  -- Windows drive letter
           filepath:match("^\\\\")    -- Windows UNC
end

-- File content manipulation
function file_utils.read_json(filepath)
    local content, err = file_utils.read_file(filepath)

    if not content then
        return nil, err
    end

    local json = require("whisker.utils.json")
    return json.decode(content)
end

function file_utils.write_json(filepath, data)
    local json = require("whisker.utils.json")
    local content = json.encode(data)

    return file_utils.write_file(filepath, content)
end

-- File searching
function file_utils.find_files(directory, pattern, recursive)
    local results = {}
    recursive = recursive or false

    local files = file_utils.list_files(directory)

    for _, filename in ipairs(files) do
        local filepath = file_utils.join_path(directory, filename)

        if pattern then
            if filename:match(pattern) then
                table.insert(results, filepath)
            end
        else
            table.insert(results, filepath)
        end

        -- Recursion (simplified - needs proper directory detection)
        if recursive and file_utils.directory_exists(filepath) then
            local sub_results = file_utils.find_files(filepath, pattern, recursive)
            for _, sub_file in ipairs(sub_results) do
                table.insert(results, sub_file)
            end
        end
    end

    return results
end

-- Temporary files
function file_utils.get_temp_path()
    return os.getenv("TMPDIR") or
           os.getenv("TEMP") or
           os.getenv("TMP") or
           "/tmp"
end

function file_utils.create_temp_file(prefix)
    prefix = prefix or "whisker_"
    local temp_dir = file_utils.get_temp_path()
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    local filename = prefix .. timestamp .. "_" .. random .. ".tmp"

    return file_utils.join_path(temp_dir, filename)
end

return file_utils
