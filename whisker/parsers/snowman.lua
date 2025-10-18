-- Snowman Twee Parser
-- Parses Twee notation into structured format

local harlowe_parser = require("whisker.parsers.harlowe")

local M = {}

-- Snowman uses the same Twee format
M.parse = harlowe_parser.parse

return M
