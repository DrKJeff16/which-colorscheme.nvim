local Util = require('which-colorscheme.util')

---@class WhichColorscheme
---@field color WhichColorscheme.Color
---@field config WhichColorscheme.Config
---@field health WhichColorscheme.Health
---@field util WhichColorscheme.Util
local M = {}

M.setup = require('which-colorscheme.config').setup

function M.disable()
  local Config = require('which-colorscheme.config')
  Config.set('enabled', false)
  Config.unmap()
end

function M.enable()
  local Config = require('which-colorscheme.config')
  Config.set('enabled', true)
  Config.map()
end

local WhichColorscheme = setmetatable(M, { ---@type WhichColorscheme
  ---@param self WhichColorscheme
  ---@param k string
  ---@return any value
  __index = function(self, k)
    if Util.mod_exists('which-colorscheme.' .. k) then
      return require('which-colorscheme.' .. k)
    end
    return rawget(self, k) or nil
  end,
})

return WhichColorscheme
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
