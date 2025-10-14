-- src/platform/file_storage.lua
-- Platform-specific file storage (Love2D, standard Lua, web)

local FileStorage = {}
FileStorage.__index = FileStorage

function FileStorage.new(base_directory)
    local instance = {
        base_directory = base_directory or "",
        platform = nil,
        file_ops = {},
        path_separator = package.config:sub(1, 1)
    }

    setmetatable(instance, FileStorage)
    instance:detect_platform()

    -- Ensure base directory exists
    if instance.base_directory ~= "" then
        instance:ensure_directory(instance.base_directory)
    end

    return instance
end

function FileStorage:detect_platform()
    -- Detect Love2D
    if love and love.filesystem then
        self.platform = "love2d"
        self:init_love2d()
    -- Detect web/Fengari
    elseif js and js.global then
        self.platform = "web"
        self:init_web()
    -- Standard Lua
    else
        self.platform = "standard"
        self:init_standard()
    end
end

-- Love2D implementation
function FileStorage:init_love2d()
    self.file_ops = {
        read = function(path)
            local content, size = love.filesystem.read(path)
            if content then
                return content, nil
            else
                return nil, "File not found"
            end
        end,

        write = function(path, content)
            local success, err = love.filesystem.write(path, content)
            if success then
                return true, nil
            else
                return false, err or "Write failed"
            end
        end,

        exists = function(path)
            local info = love.filesystem.getInfo(path)
            return info ~= nil
        end,

        mkdir = function(path)
            return love.filesystem.createDirectory(path)
        end,

        list = function(path)
            if not love.filesystem.getInfo(path, "directory") then
                return {}, "Not a directory"
            end
            return love.filesystem.getDirectoryItems(path) or {}, nil
        end,

        delete = function(path)
            return love.filesystem.remove(path)
        end,

        size = function(path)
            local info = love.filesystem.getInfo(path)
            return info and info.size or 0
        end
    }
end

-- Web/localStorage implementation
function FileStorage:init_web()
    self.file_ops = {
        read = function(path)
            if window and window.localStorage then
                local content = localStorage:getItem("whisker_" .. path)
                if content then
                    return content, nil
                end
            end
            return nil, "File not found"
        end,

        write = function(path, content)
            if window and window.localStorage then
                localStorage:setItem("whisker_" .. path, content)
                return true, nil
            end
            return false, "localStorage not available"
        end,

        exists = function(path)
            if window and window.localStorage then
                return localStorage:getItem("whisker_" .. path) ~= nil
            end
            return false
        end,

        mkdir = function(path)
            -- No-op for web storage
            return true
        end,

        list = function(path)
            local files = {}
            if window and window.localStorage then
                local prefix = "whisker_" .. path .. "/"
                for i = 0, localStorage.length - 1 do
                    local key = localStorage:key(i)
                    if key:sub(1, #prefix) == prefix then
                        local filename = key:sub(#prefix + 1)
                        table.insert(files, filename)
                    end
                end
            end
            return files, nil
        end,

        delete = function(path)
            if window and window.localStorage then
                localStorage:removeItem("whisker_" .. path)
                return true
            end
            return false
        end,

        size = function(path)
            if window and window.localStorage then
                local content = localStorage:getItem("whisker_" .. path)
                return content and #content or 0
            end
            return 0
        end
    }
end

-- Standard Lua implementation
function FileStorage:init_standard()
    self.file_ops = {
        read = function(path)
            local full_path = self:resolve_path(path)
            local file, err = io.open(full_path, "r")
            if not file then
                return nil, err
            end

            local content = file:read("*all")
            file:close()
            return content, nil
        end,

        write = function(path, content)
            local full_path = self:resolve_path(path)

            -- Ensure directory exists
            local dir = full_path:match("(.+)[/\\][^/\\]+$")
            if dir then
                self:ensure_directory(dir)
            end

            local file, err = io.open(full_path, "w")
            if not file then
                return false, err
            end

            file:write(content)
            file:close()
            return true, nil
        end,

        exists = function(path)
            local full_path = self:resolve_path(path)
            local file = io.open(full_path, "r")
            if file then
                file:close()
                return true
            end
            return false
        end,

        mkdir = function(path)
            local full_path = self:resolve_path(path)
            -- Try Unix/Mac
            local success = os.execute("mkdir -p " .. full_path .. " 2>/dev/null")
            if not success then
                -- Try Windows
                success = os.execute("mkdir " .. full_path .. " 2>nul")
            end
            return success
        end,

        list = function(path)
            local full_path = self:resolve_path(path)
            local files = {}

            -- Try Unix/Mac ls
            local handle = io.popen("ls " .. full_path .. " 2>/dev/null")
            if handle then
                for filename in handle:lines() do
                    table.insert(files, filename)
                end
                handle:close()
            end

            return files, nil
        end,

        delete = function(path)
            local full_path = self:resolve_path(path)
            return os.remove(full_path)
        end,

        size = function(path)
            local full_path = self:resolve_path(path)
            local file = io.open(full_path, "r")
            if not file then
                return 0
            end

            local size = file:seek("end")
            file:close()
            return size
        end
    }
end

-- Public API
function FileStorage:read_file(path)
    return self.file_ops.read(path)
end

function FileStorage:write_file(path, content)
    return self.file_ops.write(path, content)
end

function FileStorage:file_exists(path)
    return self.file_ops.exists(path)
end

function FileStorage:ensure_directory(path)
    return self.file_ops.mkdir(path)
end

function FileStorage:list_files(path)
    return self.file_ops.list(path)
end

function FileStorage:delete_file(path)
    return self.file_ops.delete(path)
end

function FileStorage:get_file_size(path)
    return self.file_ops.size(path)
end

-- Helper functions
function FileStorage:resolve_path(path)
    if self.base_directory == "" then
        return path
    end

    return self.base_directory .. self.path_separator .. path
end

function FileStorage:get_platform()
    return self.platform
end

return FileStorage
