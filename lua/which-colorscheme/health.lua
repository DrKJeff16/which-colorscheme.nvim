local Util = require('which-colorscheme.util')

---@class WhichColorscheme.Health
local M = {}

function M.check()
  vim.health.start('Setup')

  if not Util.mod_exists('which-key') then
    vim.health.error('`which-key.nvim` is not installed!')
    return
  end
  vim.health.ok('`which-key.nvim` installed!')

  if vim.g.WhichColorscheme_setup ~= 1 then
    vim.health.error('`which-colorscheme.nvim` has not been setup correctly!')
    return
  end
  vim.health.ok('`which-colorscheme.nvim` setup!')

  vim.health.start('Config')
  for k, v in pairs(require('which-colorscheme.config').config) do
    vim.health.info(('`%s`: `%s`'):format(k, vim.inspect(v)))
  end
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
