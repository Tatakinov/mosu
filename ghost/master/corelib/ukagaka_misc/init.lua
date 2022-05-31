local M = {}

if string.sub(package.config, 1, 1) == "\\" then
  M = require("ukagaka_misc.windows_wrap")
else
end

return M
