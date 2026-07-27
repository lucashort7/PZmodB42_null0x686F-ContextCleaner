require("ISUI/ISCollapsableWindow")
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISLabel")
require("ISUI/ISTextEntryBox")
require("ISUI/ISComboBox")
require("ISUI/ISScrollingListBox")

local preset_manager = require("null0x686F_ContextCleaner/preset_manager")
local context_cleaner = require("null0x686F_ContextCleaner/context_cleaner")

local _ipairs = ipairs
local _pairs = pairs
local _tostring = tostring
local _string_lower = string.lower

ContextCleanerWindow = ISCollapsableWindow:derive("ContextCleanerWindow")

local _THEME = {
  windowBg = { r = 0.08, g = 0.08, b = 0.08, a = 0.95 },
  border = { r = 0.25, g = 0.25, b = 0.25, a = 0.9 },
  btnNormal = { r = 0.15, g = 0.15, b = 0.15, a = 0.9 },
  btnRed = { r = 0.8, g = 0.15, b = 0.15, a = 0.95 },
  btnGreen = { r = 0.15, g = 0.6, b = 0.2, a = 0.95 },
  btnAmber = { r = 0.75, g = 0.5, b = 0.1, a = 0.95 }
}

function ContextCleanerWindow:initialise()
  ISCollapsableWindow.initialise(self)
  self.title = "Context Cleaner Options"
  self.resizable = true
  self.minimumWidth = 540
  self.minimumHeight = 380
  self.current_preset = "default"
  self.editing_index = nil
  self.preset_data = preset_manager.load_preset(self.current_preset) or { fold_title = "[Utility Menus]", rules = {} }
end

function ContextCleanerWindow:createChildren()
  ISCollapsableWindow.createChildren(self)

  local th = self:titleBarHeight()

  -- TOP ROW: Submenu Title Configuration
  self.title_label = ISLabel:new(10, th + 10, 20, "Fold Submenu Title:", 1, 1, 1, 1, UIFont.Small, true)
  self.title_label:initialise()
  self.title_label:instantiate()
  self:addChild(self.title_label)

  local cur_title = self.preset_data.fold_title or "[Utility Menus]"
  self.title_box = ISTextEntryBox:new(cur_title, 140, th + 7, 160, 22)
  self.title_box:initialise()
  self.title_box:instantiate()
  self:addChild(self.title_box)

  self.save_title_btn = ISButton:new(310, th + 7, 95, 22, "[ Save Title ]", self, ContextCleanerWindow.on_save_title_click)
  self.save_title_btn:initialise()
  self.save_title_btn:instantiate()
  self.save_title_btn.backgroundColor = _THEME.btnGreen
  self.save_title_btn.borderColor = { r = 0.3, g = 0.8, b = 0.4, a = 0.8 }
  self:addChild(self.save_title_btn)

  -- MIDDLE ROW: Rule Controls (y = th + 45)
  local mid_y = th + 45

  self.action_combo = ISComboBox:new(10, mid_y, 70, 22, self)
  self.action_combo:initialise()
  self.action_combo:instantiate()
  self.action_combo:addOptionWithData("hide", "hide")
  self.action_combo:addOptionWithData("fold", "fold")
  self:addChild(self.action_combo)

  self.type_combo = ISComboBox:new(85, mid_y, 95, 22, self)
  self.type_combo:initialise()
  self.type_combo:instantiate()
  self.type_combo:addOptionWithData("exact", "exact")
  self.type_combo:addOptionWithData("wildcard", "wildcard")
  self.type_combo:addOptionWithData("luapattern", "luapattern")
  self:addChild(self.type_combo)

  self.scope_combo = ISComboBox:new(185, mid_y, 85, 22, self)
  self.scope_combo:initialise()
  self.scope_combo:instantiate()
  self.scope_combo:addOptionWithData("all", "all")
  self.scope_combo:addOptionWithData("world", "world")
  self.scope_combo:addOptionWithData("inventory", "inventory")
  self:addChild(self.scope_combo)

  local entry_w = math.max(80, self.width - 365)
  self.entry_box = ISTextEntryBox:new("", 275, mid_y, entry_w, 22)
  self.entry_box:initialise()
  self.entry_box:instantiate()
  self:addChild(self.entry_box)

  self.add_btn = ISButton:new(self.width - 80, mid_y, 70, 22, "[ + Add ]", self, ContextCleanerWindow.on_add_click)
  self.add_btn:initialise()
  self.add_btn:instantiate()
  self.add_btn.backgroundColor = _THEME.btnNormal
  self.add_btn.borderColor = _THEME.border
  self:addChild(self.add_btn)

  -- LISTBOX (y = th + 75)
  self.listbox = ISScrollingListBox:new(10, th + 75, self.width - 20, self.height - th - 115)
  self.listbox:initialise()
  self.listbox:instantiate()
  self.listbox.drawBorder = true
  self.listbox.backgroundColor = { r = 0.04, g = 0.04, b = 0.04, a = 0.95 }
  self.listbox.borderColor = _THEME.border
  self:addChild(self.listbox)

  -- BOTTOM ROW
  local bot_y = self.height - 30

  self.cancel_btn = ISButton:new(self.width - 290, bot_y, 70, 22, "[ Cancel ]", self, ContextCleanerWindow.on_cancel_click)
  self.cancel_btn:initialise()
  self.cancel_btn:instantiate()
  self.cancel_btn.backgroundColor = _THEME.btnNormal
  self.cancel_btn.borderColor = _THEME.border
  self:addChild(self.cancel_btn)

  self.edit_btn = ISButton:new(self.width - 215, bot_y, 65, 22, "[ Edit ]", self, ContextCleanerWindow.on_edit_click)
  self.edit_btn:initialise()
  self.edit_btn:instantiate()
  self.edit_btn.backgroundColor = _THEME.btnNormal
  self.edit_btn.borderColor = _THEME.border
  self:addChild(self.edit_btn)

  self.remove_btn = ISButton:new(self.width - 145, bot_y, 135, 22, "[ Remove Selected ]", self, ContextCleanerWindow.on_remove_click)
  self.remove_btn:initialise()
  self.remove_btn:instantiate()
  self.remove_btn.backgroundColor = _THEME.btnRed
  self.remove_btn.borderColor = { r = 1, g = 0.3, b = 0.3, a = 0.8 }
  self.remove_btn.textColor = { r = 1, g = 1, b = 1, a = 1 }
  self:addChild(self.remove_btn)

  self:refresh_list_from_state()
end

function ContextCleanerWindow:render()
  ISCollapsableWindow.render(self)
  local th = self:titleBarHeight()
  -- Draw clean horizontal divider line below top section
  self:drawRect(10, th + 37, self.width - 20, 1, 0.6, 0.25, 0.25, 0.25)
end

function ContextCleanerWindow:onResize()
  ISCollapsableWindow.onResize(self)
  local th = self:titleBarHeight()

  if self.entry_box and self.add_btn and self.listbox and self.remove_btn and self.edit_btn and self.cancel_btn then
    local entry_w = math.max(80, self.width - 365)
    self.entry_box:setWidth(entry_w)
    self.add_btn:setX(self.width - 80)
    self.listbox:setWidth(self.width - 20)
    self.listbox:setHeight(self.height - th - 115)

    local bot_y = self.height - 30
    self.cancel_btn:setY(bot_y)
    self.cancel_btn:setX(self.width - 290)
    self.edit_btn:setY(bot_y)
    self.edit_btn:setX(self.width - 215)
    self.remove_btn:setY(bot_y)
    self.remove_btn:setX(self.width - 145)
  end
end

function ContextCleanerWindow:refresh_list_from_state()
  self.listbox:clear()
  self.preset_data = preset_manager.load_preset(self.current_preset) or { fold_title = "[Utility Menus]", rules = {} }

  if self.title_box then
    self.title_box:setText(self.preset_data.fold_title or "[Utility Menus]")
  end

  local rules = self.preset_data.rules or {}
  for i = 1, #rules do
    local rule = rules[i]
    if rule and rule.pattern and rule.pattern ~= "" then
      local raw_line = string.format("%s|%s|%s|%s", rule.pattern, rule.action or "hide", rule.type or "exact", rule.scope or "all")
      self.listbox:addItem(raw_line, rule)
    end
  end
end

function ContextCleanerWindow:sync_and_save()
  if self.title_box then
    local new_title = self.title_box:getText()
    if new_title and new_title ~= "" then
      self.preset_data.fold_title = new_title
    end
  end

  preset_manager.save_preset(self.current_preset, self.preset_data)
  context_cleaner.reload_preset(self.current_preset)
end

function ContextCleanerWindow:on_save_title_click()
  self:sync_and_save()
end

function ContextCleanerWindow:reset_edit_state()
  self.editing_index = nil
  if self.entry_box then self.entry_box:setText("") end
  if self.add_btn then
    self.add_btn:setTitle("[ + Add ]")
    self.add_btn.backgroundColor = _THEME.btnNormal
  end
end

function ContextCleanerWindow:on_cancel_click()
  self:reset_edit_state()
end

function ContextCleanerWindow:on_add_click()
  local text = self.entry_box:getText()
  if text and text ~= "" then
    local action = self.action_combo:getSelectedData() or "hide"
    local ptype = self.type_combo:getSelectedData() or "exact"
    local scope = self.scope_combo:getSelectedData() or "all"

    if not self.preset_data.rules then self.preset_data.rules = {} end

    if self.editing_index and self.editing_index > 0 and self.editing_index <= #self.preset_data.rules then
      -- Update existing rule in place
      self.preset_data.rules[self.editing_index] = {
        pattern = text,
        action = action,
        type = ptype,
        scope = scope,
        raw = string.format("%s|%s|%s|%s", text, action, ptype, scope)
      }
      self:reset_edit_state()
    else
      -- Append new rule
      self.preset_data.rules[#self.preset_data.rules + 1] = {
        pattern = text,
        action = action,
        type = ptype,
        scope = scope,
        raw = string.format("%s|%s|%s|%s", text, action, ptype, scope)
      }
      self.entry_box:setText("")
    end

    self:sync_and_save()
    self:refresh_list_from_state()
  end
end

function ContextCleanerWindow:on_edit_click()
  local sel = self.listbox.selected
  if sel and sel > 0 and sel <= #self.listbox.items then
    local item = self.listbox.items[sel]
    local rule = item and item.item
    if rule and rule.pattern then
      self.editing_index = sel
      self.entry_box:setText(rule.pattern)
      if self.action_combo then self.action_combo:select(rule.action or "hide") end
      if self.type_combo then self.type_combo:select(rule.type or "exact") end
      if self.scope_combo then self.scope_combo:select(rule.scope or "all") end

      self.add_btn:setTitle("[ Update ]")
      self.add_btn.backgroundColor = _THEME.btnAmber
    end
  end
end

function ContextCleanerWindow:on_remove_click()
  local sel = self.listbox.selected
  if sel and sel > 0 and sel <= #self.listbox.items then
    if self.preset_data.rules then
      table.remove(self.preset_data.rules, sel)
    end
    self:reset_edit_state()
    self:sync_and_save()
    self:refresh_list_from_state()
  end
end

function ContextCleanerWindow:close()
  self:sync_and_save()
  self:setVisible(false)
  self:removeFromUIManager()
end

function ContextCleanerWindow:new(x, y, width, height, player)
  local o = ISCollapsableWindow:new(x, y, width, height)
  setmetatable(o, self)
  self.__index = self
  o.player = player
  o.backgroundColor = _THEME.windowBg
  o.borderColor = _THEME.border
  o.resizable = true
  return o
end

return ContextCleanerWindow
