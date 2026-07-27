local log = require("null0x686F_ContextCleaner/log")

local _tostring = tostring
local _type = type
local _pairs = pairs
local _ipairs = ipairs
local _string_sub = string.sub
local _string_find = string.find
local _string_format = string.format

local preset_manager = {}

local function _trim(str)
  return _tostring(str or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function preset_manager.get_preset_filename(preset_id)
  return "ContextCleaner_preset_default.txt"
end

function preset_manager.load_preset(preset_id)
  local data = {
    fold_title = "[Utility Menus]",
    rules = {}
  }

  local filename = preset_manager.get_preset_filename(preset_id)
  local reader = getFileReader(filename, false)
  if not reader then
    return data
  end

  local line = reader:readLine()
  while line do
    local trimmed = _trim(line)
    if trimmed ~= "" and not trimmed:find("^#") then
      if trimmed:find("^fold_title=") then
        local val = _trim(trimmed:sub(12))
        if val ~= "" then data.fold_title = val end
      else
        local parts = {}
        for part in trimmed:gmatch("[^|]+") do
          parts[#parts + 1] = _trim(part)
        end

        local pattern = parts[1] or ""
        local action = _string_sub(_trim(parts[2] or "hide"):lower(), 1, 10)
        local ptype = _string_sub(_trim(parts[3] or (pattern:find("%*") and "wildcard" or "exact")):lower(), 1, 10)
        local scope = _string_sub(_trim(parts[4] or "all"):lower(), 1, 10)

        if action ~= "hide" and action ~= "fold" then action = "hide" end
        if ptype ~= "exact" and ptype ~= "wildcard" and ptype ~= "luapattern" then ptype = "exact" end
        if scope ~= "all" and scope ~= "world" and scope ~= "inventory" then scope = "all" end

        if pattern ~= "" then
          data.rules[#data.rules + 1] = {
            pattern = pattern,
            action = action,
            type = ptype,
            scope = scope,
            raw = _string_format("%s|%s|%s|%s", pattern, action, ptype, scope)
          }
        end
      end
    end
    line = reader:readLine()
  end

  reader:close()
  return data
end

function preset_manager.save_preset(preset_id, data)
  if not data or _type(data) ~= "table" then return false end
  local filename = preset_manager.get_preset_filename(preset_id)
  local writer = getFileWriter(filename, true, false)
  if not writer then return false end

  local title = data.fold_title or "[Utility Menus]"
  writer:write(_string_format("fold_title=%s\n", title))

  local rules = data.rules or {}
  for i = 1, #rules do
    local rule = rules[i]
    if rule and rule.pattern and rule.pattern ~= "" then
      local act = (rule.action or "hide"):lower()
      local typ = (rule.type or "exact"):lower()
      local scp = (rule.scope or "all"):lower()
      writer:write(_string_format("%s|%s|%s|%s\n", rule.pattern, act, typ, scp))
    end
  end

  writer:close()
  return true
end

return preset_manager
