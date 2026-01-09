---@class WhichColorscheme.Color
local M = {}

---@return string[] colorschemes
function M.calculate_colorschemes()
  local colorschemes = vim.fn.getcompletion('', 'color') ---@type string[]
  table.sort(colorschemes)

  return colorschemes
end

---@param colors string[]
---@return string[] colorschemes
function M.remove_builtins(colors)
  local builtins = {
    'blue',
    'darkblue',
    'default',
    'delek',
    'desert',
    'elflord',
    'evening',
    'habamax',
    'industry',
    'koehler',
    'lunaperche',
    'morning',
    'murphy',
    'pablo',
    'peachpuff',
    'quiet',
    'retrobox',
    'ron',
    'shine',
    'slate',
    'sorbet',
    'torte',
    'unokai',
    'vim',
    'wildcharm',
    'zaibatsu',
    'zellner',
  }

  local colorschemes = {} ---@type string[]
  for _, color in ipairs(colors) do
    if not vim.list_contains(builtins, color) then
      table.insert(colorschemes, color)
    end
  end

  return colorschemes
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
