local log = require("null0x686F_ContextCleaner/log")
local context_cleaner = require("null0x686F_ContextCleaner/context_cleaner")

local function _init()
  context_cleaner.init()
  log.info("null0x686F_ContextCleaner suite initialized successfully")
end

Events.OnGameStart.Add(_init)

return {
  init = _init
}
