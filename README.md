# which-colorscheme.nvim

Use [`which-key.nvim`](https://github.com/folke/which-key.nvim) bindings to cycle between your colorschemes.

https://github.com/user-attachments/assets/c098edd7-fc92-45e4-9312-cecf9f222428

---

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
  - [Custom Grouping](#custom-grouping)
- [License](#license)

---

## Installation

**Requirements**:

- Neovim >= v0.9.0
- [`which-key.nvim`](https://github.com/folke/which-key.nvim)

[`folke/lazy.nvim`](https://github.com/folke/lazy.nvim) is highly recommended to install this plugin!

**IMPORTANT**: Load `which-key.nvim` and all your colorschemes BEFORE you load this plugin!

```lua
{
  'DrKJeff16/which-colorscheme.nvim',
  event = 'VeryLazy', -- IMPORTANT
  dependencies = { 'folke/which-key.nvim' },
  opts = {},
}
```

---

## Configuration

The default setup options are the following:

```lua
{
  prefix = '<leader>C', -- The prefix to your keymap
  group_name = 'Colorschemes', -- The prefix group in `which-key.nvim`
  include_builtin = false, -- Whether to include the built-in Neovim colorschemes
  custom_groups = {}, -- Custom groups for colorschemes (see the `Custom Groups` section below)
  grouping = {
    uppercase_groups = false, -- Whether to use uppercase groups for keymaps
    random = false, -- Whether to randomize the mappings
    inverse = false, -- Whether to map your colorschemes from z-a (if random is `true`, this does nothing)
    current_first = true, -- Whether to put the current colorscheme in the first group
  },
}
```

### Custom Grouping

If you wish to order your colorschemes manually you can use the `custom_groups` option:

```lua
require('which-colorscheme').setup({
  custom_groups = {
    A = { 'tokyonight', 'tokyonight-storm', 'tokyonight-moon', 'tokyonight-night', 'tokyonight-day' },
    -- Skip section B
    C = { '', 'catppuccin' }, -- Blank strings are ignored
    D = { 'foo' }, -- If `foo` is not a colorscheme it'll get skipped
  },
})
```

https://github.com/user-attachments/assets/53e72f8e-71cc-4cf8-9a6c-5927b3fb7fad

---

## License

[MIT](./LICENSE)

<!-- vim: set ts=2 sts=2 sw=2 et ai si sta: -->
