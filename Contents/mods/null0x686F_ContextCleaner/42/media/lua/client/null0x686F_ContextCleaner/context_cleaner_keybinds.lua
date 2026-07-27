require("ISUI/ISUIElement")

local _keyboard = Keyboard
local _numpad7_key = (_keyboard and _keyboard.KEY_NUMPAD7) or 71

if not keyBinding then keyBinding = {} end

local key_id = "[null0x686F] Context Cleaner"
local exists = false
for i = 1, #keyBinding do
  if keyBinding[i] and keyBinding[i].value == key_id then
    exists = true
    break
  end
end

if not exists then
  table.insert(keyBinding, {
    value = key_id,
    key = _numpad7_key
  })
end
