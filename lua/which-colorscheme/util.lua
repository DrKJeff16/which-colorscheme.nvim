---@module 'which-colorscheme._meta'

local direction_funcs = { ---@type DirectionFuncs
  r = function(t)
    local keys = vim.tbl_keys(t) ---@type string[]
    table.sort(keys)

    local res = {} ---@type table<string, any>
    for i, v in ipairs(keys) do
      res[v] = t[keys[i == 1 and #keys or (i - 1)]]
    end
    return res
  end,
  l = function(t)
    local keys = vim.tbl_keys(t) ---@type string[]
    table.sort(keys)

    local res = {} ---@type table<string, any>
    for i, v in ipairs(keys) do
      res[v] = t[keys[i == #keys and 1 or (i + 1)]]
    end
    return res
  end,
}

---@class WhichColorscheme.Util
local M = {}

---@generic T: any
---@param t type
---@param data T
---@param sep? string
---@param constraints? string[]
---@return string
---@return boolean|nil
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
    if not M.is_type('table', constraints) then
      return res
    end
    if constraints ~= nil and vim.list_contains(constraints, data) then
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
    k = M.is_type('number', k) and ('[%s]'):format(tostring(k)) or k
    msg = ('%s\n%s`%s`: '):format(msg, sep, k)
    if not M.is_type('string', v) then
      msg = ('%s%s'):format(msg, M.format_per_type(type(v), v, sep))
    else
      msg = ('%s`"%s"`'):format(msg, v)
    end
  end
  return msg
end

---@param feature string
---@return boolean has
---@nodiscard
function M.vim_has(feature)
  return vim.fn.has(feature) == 1
end

---@generic T: string
---@param T T[]
---@param item string|number|boolean
---@return T[] T
---@nodiscard
function M.move_start(T, item)
  M.validate({
    T = { T, { 'table' } },
    item = { item, { 'string', 'number', 'boolean' } },
  })

  local new_list = { item } ---@type any[]
  for _, v in ipairs(T) do
    if v ~= item then
      table.insert(new_list, v)
    end
  end

  return T
end

---Dynamic `vim.validate()` wrapper which covers both legacy and newer implementations.
--- ---
---@param T table<string, vim.validate.Spec|ValidateSpec>
function M.validate(T)
  local max = M.vim_has('nvim-0.11') and 3 or 4
  for name, spec in pairs(T) do
    while #spec > max do
      table.remove(spec, #spec)
    end
    T[name] = spec
  end

  if M.vim_has('nvim-0.11') then
    for name, spec in pairs(T) do
      table.insert(spec, 1, name)
      vim.validate(unpack(spec))
    end
    return
  end

  vim.validate(T)
end

---Checks whether nvim is running on Windows.
--- ---
---@return boolean win32
---@nodiscard
function M.is_windows()
  return M.vim_has('win32')
end

---Get rid of all duplicates in the given list.
---
---If the list is empty it'll just return it as-is.
---
---If the data passed to the function is not a table,
---an error will be raised.
--- ---
---@generic T
---@param T T[]
---@return T[] NT
---@nodiscard
function M.dedup(T)
  M.validate({ T = { T, { 'table' } } })

  if vim.tbl_isempty(T) then
    return T
  end
  if not vim.islist(T) then
    error('Table is not list-like!', vim.log.levels.ERROR)
  end

  local NT = {} ---@type any[]
  for _, v in ipairs(T) do
    local not_dup = false
    ---@cast v table
    if M.is_type('table', v) then
      not_dup = not vim.tbl_contains(NT, function(val)
        return vim.deep_equal(val, v)
      end, { predicate = true })
    else
      ---@cast v any
      not_dup = not vim.list_contains(NT, v)
    end
    if not_dup then
      table.insert(NT, v)
    end
  end
  return NT
end

---@param c string
---@param direction? 'next'|'prev'
---@return string letter
---@nodiscard
function M.displace_letter(c, direction)
  M.validate({
    c = { c, { 'string' } },
    direction = { direction, { 'string', 'nil' }, true },
  })
  direction = direction or 'next'
  direction = vim.list_contains({ 'next', 'prev' }, direction) and direction or 'next'

  local A = vim.deepcopy(require('which-colorscheme.util.string').alphabet)
  ---@type string[], string[]
  local LOWER_K, UPPER_K = vim.tbl_keys(A.lower_map), vim.tbl_keys(A.upper_map)
  if not (vim.list_contains(LOWER_K, c) or vim.list_contains(UPPER_K, c)) then
    return 'a'
  end

  local d = direction == 'prev' and 'r' or 'l'
  return M.mv_tbl_values(vim.list_contains(LOWER_K, c) and A.lower_map or A.upper_map, 0, d)[c]
end

---@param T table<string|integer, any>
---@return integer len
---@nodiscard
function M.get_dict_size(T)
  M.validate({ T = { T, { 'table' } } })

  if vim.tbl_isempty(T) then
    return 0
  end

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
---@generic T
---@param T T[]
---@return T[] T
---@nodiscard
function M.reverse(T)
  M.validate({ T = { T, { 'table' } } })

  if vim.tbl_isempty(T) then
    return T
  end

  local len = #T
  for i = 1, math.floor(len / 2) do
    T[i], T[len - i + 1] = T[len - i + 1], T[i]
  end
  return T
end

---@generic T
---@param T T[]
---@return T[] new_list
---@nodiscard
function M.randomize_list(T)
  M.validate({ T = { T, { 'table' } } })
  if not vim.islist(T) then
    error('Table is not a list!', vim.log.levels.ERROR)
  end
  if vim.tbl_isempty(T) then
    return T
  end

  local new_list = {} ---@type (string|number)[]
  local len = #T
  while #new_list < len do
    local item = T[math.random(1, len)]
    if not vim.list_contains(new_list, item) then
      table.insert(new_list, item)
    end
  end
  return new_list
end

---@param T table<string, any>
---@param steps? integer
---@param direction? 'l'|'r'
---@return table<string, any> res
---@nodiscard
function M.mv_tbl_values(T, steps, direction)
  M.validate({
    T = { T, { 'table' } },
    steps = { steps, { 'number' } },
    direction = { direction, { 'string', 'nil' }, true },
  })
  steps = (steps and M.is_int(steps, steps > 0)) and steps or 1
  direction = (direction and vim.list_contains({ 'l', 'r' }, direction)) and direction or 'r'

  local res, func = T, direction_funcs[direction]
  while steps > 0 do
    res = func(res)
    steps = steps - 1
  end
  return res
end

---Checks if module `mod` exists to be imported.
--- ---
---@param mod string The `require()` argument to be checked
---@param return_mod? boolean Whether to return the called module
---@return boolean exists A boolean indicating whether the module exists or not
---@return unknown? module
---@nodiscard
function M.mod_exists(mod, return_mod)
  M.validate({
    mod = { mod, { 'string' } },
    return_mod = { return_mod, { 'boolean', 'nil' }, true },
  })
  return_mod = return_mod ~= nil and return_mod or false

  if mod == '' then
    return false
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
---@param cond? boolean
---@return boolean int
---@nodiscard
function M.is_int(num, cond)
  M.validate({
    num = { num, { 'number' } },
    cond = { cond, { 'boolean', 'nil' }, true },
  })
  cond = cond ~= nil and cond or true

  local is_int = math.floor(num) == num and math.ceil(num) == num
  return is_int and cond
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

  ---@cast exe string
  if M.is_type('string', exe) then
    return vim.fn.executable(exe) == 1
  end

  local res = false

  ---@cast exe string[]
  for _, v in ipairs(exe) do
    res = M.executable(v)
    if not res then
      break
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

  ---@cast char string[]
  if M.is_type('table', char) then
    if not vim.tbl_isempty(char) then
      for _, c in ipairs(char) do
        str = M.lstrip(c, str)
      end
    end
    return str
  end

  ---@cast char string
  if not vim.startswith(str, char) or char:len() > str:len() then
    return str
  end

  local i, len, new_str = 1, str:len(), ''
  local other = false
  while i <= len and i + char:len() - 1 <= len do
    if str:sub(i, i + char:len() - 1) ~= char and not other then
      other = true
    end
    if other then
      new_str = ('%s%s'):format(new_str, str:sub(i, i))
    end
    i = i + 1
  end
  return new_str
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

  ---@cast char string[]
  if M.is_type('table', char) then
    if not vim.tbl_isempty(char) then
      for _, c in ipairs(char) do
        str = M.rstrip(c, str)
      end
    end
    return str
  end

  ---@cast char string
  if char:len() > str:len() then
    return str
  end

  if not vim.startswith(str:reverse(), char) then
    return str
  end

  return M.lstrip(char, str:reverse()):reverse()
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

  if M.is_type('table', char) then
    ---@cast char string[]
    if not vim.tbl_isempty(char) then
      for _, c in ipairs(char) do
        str = M.strip(c, str)
      end
    end
    return str
  end

  ---@cast char string
  if char:len() > str:len() then
    return str
  end

  return M.rstrip(char, M.lstrip(char, str))
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
