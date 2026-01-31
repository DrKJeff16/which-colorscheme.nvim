# which-colorscheme.nvim

Use [`which-key.nvim`](https://github.com/folke/which-key.nvim) bindings to cycle between your colorschemes.

https://github.com/user-attachments/assets/c098edd7-fc92-45e4-9312-cecf9f222428

---

## Table of Contents

- [Installation](#installation)
  - [LuaRocks](#luarocks)
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

### LuaRocks

You can also install this through [LuaRocks](https://luarocks.org/modules/drkjeff16/which-colorscheme.nvim):

```bash
luarocks install which-colorscheme.nvim # Global install
luarocks install --local which-colorscheme.nvim # Local install
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
    labels = {}, -- The labels assigned to a given group (see the `Labeling` section below)
    uppercase_groups = false, -- Whether to use uppercase groups for keymaps
    random = false, -- Whether to randomize the mappings
    inverse = false, -- Whether to map your colorschemes from z-a (if random is `true`, this does nothing)
    current_first = true, -- Whether to put the current colorscheme in the first group
  },
}
```

### Custom Grouping

https://github.com/user-attachments/assets/53e72f8e-71cc-4cf8-9a6c-5927b3fb7fad

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

### Labeling

![Labeling](https://github.com/user-attachments/assets/e782f65d-7802-4e72-9430-c637e7be283d)

You can add custom group names to any desired group section:

```lua
require('which-colorscheme').setup({
  grouping = {
    labels = {
      A = 'Favorites',
      B = '', -- The default `B` group name will be used
      C = '    ', -- The default `C` group name will be used
      E = 'Extras', -- The `D` group will fall back to its default value
      F = '    Foo   ', -- Will be stripped down to `Foo`
    },
  },
})
```

---

## License

[MIT](./LICENSE)

<!-- vim: set ts=2 sts=2 sw=2 et ai si sta: -->
