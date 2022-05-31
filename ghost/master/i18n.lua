local path  = arg[1]
local ext   = arg[2]
local base  = arg[3]

package.path  = path .. "?.lua;" .. path .. "?/init.lua;" ..
                path .. "corelib/?.lua;" ..
                path .. "corelib/?/init.lua;" ..
                path .. "lib/?.lua;" ..
                path .. "lib/?/init.lua"

package.cpath = path .. "?." .. ext .. ";" ..
                path .. "?/init." .. ext .. ";" ..
                path .. "corelib/?." .. ext .. ";" ..
                path .. "corelib/?/init." .. ext .. ";" ..
                path .. "lib/?." .. ext .. ";" ..
                path .. "lib/?/init." .. ext

local Path          = require("path")

local function exist(t, id)
  for _, v in ipairs(t) do
    if v.id == id then
      return v.content
    end
  end
end

local existing  = loadfile(base, "t")
if existing then
  existing  = existing()
else
  existing  = {}
end
local cache = {}

print("return {")

local list  = {}

Path.dirWalk(path .. "talk", function(file_path)
  if string.sub(file_path, 1, 1) == "_" or string.sub(file_path, -4, -1) ~= ".lua" then
    return
  end
  table.insert(list, file_path)
end)
table.sort(list)
for _, v in ipairs(list) do
  print(string.format("-- %s", Path.relative(path .. "talk/", v)))
  local f = io.open(v, "r")
  local index = 1
  for line in f:lines() do
    string.gsub(line, [==[[^A-Za-z_]_T%("([^"]+)"%)]==], function(str)
      if cache[str] then
        print("-- duplicated")
        print("--[==[")
      end
      local t = exist(existing, str)
      if t then
        print(string.format([[  {
    i18n = true,
    id  = "%s",
    content = {]], str))
        for k, v in pairs(t) do
          local s = string.format([[        %s  = %q,]], k, v)
          s = string.gsub(s, "\\(%d%d%d)", function(num)
            local n = tonumber(num)
            if n >= 0x80 then
              return string.format("%s", string.char(n))
            else
              return string.format("\\%s", num)
            end
          end)
          print(s)
        end
        print([[    },
  },]])
      else
        print(string.format([[  {
    translate = true,
    id  = "%s",
    content = {
      Japanese  = ""
    },
  },]], str))
      end
      if cache[str] then
        print("--]==]")
      else
        cache[str]  = true
      end
      return str
    end)
    index = index + 1
  end
end

print("}")
