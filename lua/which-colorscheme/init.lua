local Util = require('which-colorscheme.util')

---@generic T: table, F
---@param t T
---@param k any
---@param fallback F
---@return F fallback
local function get(t, k, fallback)
  return Util.get(t, k, function()
    return Util.rawset(t, k, fallback)
  end, true)
end

---@class WhichColorscheme
---@field color WhichColorscheme.Color
---@field config WhichColorscheme.Config
---@field disable function
---@field enable function
---@field health WhichColorscheme.Health
---@field setup (fun())|(fun(opts: WhichColorschemeOpts))
---@field util WhichColorscheme.Util
local M = {}

setmetatable(M, {
  __index = function(self, k) ---@param self WhichColorscheme
    local raw = Util.get(self, k)
    if raw ~= nil then
      return raw
    end

    if type(k) ~= 'string' then
      return
    end

    ---@cast k string
    if Util.mod_exists('which-colorscheme.' .. k) then
      return get(self, k, require('which-colorscheme.' .. k))
    end
    if k == 'disable' then
      return get(self, k, function()
        self.config.set('enabled', false)
        self.config.unmap()
      end)
    end
    if k == 'enable' then
      return get(self, k, function()
        self.config.set('enabled', true)
        self.config.map()
      end)
    end
    if k == 'setup' then
      return get(self, k, self.config.setup)
    end
  end,
})

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
