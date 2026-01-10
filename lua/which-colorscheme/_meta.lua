---@meta

---@class WhichColorschemeGroup
---@field [1]? string
---@field [2]? string
---@field [3]? string
---@field [4]? string
---@field [5]? string
---@field [6]? string
---@field [7]? string
---@field [8]? string
---@field [9]? string

---@alias WhichColorschemeGroups table <string, WhichColorschemeGroup>

---@class WhichColorschemeGroupping
---@field uppercase_groups? boolean
---@field random? boolean
---@field inverse? boolean
---@field current_first? boolean

---@class WhichColorschemeOpts
---@field prefix? string
---@field group_name? string
---@field include_builtin? boolean
---@field grouping? WhichColorschemeGroupping
---@field custom_groups? WhichColorschemeGroups

-- vim: set ts=2 sts=2 sw=2  ai si sta:
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
