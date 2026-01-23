local Util = require('which-colorscheme.util')

---@class WhichColorscheme.Color
local M = {}

---@return string current
---@nodiscard
function M.get_current()
  return vim.api.nvim_exec2('colorscheme', { output = true }).output
end

---@return string[] colorschemes
---@nodiscard
function M.calculate_colorschemes()
  local colorschemes = vim.fn.getcompletion('', 'color')
  table.sort(colorschemes)

  return colorschemes
end

---@param color string
---@return boolean result
---@nodiscard
function M.is_color(color)
  Util.validate({ color = { color, { 'string' } } })

  return vim.list_contains(vim.fn.getcompletion('', 'color'), color)
end

---@param colors string[]
---@return string[] colorschemes
---@nodiscard
function M.remove_builtins(colors)
  Util.validate({ colors = { colors, { 'table' } } })

  local builtins = { ---@type string[]
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
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
