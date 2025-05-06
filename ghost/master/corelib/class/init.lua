local function inheritance(parent)
  local t = require(parent).class()
  return setmetatable({
    super = function() return t end,
  }, {
    __index = t
  })
end

local function new(_, class)
  class.__index = class
  return setmetatable({
    class = function() return class end,
  }, {
    __call = function(_, ...)
      local instance = setmetatable({}, class)
      if type(instance._init) == "function" then
        instance:_init(...)
      end
      return instance
    end,
  })
end

return setmetatable({
  inheritance = inheritance,
}, {
  __call = new
})
