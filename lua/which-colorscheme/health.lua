---@class WhichColorscheme.Health
local M = {}

function M.check()
  vim.health.start('WhichColorscheme')

  if vim.g.WhichColorscheme_setup == 1 then
    vim.health.ok('WhichColorscheme has been setup!')
    return
  end

  vim.health.error('WhichColorscheme has not been setup correctly!')
end

return M
-- vim: set ts=2 sts=2 sw=2  ai si sta:
