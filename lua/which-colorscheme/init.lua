---@class WhichColorscheme
---@field color WhichColorscheme.Color
---@field config WhichColorscheme.Config
---@field health WhichColorscheme.Health
---@field setup fun(opts?: WhichColorschemeOpts)
---@field util WhichColorscheme.Util
local M = {}

function M.disable()
  require('which-colorscheme.config').set('enabled', false)
  require('which-colorscheme.config').unmap()
end

function M.enable()
  require('which-colorscheme.config').set('enabled', true)
  require('which-colorscheme.config').map()
end

local WhichColorscheme = setmetatable(M, { ---@type WhichColorscheme
  __index = function(self, k)
    if require('which-colorscheme.util').mod_exists('which-colorscheme.' .. k) then
      return require('which-colorscheme.' .. k)
    end
    if k == 'setup' then
      return require('which-colorscheme.config').setup
    end
    return rawget(self, k) or nil
  end,
})

return WhichColorscheme
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
