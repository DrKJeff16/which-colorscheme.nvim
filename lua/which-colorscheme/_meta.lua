---@meta

---Non-legacy validation spec (>=v0.11)
---@class ValidateSpec
---@field [1] any
---@field [2] vim.validate.Validator
---@field [3]? boolean
---@field [4]? string

---@alias DirectionFunc fun(t: table<string, any>): new_direction: table<string, any>

---@class DirectionFuncs
---@field r DirectionFunc
---@field l DirectionFunc

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

---@class WhichColorschemeGrouping.Labels
---@field a? string
---@field b? string
---@field c? string
---@field d? string
---@field e? string
---@field f? string
---@field g? string
---@field h? string
---@field i? string
---@field j? string
---@field k? string
---@field l? string
---@field m? string
---@field n? string
---@field o? string
---@field p? string
---@field q? string
---@field r? string
---@field s? string
---@field t? string
---@field u? string
---@field v? string
---@field w? string
---@field x? string
---@field y? string
---@field z? string
---@field A? string
---@field B? string
---@field C? string
---@field D? string
---@field E? string
---@field F? string
---@field G? string
---@field H? string
---@field I? string
---@field J? string
---@field K? string
---@field L? string
---@field M? string
---@field N? string
---@field O? string
---@field P? string
---@field Q? string
---@field R? string
---@field S? string
---@field T? string
---@field U? string
---@field V? string
---@field W? string
---@field X? string
---@field Y? string
---@field Z? string

---@class WhichColorschemeGrouping
---@field uppercase_groups? boolean
---@field random? boolean
---@field inverse? boolean
---@field current_first? boolean
---@field labels? WhichColorschemeGrouping.Labels|table<Letter, string>

---@class WhichColorschemeOpts
---@field prefix? string
---@field group_name? string
---@field include_builtin? boolean
---@field grouping? WhichColorschemeGrouping
---@field custom_groups? WhichColorschemeGroups

---@enum (key) Letter
local Letter = { ---@diagnostic disable-line:unused-local
  a = 1,
  b = 1,
  c = 1,
  d = 1,
  e = 1,
  f = 1,
  g = 1,
  h = 1,
  i = 1,
  j = 1,
  k = 1,
  l = 1,
  m = 1,
  n = 1,
  o = 1,
  p = 1,
  q = 1,
  r = 1,
  s = 1,
  t = 1,
  u = 1,
  v = 1,
  w = 1,
  x = 1,
  y = 1,
  z = 1,
  A = 1,
  B = 1,
  C = 1,
  D = 1,
  E = 1,
  F = 1,
  G = 1,
  H = 1,
  I = 1,
  J = 1,
  K = 1,
  L = 1,
  M = 1,
  N = 1,
  O = 1,
  P = 1,
  Q = 1,
  R = 1,
  S = 1,
  T = 1,
  U = 1,
  V = 1,
  W = 1,
  X = 1,
  Y = 1,
  Z = 1,
}

-- vim: set ts=2 sts=2 sw=2 et ai si sta:
