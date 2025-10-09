-- src/parser/parser.lua
-- Complete parser for whisker format

local Parser = {}
Parser.__index = Parser

function Parser:new()
    local instance = {
        tokens = {},
        current = 1,
        errors = {},
        warnings = {},

        -- Parse results
        story_data = {
            metadata = {},
            variables = {},
            passages = {},
            start_passage = nil
        },

        -- Track passage references for validation
        referenced_passages = {},
        parsing_passage = nil
    }

    setmetatable(instance, Parser)
    return instance
end

function Parser:parse(tokens)
    self.tokens = tokens or {}
    self.current = 1
    self.errors = {}
    self.warnings = {}
    self.story_data = {
        metadata = {},
        variables = {},
        passages = {},
        start_passage = nil
    }
    self.referenced_passages = {}

    if #self.tokens == 0 then
        self:add_error("No tokens to parse")
        return {
            success = false,
            story = nil,
            errors = self.errors,
            warnings = self.warnings
        }
    end

    -- Parse story structure
    while not self:is_at_end() do
        if self:match("PASSAGE") then
            self:parse_passage()
        elseif self:match("NEWLINE") then
            -- Skip newlines at top level
        elseif self:match("EOF") then
            break
        else
            self:add_error("Unexpected token at top level: " .. self:peek().type)
            self:advance()
        end
    end

    -- Validate passage references
    self:validate_passage_references()

    -- Set start passage if not explicitly set
    if not self.story_data.start_passage and next(self.story_data.passages) then
        -- Use first passage as start
        for passage_id, _ in pairs(self.story_data.passages) do
            self.story_data.start_passage = passage_id
            break
        end
    end

    return {
        success = #self.errors == 0,
        story = self.story_data,
        errors = self.errors,
        warnings = self.warnings
    }
end

function Parser:parse_passage()
    -- passage "name" { ... }
    local passage_name_token = self:consume("STRING", "Expected passage name")
    if not passage_name_token then return end

    local passage_name = self:extract_string_value(passage_name_token.value)

    -- Check for duplicate passage
    if self.story_data.passages[passage_name] then
        self:add_warning("Duplicate passage definition: " .. passage_name)
    end

    self:consume("LEFT_BRACE", "Expected '{' after passage name")

    local passage_data = {
        id = passage_name,
        name = passage_name,
        content = "",
        choices = {},
        tags = {},
        metadata = {},
        on_enter_script = nil,
        on_exit_script = nil
    }

    self.parsing_passage = passage_name

    -- Parse passage body
    while not self:check("RIGHT_BRACE") and not self:is_at_end() do
        if self:match("CONTENT") then
            self:consume("ASSIGN", "Expected '=' after 'content'")
            passage_data.content = self:parse_content()

        elseif self:match("CHOICE") then
            local choice = self:parse_choice()
            if choice then
                table.insert(passage_data.choices, choice)
            end

        elseif self:match("ACTION") then
            self:consume("ASSIGN", "Expected '=' after 'action'")
            passage_data.on_enter_script = self:parse_code_block()

        elseif self:match("NEWLINE") then
            -- Skip newlines

        else
            -- Try to parse as property
            if self:check("IDENTIFIER") then
                local property_name = self:advance().value
                self:consume("ASSIGN", "Expected '=' after property name")
                local property_value = self:parse_value()
                passage_data.metadata[property_name] = property_value
            else
                self:add_error("Unexpected token in passage: " .. self:peek().type)
                self:advance()
            end
        end
    end

    self:consume("RIGHT_BRACE", "Expected '}' to close passage")

    -- Store passage data
    self.story_data.passages[passage_name] = passage_data
    self.parsing_passage = nil
end

function Parser:parse_choice()
    -- choice "text" -> "target" { ... }
    local choice_text_token = self:consume("STRING", "Expected choice text")
    if not choice_text_token then return nil end

    self:consume("ARROW", "Expected '->' after choice text")

    local choice_target_token = self:consume("STRING", "Expected choice target")
    if not choice_target_token then return nil end

    local choice_data = {
        text = self:extract_string_value(choice_text_token.value),
        target_passage = self:extract_string_value(choice_target_token.value),
        condition = nil,
        action = nil,
        metadata = {}
    }

    -- Track passage reference
    self.referenced_passages[choice_data.target_passage] = true

    -- Parse optional choice properties
    if self:match("LEFT_BRACE") then
        while not self:check("RIGHT_BRACE") and not self:is_at_end() do
            if self:match("ACTION") then
                self:consume("ASSIGN", "Expected '=' after 'action'")
                choice_data.action = self:parse_code_block()

            elseif self:match("CONDITION") then
                self:consume("ASSIGN", "Expected '=' after 'condition'")
                choice_data.condition = self:parse_code_block()

            elseif self:match("NEWLINE") then
                -- Skip newlines

            else
                self:add_error("Unexpected token in choice: " .. self:peek().type)
                self:advance()
            end
        end

        self:consume("RIGHT_BRACE", "Expected '}' to close choice")
    end

    return choice_data
end

function Parser:parse_content()
    if self:check("STRING") then
        local token = self:advance()
        return self:extract_string_value(token.value)
    elseif self:check("MULTILINE_STRING") then
        local token = self:advance()
        -- Remove [[ and ]]
        local content = token.value:sub(3, -3)
        return content
    else
        self:add_error("Expected string for content")
        return ""
    end
end

function Parser:parse_code_block()
    if self:check("STRING") then
        local token = self:advance()
        return self:extract_string_value(token.value)
    elseif self:check("MULTILINE_STRING") then
        local token = self:advance()
        -- Remove [[ and ]]
        local code = token.value:sub(3, -3)
        return code
    else
        self:add_error("Expected string or multiline string for code block")
        return ""
    end
end

function Parser:parse_value()
    if self:check("STRING") or self:check("STRING_SINGLE") then
        local token = self:advance()
        return self:extract_string_value(token.value)
    elseif self:check("NUMBER") then
        local token = self:advance()
        return tonumber(token.value)
    elseif self:check("TRUE") then
        self:advance()
        return true
    elseif self:check("FALSE") then
        self:advance()
        return false
    elseif self:check("NIL") then
        self:advance()
        return nil
    else
        self:add_error("Expected value")
        return nil
    end
end

function Parser:extract_string_value(str)
    -- Remove quotes
    if str:sub(1, 1) == '"' and str:sub(-1) == '"' then
        return str:sub(2, -2)
    elseif str:sub(1, 1) == "'" and str:sub(-1) == "'" then
        return str:sub(2, -2)
    end
    return str
end

function Parser:validate_passage_references()
    for passage_id, _ in pairs(self.referenced_passages) do
        if not self.story_data.passages[passage_id] then
            self:add_warning("Referenced passage does not exist: " .. passage_id)
        end
    end
end

-- Token navigation helpers
function Parser:peek()
    if self.current <= #self.tokens then
        return self.tokens[self.current]
    end
    return self.tokens[#self.tokens] -- Return EOF
end

function Parser:previous()
    return self.tokens[self.current - 1]
end

function Parser:advance()
    if not self:is_at_end() then
        self.current = self.current + 1
    end
    return self:previous()
end

function Parser:is_at_end()
    return self:peek().type == "EOF"
end

function Parser:check(token_type)
    if self:is_at_end() then return false end
    return self:peek().type == token_type
end

function Parser:match(...)
    local types = {...}
    for _, token_type in ipairs(types) do
        if self:check(token_type) then
            self:advance()
            return true
        end
    end
    return false
end

function Parser:consume(token_type, error_message)
    if self:check(token_type) then
        return self:advance()
    end

    self:add_error(error_message or ("Expected " .. token_type))
    return nil
end

-- Error handling
function Parser:add_error(message)
    local token = self:peek()
    table.insert(self.errors, {
        message = message,
        line = token.line,
        column = token.column,
        token = token.type
    })
end

function Parser:add_warning(message)
    local token = self:peek()
    table.insert(self.warnings, {
        message = message,
        line = token.line,
        column = token.column,
        token = token.type
    })
end

return Parser