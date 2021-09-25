-- モジュールとしてひとまとめにしたい場合はtalkフォルダ内に書くより
-- こっちにまとめた方が良い。

local M = {}

function M.add(a, b)
  return a + b
end

function M.sub(a, b)
  return a - b
end

function M.mul(a, b)
  return a * b
end

function M.div(a, b)
  return a / b
end

return M
