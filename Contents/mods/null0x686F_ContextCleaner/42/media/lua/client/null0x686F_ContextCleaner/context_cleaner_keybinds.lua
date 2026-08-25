local _mod_id = "null0x686F_ContextCleaner"
local _mod_name_key = "UI_null0x686F_ContextCleaner_options_title"
local _key_id = "ContextCleaner_ToggleKey"

local _keyboard = Keyboard
local _default_key = (_keyboard and _keyboard.KEY_NUMPAD7) or 71

local function _init_mod_options()
  if not (PZAPI and PZAPI.ModOptions and PZAPI.ModOptions.create) then
    return
  end

  local options = PZAPI.ModOptions:create(_mod_id, getText(_mod_name_key))
  if not options then return end

  options:addKeyBind(_key_id, getText("UI_null0x686F_ContextCleaner_toggle_key"), _default_key)
end

local function get_bound_key()
  if PZAPI and PZAPI.ModOptions and PZAPI.ModOptions.getOptions then
    local opts = PZAPI.ModOptions:getOptions(_mod_id)
    if opts then
      local kb = opts:getOption(_key_id)
      if kb and kb:getValue() then
        return kb:getValue()
      end
    end
  end
  return _default_key
end

Events.OnGameBoot.Add(_init_mod_options)

return {
  get_bound_key = get_bound_key,
}
