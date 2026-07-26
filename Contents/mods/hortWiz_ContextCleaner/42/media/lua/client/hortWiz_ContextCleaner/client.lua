local log = require("hortWiz_ContextCleaner/log")
local context_cleaner = require("hortWiz_ContextCleaner/context_cleaner")

local function _init()
  context_cleaner.init()
  log.info("HortWiz_ContextCleaner suite initialized successfully")
end

Events.OnGameStart.Add(_init)

return {
  init = _init
}
