---@class WhichColorscheme.Color
local M = {}

---@return string[] colorschemes
function M.calculate_colorschemes()
  local colorschemes = vim.fn.getcompletion('', 'color') ---@type string[]
  table.sort(colorschemes)

  return colorschemes
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
