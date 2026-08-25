local log = require("null0x686F_ContextCleaner/log")

local preset_manager = {}

-- moved out of Zomboid/Lua/'s root, which holds ~110 loose files from every
-- installed mod. LEGACY_FILE is the pre-move path: it is still read when the
-- new one is absent, and never written or deleted. the cost of keeping it is
-- 133 bytes sitting there; the cost of getting the move wrong is a published
-- mod silently losing a user's rules.
local PRESET_FILE = "null0x686F/contextcleaner_presets.txt"
local LEGACY_FILE = "ContextCleaner_preset_default.txt"

local DEFAULT_FOLD_TITLE = "[Utility Menus]"

local VALID_ACTIONS = { hide = true, fold = true }
local VALID_TYPES = { exact = true, wildcard = true, luapattern = true }
local VALID_SCOPES = { all = true, world = true, inventory = true }

-- the parenthesis is load-bearing: gsub returns (string, count), and without
-- it this function returns both. every existing call site happened to use the
-- result in a position that discards the second value, so it worked by luck.
local function _trim(str)
  return (tostring(str or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function _one_of(value, valid, fallback)
  value = _trim(value):lower()
  return valid[value] and value or fallback
end

local function _open_preset_reader()
  local reader = getFileReader(PRESET_FILE, false)
  if reader then return reader end

  reader = getFileReader(LEGACY_FILE, false)
  if reader then
    log.info("reading presets from the pre-move path; they migrate to", PRESET_FILE, "on next save")
  end
  return reader
end

local function _parse_rule(line, rules)
  local parts = {}
  for part in line:gmatch("[^|]+") do
    parts[#parts + 1] = _trim(part)
  end

  local pattern = parts[1] or ""
  if pattern == "" then return end

  local default_type = pattern:find("%*") and "wildcard" or "exact"

  rules[#rules + 1] = {
    pattern = pattern,
    action = _one_of(parts[2], VALID_ACTIONS, "hide"),
    type = _one_of(parts[3] or default_type, VALID_TYPES, "exact"),
    scope = _one_of(parts[4], VALID_SCOPES, "all"),
  }
end

function preset_manager.load_preset()
  local data = { fold_title = DEFAULT_FOLD_TITLE, rules = {} }

  local reader = _open_preset_reader()
  if not reader then return data end

  local line = reader:readLine()
  while line do
    local trimmed = _trim(line)
    if trimmed ~= "" and not trimmed:find("^#") then
      if trimmed:find("^fold_title=") then
        local title = _trim(trimmed:sub(12))
        if title ~= "" then data.fold_title = title end
      else
        _parse_rule(trimmed, data.rules)
      end
    end
    line = reader:readLine()
  end

  reader:close()
  return data
end

function preset_manager.save_preset(data)
  if type(data) ~= "table" then return false end

  local writer = getFileWriter(PRESET_FILE, true, false)
  if not writer then return false end

  writer:write(string.format("fold_title=%s\n", data.fold_title or DEFAULT_FOLD_TITLE))

  for _, rule in ipairs(data.rules or {}) do
    if rule.pattern and rule.pattern ~= "" then
      writer:write(string.format("%s|%s|%s|%s\n",
        rule.pattern,
        (rule.action or "hide"):lower(),
        (rule.type or "exact"):lower(),
        (rule.scope or "all"):lower()))
    end
  end

  writer:close()
  return true
end

return preset_manager
