---@module 'which-colorscheme._meta'

---@class WhichColorscheme.Util
---@field string WhichColorscheme.Util.String
local M = {}

---@generic T: table, F
---@param t T
---@param k any
---@param fallback F
---@return F fallback
local function get(t, k, fallback)
  return M.get(t, k, function()
    return M.rawset(t, k, fallback)
  end, true)
end

setmetatable(M, {
  __index = function(self, k) ---@param self WhichColorscheme.Util
    local raw = M.get(self, k)
    if raw ~= nil then
      return raw
    end

    if type(k) ~= 'string' then
      return
    end

    ---@cast k string
    if self.mod_exists('which-colorscheme.util.' .. k) then
      return get(self, k, require('which-colorscheme.util.' .. k))
    end
  end,
})

---@class DirectionFuncs
M.direction_funcs = {}

---@generic T
---@param t T
---@return T res
---@nodiscard
function M.direction_funcs.r(t)
  local keys = vim.tbl_keys(t) ---@type string[]
  table.sort(keys)

  local res = {}
  for i, v in ipairs(keys) do
    res[v] = t[keys[i == 1 and #keys or (i - 1)]]
  end
  return res
end
function M.direction_funcs.l(t)
  local res = {} ---@type table<string, any>
  local keys = vim.tbl_keys(t) --[[@as string[]\]]
  table.sort(keys)

  for i, v in ipairs(keys) do
    res[v] = t[keys[i == #keys and 1 or (i + 1)]]
  end
  return res
end

---@param t type
---@param data any
---@param sep string
---@param constraints string[]
---@return string txt
---@return boolean|nil|? ok
---@overload fun(t: type, data: any): txt: string, ok: boolean|nil|?
---@overload fun(t: type, data: any, sep: string): txt: string, ok: boolean|nil|?
---@overload fun(t: type, data: any, sep: nil, constraints: string[]): txt: string, ok: boolean|nil|?
---@nodiscard
function M.format_per_type(t, data, sep, constraints)
  M.validate({
    t = { t, { 'string' } },
    sep = { sep, { 'string', 'nil' }, true },
    constraints = { constraints, { 'table', 'nil' }, true },
  })
  sep = sep or ''
  constraints = constraints or nil

  if t == 'string' then
    local res = ('%s`"%s"`'):format(sep, data)
    if type(constraints) ~= 'table' or (constraints and vim.list_contains(constraints, data)) then
      return res
    end
    return res, true
  end
  if vim.list_contains({ 'number', 'boolean' }, t) then
    return ('%s`%s`'):format(sep, tostring(data))
  end
  if t == 'function' then
    return ('%s`%s`'):format(sep, t)
  end

  local msg = ''
  if t == 'nil' then
    return ('%s%s `nil`'):format(sep, msg)
  end
  if t ~= 'table' then
    return ('%s%s `?`'):format(sep, msg)
  end
  if vim.tbl_isempty(data) then
    return ('%s%s `{}`'):format(sep, msg)
  end

  sep = ('%s '):format(sep)
  for k, v in pairs(data) do
    msg = ('%s\n%s`%s`: '):format(msg, sep, type(k) == 'number' and ('[%s]'):format(tostring(k)) or k)
    msg = type(v) == 'string' and ('%s`"%s"`'):format(msg, v)
      or ('%s%s'):format(msg, M.format_per_type(type(v), v, sep))
  end
  return msg
end

---@param feature string
---@return boolean has
---@nodiscard
function M.vim_has(feature)
  return vim.fn.has(feature) == 1
end

---@param T string[]
---@param item string
---@return string[] T
---@nodiscard
function M.move_start(T, item)
  M.validate({
    T = { T, { 'table' } },
    item = { item, { 'string' } },
  })

  for i = 1, #T do
    if T[i] == item then
      table.remove(T, i)
      break
    end
    if i >= 9 then
      table.remove(T, i)
    end
  end
  table.insert(T, 1, item)
  return T
end

---Dynamic `vim.validate()` wrapper which covers both legacy and newer implementations.
--- ---
---@param T table<string, vim.validate.Spec|WhichColorscheme.ValidateSpec>
function M.validate(T)
  local max = vim.fn.has('nvim-0.11') == 1 and 4 or 3
  for name, spec in pairs(T) do
    while #spec > max do
      table.remove(spec, #spec)
    end
    T[name] = spec
  end

  if max == 3 then
    ---@cast T vim.validate.Spec
    vim.validate(T)
  else
    ---@cast T WhichColorscheme.ValidateSpec
    for name, spec in pairs(T) do
      table.insert(spec, 1, name)
      vim.validate(unpack(spec))
    end
  end
end

---Checks whether nvim is running on Windows.
--- ---
---@return boolean win32
---@nodiscard
function M.is_windows()
  return vim.fn.has('win32') == 1
end

---Get rid of all duplicates in the given list.
---
---If the list is empty it'll just return it as-is.
---
---If the data passed to the function is not a table,
---an error will be raised.
--- ---
---@generic T: table
---@param T T
---@return T NT
---@nodiscard
function M.dedup(T)
  M.validate({ T = { T, { 'table' } } })

  if vim.islist(T) then
    local NT = {} ---@type any[]
    for _, v in ipairs(T) do
      local not_dup = false
      if type(v) == 'table' then
        not_dup = not vim.tbl_contains(NT, function(val)
          return vim.deep_equal(val, v)
        end, { predicate = true })
      else
        not_dup = not vim.list_contains(NT, v)
      end
      if not_dup then
        table.insert(NT, v)
      end
    end
    T = vim.deepcopy(NT)
  end
  return T
end

---@param c string
---@param direction 'next'|'prev'
---@return string letter
---@overload fun(c: string): letter: string
---@nodiscard
function M.displace_letter(c, direction)
  M.validate({
    c = { c, { 'string' } },
    direction = { direction, { 'string', 'nil' }, true },
  })
  direction = direction or 'next'
  direction = vim.list_contains({ 'next', 'prev' }, direction) and direction or 'next'

  return not (vim.tbl_contains(M.string.alphabet.lower_map, c) or vim.tbl_contains(M.string.alphabet.upper_map, c))
      and 'a'
    or M.mv_tbl_values(
      vim.tbl_contains(M.string.alphabet.lower_map, c) and M.string.alphabet.lower_map or M.string.alphabet.upper_map,
      nil,
      direction == 'prev' and 'r' or 'l'
    )[c]
end

---@param T table
---@return integer len
---@nodiscard
function M.get_dict_size(T)
  M.validate({ T = { T, { 'table' } } })

  local len = 0
  for _ in pairs(T) do
    len = len + 1
  end
  return len
end

---Reverses a given list-like table.
---
---If the passed data is an empty table it'll be returned as-is.
---
---If the data passed to the function is not a table,
---an error will be raised.
--- ---
---@generic T: table
---@param T T
---@return T T
---@nodiscard
function M.reverse(T)
  M.validate({ T = { T, { 'table' } } })

  for i = 1, math.floor(#T / 2) do
    T[i], T[#T - i + 1] = T[#T - i + 1], T[i]
  end
  return T
end

---@generic T: table
---@param T T
---@return T new_list
---@nodiscard
function M.randomize_list(T)
  M.validate({ T = { T, { 'table' } } })

  assert(vim.islist(T), 'Table is not list-like')

  local new_list = {} ---@type table
  while #new_list < #T do
    local item = T[math.random(1, #T)]
    if not vim.list_contains(new_list, item) then
      table.insert(new_list, item)
    end
  end
  return new_list
end

---@param T table<string, any>
---@param steps integer
---@param direction 'l'|'r'
---@return table<string, any> T
---@overload fun(T: table<string, any>): T: table<string, any>
---@overload fun(T: table<string, any>, steps: integer): T: table<string, any>
---@overload fun(T: table<string, any>, steps: nil, directior: 'l'|'r'): T: table<string, any>
---@nodiscard
function M.mv_tbl_values(T, steps, direction)
  M.validate({
    T = { T, { 'table' } },
    steps = { steps, { 'number', 'nil' }, true },
    direction = { direction, { 'string', 'nil' }, true },
  })
  steps = (steps and M.is_int(steps)) and steps or 1
  direction = (direction and vim.list_contains({ 'l', 'r' }, direction)) and direction or 'r'

  local func = M.direction_funcs[direction] --[[@as fun(t: any): t: table<string, any>]]
  while steps > 0 do
    T, steps = func(T), steps - 1
  end
  return T
end

---Checks if module `mod` exists to be imported.
--- ---
---@param mod string The `require()` argument to be checked
---@param return_mod boolean Whether to return the called module
---@return boolean exists A boolean indicating whether the module exists or not
---@return unknown|nil|? module
---@overload fun(mod: string): exists: boolean
---@nodiscard
function M.mod_exists(mod, return_mod)
  M.validate({
    mod = { mod, { 'string' } },
    return_mod = { return_mod, { 'boolean', 'nil' }, true },
  })
  if return_mod == nil then
    return_mod = false
  end

  local exists, module = pcall(require, mod)
  if return_mod then
    return exists, module
  end
  return exists
end

---Checks if a given number is type integer.
--- ---
---@param num number
---@param cond boolean
---@return boolean int
---@overload fun(num: number): int: boolean
---@nodiscard
function M.is_int(num, cond)
  M.validate({
    num = { num, { 'number' } },
    cond = { cond, { 'boolean', 'nil' }, true },
  })
  if cond == nil then
    cond = true
  end

  return math.floor(num) == num and math.ceil(num) == num and cond
end

---Checks whether `data` is of type `t` or not.
---
---If `data` is `nil`, the function will always return `false`.
--- ---
---@generic T: any
---@param t type Any return value the `type()` function would return
---@param data T The data to be type-checked
---@return boolean correct_type
---@nodiscard
function M.is_type(t, data)
  return data ~= nil and type(data) == t
end

---@param exe string[]|string
---@return boolean is_executable
---@nodiscard
function M.executable(exe)
  M.validate({ exe = { exe, { 'string', 'table' } } })

  local res = false ---@type boolean
  if type(exe) == 'string' then
    res = vim.fn.executable(exe) == 1
  else
    for _, v in ipairs(exe) do
      res = M.executable(v)
      if not res then
        break
      end
    end
  end
  return res
end

---Left strip given a leading string (or list of strings) within a string, if any.
--- ---
---@param char string[]|string
---@param str string
---@return string new_str
---@nodiscard
function M.lstrip(char, str)
  M.validate({
    char = { char, { 'string', 'table' } },
    str = { str, { 'string' } },
  })

  if str == '' then
    return str
  end

  if type(char) == 'table' then
    for _, c in ipairs(char) do
      str = M.lstrip(c, str)
    end
  elseif vim.startswith(str, char) and char:len() <= str:len() then
    local i, new_str, other = 1, '', false
    while i <= str:len() and i + char:len() - 1 <= str:len() do
      if str:sub(i, i + char:len() - 1) ~= char and not other then
        other = true
      end
      if other then
        new_str = ('%s%s'):format(new_str, str:sub(i, i))
      end
      i = i + 1
    end

    str = new_str --[[@as string]]
  end
  return str
end

---Right strip given a leading string (or list of strings) within a string, if any.
--- ---
---@param char string[]|string
---@param str string
---@return string new_str
---@nodiscard
function M.rstrip(char, str)
  M.validate({
    char = { char, { 'string', 'table' } },
    str = { str, { 'string' } },
  })

  if str == '' then
    return str
  end

  if type(char) == 'table' then
    for _, c in ipairs(char) do
      str = M.rstrip(c, str)
    end
  elseif char:len() <= str:len() and vim.startswith(str:reverse(), char) then
    str = M.lstrip(char, str:reverse()):reverse()
  end
  return str
end

---Strip given a leading string (or list of strings) within a string, if any, bidirectionally.
--- ---
---@param char string[]|string
---@param str string
---@return string new_str
---@nodiscard
function M.strip(char, str)
  M.validate({
    char = { char, { 'string', 'table' } },
    str = { str, { 'string' } },
  })

  if str == '' then
    return str
  end

  if type(char) == 'table' then
    for _, c in ipairs(char) do
      str = M.strip(c, str)
    end
  elseif char:len() <= str:len() then
    str = M.rstrip(char, M.lstrip(char, str))
  end
  return str
end

---@generic T: table, V
---@param t T
---@param k string|integer
---@param v V
---@return V v
function M.rawset(t, k, v)
  rawset(t, k, v)
  return v
end

---@generic T: table, F, K, V
---@param t T<K, V>
---@param k K
---@param fallback F|fun(): raw: F
---@param is_rawset boolean
---@return F|V?
---@overload fun(t: T<K, V>, k: K): raw: V?
---@overload fun(t: T<K, V>, k: K, fallback: F): raw: F|V
---@overload fun(t: T<K, V>, k: K, fallback: F, is_rawset: false): raw: F|V
---@overload fun(t: T<K, V>, k: K, fallback: (fun(): raw: F), is_rawset: true): raw: F|V
function M.get(t, k, fallback, is_rawset)
  if is_rawset == nil then
    is_rawset = false
  end

  if k ~= nil then
    local raw = rawget(t, k) or nil --[[@as unknown|nil|?]]
    if raw ~= nil or fallback == nil then
      return raw
    end

    if is_rawset then
      ---@cast fallback fun(): any
      local _, res = pcall(fallback)
      return res
    end
    ---@cast fallback any
    return fallback
  end
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
