local Util = require('which-colorscheme.util')
local Config = require('which-colorscheme.config')

---@class WhichColorscheme
local M = {}

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  Config.setup(opts or {})
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
