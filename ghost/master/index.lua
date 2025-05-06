local Socket  = require("socket")
local client  = Socket.connect("localhost", 39801)
if client then
  print_orig  = print
  print = function(...)
    print_orig(...)
    local size  = select("#", ...)
    if size > 0 then
      local str = tostring(select(1, ...))
      for i = 2, size do
        str = str .. "\t" .. tostring(select(i, ...))
      end
      client:send(str .. "\n")
    end
  end
end

-- うっかりグローバル変数を宣言したりするので確認用。
setmetatable(_G, {
  __newindex  = function(t, k, v)
    -- sol.から始まるのはまあ大体意図的なものなので無視
    if string.sub(k, 1, 4) ~= "sol." then
      print(debug.traceback("WARNING: attempt to write to undeclared variable: " .. tostring(k), 2))
    end
    rawset(t, k, v)
  end,
  __index = function(t, k)
    -- sol.から始まるのはまあ大体意図的なものなので無視
    if string.sub(k, 1, 4) ~= "sol." then
      print(debug.traceback("WARNING: attempt to read undeclared variable: " .. tostring(k), 2))
    end
  end,
})

local Shiori    = require("shiori")
local Module    = require("ukagaka_module.shiori")
local Request   = Module.Request

local shiori  = nil

local M = {}

function M.load(path)
  shiori  = Shiori()
  shiori:load(path)
  return true
end

function M.request(str)
  local req = Request.class().parse(str)
  local res = shiori:request(req)
  return res:tostring()
end

function M.unload()
  shiori:unload()
  return true
end

function M.debug()
  return shiori
end

return M
