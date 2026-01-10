---@module 'which-colorscheme._meta'

local in_list = vim.list_contains
local Util = require('which-colorscheme.util')
local Color = require('which-colorscheme.color')
local WK = require('which-key')
local ERROR = vim.log.levels.ERROR

---@class WhichColorscheme.Config
local M = {}

M.maps = {} ---@type WhichColorschemeGroups

---@return WhichColorschemeOpts defaults
function M.get_defaults()
  return { ---@type WhichColorschemeOpts
    prefix = '<leader>C',
    group_name = 'Colorschemes',
    include_builtin = false,
    custom_groups = {},
    grouping = {
      uppercase_groups = false,
      random = false,
      inverse = false,
      current_first = true,
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

---@param colors string[]
---@param group Letter
function M.generate_maps(colors, group)
  Util.validate({
    colors = { colors, { 'table' } },
    group = { group, { 'string' } },
  })

  if not M.config.custom_groups then
    return
  end

  M.maps = {}
  M.manually_set = {} ---@type string[]
  for custom_group, category in pairs(M.config.custom_groups) do
    M.maps[custom_group] = {}
    for _, color in ipairs(category) do
      if in_list(colors, color) and not in_list(M.manually_set, color) then
        table.insert(M.manually_set, color)
        table.insert(M.maps[custom_group], color)
      end
    end
  end

  local new_colors = {} ---@type string[]
  for _, color in ipairs(colors) do
    if not in_list(M.manually_set, color) then
      table.insert(new_colors, color)
    end
  end

  local i, idx = 1, 1
  while idx < #new_colors do
    if not M.maps[group] then
      M.maps[group] = {}
    end
    local color = new_colors[idx]
    if M.maps[group][i] then
      if in_list(new_colors, M.maps[group][i]) then
        M.maps[group][i] = color
      end
    else
      M.maps[group][i] = color
    end
    idx = idx + 1

    if i == 9 then
      i = 1
      group = Util.displace_letter(group)
    elseif i < 9 then
      i = i + 1
    end
  end
end

function M.map()
  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!', ERROR)
  end
  if vim.g.WhichColorscheme_setup ~= 1 then
    return
  end

  local colors = Color.calculate_colorschemes()

  if not M.config.include_builtin then
    colors = Color.remove_builtins(vim.deepcopy(colors))
  end

  if M.config.grouping then
    if M.config.grouping.inverse ~= nil and M.config.grouping.inverse then
      colors = Util.reverse(vim.deepcopy(colors)) ---@type string[]
    end
    if M.config.grouping.random ~= nil and M.config.grouping.random then
      colors = Util.randomize_list(vim.deepcopy(colors)) ---@type string[]
    end
  end

  if M.config.grouping.current_first ~= nil and M.config.grouping.current_first then
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
  end

  M.generate_maps(colors, M.config.grouping.uppercase_groups and 'A' or 'a')

  local prefix = M.config.prefix or '<leader>c' ---@type string
  local keys = { { prefix, group = M.config.group_name or 'Colorschemes' } } ---@type wk.Spec
  for group, category in pairs(M.maps) do
    table.insert(keys, { prefix .. group, group = 'Group ' .. group })
    for i, color in ipairs(category) do
      table.insert(keys, {
        prefix .. group .. tostring(i),
        function()
          vim.cmd.colorscheme(color)
        end,
        desc = ('Set Colorscheme `%s`'):format(color),
        mode = 'n',
      })
    end
  end

  WK.add(keys)
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
