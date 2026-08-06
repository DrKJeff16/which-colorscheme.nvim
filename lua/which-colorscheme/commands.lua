local options = { 'enable', 'disable', 'toggle' }

---@class WhichColorscheme.Commands
local M = {}

function M.create()
  vim.api.nvim_create_user_command('WhichColorscheme', function(ctx)
    if #ctx.fargs ~= 1 then
      vim.notify(
        [[Usage:
    :WhichColorscheme disable
    :WhichColorscheme enable
    :WhichColorscheme toggle]],
        vim.log.levels.INFO
      )
      return
    end

    if ctx.fargs[1] == 'disable' then
      if vim.g.which_colorscheme_enabled == 1 then
        require('which-colorscheme.config').unmap()
      else
        vim.notify('which-colorscheme.nvim - Already disabled!', vim.log.levels.INFO)
      end
    elseif ctx.fargs[1] == 'enable' then
      if vim.g.which_colorscheme_enabled == 0 then
        require('which-colorscheme.config').map()
      else
        vim.notify('which-colorscheme.nvim - Already enabled!', vim.log.levels.INFO)
      end
    elseif ctx.fargs[1] == 'toggle' then
      if vim.g.which_colorscheme_enabled == 1 then
        require('which-colorscheme.config').unmap()
      else
        require('which-colorscheme.config').map()
      end
    end
  end, {
    nargs = 1,
    bar = true,
    complete = function(_, args)
      local split = vim.split(args, '%s+', { trimempty = false })
      local items = {} ---@type string[]
      if #split == 2 and split[1] == 'WhichColorscheme' then
        for _, option in ipairs(options) do
          if vim.startswith(option, split[2]) then
            table.insert(items, option)
          end
        end
      end
      return items
    end,
  })
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
