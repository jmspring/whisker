-- SugarCube Twee Parser
-- Parses Twee notation into structured format

-- Use the same basic Twee parser since the passage structure is the same
local harlowe_parser = require("engine.format.parsers.harlowe")

local M = {}

-- SugarCube uses the same Twee format, just different macro syntax
M.parse = harlowe_parser.parse

return M
