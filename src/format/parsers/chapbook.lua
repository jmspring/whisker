-- Chapbook Twee Parser
-- Parses Twee notation into structured format

local harlowe_parser = require("src.format.parsers.harlowe")

local M = {}

-- Chapbook uses the same Twee format
M.parse = harlowe_parser.parse

return M
