local cfg = require("hortWiz_ContextCleaner/cfg")
local core_log = require("hortWiz_Core/log")

local function _get_level()
  if isDebugEnabled and isDebugEnabled() then
    return "debug"
  end
  return (cfg and cfg.LOG_LEVEL) or "info"
end

return core_log.new("HortWiz_ContextCleaner", _get_level)
