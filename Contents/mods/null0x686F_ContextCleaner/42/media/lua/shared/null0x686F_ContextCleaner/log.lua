local cfg = require("null0x686F_ContextCleaner/cfg")
local core_log = require("null0x686F_CoreLib/utils/log")

local function _get_level()
  if isDebugEnabled and isDebugEnabled() then
    return "debug"
  end
  return (cfg and cfg.LOG_LEVEL) or "info"
end

return core_log.new("null0x686F_ContextCleaner", _get_level)
