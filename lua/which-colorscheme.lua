local Util = require('which-colorscheme.util')

---@class WhichColorscheme
---@field color WhichColorscheme.Color
---@field config WhichColorscheme.Config
---@field health WhichColorscheme.Health
---@field util WhichColorscheme.Util
local M = {}

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  require('which-colorscheme.config').setup(opts or {})
end

local WhichColorscheme = setmetatable(M, { ---@type WhichColorscheme
  __index = function(self, k)
    if Util.mod_exists('which-colorscheme.' .. k) then
      return require('which-colorscheme.' .. k)
    end
    return rawget(self, k) or nil
  end,
})

return WhichColorscheme
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
