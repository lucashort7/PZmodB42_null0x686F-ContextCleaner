require("null0x686F_ContextCleaner/context_cleaner_keybinds")

local cfg = require("null0x686F_ContextCleaner/cfg")
local log = require("null0x686F_ContextCleaner/log")
local preset_manager = require("null0x686F_ContextCleaner/preset_manager")

local _is_patched = false
local _pairs = pairs
local _ipairs = ipairs
local _tostring = tostring
local _string_lower = string.lower
local _string_format = string.format
local _pcall = pcall
local _get_core = getCore

local context_cleaner = {}

function context_cleaner.reload_preset(preset_id)
  local id = preset_id or cfg.current_preset or "default"
  cfg.current_preset = id
  local data = preset_manager.load_preset(id)

  cfg.fold_title = (data and data.fold_title) and data.fold_title or "[Utility Menus]"
  cfg.active_rules = (data and data.rules) and data.rules or {}

  log.debug(_string_format("Loaded %d rules for preset '%s' (Fold Title: '%s')", #cfg.active_rules, id, cfg.fold_title))
end

local function _evaluate_rule(name, rule, current_scope)
  if not name or not rule or not rule.pattern then return false end

  local rule_scope = rule.scope or "all"
  if rule_scope ~= "all" and rule_scope ~= current_scope then
    return false
  end

  local lower_name = _string_lower(name)
  local lower_pat = _string_lower(rule.pattern)
  local ptype = rule.type or "exact"

  if ptype == "exact" then
    return lower_name == lower_pat or lower_name:find(lower_pat, 1, true) ~= nil
  elseif ptype == "wildcard" then
    local p = lower_pat:gsub("([%^%$%(%)%%%.%[%]%+%-%?])", "%%%1"):gsub("%*", ".*")
    local ok, match = _pcall(function() return lower_name:find("^" .. p .. "$") or lower_name:find(p) end)
    return ok and match ~= nil
  elseif ptype == "luapattern" then
    local ok, match = _pcall(function() return lower_name:find(lower_pat) end)
    return ok and match ~= nil
  end
  return false
end

local function _should_hide(name, current_scope)
  if not name or not cfg.active_rules then return false end
  for i = 1, #cfg.active_rules do
    local rule = cfg.active_rules[i]
    if rule and rule.action == "hide" and _evaluate_rule(name, rule, current_scope) then
      return true, rule
    end
  end
  return false
end

local function _should_fold(name, current_scope)
  if not name or not cfg.active_rules then return false end
  for i = 1, #cfg.active_rules do
    local rule = cfg.active_rules[i]
    if rule and rule.action == "fold" and _evaluate_rule(name, rule, current_scope) then
      return true, rule
    end
  end
  return false
end

local function _get_or_create_submenu(context, label)
  local title = label or cfg.fold_title or "[Utility Menus]"
  local parent = context:getOptionFromName(title)
  if parent and parent.subMenu then
    return parent.subMenu
  end

  if not parent then
    parent = context:addOption(title)
    if not parent then return nil end
  end

  local sub = parent.subMenu
  if not sub and context.addSubMenu then
    sub = ISContextMenu:getNew(context)
    if sub then
      context:addSubMenu(parent, sub)
    end
  end
  return sub
end

local function _process_context_menu(context, current_scope)
  if not cfg.enabled or not context or not context.options then return end

  local options = context.options
  log.debug(_string_format("Menu opened (Scope: %s) containing %d options", current_scope, #options))

  local to_remove_indices = {}
  local to_fold_options = {}

  for i = #options, 1, -1 do
    local opt = options[i]
    if opt and opt.name and opt.name ~= "[Context Cleaner]" and opt.name ~= cfg.fold_title then
      local hide, hide_rule = _should_hide(opt.name, current_scope)
      if hide then
        log.debug(_string_format("[HIDE MATCH] Option '%s' matched pattern '%s' (Scope: %s)", opt.name, hide_rule.pattern, current_scope))
        to_remove_indices[#to_remove_indices + 1] = i
      else
        local fold, fold_rule = _should_fold(opt.name, current_scope)
        if fold then
          log.debug(_string_format("[FOLD MATCH] Option '%s' matched pattern '%s' (Scope: %s)", opt.name, fold_rule.pattern, current_scope))
          to_fold_options[#to_fold_options + 1] = opt
          to_remove_indices[#to_remove_indices + 1] = i
        end
      end
    end
  end

  -- STEP 1: Add folded options to target sub-menu FIRST
  if #to_fold_options > 0 then
    local sub = _get_or_create_submenu(context, cfg.fold_title)
    if sub then
      for i = 1, #to_fold_options do
        local opt = to_fold_options[i]
        local cb = opt.onSelect or opt.onClick or opt.doClick or opt.callback or opt.func
        local tgt = opt.target or opt.targetObject
        local newOpt = sub:addOption(opt.name, tgt, cb, opt.param1, opt.param2, opt.param3, opt.param4)

        if newOpt then
          for k, v in _pairs(opt) do
            if newOpt[k] == nil then
              newOpt[k] = v
            end
          end
          if newOpt.subMenu then
            newOpt.subMenu.parent = sub
          end
          log.debug(_string_format("Successfully moved option '%s' to sub-menu '%s'", opt.name, cfg.fold_title))
        end
      end
    end
  end

  -- STEP 2: Remove matched options from parent context menu
  for i = 1, #to_remove_indices do
    local idx = to_remove_indices[i]
    local removed_opt = options[idx]
    table.remove(context.options, idx)
    if removed_opt then
      log.debug(_string_format("Removed option '%s' from parent menu", _tostring(removed_opt.name)))
    end
  end
end

local _inv_wrapper_dispatching = false
local function _inv_wrapper(player_num, context, items)
  if _inv_wrapper_dispatching then return end
  _inv_wrapper_dispatching = true
  Events.OnFillInventoryObjectContextMenu.Remove(_inv_wrapper)
  Events.OnFillInventoryObjectContextMenu.Add(_inv_wrapper)
  _process_context_menu(context, "inventory")
  _inv_wrapper_dispatching = false
end

local _world_wrapper_dispatching = false
local function _world_wrapper(player_num, context, world_objects, test)
  if test then return true end
  if _world_wrapper_dispatching then return end
  _world_wrapper_dispatching = true
  Events.OnFillWorldObjectContextMenu.Remove(_world_wrapper)
  Events.OnFillWorldObjectContextMenu.Add(_world_wrapper)
  _process_context_menu(context, "world")
  _world_wrapper_dispatching = false
end

local _context_cleaner_win_instance = nil

local function _toggle_context_cleaner_window()
  local ContextCleanerWindow = require("null0x686F_ContextCleaner/ui/context_cleaner_window")
  if not _context_cleaner_win_instance then
    local w = 520
    local h = 380
    local x = (getCore():getScreenWidth() / 2) - (w / 2)
    local y = (getCore():getScreenHeight() / 2) - (h / 2)

    _context_cleaner_win_instance = ContextCleanerWindow:new(x, y, w, h)
    _context_cleaner_win_instance:initialise()
    _context_cleaner_win_instance:instantiate()
    _context_cleaner_win_instance:addToUIManager()
  else
    if _context_cleaner_win_instance:getIsVisible() then
      _context_cleaner_win_instance:close()
    else
      _context_cleaner_win_instance:removeFromUIManager()
      local w = 520
      local h = 380
      local x = (getCore():getScreenWidth() / 2) - (w / 2)
      local y = (getCore():getScreenHeight() / 2) - (h / 2)
      _context_cleaner_win_instance = ContextCleanerWindow:new(x, y, w, h)
      _context_cleaner_win_instance:initialise()
      _context_cleaner_win_instance:instantiate()
      _context_cleaner_win_instance:addToUIManager()
    end
  end
end

local function _on_key_pressed(key)
  local default_key = (Keyboard and Keyboard.KEY_NUMPAD7) or 71
  local bound_key = _get_core():getKey("[null0x686F] Context Cleaner")
  if bound_key == 0 or bound_key == nil then
    bound_key = default_key
  end

  if key == bound_key then
    log.debug("Hotkey pressed -> Toggling window")
    _toggle_context_cleaner_window()
  end
end
Events.OnKeyPressed.Add(_on_key_pressed)

if Events.OnResetLua then
  Events.OnResetLua.Add(function()
    _context_cleaner_win_instance = nil
  end)
end

local function _init_context_cleaner()
  if _is_patched then return end

  context_cleaner.reload_preset("default")

  Events.OnFillInventoryObjectContextMenu.Add(_inv_wrapper)
  Events.OnFillWorldObjectContextMenu.Add(_world_wrapper)

  _is_patched = true
  log.debug("context_cleaner.lua initialized")
end

Events.OnGameStart.Add(_init_context_cleaner)
if _get_core() then
  _init_context_cleaner()
end

return {
  init = _init_context_cleaner,
  reload_preset = context_cleaner.reload_preset,
  toggle_window = _toggle_context_cleaner_window
}
