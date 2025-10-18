-- whisker Asset Manager
-- Handles loading and caching of multimedia assets (images, audio, video)
-- Supports multiple platforms (web, desktop, mobile)

local AssetManager = {}
AssetManager.__index = AssetManager

-- Asset types
AssetManager.AssetType = {
    IMAGE = "image",
    AUDIO = "audio",
    VIDEO = "video",
    FONT = "font",
    DATA = "data"
}

-- Asset status
local AssetStatus = {
    UNLOADED = "unloaded",
    LOADING = "loading",
    LOADED = "loaded",
    FAILED = "failed"
}

-- Create new asset manager instance
function AssetManager.new(config)
    local self = setmetatable({}, AssetManager)

    config = config or {}

    -- Configuration
    self.base_path = config.base_path or "assets/"
    self.max_cache_size = config.max_cache_size or 50 * 1024 * 1024 -- 50MB default
    self.preload_audio = config.preload_audio or false
    self.enable_compression = config.enable_compression or true

    -- Asset storage
    self.assets = {}  -- Loaded assets
    self.cache = {}   -- Asset cache with metadata
    self.loading = {} -- Currently loading assets

    -- Statistics
    self.stats = {
        total_loaded = 0,
        total_size = 0,
        failed_loads = 0,
        cache_hits = 0,
        cache_misses = 0
    }

    -- Platform detection
    self.platform = self:detect_platform()

    -- Supported formats by platform
    self.supported_formats = {
        image = {"png", "jpg", "jpeg", "gif", "webp", "svg"},
        audio = {"mp3", "ogg", "wav", "m4a"},
        video = {"mp4", "webm", "ogg"}
    }

    return self
end

-- Detect current platform
function AssetManager:detect_platform()
    -- Check for web environment
    if type(_G.js) ~= "nil" then
        return "web"
    end

    -- Check for LÖVE framework
    if type(love) ~= "nil" then
        return "love2d"
    end

    -- Default to generic Lua
    return "lua"
end

-- Load an asset
function AssetManager:load(asset_path, asset_type, options)
    options = options or {}

    -- Normalize path
    local full_path = self:normalize_path(asset_path)

    -- Check cache first
    if self.cache[full_path] and self.cache[full_path].status == AssetStatus.LOADED then
        self.stats.cache_hits = self.stats.cache_hits + 1
        return self.assets[full_path], nil
    end

    self.stats.cache_misses = self.stats.cache_misses + 1

    -- Check if already loading
    if self.loading[full_path] then
        return nil, "Asset is currently loading"
    end

    -- Validate asset type
    asset_type = asset_type or self:detect_type(full_path)
    if not asset_type then
        return nil, "Unable to detect asset type"
    end

    -- Mark as loading
    self.loading[full_path] = true
    self.cache[full_path] = {
        path = full_path,
        type = asset_type,
        status = AssetStatus.LOADING,
        loaded_at = os.time()
    }

    -- Platform-specific loading
    local asset, err = self:platform_load(full_path, asset_type, options)

    -- Update status
    self.loading[full_path] = nil

    if asset then
        -- Store asset
        self.assets[full_path] = asset

        -- Update cache metadata
        local size = self:get_asset_size(asset, asset_type)
        self.cache[full_path].status = AssetStatus.LOADED
        self.cache[full_path].size = size

        -- Update statistics
        self.stats.total_loaded = self.stats.total_loaded + 1
        self.stats.total_size = self.stats.total_size + size

        -- Enforce cache limits
        self:enforce_cache_limits()

        return asset, nil
    else
        -- Mark as failed
        self.cache[full_path].status = AssetStatus.FAILED
        self.cache[full_path].error = err
        self.stats.failed_loads = self.stats.failed_loads + 1

        return nil, err
    end
end

-- Platform-specific asset loading
function AssetManager:platform_load(path, asset_type, options)
    if self.platform == "web" then
        return self:web_load(path, asset_type, options)
    elseif self.platform == "love2d" then
        return self:love2d_load(path, asset_type, options)
    else
        return self:generic_load(path, asset_type, options)
    end
end

-- Web platform loading
function AssetManager:web_load(path, asset_type, options)
    if asset_type == AssetManager.AssetType.IMAGE then
        -- Create image element
        local img = _G.document:createElement("img")
        img.src = path

        -- Wait for load (synchronous for now)
        -- In real implementation, this would be async with callbacks
        return img, nil

    elseif asset_type == AssetManager.AssetType.AUDIO then
        -- Create audio element
        local audio = _G.document:createElement("audio")
        audio.src = path

        if self.preload_audio then
            audio:load()
        end

        return audio, nil

    elseif asset_type == AssetManager.AssetType.VIDEO then
        -- Create video element
        local video = _G.document:createElement("video")
        video.src = path

        return video, nil

    else
        return nil, "Unsupported asset type for web: " .. asset_type
    end
end

-- LÖVE2D platform loading
function AssetManager:love2d_load(path, asset_type, options)
    local success, result = pcall(function()
        if asset_type == AssetManager.AssetType.IMAGE then
            return love.graphics.newImage(path)

        elseif asset_type == AssetManager.AssetType.AUDIO then
            local source_type = options.stream and "stream" or "static"
            return love.audio.newSource(path, source_type)

        elseif asset_type == AssetManager.AssetType.FONT then
            local size = options.size or 14
            return love.graphics.newFont(path, size)

        else
            error("Unsupported asset type for LÖVE2D: " .. asset_type)
        end
    end)

    if success then
        return result, nil
    else
        return nil, tostring(result)
    end
end

-- Generic Lua loading (file reading)
function AssetManager:generic_load(path, asset_type, options)
    local file, err = io.open(path, "rb")

    if not file then
        return nil, "Failed to open file: " .. tostring(err)
    end

    local content = file:read("*all")
    file:close()

    if not content then
        return nil, "Failed to read file content"
    end

    -- Return raw data
    return {
        path = path,
        type = asset_type,
        data = content,
        size = #content
    }, nil
end

-- Preload multiple assets
function AssetManager:preload(asset_list, callback)
    local results = {}
    local total = #asset_list
    local loaded = 0
    local failed = 0

    for i, asset_info in ipairs(asset_list) do
        local path = asset_info.path or asset_info[1]
        local asset_type = asset_info.type or asset_info[2]
        local options = asset_info.options or {}

        local asset, err = self:load(path, asset_type, options)

        table.insert(results, {
            path = path,
            success = asset ~= nil,
            asset = asset,
            error = err
        })

        if asset then
            loaded = loaded + 1
        else
            failed = failed + 1
        end

        -- Progress callback
        if callback then
            callback(i, total, loaded, failed)
        end
    end

    return results
end

-- Unload an asset
function AssetManager:unload(asset_path)
    local full_path = self:normalize_path(asset_path)

    if not self.cache[full_path] then
        return false
    end

    local cache_entry = self.cache[full_path]

    -- Update statistics
    if cache_entry.size then
        self.stats.total_size = self.stats.total_size - cache_entry.size
    end

    -- Remove from cache
    self.assets[full_path] = nil
    self.cache[full_path] = nil

    return true
end

-- Clear all cached assets
function AssetManager:clear_cache()
    self.assets = {}
    self.cache = {}
    self.loading = {}

    self.stats.total_size = 0
    self.stats.cache_hits = 0
    self.stats.cache_misses = 0
end

-- Normalize asset path
function AssetManager:normalize_path(path)
    -- Remove leading/trailing whitespace
    path = path:match("^%s*(.-)%s*$")

    -- Add base path if relative
    if not path:match("^/") and not path:match("^%a:") and not path:match("^https?://") then
        path = self.base_path .. path
    end

    return path
end

-- Detect asset type from file extension
function AssetManager:detect_type(path)
    local ext = path:match("%.([^%.]+)$")
    if not ext then
        return nil
    end

    ext = ext:lower()

    for asset_type, formats in pairs(self.supported_formats) do
        for _, format in ipairs(formats) do
            if ext == format then
                return asset_type
            end
        end
    end

    return AssetManager.AssetType.DATA
end

-- Get asset size (estimated)
function AssetManager:get_asset_size(asset, asset_type)
    if type(asset) == "table" and asset.size then
        return asset.size
    end

    if type(asset) == "string" then
        return #asset
    end

    -- Rough estimates for different asset types
    if asset_type == AssetManager.AssetType.IMAGE then
        return 1024 * 100 -- 100KB estimate
    elseif asset_type == AssetManager.AssetType.AUDIO then
        return 1024 * 1024 -- 1MB estimate
    end

    return 0
end

-- Enforce cache size limits
function AssetManager:enforce_cache_limits()
    if self.stats.total_size <= self.max_cache_size then
        return
    end

    -- Build list of cached assets sorted by last access time
    local cached_assets = {}
    for path, cache_entry in pairs(self.cache) do
        if cache_entry.status == AssetStatus.LOADED then
            table.insert(cached_assets, {
                path = path,
                loaded_at = cache_entry.loaded_at or 0,
                size = cache_entry.size or 0
            })
        end
    end

    -- Sort by oldest first
    table.sort(cached_assets, function(a, b)
        return a.loaded_at < b.loaded_at
    end)

    -- Remove oldest assets until under limit
    for _, asset_info in ipairs(cached_assets) do
        if self.stats.total_size <= self.max_cache_size then
            break
        end

        self:unload(asset_info.path)
    end
end

-- Get statistics
function AssetManager:get_stats()
    return {
        total_loaded = self.stats.total_loaded,
        total_size = self.stats.total_size,
        failed_loads = self.stats.failed_loads,
        cache_hits = self.stats.cache_hits,
        cache_misses = self.stats.cache_misses,
        cache_size_mb = self.stats.total_size / (1024 * 1024)
    }
end

-- List all loaded assets
function AssetManager:list_assets(asset_type)
    local list = {}

    for path, cache_entry in pairs(self.cache) do
        if cache_entry.status == AssetStatus.LOADED then
            if not asset_type or cache_entry.type == asset_type then
                table.insert(list, {
                    path = path,
                    type = cache_entry.type,
                    size = cache_entry.size,
                    loaded_at = cache_entry.loaded_at
                })
            end
        end
    end

    return list
end

-- Check if asset is loaded
function AssetManager:is_loaded(asset_path)
    local full_path = self:normalize_path(asset_path)
    return self.cache[full_path] and self.cache[full_path].status == AssetStatus.LOADED
end

-- Get loaded asset
function AssetManager:get(asset_path)
    local full_path = self:normalize_path(asset_path)
    return self.assets[full_path]
end

return AssetManager