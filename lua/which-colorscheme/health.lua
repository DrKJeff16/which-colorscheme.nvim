local Util = require('which-colorscheme.util')

---@class WhichColorscheme.Health
local M = {}

function M.check()
  vim.health.start('whick-key')
  if not Util.mod_exists('which-key') then
    vim.health.error('`which-key.nvim` is not installed!')
    return
  end
  vim.health.ok('`which-key.nvim` installed!')

  vim.health.start('Setup')
  if vim.g.which_colorscheme_setup ~= 1 then
    vim.health.error('`which-colorscheme.nvim` has not been setup correctly!')
    return
  end
  vim.health.ok('`which-colorscheme.nvim` set up!')

  vim.health.start('Config')
  for k, v in pairs(require('which-colorscheme.config').config) do
    local str, warning = Util.format_per_type(type(v), v)
    local func = (warning ~= nil and warning) and vim.health.warn or vim.health.ok
    func((' - `%s`: %s'):format(k, str))
  end
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
