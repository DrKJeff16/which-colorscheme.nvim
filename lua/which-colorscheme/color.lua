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

---@class WhichColorscheme.Color
local M = {}

---@return string current
---@nodiscard
function M.current()
  return vim.g.colors_name --[[@as string]]
end

---@param no_builtins? boolean
---@return string[] colorschemes
---@nodiscard
function M.calculate_colorschemes(no_builtins)
  require('which-colorscheme.util').validate({ no_builtins = { no_builtins, { 'boolean', 'nil' }, true } })
  if no_builtins == nil then
    no_builtins = true
  end

  local colorschemes = vim.fn.getcompletion('', 'color')
  if no_builtins then
    local colors = {} ---@type string[]
    for _, color in ipairs(colorschemes) do
      if not vim.list_contains(builtins, color) then
        table.insert(colors, color)
      end
    end
    colorschemes = colors
  end
  return colorschemes
end

---@param color string
---@return boolean result
---@nodiscard
function M.is_color(color)
  require('which-colorscheme.util').validate({ color = { color, { 'string' } } })

  return vim.list_contains(vim.fn.getcompletion('', 'color'), color)
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
