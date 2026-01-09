---@class WhichColorschemeGroupping
---@field uppercase_groups? boolean
---@field random? boolean
---@field inverse? boolean

---@class WhichColorschemeOpts
---@field prefix? string
---@field group_name? string
---@field include_builtin? boolean
---@field groupping? WhichColorschemeGroupping

local in_list = vim.list_contains
local Util = require('which-colorscheme.util')
local Color = require('which-colorscheme.color')
local WK = require('which-key')
local ERROR = vim.log.levels.ERROR

---@class WhichColorscheme.Config
local M = {}

---@return WhichColorschemeOpts defaults
function M.get_defaults()
  return { ---@type WhichColorschemeOpts
    prefix = '<leader>C',
    group_name = 'Colorschemes',
    include_builtin = false,
    groupping = {
      uppercase_groups = false,
      random = false,
      inverse = false,
    },
  }
end

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!')
  end

  M.config = vim.tbl_deep_extend('keep', opts or {}, M.get_defaults())
  vim.g.WhichColorscheme_setup = 1

  M.map()

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('WhichColorscheme', { clear = true }),
    callback = function()
      M.map()
    end,
  })
end

function M.map()
  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!', ERROR)
  end
  if vim.g.WhichColorscheme_setup ~= 1 then
    error('which-colorscheme.nvim has not been setup!', ERROR)
  end

  local colors = Color.calculate_colorschemes()

  if not M.config.include_builtin then
    colors = Color.remove_builtins(vim.deepcopy(colors))
  end

  if M.config.groupping then
    if M.config.groupping.inverse ~= nil and M.config.groupping.inverse then
      colors = Util.reverse(vim.deepcopy(colors)) ---@type string[]
    end
    if M.config.groupping.random ~= nil and M.config.groupping.random then
      colors = Util.randomize_list(vim.deepcopy(colors)) ---@type string[]
    end
  end

  local current = vim.api.nvim_exec2('colorscheme', { output = true }).output ---@type string
  if in_list(colors, current) then
    local idx = 1
    for i, v in ipairs(colors) do
      if v == current then
        idx = i
        break
      end
    end
    table.remove(colors, idx)
  end
  table.insert(colors, 1, current)

  local prefix, i = M.config.prefix or '<leader>c', 1 ---@type string, integer
  local group = M.config.groupping.uppercase_groups and 'A' or 'a' ---@type Letter
  local keys = { { prefix, group = M.config.group_name or 'Colorschemes' } } ---@type wk.Spec
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
