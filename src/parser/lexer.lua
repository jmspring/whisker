-- src/parser/lexer.lua
-- Complete tokenization for whisker format

local Lexer = {}
Lexer.__index = Lexer

function Lexer.new()
    local instance = {
        -- Input processing
        input = "",
        position = 1,
        line = 1,
        column = 1,

        -- Output
        tokens = {},
        errors = {},

        -- Token patterns (order matters - more specific first)
        token_patterns = {
            -- Keywords
            {"PASSAGE", "^passage"},
            {"CHOICE", "^choice"},
            {"CONTENT", "^content"},
            {"ACTION", "^action"},
            {"CONDITION", "^condition"},
            {"IF", "^if"},
            {"ELSE", "^else"},
            {"ELSEIF", "^elseif"},
            {"END", "^end"},
            {"FUNCTION", "^function"},
            {"RETURN", "^return"},
            {"LOCAL", "^local"},
            {"TRUE", "^true"},
            {"FALSE", "^false"},
            {"NIL", "^nil"},

            -- Operators
            {"ARROW", "^%->"},
            {"ASSIGN", "^="},
            {"EQUALS", "^=="},
            {"NOT_EQUALS", "^~="},
            {"LESS_EQUAL", "^<="},
            {"GREATER_EQUAL", "^>="},
            {"LESS_THAN", "^<"},
            {"GREATER_THAN", "^>"},
            {"PLUS", "^%+"},
            {"MINUS", "^%-"},
            {"MULTIPLY", "^%*"},
            {"DIVIDE", "^/"},
            {"MODULO", "^%%"},
            {"CONCAT", "^%.%."},
            {"DOT", "^%."},

            -- Delimiters
            {"LEFT_BRACE", "^{"},
            {"RIGHT_BRACE", "^}"},
            {"LEFT_PAREN", "^%("},
            {"RIGHT_PAREN", "^%)"},
            {"LEFT_BRACKET", "^%["},
            {"RIGHT_BRACKET", "^%]"},
            {"SEMICOLON", "^;"},
            {"COMMA", "^,"},
            {"COLON", "^:"},

            -- Literals
            {"NUMBER", "^%d+%.?%d*"},
            {"STRING", '^"[^"]*"'},
            {"STRING_SINGLE", "^'[^']*'"},
            {"MULTILINE_STRING", "^%[%[.-%]%]"},
            {"IDENTIFIER", "^[%a_][%w_]*"},

            -- Whitespace and comments
            {"NEWLINE", "^[\r\n]+"},
            {"WHITESPACE", "^[ \t]+"},
            {"COMMENT", "^%-%-[^\r\n]*"},
            {"BLOCK_COMMENT", "^%-%-%[%[.-%]%]"}
        }
    }

    setmetatable(instance, Lexer)
    return instance
end

function Lexer:tokenize(input)
    self.input = input or ""
    self.position = 1
    self.line = 1
    self.column = 1
    self.tokens = {}
    self.errors = {}

    -- Handle empty input
    if self.input == "" then
        return {
            success = true,
            tokens = {},
            errors = {}
        }
    end

    while self.position <= #self.input do
        local token_found = false

        -- Try to match each token pattern
        for _, pattern_info in ipairs(self.token_patterns) do
            local token_type = pattern_info[1]
            local pattern = pattern_info[2]

            local remaining_input = self.input:sub(self.position)
            local match = remaining_input:match(pattern)

            if match then
                -- Create token
                local token = {
                    type = token_type,
                    value = match,
                    line = self.line,
                    column = self.column,
                    position = self.position
                }

                -- Skip whitespace and comment tokens (unless needed for parsing)
                if token_type ~= "WHITESPACE" and
                   token_type ~= "COMMENT" and
                   token_type ~= "BLOCK_COMMENT" then
                    table.insert(self.tokens, token)
                end

                -- Update position tracking
                local lines_in_token = 0
                for _ in match:gmatch("\n") do
                    lines_in_token = lines_in_token + 1
                end

                if lines_in_token > 0 then
                    self.line = self.line + lines_in_token
                    -- Find last newline position
                    local last_newline = match:match(".*\n()")
                    if last_newline then
                        self.column = #match - last_newline + 2
                    else
                        self.column = 1
                    end
                else
                    self.column = self.column + #match
                end

                self.position = self.position + #match
                token_found = true
                break
            end
        end

        -- Handle unrecognized character
        if not token_found then
            local char = self.input:sub(self.position, self.position)
            table.insert(self.errors, {
                type = "UNEXPECTED_CHARACTER",
                message = "Unexpected character: '" .. char .. "'",
                line = self.line,
                column = self.column,
                position = self.position
            })

            -- Skip the character and continue
            self.position = self.position + 1
            self.column = self.column + 1
        end
    end

    -- Add EOF token
    table.insert(self.tokens, {
        type = "EOF",
        value = "",
        line = self.line,
        column = self.column,
        position = self.position
    })

    return {
        success = #self.errors == 0,
        tokens = self.tokens,
        errors = self.errors
    }
end

function Lexer:get_tokens()
    return self.tokens
end

function Lexer:get_errors()
    return self.errors
end

function Lexer:has_errors()
    return #self.errors > 0
end

return Lexer