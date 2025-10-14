-- whisker/src/editor/core/project.lua
-- Project Management Module

local Project = {}
Project.__index = Project

function Project.new()
    local instance = {
        metadata = {
            title = "Untitled Story",
            author = "",
            version = "1.0.0",
            created = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            modified = os.date("!%Y-%m-%dT%H:%M:%SZ")
        },
        variables = {},
        passages = {},
        startPassage = nil,
        settings = {
            theme = "default",
            autoSave = true,
            debugMode = false
        }
    }
    setmetatable(instance, self)
    return instance
end

function Project:setMetadata(key, value)
    if self.metadata[key] ~= nil then
        self.metadata[key] = value
        self:touch()
    end
end

function Project:addVariable(name, varType, initialValue)
    self.variables[name] = {
        type = varType or "number",
        initial = initialValue or 0,
        description = ""
    }
    self:touch()
end

function Project:removeVariable(name)
    self.variables[name] = nil
    self:touch()
end

function Project:addPassage(passage)
    table.insert(self.passages, passage)
    if not self.startPassage then
        self.startPassage = passage.id
    end
    self:touch()
end

function Project:removePassage(passageId)
    for i, passage in ipairs(self.passages) do
        if passage.id == passageId then
            table.remove(self.passages, i)
            break
        end
    end

    -- Clean up references
    for _, passage in ipairs(self.passages) do
        local newChoices = {}
        for _, choice in ipairs(passage.choices) do
            if choice.target ~= passageId then
                table.insert(newChoices, choice)
            end
        end
        passage.choices = newChoices
    end

    if self.startPassage == passageId and #self.passages > 0 then
        self.startPassage = self.passages[1].id
    end

    self:touch()
end

function Project:getPassage(passageId)
    for _, passage in ipairs(self.passages) do
        if passage.id == passageId then
            return passage
        end
    end
    return nil
end

function Project:updatePassage(passageId, updates)
    local passage = self:getPassage(passageId)
    if not passage then return false end

    for key, value in pairs(updates) do
        passage[key] = value
    end
    self:touch()
    return true
end

function Project:touch()
    self.metadata.modified = os.date("!%Y-%m-%dT%H:%M:%SZ")
end

function Project:toJSON()
    local json = require('json')
    return json.encode({
        metadata = self.metadata,
        variables = self.variables,
        passages = self.passages,
        startPassage = self.startPassage,
        settings = self.settings
    })
end

function Project:fromJSON(jsonStr)
    local json = require('json')
    local data = json.decode(jsonStr)

    self.metadata = data.metadata or self.metadata
    self.variables = data.variables or {}
    self.passages = data.passages or {}
    self.startPassage = data.startPassage
    self.settings = data.settings or self.settings

    return true
end

function Project:save(filepath)
    local file = io.open(filepath, "w")
    if not file then
        return false, "Could not open file for writing"
    end

    file:write(self:toJSON())
    file:close()
    return true
end

function Project:load(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return false, "Could not open file for reading"
    end

    local content = file:read("*all")
    file:close()

    return self:fromJSON(content)
end

return Project