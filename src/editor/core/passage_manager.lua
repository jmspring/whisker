-- whisker/src/editor/core/passage_manager.lua
-- Passage Management Module

local PassageManager = {}
PassageManager.__index = PassageManager

function PassageManager:new(project)
    local instance = {
        project = project,
        idCounter = 0
    }
    setmetatable(instance, self)
    return instance
end

function PassageManager:generateId()
    self.idCounter = self.idCounter + 1
    return "passage_" .. os.time() .. "_" .. self.idCounter
end

function PassageManager:create(title, content)
    local passage = {
        id = self:generateId(),
        title = title or "Untitled Passage",
        content = content or "",
        tags = {},
        choices = {},
        script = "",
        position = {x = 0, y = 0},
        metadata = {
            created = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            modified = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    self.project:addPassage(passage)
    return passage
end

function PassageManager:update(passageId, updates)
    local passage = self.project:getPassage(passageId)
    if not passage then return false end

    for key, value in pairs(updates) do
        if key ~= "id" and key ~= "metadata" then
            passage[key] = value
        end
    end

    passage.metadata.modified = os.date("!%Y-%m-%dT%H:%M:%SZ")
    self.project:touch()
    return true
end

function PassageManager:delete(passageId)
    return self.project:removePassage(passageId)
end

function PassageManager:addChoice(passageId, text, target, condition)
    local passage = self.project:getPassage(passageId)
    if not passage then return false end

    local choice = {
        text = text or "New choice",
        target = target or "",
        condition = condition or "",
        script = ""
    }

    table.insert(passage.choices, choice)
    self.project:touch()
    return true
end

function PassageManager:updateChoice(passageId, choiceIndex, updates)
    local passage = self.project:getPassage(passageId)
    if not passage or not passage.choices[choiceIndex] then
        return false
    end

    for key, value in pairs(updates) do
        passage.choices[choiceIndex][key] = value
    end

    self.project:touch()
    return true
end

function PassageManager:removeChoice(passageId, choiceIndex)
    local passage = self.project:getPassage(passageId)
    if not passage or not passage.choices[choiceIndex] then
        return false
    end

    table.remove(passage.choices, choiceIndex)
    self.project:touch()
    return true
end

function PassageManager:addTag(passageId, tag)
    local passage = self.project:getPassage(passageId)
    if not passage then return false end

    for _, existingTag in ipairs(passage.tags) do
        if existingTag == tag then return true end
    end

    table.insert(passage.tags, tag)
    self.project:touch()
    return true
end

function PassageManager:removeTag(passageId, tag)
    local passage = self.project:getPassage(passageId)
    if not passage then return false end

    for i, existingTag in ipairs(passage.tags) do
        if existingTag == tag then
            table.remove(passage.tags, i)
            self.project:touch()
            return true
        end
    end

    return false
end

function PassageManager:getConnections(passageId)
    local connections = {
        outgoing = {},
        incoming = {}
    }

    local passage = self.project:getPassage(passageId)
    if not passage then return connections end

    -- Get outgoing connections
    for _, choice in ipairs(passage.choices) do
        if choice.target and choice.target ~= "" then
            table.insert(connections.outgoing, {
                target = choice.target,
                text = choice.text,
                condition = choice.condition
            })
        end
    end

    -- Get incoming connections
    for _, p in ipairs(self.project.passages) do
        if p.id ~= passageId then
            for _, choice in ipairs(p.choices) do
                if choice.target == passageId then
                    table.insert(connections.incoming, {
                        source = p.id,
                        sourceTitle = p.title,
                        text = choice.text
                    })
                end
            end
        end
    end

    return connections
end

function PassageManager:findPassagesByTag(tag)
    local results = {}
    for _, passage in ipairs(self.project.passages) do
        for _, passageTag in ipairs(passage.tags) do
            if passageTag == tag then
                table.insert(results, passage)
                break
            end
        end
    end
    return results
end

function PassageManager:findPassagesByTitle(searchTerm)
    local results = {}
    local lowerSearch = searchTerm:lower()

    for _, passage in ipairs(self.project.passages) do
        if passage.title:lower():find(lowerSearch, 1, true) then
            table.insert(results, passage)
        end
    end

    return results
end

return PassageManager