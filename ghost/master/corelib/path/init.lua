local lc  = require("luachild")

local M = {}
local SEP = string.sub(package.config, 1, 1)

function M.join(...)
  local t = {...}
  return table.concat(t, SEP)
end

function M.basename(path)
  local match = string.match(path, [[.+[/\](.-)$]])
  return match or path
end

function M.dirname(path)
  local reverse = string.reverse(path)
  local pos = -1
  if string.sub(package.config, 1, 1) == "\\" then
    local p1 = string.find(reverse, "\\") or #reverse + 1
    local p2 = string.find(reverse, "/") or #reverse + 1
    local min = p1 < p2 and p1 or p2
    if min <= #reverse then
      pos = min
    end
  else
    pos = string.find(reverse, "/") or -1
  end
  if pos > 0 then
    local dirname = string.sub(path, 1, -pos)
    --print("dirname: " .. dirname)
    return dirname
  end
  return nil
end

function M.normalize(path)
  -- TODO stub
  return path
end

function M.relative(base, path)
  -- TODO stub
  base  = M.normalize(base)
  path  = M.normalize(path)
  return string.sub(path, #base + 1)
end

function M.dirWalk(path, func)
  for entry in lc.dir(path) do
    if entry.type == "directory" then
      M.dirWalk(path .. SEP .. entry.name, func)
    elseif entry.type == "file" then
      func(path .. SEP .. entry.name)
    end
  end
end

return M
