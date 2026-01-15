---@module 'which-colorscheme._meta'

---@class WhichColorscheme.Util.String
local M = {}

---@class WhichColorscheme.Util.String.Alphabet
M.alphabet = {
  ---@class WhichColorscheme.Util.String.Alphabet.UpperList
  upper_list = {
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  },
  ---@class WhichColorscheme.Util.String.Alphabet.LowerList
  lower_list = {
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  },
  ---@class WhichColorscheme.Util.String.Alphabet.UpperMap
  upper_map = {
    A = 'A',
    B = 'B',
    C = 'C',
    D = 'D',
    E = 'E',
    F = 'F',
    G = 'G',
    H = 'H',
    I = 'I',
    J = 'J',
    K = 'K',
    L = 'L',
    M = 'M',
    N = 'N',
    O = 'O',
    P = 'P',
    Q = 'Q',
    R = 'R',
    S = 'S',
    T = 'T',
    U = 'U',
    V = 'V',
    W = 'W',
    X = 'X',
    Y = 'Y',
    Z = 'Z',
  },
  ---@class WhichColorscheme.Util.String.Alphabet.LowerMap
  lower_map = {
    a = 'a',
    b = 'b',
    c = 'c',
    d = 'd',
    e = 'e',
    f = 'f',
    g = 'g',
    h = 'h',
    i = 'i',
    j = 'j',
    k = 'k',
    l = 'l',
    m = 'm',
    n = 'n',
    o = 'o',
    p = 'p',
    q = 'q',
    r = 'r',
    s = 's',
    t = 't',
    u = 'u',
    v = 'v',
    w = 'w',
    x = 'x',
    y = 'y',
    z = 'z',
  },
  ---@class WhichColorscheme.Util.String.Alphabet.Vowels
  vowels = {
    upper_list = { 'A', 'E', 'I', 'O', 'U' }, ---@type { [1]: 'A', [2]: 'E', [3]: 'I', [4]: 'O', [5]: 'U' }
    lower_list = { 'a', 'e', 'i', 'o', 'u' }, ---@type { [1]: 'a', [2]: 'e', [3]: 'i', [4]: 'o', [5]: 'u' }
    ---@enum UpperVowel
    upper_map = { A = 'A', E = 'E', I = 'I', O = 'O', U = 'U' },
    ---@enum LowerVowel
    lower_map = { a = 'a', e = 'e', i = 'i', o = 'o', u = 'u' },
  },
}

---@class WhichColorscheme.Util.String.Digits
M.digits = {
  ---@enum AllDigits
  all = {
    ['0'] = '0',
    ['1'] = '1',
    ['2'] = '2',
    ['3'] = '3',
    ['4'] = '4',
    ['5'] = '5',
    ['6'] = '6',
    ['7'] = '7',
    ['8'] = '8',
    ['9'] = '9',
  },
  odd_list = { '1', '3', '5', '7', '9' }, ---@type { [1]: '1', [2]: '3', [3]: '5', [4]: '7', [5]: '9' }
  even_list = { '0', '2', '4', '6', '8' }, ---@type { [1]: '0', [2]: '2', [3]: '4', [4]: '6', [5]: '8' }
  ---@enum EvenDigits
  even_map = { ['0'] = '0', ['2'] = '2', ['4'] = '4', ['6'] = '6', ['8'] = '8' },
  ---@enum OddDigits
  odd_map = { ['1'] = '1', ['3'] = '3', ['5'] = '5', ['7'] = '7', ['9'] = '9' },
}

---@param str string
---@param use_dot boolean
---@param triggers string[]
---@return string new_str
---@overload fun(str: string): new_str: string
---@overload fun(str: string, use_dot: boolean): new_str: string
---@overload fun(str: string, use_dot?: boolean, triggers: string[]): new_str: string
function M.capitalize(str, use_dot, triggers)
  require('which-colorscheme.util').validate({
    str = { str, { 'string' } },
    use_dot = { use_dot, { 'boolean', 'nil' }, true },
    triggers = { triggers, { 'table', 'nil' }, true },
  })
  if str == '' then
    return str
  end

  use_dot = use_dot ~= nil and use_dot or false
  triggers = vim.tbl_deep_extend('force', triggers or {}, { ' ', '' })

  local strlen, dot = str:len(), true
  local prev_char, new_str, i = '', '', 1
  while i <= strlen do
    local char = str:sub(i, i)
    if char == char:lower() and vim.list_contains(triggers, prev_char) then
      char = dot and char:upper() or char:lower()
      if dot then
        dot = false
      end
    else
      char = char:lower()
    end

    if use_dot and not dot then
      dot = char == '.'
    elseif not use_dot then
      dot = true
    end

    new_str = ('%s%s'):format(new_str, char)
    prev_char = char
    i = i + 1
  end
  return new_str
end

---@param str string
---@param target string
---@param new string
---@return string new_str
function M.replace(str, target, new)
  require('which-colorscheme.util').validate({
    str = { str, { 'string' } },
    target = { target, { 'string' } },
    new = { new, { 'string' } },
  })
  if vim.list_contains({ str:len(), target:len(), new:len() }, 0) or new == target then
    return str
  end

  local new_str, len = '', str:len()
  for i = 1, len, 1 do
    local c = str:sub(i, i)
    c = c == target and new or c
    new_str = ('%s%s'):format(new_str, c)
  end
  return new_str
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
