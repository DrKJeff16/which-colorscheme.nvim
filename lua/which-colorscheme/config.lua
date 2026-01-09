---@class WhichColorschemeOpts
---@field prefix? string
---@field group? string
---@field random? boolean

local Util = require('which-colorscheme.util')
local WK = require('which-key')

---@class WhichColorscheme.Config
local M = {}

---@return WhichColorschemeOpts defaults
function M.get_defaults()
  return { ---@type WhichColorschemeOpts
    prefix = '<leader>C',
    group = 'Colorschemes',
    random = false,
  }
end

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!')
  end

  M.config = vim.tbl_deep_extend('keep', opts or {}, M.get_defaults())

  M.map()
  vim.g.WhichColorscheme_setup = 1
end

function M.map()
  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!')
  end

  local prefix = M.config.prefix or '<leader>c'
  local group = 'A' ---@type Letter
  local i = 1
  local colors = require('which-colorscheme.color').calculate_colorschemes()

  if M.config.random ~= nil and M.config.random then
    colors = Util.randomize_list(vim.deepcopy(colors)) ---@type string[]
  end

  local keys = { { prefix, group = M.config.group or 'Colorschemes' } } ---@type wk.Spec
  for _, name in pairs(colors) do
    if i == 1 then
      table.insert(keys, { prefix .. group, group = 'Group ' .. group })
    end
    table.insert(keys, {
      prefix .. group .. tostring(i),
      ('<CMD>colorscheme %s<CR>'):format(name),
      desc = ('Set Colorscheme `%s`'):format(name),
      mode = 'n',
    })
    if i == 9 then
      i = 1
      group = Util.displace_letter(group)
    elseif i < 9 then
      i = i + 1
    end
  end

  WK.add(keys)
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
