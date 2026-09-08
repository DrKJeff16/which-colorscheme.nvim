local Config = require('which-colorscheme.config')

---@class WhichColorscheme
---@field color WhichColorscheme.Color
---@field config WhichColorscheme.Config
---@field health WhichColorscheme.Health
---@field util WhichColorscheme.Util
local M = {}

function M.disable()
  Config.set('enabled', false)
  Config.unmap()
end

function M.enable()
  Config.set('enabled', true)
  Config.map()
end

---@param opts? WhichColorschemeOpts
function M.setup(opts)
  Config.setup(opts)
end

local WhichColorscheme = setmetatable(M, { ---@type WhichColorscheme
  __index = function(self, k)
    local raw = rawget(self, k) or nil
    if raw ~= nil then
      return raw
    end

    if require('which-colorscheme.util').mod_exists('which-colorscheme.' .. k) then
      return require('which-colorscheme.util').rawset(self, k, require('which-colorscheme.' .. k))
    end
  end,
})

return WhichColorscheme
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
