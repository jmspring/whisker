-- whisker/src/editor/validation/validator.lua
-- Story Validation Module

local Validator = {}

function Validator.new(project)
    return {
        project = project,
        errors = {},
        warnings = {}
    }
end

function Validator:validate()
    self.errors = {}
    self.warnings = {}

    self:checkMetadata()
    self:checkPassages()
    self:checkVariables()
    self:checkConnections()
    self:checkOrphans()
    self:checkDeadEnds()

    return {
        valid = #self.errors == 0,
        errors = self.errors,
        warnings = self.warnings
    }
end

function Validator:checkMetadata()
    if not self.project.metadata.title or self.project.metadata.title == "" then
        table.insert(self.warnings, {
            type = "metadata",
            message = "Story has no title"
        })
    end

    if not self.project.metadata.author or self.project.metadata.author == "" then
        table.insert(self.warnings, {
            type = "metadata",
            message = "Story has no author"
        })
    end
end

function Validator:checkPassages()
    if #self.project.passages == 0 then
        table.insert(self.errors, {
            type = "passages",
            message = "Story has no passages"
        })
        return
    end

    if not self.project.startPassage then
        table.insert(self.errors, {
            type = "passages",
            message = "Story has no start passage defined"
        })
    end

    -- Check for duplicate titles
    local titles = {}
    for _, passage in ipairs(self.project.passages) do
        if titles[passage.title] then
            table.insert(self.warnings, {
                type = "passages",
                passage = passage.id,
                message = "Duplicate passage title: " .. passage.title
            })
        end
        titles[passage.title] = true

        -- Check for empty content
        if not passage.content or passage.content == "" then
            table.insert(self.warnings, {
                type = "passages",
                passage = passage.id,
                message = "Passage '" .. passage.title .. "' has no content"
            })
        end
    end
end

function Validator:checkVariables()
    -- Check for unused variables
    local usedVars = {}

    for _, passage in ipairs(self.project.passages) do
        -- Check in content
        if passage.content then
            for varName in passage.content:gmatch("%$(%w+)") do
                usedVars[varName] = true
            end
        end

        -- Check in scripts
        if passage.script then
            for varName in passage.script:gmatch("%$(%w+)") do
                usedVars[varName] = true
            end
        end

        -- Check in choice conditions
        for _, choice in ipairs(passage.choices) do
            if choice.condition then
                for varName in choice.condition:gmatch("%$(%w+)") do
                    usedVars[varName] = true
                end
            end
        end
    end

    for varName in pairs(self.project.variables) do
        if not usedVars[varName] then
            table.insert(self.warnings, {
                type = "variables",
                message = "Variable '$" .. varName .. "' is defined but never used"
            })
        end
    end
end

function Validator:checkConnections()
    for _, passage in ipairs(self.project.passages) do
        for choiceIdx, choice in ipairs(passage.choices) do
            if not choice.target or choice.target == "" then
                table.insert(self.warnings, {
                    type = "connections",
                    passage = passage.id,
                    message = "Choice " .. choiceIdx .. " in '" .. passage.title .. "' has no target"
                })
            else
                -- Check if target exists
                local targetExists = false
                for _, p in ipairs(self.project.passages) do
                    if p.id == choice.target then
                        targetExists = true
                        break
                    end
                end

                if not targetExists then
                    table.insert(self.errors, {
                        type = "connections",
                        passage = passage.id,
                        message = "Choice in '" .. passage.title .. "' links to non-existent passage: " .. choice.target
                    })
                end
            end
        end
    end
end

function Validator:checkOrphans()
    local reachable = {}
    local toVisit = {self.project.startPassage}

    while #toVisit > 0 do
        local current = table.remove(toVisit)
        if current and not reachable[current] then
            reachable[current] = true

            local passage = self.project:getPassage(current)
            if passage then
                for _, choice in ipairs(passage.choices) do
                    if choice.target and choice.target ~= "" then
                        table.insert(toVisit, choice.target)
                    end
                end
            end
        end
    end

    for _, passage in ipairs(self.project.passages) do
        if passage.id ~= self.project.startPassage and not reachable[passage.id] then
            table.insert(self.warnings, {
                type = "flow",
                passage = passage.id,
                message = "Passage '" .. passage.title .. "' is unreachable from start"
            })
        end
    end
end

function Validator:checkDeadEnds()
    for _, passage in ipairs(self.project.passages) do
        if #passage.choices == 0 then
            table.insert(self.warnings, {
                type = "flow",
                passage = passage.id,
                message = "Passage '" .. passage.title .. "' has no choices (dead end)"
            })
        end
    end
end

return Validator