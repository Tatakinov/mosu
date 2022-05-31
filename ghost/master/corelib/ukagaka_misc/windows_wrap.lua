local Native  = require("ukagaka_misc.windows")

local M = {}

function M.getFMO(name)
  name  = name or "Sakura"
  return Native.getFMO(name)
end

function M.sendSSTP(unique_id, str)
  Native.sendSSTP(unique_id, str)
end

function M.speak(unique_id, talk)
  local str = string.format(
    "NOTIFY SSTP/1.1\r\n" ..
    "Charset: UTF-8\r\n" ..
    "Sender: Kagari\r\n" ..
    "Script: %s\r\n" ..
    "ID: %s\r\n" ..
    "HWnd: 0\r\n" ..
    "\r\n",
    talk, unique_id)
  return M.sendSSTP(unique_id, str)
end

return M
