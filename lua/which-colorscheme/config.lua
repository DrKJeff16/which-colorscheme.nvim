local util = require('which-colorscheme.util')

---@class WhichColorscheme.Config
local M = {}

---@return WhichColorschemeOpts defaults
function M.get_defaults()
  return { ---@class WhichColorschemeOpts
    debug = false,
    foo = true,
    bar = false,
  }
end

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  M.config = vim.tbl_deep_extend('keep', opts or {}, M.get_defaults())

  -- ...
  vim.g.WhichColorscheme_setup = 1 -- OPTIONAL for `health.lua`, delete if you want to
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
