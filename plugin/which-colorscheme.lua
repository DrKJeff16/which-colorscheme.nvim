if vim.g.which_colorscheme_command_loaded == 1 then
  return
end

vim.g.which_colorscheme_command_loaded = 1

vim.api.nvim_create_user_command('WhichColorscheme', function(ctx)
  local WC = require('which-colorscheme')
  if ctx.fargs[1] == 'disable' and vim.g.which_colorscheme_enabled == 1 then
    WC.config.unmap()
  elseif ctx.fargs[1] == 'disable' then
    vim.notify('which-colorscheme.nvim - Already disabled!', vim.log.levels.INFO)
  elseif ctx.fargs[1] == 'enable' and vim.g.which_colorscheme_enabled ~= 1 then
    WC.config.map()
  elseif ctx.fargs[1] == 'enable' and vim.g.which_colorscheme_enabled ~= 0 then
    vim.notify('which-colorscheme.nvim - Already enabled!', vim.log.levels.INFO)
  elseif ctx.fargs[1] == 'toggle' then
    (vim.g.which_colorscheme_enabled == 1 and WC.config.unmap or WC.config.map)()
  else
    vim.notify(
      [[Usage:
  :WhichColorscheme disable
  :WhichColorscheme enable
  :WhichColorscheme toggle]],
      vim.log.levels.INFO
    )
  end
end, {
  nargs = 1,
  bar = true,
  complete = function(_, line) ---@param line string
    local split = vim.split(line, '%s+', { trimempty = false })
    local items = {} ---@type string[]
    if #split == 2 and split[1] == 'WhichColorscheme' then
      for _, option in ipairs({ 'disable', 'enable', 'toggle' }) do
        if vim.startswith(option, split[2]) then
          table.insert(items, option)
        end
      end
    end
    return items
  end,
})
