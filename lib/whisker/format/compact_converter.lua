-- Compact Converter
-- Converts between verbose (1.0) and compact (2.0) Whisker formats
-- Provides significant file size reduction while maintaining full compatibility

local CompactConverter = {}

-- Format version constants
CompactConverter.VERSION_VERBOSE = "1.0"
CompactConverter.VERSION_COMPACT = "2.0"

-- Default values
local DEFAULTS = {
    position = {x = 0, y = 0},
    size = {width = 100, height = 100}
}

-- Create new converter instance
function CompactConverter.new()
    local self = setmetatable({}, {__index = CompactConverter})
    return self
end

--------------------------------------------------------------------------------
-- COMPACT CONVERSION (1.0 → 2.0)
--------------------------------------------------------------------------------

-- Convert verbose 1.0 format to compact 2.0 format
function CompactConverter:to_compact(doc)
    if not doc then
        return nil, "Document is nil"
    end

    -- Detect if already compact
    if doc.formatVersion == CompactConverter.VERSION_COMPACT then
        return doc, nil  -- Already compact
    end

    local compact = {
        format = "whisker",
        formatVersion = CompactConverter.VERSION_COMPACT,
        metadata = self:compact_metadata(doc.metadata),
        passages = {},
        settings = doc.settings
    }

    -- Only include non-empty arrays
    if doc.assets and #doc.assets > 0 then
        compact.assets = doc.assets
    end

    if doc.scripts and #doc.scripts > 0 then
        compact.scripts = doc.scripts
    end

    if doc.stylesheets and #doc.stylesheets > 0 then
        compact.stylesheets = doc.stylesheets
    end

    if doc.variables and #doc.variables > 0 then
        compact.variables = doc.variables
    end

    -- Compact passages
    for _, passage in ipairs(doc.passages or {}) do
        table.insert(compact.passages, self:compact_passage(passage))
    end

    return compact, nil
end

-- Compact metadata (remove duplicates and empty fields)
function CompactConverter:compact_metadata(metadata)
    if not metadata then
        return {}
    end

    local compact = {}

    -- Core required fields
    if metadata.title then
        compact.title = metadata.title
    end

    if metadata.ifid then
        compact.ifid = metadata.ifid
    end

    -- Optional fields (only if present and non-empty)
    if metadata.author and metadata.author ~= "" then
        compact.author = metadata.author
    end

    if metadata.created and metadata.created ~= "" then
        compact.created = metadata.created
    end

    if metadata.modified and metadata.modified ~= "" then
        compact.modified = metadata.modified
    end

    if metadata.description and metadata.description ~= "" then
        compact.description = metadata.description
    end

    -- Only include version if not default "1.0"
    if metadata.version and metadata.version ~= "1.0" then
        compact.version = metadata.version
    end

    -- Don't include duplicate format/format_version/name fields
    -- These are at root level already

    return compact
end

-- Compact a single passage
function CompactConverter:compact_passage(passage)
    if not passage then
        return nil
    end

    local compact = {
        id = passage.id,
        name = passage.name,
        pid = passage.pid,
        text = passage.text or passage.content  -- Use text, eliminate content duplicate
    }

    -- Only include choices if non-empty
    if passage.choices and #passage.choices > 0 then
        compact.choices = {}
        for _, choice in ipairs(passage.choices) do
            table.insert(compact.choices, self:compact_choice(choice))
        end
    end

    -- Only include tags if non-empty
    if passage.tags and #passage.tags > 0 then
        compact.tags = passage.tags
    end

    -- Only include position if non-default (not 0,0)
    if passage.position then
        if passage.position.x ~= 0 or passage.position.y ~= 0 then
            compact.position = passage.position
        end
    end

    -- Only include size if non-default (not 100x100)
    if passage.size then
        if passage.size.width ~= 100 or passage.size.height ~= 100 then
            compact.size = passage.size
        end
    end

    -- Only include metadata if non-empty
    if passage.metadata and #passage.metadata > 0 then
        compact.metadata = passage.metadata
    end

    return compact
end

-- Compact a choice (shorten field names, remove empty metadata)
function CompactConverter:compact_choice(choice)
    if not choice then
        return nil
    end

    local compact = {
        target = choice.target_passage or choice.target,  -- Handle both field names
        text = choice.text
    }

    -- Only include metadata if non-empty
    if choice.metadata and #choice.metadata > 0 then
        compact.metadata = choice.metadata
    end

    -- Include condition if present
    if choice.condition then
        compact.condition = choice.condition
    end

    return compact
end

--------------------------------------------------------------------------------
-- VERBOSE CONVERSION (2.0 → 1.0)
--------------------------------------------------------------------------------

-- Convert compact 2.0 format to verbose 1.0 format
function CompactConverter:to_verbose(doc)
    if not doc then
        return nil, "Document is nil"
    end

    -- Detect if already verbose
    if doc.formatVersion == CompactConverter.VERSION_VERBOSE or not doc.formatVersion then
        return doc, nil  -- Already verbose or legacy format
    end

    local verbose = {
        format = "whisker",
        formatVersion = CompactConverter.VERSION_VERBOSE,
        metadata = self:expand_metadata(doc.metadata),
        assets = doc.assets or {},
        scripts = doc.scripts or {},
        stylesheets = doc.stylesheets or {},
        variables = doc.variables or {},
        passages = {},
        settings = doc.settings or {
            autoSave = true,
            scriptingLanguage = "lua",
            startPassage = "start",
            theme = "default",
            undoLimit = 50
        }
    }

    -- Expand passages
    for _, passage in ipairs(doc.passages or {}) do
        table.insert(verbose.passages, self:expand_passage(passage))
    end

    return verbose, nil
end

-- Expand metadata (restore duplicate fields for 1.0 compatibility)
function CompactConverter:expand_metadata(metadata)
    if not metadata then
        return {
            title = "Untitled Story",
            ifid = "WHISKER-" .. tostring(os.time()),
            format = "whisker",
            format_version = "1.0",
            name = "Untitled Story",
            author = "",
            created = "",
            modified = "",
            description = "",
            version = "1.0"
        }
    end

    local expanded = {}

    -- Copy all fields from compact metadata
    for key, value in pairs(metadata) do
        expanded[key] = value
    end

    -- Add duplicate fields for 1.0 compatibility
    expanded.format = "whisker"
    expanded.format_version = metadata.version or "1.0"
    expanded.name = metadata.title or "Untitled Story"

    -- Ensure required fields exist with defaults
    expanded.title = expanded.title or "Untitled Story"
    expanded.ifid = expanded.ifid or "WHISKER-" .. tostring(os.time())
    expanded.author = expanded.author or ""
    expanded.created = expanded.created or ""
    expanded.modified = expanded.modified or ""
    expanded.description = expanded.description or ""
    expanded.version = expanded.version or "1.0"

    return expanded
end

-- Expand a compact passage to verbose format
function CompactConverter:expand_passage(passage)
    if not passage then
        return nil
    end

    local verbose = {
        id = passage.id,
        name = passage.name,
        pid = passage.pid,
        content = passage.text,  -- Duplicate for 1.0 compatibility
        text = passage.text,
        metadata = passage.metadata or {},
        tags = passage.tags or {},
        position = passage.position or {x = DEFAULTS.position.x, y = DEFAULTS.position.y},
        size = passage.size or {width = DEFAULTS.size.width, height = DEFAULTS.size.height}
    }

    -- Expand choices
    if passage.choices and #passage.choices > 0 then
        verbose.choices = {}
        for _, choice in ipairs(passage.choices) do
            table.insert(verbose.choices, self:expand_choice(choice))
        end
    else
        verbose.choices = {}
    end

    return verbose
end

-- Expand a choice to verbose format
function CompactConverter:expand_choice(choice)
    if not choice then
        return nil
    end

    local verbose = {
        text = choice.text,
        target_passage = choice.target or choice.target_passage,  -- Handle both
        metadata = choice.metadata or {}
    }

    -- Include condition if present
    if choice.condition then
        verbose.condition = choice.condition
    end

    return verbose
end

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

-- Calculate size savings of compact format
function CompactConverter:calculate_savings(verbose_doc, compact_doc, json_encoder)
    if not json_encoder then
        json_encoder = require("whisker.utils.json")
    end

    local verbose_json = json_encoder.encode(verbose_doc)
    local compact_json = json_encoder.encode(compact_doc)

    local verbose_size = #verbose_json
    local compact_size = #compact_json
    local savings = verbose_size - compact_size
    local percentage = math.floor((savings / verbose_size) * 100)

    return {
        verbose_size = verbose_size,
        compact_size = compact_size,
        savings_bytes = savings,
        savings_percent = percentage
    }
end

-- Validate that round-trip conversion preserves data
function CompactConverter:validate_round_trip(original_doc)
    -- Convert to compact and back
    local compact, err = self:to_compact(original_doc)
    if err then
        return false, "Failed to convert to compact: " .. err
    end

    local restored, err = self:to_verbose(compact)
    if err then
        return false, "Failed to convert back to verbose: " .. err
    end

    -- Check critical fields are preserved
    if #original_doc.passages ~= #restored.passages then
        return false, "Passage count mismatch"
    end

    for i, orig_passage in ipairs(original_doc.passages) do
        local rest_passage = restored.passages[i]

        if orig_passage.id ~= rest_passage.id then
            return false, string.format("Passage %d: ID mismatch", i)
        end

        if orig_passage.name ~= rest_passage.name then
            return false, string.format("Passage %d: Name mismatch", i)
        end

        -- Compare text (handle both text and content fields)
        local orig_text = orig_passage.text or orig_passage.content
        local rest_text = rest_passage.text or rest_passage.content
        if orig_text ~= rest_text then
            return false, string.format("Passage %d: Text mismatch", i)
        end

        -- Check choices count
        local orig_choices = orig_passage.choices or {}
        local rest_choices = rest_passage.choices or {}
        if #orig_choices ~= #rest_choices then
            return false, string.format("Passage %d: Choice count mismatch", i)
        end
    end

    return true, nil
end

-- Get format version from document
function CompactConverter:get_format_version(doc)
    if not doc then
        return nil
    end
    return doc.formatVersion or CompactConverter.VERSION_VERBOSE
end

-- Check if document is in compact format
function CompactConverter:is_compact(doc)
    return self:get_format_version(doc) == CompactConverter.VERSION_COMPACT
end

-- Check if document is in verbose format
function CompactConverter:is_verbose(doc)
    local version = self:get_format_version(doc)
    return version == CompactConverter.VERSION_VERBOSE or version == nil
end

return CompactConverter
