-- whisker Story Validator
-- Validates story structure, detects dead links, analyzes variable usage,
-- and checks accessibility compliance for interactive stories

local Validator = {}
Validator.__index = Validator

-- Validation severity levels
Validator.Severity = {
    ERROR = "error",     -- Critical issues that prevent story from working
    WARNING = "warning", -- Issues that should be fixed
    INFO = "info"        -- Suggestions for improvement
}

-- Validation categories
Validator.Category = {
    STRUCTURE = "structure",
    LINKS = "links",
    VARIABLES = "variables",
    ACCESSIBILITY = "accessibility",
    CONTENT = "content",
    PERFORMANCE = "performance"
}

-- Create new validator instance
function Validator.new()
    local self = setmetatable({}, Validator)

    -- Validation results
    self.results = {
        errors = {},
        warnings = {},
        info = {}
    }

    -- Analysis data
    self.analysis = {
        total_passages = 0,
        total_choices = 0,
        total_variables = 0,
        unreachable_passages = {},
        dead_links = {},
        unused_variables = {},
        undefined_variables = {}
    }

    -- Configuration
    self.config = {
        check_accessibility = true,
        check_variables = true,
        check_links = true,
        check_structure = true,
        max_passage_length = 1000,
        max_choices = 10
    }

    return self
end

-- Validate a complete story
function Validator:validate_story(story)
    self:reset()

    if not story then
        self:add_result(Validator.Severity.ERROR, Validator.Category.STRUCTURE,
                       "Story object is nil", nil)
        return self:get_results()
    end

    -- Run validation checks
    self:validate_structure(story)

    if self.config.check_links then
        self:validate_links(story)
    end

    if self.config.check_variables then
        self:validate_variables(story)
    end

    if self.config.check_accessibility then
        self:validate_accessibility(story)
    end

    self:validate_content(story)

    return self:get_results()
end

-- Validate story structure
function Validator:validate_structure(story)
    -- Check for start passage
    local start_passage = story:get_start_passage()
    if not start_passage then
        self:add_result(Validator.Severity.ERROR, Validator.Category.STRUCTURE,
                       "No start passage defined", nil)
    else
        local start_exists = story:get_passage(start_passage)
        if not start_exists then
            self:add_result(Validator.Severity.ERROR, Validator.Category.STRUCTURE,
                           "Start passage '" .. start_passage .. "' does not exist", start_passage)
        end
    end

    -- Check for passages
    local passages = story:get_all_passages()
    if not passages or #passages == 0 then
        self:add_result(Validator.Severity.ERROR, Validator.Category.STRUCTURE,
                       "Story has no passages", nil)
        return
    end

    self.analysis.total_passages = #passages

    -- Check each passage structure
    for _, passage in ipairs(passages) do
        self:validate_passage_structure(passage)
    end

    -- Check for unreachable passages
    self:find_unreachable_passages(story)
end

-- Validate individual passage structure
function Validator:validate_passage_structure(passage)
    local id = passage.id or passage:get_id()

    -- Check for passage ID
    if not id or id == "" then
        self:add_result(Validator.Severity.ERROR, Validator.Category.STRUCTURE,
                       "Passage missing ID", nil)
        return
    end

    -- Check for content
    local content = passage.content or passage:get_content()
    if not content or content == "" then
        self:add_result(Validator.Severity.WARNING, Validator.Category.CONTENT,
                       "Passage '" .. id .. "' has no content", id)
    end

    -- Check content length
    if content and #content > self.config.max_passage_length then
        self:add_result(Validator.Severity.INFO, Validator.Category.CONTENT,
                       "Passage '" .. id .. "' is very long (" .. #content .. " chars)", id)
    end

    -- Check for choices
    local choices = passage.choices or passage:get_choices()
    if choices then
        self.analysis.total_choices = self.analysis.total_choices + #choices

        if #choices > self.config.max_choices then
            self:add_result(Validator.Severity.WARNING, Validator.Category.STRUCTURE,
                           "Passage '" .. id .. "' has many choices (" .. #choices .. ")", id)
        end

        -- Check if passage is a dead end (no choices)
        if #choices == 0 and not passage.is_ending then
            self:add_result(Validator.Severity.INFO, Validator.Category.STRUCTURE,
                           "Passage '" .. id .. "' has no choices (dead end)", id)
        end
    end
end

-- Validate links between passages
function Validator:validate_links(story)
    local passages = story:get_all_passages()
    local passage_ids = {}

    -- Build set of valid passage IDs
    for _, passage in ipairs(passages) do
        local id = passage.id or passage:get_id()
        passage_ids[id] = true
    end

    -- Check all choice targets
    for _, passage in ipairs(passages) do
        local id = passage.id or passage:get_id()
        local choices = passage.choices or passage:get_choices()

        if choices then
            for i, choice in ipairs(choices) do
                local target = choice.target or choice:get_target()

                if not target or target == "" then
                    self:add_result(Validator.Severity.ERROR, Validator.Category.LINKS,
                                   "Choice " .. i .. " in passage '" .. id .. "' has no target", id)
                    table.insert(self.analysis.dead_links, {
                        passage = id,
                        choice = i,
                        target = nil
                    })
                elseif not passage_ids[target] then
                    self:add_result(Validator.Severity.ERROR, Validator.Category.LINKS,
                                   "Choice " .. i .. " in passage '" .. id .. "' links to non-existent passage '" .. target .. "'", id)
                    table.insert(self.analysis.dead_links, {
                        passage = id,
                        choice = i,
                        target = target
                    })
                end
            end
        end
    end
end

-- Find unreachable passages
function Validator:find_unreachable_passages(story)
    local passages = story:get_all_passages()
    local reachable = {}
    local to_visit = {}

    -- Start from start passage
    local start_passage = story:get_start_passage()
    if start_passage then
        table.insert(to_visit, start_passage)
        reachable[start_passage] = true
    end

    -- BFS to find all reachable passages
    while #to_visit > 0 do
        local current_id = table.remove(to_visit, 1)
        local passage = story:get_passage(current_id)

        if passage then
            local choices = passage.choices or passage:get_choices()
            if choices then
                for _, choice in ipairs(choices) do
                    local target = choice.target or choice:get_target()
                    if target and not reachable[target] then
                        reachable[target] = true
                        table.insert(to_visit, target)
                    end
                end
            end
        end
    end

    -- Find unreachable passages
    for _, passage in ipairs(passages) do
        local id = passage.id or passage:get_id()
        if not reachable[id] then
            table.insert(self.analysis.unreachable_passages, id)
            self:add_result(Validator.Severity.WARNING, Validator.Category.LINKS,
                           "Passage '" .. id .. "' is unreachable from start", id)
        end
    end
end

-- Validate variable usage
function Validator:validate_variables(story)
    local passages = story:get_all_passages()
    local defined_vars = {}
    local used_vars = {}

    -- Scan all passages for variable usage
    for _, passage in ipairs(passages) do
        local content = passage.content or passage:get_content()
        if content then
            -- Find variable references {{var}}
            for var in content:gmatch("{{%s*([%w_]+)%s*}}") do
                used_vars[var] = (used_vars[var] or 0) + 1
            end

            -- Find variable assignments (simple pattern)
            for var in content:gmatch("set%s+([%w_]+)%s*=") do
                defined_vars[var] = true
            end
        end

        -- Check Lua code in choices
        local choices = passage.choices or passage:get_choices()
        if choices then
            for _, choice in ipairs(choices) do
                local condition = choice.condition or (choice.get_condition and choice:get_condition())
                if condition then
                    -- Extract variable names from conditions
                    for var in condition:gmatch("([%w_]+)") do
                        if not self:is_lua_keyword(var) then
                            used_vars[var] = (used_vars[var] or 0) + 1
                        end
                    end
                end
            end
        end
    end

    self.analysis.total_variables = 0
    for _ in pairs(defined_vars) do
        self.analysis.total_variables = self.analysis.total_variables + 1
    end

    -- Check for undefined variables
    for var, count in pairs(used_vars) do
        if not defined_vars[var] then
            table.insert(self.analysis.undefined_variables, var)
            self:add_result(Validator.Severity.WARNING, Validator.Category.VARIABLES,
                           "Variable '" .. var .. "' used but never defined (used " .. count .. " times)", nil)
        end
    end

    -- Check for unused variables
    for var in pairs(defined_vars) do
        if not used_vars[var] then
            table.insert(self.analysis.unused_variables, var)
            self:add_result(Validator.Severity.INFO, Validator.Category.VARIABLES,
                           "Variable '" .. var .. "' defined but never used", nil)
        end
    end
end

-- Validate accessibility
function Validator:validate_accessibility(story)
    local passages = story:get_all_passages()

    for _, passage in ipairs(passages) do
        local id = passage.id or passage:get_id()
        local content = passage.content or passage:get_content()

        if content then
            -- Check for very short content
            if #content < 10 then
                self:add_result(Validator.Severity.WARNING, Validator.Category.ACCESSIBILITY,
                               "Passage '" .. id .. "' has very short content", id)
            end

            -- Check for images without alt text
            if content:match("<img[^>]*>") and not content:match("<img[^>]*alt=") then
                self:add_result(Validator.Severity.WARNING, Validator.Category.ACCESSIBILITY,
                               "Passage '" .. id .. "' contains image without alt text", id)
            end

            -- Check for color-only information (basic check)
            if content:match("color:red") or content:match("color:green") then
                self:add_result(Validator.Severity.INFO, Validator.Category.ACCESSIBILITY,
                               "Passage '" .. id .. "' may rely on color for information", id)
            end
        end

        -- Check choice text
        local choices = passage.choices or passage:get_choices()
        if choices then
            for i, choice in ipairs(choices) do
                local text = choice.text or choice:get_text()
                if not text or text == "" then
                    self:add_result(Validator.Severity.ERROR, Validator.Category.ACCESSIBILITY,
                                   "Choice " .. i .. " in passage '" .. id .. "' has no text", id)
                end

                if text and #text < 2 then
                    self:add_result(Validator.Severity.WARNING, Validator.Category.ACCESSIBILITY,
                                   "Choice " .. i .. " in passage '" .. id .. "' has very short text", id)
                end
            end
        end
    end
end

-- Validate content quality
function Validator:validate_content(story)
    local passages = story:get_all_passages()

    for _, passage in ipairs(passages) do
        local id = passage.id or passage:get_id()
        local content = passage.content or passage:get_content()

        if content then
            -- Check for common typos/issues
            if content:match("TODO") or content:match("FIXME") then
                self:add_result(Validator.Severity.INFO, Validator.Category.CONTENT,
                               "Passage '" .. id .. "' contains TODO/FIXME markers", id)
            end

            -- Check for placeholder text
            if content:match("Lorem ipsum") then
                self:add_result(Validator.Severity.WARNING, Validator.Category.CONTENT,
                               "Passage '" .. id .. "' contains placeholder text", id)
            end

            -- Check for repeated words
            if content:match("(%w+)%s+%1") then
                self:add_result(Validator.Severity.INFO, Validator.Category.CONTENT,
                               "Passage '" .. id .. "' may contain repeated words", id)
            end
        end
    end
end

-- Add validation result
function Validator:add_result(severity, category, message, passage_id)
    local result = {
        severity = severity,
        category = category,
        message = message,
        passage_id = passage_id,
        timestamp = os.time()
    }

    if severity == Validator.Severity.ERROR then
        table.insert(self.results.errors, result)
    elseif severity == Validator.Severity.WARNING then
        table.insert(self.results.warnings, result)
    else
        table.insert(self.results.info, result)
    end
end

-- Get validation results
function Validator:get_results()
    return {
        errors = self.results.errors,
        warnings = self.results.warnings,
        info = self.results.info,
        analysis = self.analysis,
        summary = self:get_summary()
    }
end

-- Get validation summary
function Validator:get_summary()
    return {
        total_issues = #self.results.errors + #self.results.warnings + #self.results.info,
        error_count = #self.results.errors,
        warning_count = #self.results.warnings,
        info_count = #self.results.info,
        total_passages = self.analysis.total_passages,
        total_choices = self.analysis.total_choices,
        unreachable_passages = #self.analysis.unreachable_passages,
        dead_links = #self.analysis.dead_links,
        undefined_variables = #self.analysis.undefined_variables,
        is_valid = #self.results.errors == 0
    }
end

-- Generate validation report
function Validator:generate_report(format)
    format = format or "text"

    if format == "text" then
        return self:generate_text_report()
    elseif format == "json" then
        return self:get_results()
    end

    return nil
end

-- Generate text report
function Validator:generate_text_report()
    local lines = {
        "=== Story Validation Report ===",
        ""
    }

    local summary = self:get_summary()

    -- Summary
    table.insert(lines, "Summary:")
    table.insert(lines, "  Total Passages: " .. summary.total_passages)
    table.insert(lines, "  Total Choices: " .. summary.total_choices)
    table.insert(lines, "  Total Issues: " .. summary.total_issues)
    table.insert(lines, "    Errors: " .. summary.error_count)
    table.insert(lines, "    Warnings: " .. summary.warning_count)
    table.insert(lines, "    Info: " .. summary.info_count)
    table.insert(lines, "  Valid: " .. tostring(summary.is_valid))
    table.insert(lines, "")

    -- Errors
    if #self.results.errors > 0 then
        table.insert(lines, "ERRORS:")
        for _, result in ipairs(self.results.errors) do
            local location = result.passage_id and (" [" .. result.passage_id .. "]") or ""
            table.insert(lines, "  [" .. result.category .. "]" .. location .. " " .. result.message)
        end
        table.insert(lines, "")
    end

    -- Warnings
    if #self.results.warnings > 0 then
        table.insert(lines, "WARNINGS:")
        for i, result in ipairs(self.results.warnings) do
            if i <= 10 then -- Limit to 10 warnings
                local location = result.passage_id and (" [" .. result.passage_id .. "]") or ""
                table.insert(lines, "  [" .. result.category .. "]" .. location .. " " .. result.message)
            end
        end
        if #self.results.warnings > 10 then
            table.insert(lines, "  ... and " .. (#self.results.warnings - 10) .. " more warnings")
        end
        table.insert(lines, "")
    end

    -- Info
    if #self.results.info > 0 then
        table.insert(lines, "INFO:")
        for i, result in ipairs(self.results.info) do
            if i <= 5 then -- Limit to 5 info items
                local location = result.passage_id and (" [" .. result.passage_id .. "]") or ""
                table.insert(lines, "  [" .. result.category .. "]" .. location .. " " .. result.message)
            end
        end
        if #self.results.info > 5 then
            table.insert(lines, "  ... and " .. (#self.results.info - 5) .. " more items")
        end
        table.insert(lines, "")
    end

    -- Analysis details
    if #self.analysis.unreachable_passages > 0 then
        table.insert(lines, "Unreachable Passages:")
        for i, id in ipairs(self.analysis.unreachable_passages) do
            if i <= 10 then
                table.insert(lines, "  - " .. id)
            end
        end
        if #self.analysis.unreachable_passages > 10 then
            table.insert(lines, "  ... and " .. (#self.analysis.unreachable_passages - 10) .. " more")
        end
        table.insert(lines, "")
    end

    return table.concat(lines, "\n")
end

-- Utility functions
function Validator:is_lua_keyword(word)
    local keywords = {
        ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
        ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
        ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
        ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
        ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
        ["while"] = true
    }
    return keywords[word] == true
end

-- Reset validator state
function Validator:reset()
    self.results = {
        errors = {},
        warnings = {},
        info = {}
    }

    self.analysis = {
        total_passages = 0,
        total_choices = 0,
        total_variables = 0,
        unreachable_passages = {},
        dead_links = {},
        unused_variables = {},
        undefined_variables = {}
    }
end

-- Quick validation (returns boolean and error count)
function Validator:quick_validate(story)
    local results = self:validate_story(story)
    return #results.errors == 0, #results.errors
end

-- Get issues by category
function Validator:get_issues_by_category(category)
    local issues = {}

    for _, result in ipairs(self.results.errors) do
        if result.category == category then
            table.insert(issues, result)
        end
    end

    for _, result in ipairs(self.results.warnings) do
        if result.category == category then
            table.insert(issues, result)
        end
    end

    for _, result in ipairs(self.results.info) do
        if result.category == category then
            table.insert(issues, result)
        end
    end

    return issues
end

-- Get issues by passage
function Validator:get_issues_by_passage(passage_id)
    local issues = {}

    for _, result in ipairs(self.results.errors) do
        if result.passage_id == passage_id then
            table.insert(issues, result)
        end
    end

    for _, result in ipairs(self.results.warnings) do
        if result.passage_id == passage_id then
            table.insert(issues, result)
        end
    end

    for _, result in ipairs(self.results.info) do
        if result.passage_id == passage_id then
            table.insert(issues, result)
        end
    end

    return issues
end

return Validator