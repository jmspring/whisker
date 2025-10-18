-- src/platform/file_system.lua
-- Basic cross-platform file system operations

local FileSystem = {}
FileSystem.__index = FileSystem

function FileSystem.new()
    local instance = {
        path_separator = package.config:sub(1, 1)
    }

    setmetatable(instance, FileSystem)
    return instance
end

-- Path operations
function FileSystem:join(...)
    local parts = {...}
    local result = parts[1] or ""

    for i = 2, #parts do
        if parts[i] and parts[i] ~= "" then
            result = result:gsub("[/\\]$", "")
            local next_part = parts[i]:gsub("^[/\\]", "")
            result = result .. self.path_separator .. next_part
        end
    end

    return result
end

function FileSystem:normalize(path)
    path = path:gsub("[/\\]", self.path_separator)
    path = path:gsub(self.path_separator .. "+", self.path_separator)
    return path
end

function FileSystem:dirname(path)
    return path:match("(.+)[/\\][^/\\]+$") or "."
end

function FileSystem:basename(path)
    return path:match("([^/\\]+)$") or path
end

function FileSystem:extension(path)
    return path:match("%.([^%.]+)$")
end

function FileSystem:without_extension(path)
    return path:match("(.+)%.[^%.]+$") or path
end

-- File operations
function FileSystem:read(filepath)
    local file, err = io.open(filepath, "r")
    if not file then
        return nil, err
    end

    local content = file:read("*all")
    file:close()
    return content
end

function FileSystem:write(filepath, content)
    -- Ensure directory exists
    local dir = self:dirname(filepath)
    self:mkdir_p(dir)

    local file, err = io.open(filepath, "w")
    if not file then
        return false, err
    end

    file:write(content)
    file:close()
    return true
end

function FileSystem:append(filepath, content)
    local file, err = io.open(filepath, "a")
    if not file then
        return false, err
    end

    file:write(content)
    file:close()
    return true
end

function FileSystem:exists(filepath)
    local file = io.open(filepath, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function FileSystem:delete(filepath)
    return os.remove(filepath)
end

function FileSystem:copy(source, dest)
    local content, err = self:read(source)
    if not content then
        return false, err
    end

    return self:write(dest, content)
end

function FileSystem:move(source, dest)
    local success, err = self:copy(source, dest)
    if not success then
        return false, err
    end

    return self:delete(source)
end

-- Directory operations
function FileSystem:mkdir_p(path)
    if self:exists(path) then
        return true
    end

    -- Try Unix/Mac mkdir
    local success = os.execute("mkdir -p " .. path .. " 2>/dev/null")
    if success then
        return true
    end

    -- Try Windows mkdir
    success = os.execute("mkdir " .. path .. " 2>nul")
    return success
end

function FileSystem:list(directory, pattern)
    local files = {}
    pattern = pattern or "*"

    -- Try Unix/Mac ls
    local handle = io.popen("ls " .. directory .. "/" .. pattern .. " 2>/dev/null")
    if handle then
        for filename in handle:lines() do
            table.insert(files, filename)
        end
        handle:close()
    end

    -- If no files found, try Windows dir
    if #files == 0 then
        handle = io.popen("dir /b " .. directory .. "\\" .. pattern .. " 2>nul")
        if handle then
            for filename in handle:lines() do
                table.insert(files, filename)
            end
            handle:close()
        end
    end

    return files
end

-- File info
function FileSystem:size(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return 0
    end

    local size = file:seek("end")
    file:close()
    return size
end

function FileSystem:is_absolute(path)
    -- Unix absolute path starts with /
    if path:match("^/") then
        return true
    end

    -- Windows absolute path has drive letter
    if path:match("^%a:") then
        return true
    end

    -- Windows UNC path
    if path:match("^\\\\") then
        return true
    end

    return false
end

return FileSystem