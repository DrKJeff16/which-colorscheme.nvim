---@module 'which-colorscheme._meta'

local Util = require('which-colorscheme.util')

local colors = {} ---@type string[]
local keys ---@type wk.Spec
local maps ---@type WhichColorschemeGroups
local manually_set = {} ---@type string[]
local new_colors = {} ---@type string[]

---@class WhichColorscheme.Config
---@field maps WhichColorschemeGroups
local M = {}

---@return WhichColorschemeOpts defaults
---@nodiscard
function M.get_defaults()
  return { ---@type WhichColorschemeOpts
    custom_groups = {},
    custom_only = false,
    description_prefix = '',
    enabled = true,
    excluded = {},
    group_name = 'Colorschemes',
    grouping = { labels = {}, uppercase_groups = false, random = false, inverse = false, current_first = true },
    include_builtin = false,
    prefix = '<leader>C',
  }
end

local options ---@type WhichColorschemeOpts

---@return WhichColorschemeOpts options
function M.get()
  return options
end

---@return string[] colors
function M.get_colors()
  return colors
end

---@param k string
---@param v any
function M.set(k, v)
  Util.validate({ k = { k, { 'string' } } })

  if M.get_defaults()[k] then
    options[k] = v
  end
end

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!')
  end
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  options = vim.tbl_deep_extend('force', M.get_defaults(), opts or {})
  vim.g.which_colorscheme_setup = 1

  if options.enabled then
    local map = vim.schedule_wrap(M.map)
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('WhichColorscheme', { clear = true }),
      desc = 'which-colorscheme.nvim hook to randomize the keymaps if enabled in setup',
      callback = function()
        if
          require('which-colorscheme.color').current() ~= vim.g.which_colorscheme_last_color
          and vim.g.which_colorscheme_enabled == 1
        then
          map()
        end
      end,
    })

    map()

    require('which-colorscheme.commands').create()
  end
end

---@param group Letter
---@param custom_only? boolean
function M.generate_maps(group, custom_only)
  Util.validate({
    group = { group, { 'string' } },
    custom_only = { custom_only, { 'boolean', 'nil' }, true },
  })
  if custom_only == nil then
    custom_only = false
  end
  if not options.custom_groups then
    return
  end

  local Color = require('which-colorscheme.color')
  maps, manually_set, new_colors = {}, {}, {}

  local excluded = options.excluded or {}
  for custom_group, category in pairs(options.custom_groups) do
    maps[custom_group] = {}
    for _, color in ipairs(category) do
      if
        Color.is_color(color) and not (vim.list_contains(excluded, color) or vim.list_contains(manually_set, color))
      then
        table.insert(manually_set, color)
        table.insert(new_colors, color)
        table.insert(maps[custom_group], color)
      end
    end
  end

  if not custom_only or vim.tbl_isempty(manually_set) then
    for _, color in ipairs(colors) do
      if not (vim.list_contains(excluded, color) or vim.list_contains(new_colors, color)) then
        table.insert(new_colors, color)
      end
    end
  end

  if options.grouping.current_first then
    new_colors = Util.move_start(new_colors, Color.current()) --[[@as string[]\]]
  end

  local i, idx = 1, 1
  while idx < #new_colors do
    maps[group] = maps[group] or {}
    if
      not (
        maps[group][i]
        and vim.list_contains(new_colors, maps[group][i])
        and vim.list_contains(excluded, maps[group][i])
      )
    then
      if not vim.list_contains(manually_set, new_colors[idx]) then
        maps[group][i] = new_colors[idx]
      end
      if i == 9 then
        i = 1
        group = Util.displace_letter(group)
      elseif i < 9 then
        i = i + 1
      end
    end
    idx = idx + 1
  end
end

function M.unmap()
  if vim.g.which_colorscheme_setup ~= 1 then
    error('`which-colorscheme.nvim` has not been setup!')
  end
  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!')
  end

  if not vim.tbl_isempty(keys) then
    for i in pairs(keys) do
      keys[i].hidden = true
    end
    pcall(require('which-key').add, vim.deepcopy(keys))
    vim.g.which_colorscheme_enabled = 0
  end
end

---@return wk.Spec keys
---@nodiscard
function M.get_keys()
  return keys
end

function M.map()
  if vim.g.which_colorscheme_setup ~= 1 then
    error('`which-colorscheme.nvim` has not been setup!')
  end
  if not Util.mod_exists('which-key') then
    error('which-key.nvim is not installed!')
  end

  local Color = require('which-colorscheme.color')
  colors = Color.calculate_colorschemes(not options.include_builtin)

  if options.grouping then
    if options.grouping.inverse then
      colors = Util.reverse(colors)
    end
    if options.grouping.random then
      colors = Util.randomize_list(colors)
    end
  end

  if options.grouping.current_first then
    colors = Util.move_start(colors, Color.current())
  end

  M.generate_maps(options.grouping.uppercase_groups and 'A' or 'a', options.custom_only)

  local prefix = options.prefix or '<leader>c' --[[@as string]]
  keys = { { prefix, group = options.group_name or 'Colorschemes' } }
  for group, category in pairs(maps) do
    local g = (options.grouping.labels[group] and options.grouping.labels[group] ~= '')
        and options.grouping.labels[group]
      or ('Group %s'):format(group)

    g = Util.strip(' ', g) ~= '' and Util.strip(' ', g) or ('Group %s'):format(group)
    table.insert(keys, { prefix .. group, group = Util.strip(' ', g) })

    for i, color in ipairs(category) do
      table.insert(keys, {
        ('%s%s%s'):format(prefix, group, i),
        function()
          pcall(vim.cmd.colorscheme, color)
        end,
        desc = ('%s %s'):format(options.description_prefix or '', color),
        mode = 'n',
      })
    end
  end

  pcall(require('which-key').add, vim.deepcopy(keys))
  vim.g.which_colorscheme_last_color = Color.current()
  vim.g.which_colorscheme_enabled = 1
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
