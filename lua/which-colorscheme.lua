local util = require('which-colorscheme.util')
local config = require('which-colorscheme.config')

---@class WhichColorscheme
local M = {}

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  config.setup(opts or {})
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
