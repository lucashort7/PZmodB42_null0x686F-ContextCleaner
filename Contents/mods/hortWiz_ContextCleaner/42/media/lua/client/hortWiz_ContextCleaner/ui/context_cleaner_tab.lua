require("ISUI/ISPanel")
require("ISUI/ISLabel")
require("ISUI/ISTextEntryBox")
require("ISUI/ISButton")
require("ISUI/ISComboBox")
require("ISUI/ISScrollingListBox")

local cfg = require("hortWiz_ContextCleaner/cfg")
local log = require("hortWiz_ContextCleaner/log")
local preset_manager = require("hortWiz_ContextCleaner/preset_manager")
local context_cleaner = require("hortWiz_ContextCleaner/context_cleaner")

local _pairs = pairs
local _tostring = tostring
local _string_lower = string.lower

ContextCleanerTabUI = ISPanel:derive("ContextCleanerTabUI")

function ContextCleanerTabUI:initialise()
  ISPanel.initialise(self)

  self.active_mode = "hide"
  self.preset_labels = preset_manager.load_preset_labels()
  self.current_preset_state = preset_manager.load_preset(cfg.current_preset)

  local font = (UIFont and UIFont.Small) and UIFont.Small or 0
  self.preset_label = ISLabel:new(10, 10, 20, "Preset:", 1, 1, 1, 1, font, true)
  self:addChild(self.preset_label)

  self.preset_combo = ISComboBox:new(60, 8, 140, 20, self, self.on_preset_selected)
  self.preset_combo:initialise()
  self:addChild(self.preset_combo)

  self.hide_mode_btn = ISButton:new(210, 8, 90, 20, "[Hide List]", self, self.on_switch_hide_mode)
  self.hide_mode_btn:initialise()
  self:addChild(self.hide_mode_btn)

  self.fold_mode_btn = ISButton:new(305, 8, 90, 20, "[Fold List]", self, self.on_switch_fold_mode)
  self.fold_mode_btn:initialise()
  self:addChild(self.fold_mode_btn)

  self.search_entry = ISTextEntryBox:new("", 10, 35, self.width - 20, 20)
  self.search_entry:initialise()
  self.search_entry.onTextChange = function() self:populate_list() end
  self:addChild(self.search_entry)

  self.entry_list = ISScrollingListBox:new(10, 60, self.width - 20, self.height - 110)
  self.entry_list:initialise()
  self.entry_list:instantiate()
  self.entry_list.itemheight = 22
  self.entry_list.selected = 0
  self.entry_list.font = UIFont.Small
  self.entry_list.doDrawItem = self.draw_list_item
  self.entry_list.drawBorder = true
  self:addChild(self.entry_list)

  self.add_entry = ISTextEntryBox:new("", 10, self.height - 40, self.width - 160, 20)
  self.add_entry:initialise()
  self:addChild(self.add_entry)

  self.add_btn = ISButton:new(self.width - 145, self.height - 40, 65, 20, "Add", self, self.on_add_entry)
  self.add_btn:initialise()
  self:addChild(self.add_btn)

  self.del_btn = ISButton:new(self.width - 75, self.height - 40, 65, 20, "Remove", self, self.on_remove_entry)
  self.del_btn:initialise()
  self:addChild(self.del_btn)

  self:populate_preset_combo()
  self:populate_list()
end

function ContextCleanerTabUI:populate_preset_combo()
  self.preset_combo:clear()
  self.preset_combo:addOptionWithData(self.preset_labels.default or "Default", "default")
  self.preset_combo:addOptionWithData(self.preset_labels.preset1 or "Preset I", "preset1")
  self.preset_combo:addOptionWithData(self.preset_labels.preset2 or "Preset II", "preset2")
  self.preset_combo:addOptionWithData(self.preset_labels.preset3 or "Preset III", "preset3")
end

function ContextCleanerTabUI:on_preset_selected()
  local selected_id = self.preset_combo:getSelectedData()
  if selected_id then
    cfg.current_preset = selected_id
    self.current_preset_state = preset_manager.load_preset(selected_id)
    context_cleaner.reload_preset(selected_id)
    self:populate_list()
  end
end

function ContextCleanerTabUI:on_switch_hide_mode()
  self.active_mode = "hide"
  self:populate_list()
end

function ContextCleanerTabUI:on_switch_fold_mode()
  self.active_mode = "fold"
  self:populate_list()
end

function ContextCleanerTabUI:populate_list()
  self.entry_list:clear()
  local search_text = _string_lower(self.search_entry:getText() or "")
  local target_table = self.current_preset_state[self.active_mode] or {}

  for pattern, active in _pairs(target_table) do
    if active then
      if search_text == "" or _string_lower(pattern):find(search_text, 1, true) then
        self.entry_list:addItem(pattern, pattern)
      end
    end
  end
end

function ContextCleanerTabUI:draw_list_item(y, item, alt)
  local is_selected = self.selected == item.index
  if is_selected then
    self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.2, 0.4, 0.8)
  elseif alt then
    self:drawRect(0, y, self:getWidth(), self.itemheight, 0.1, 0.1, 0.1, 0.2)
  end

  local prefix = self.parent.active_mode == "hide" and "[HIDE] " or "[FOLD] "
  self:drawText(prefix .. item.text, 10, y + 2, 1, 1, 1, 1, self.font)
  return y + self.itemheight
end

function ContextCleanerTabUI:on_add_entry()
  local text = self.add_entry:getText()
  if text and text ~= "" then
    local mode = self.active_mode
    if not self.current_preset_state[mode] then
      self.current_preset_state[mode] = {}
    end
    self.current_preset_state[mode][text] = true
    preset_manager.save_preset(cfg.current_preset, self.current_preset_state)
    context_cleaner.reload_preset(cfg.current_preset)
    self.add_entry:setText("")
    self:populate_list()
  end
end

function ContextCleanerTabUI:on_remove_entry()
  local selected_item = self.entry_list.items[self.entry_list.selected]
  if selected_item then
    local mode = self.active_mode
    if self.current_preset_state[mode] then
      self.current_preset_state[mode][selected_item.item] = nil
      preset_manager.save_preset(cfg.current_preset, self.current_preset_state)
      context_cleaner.reload_preset(cfg.current_preset)
      self:populate_list()
    end
  end
end

function ContextCleanerTabUI:new(x, y, width, height)
  local o = ISPanel:new(x, y, width, height)
  setmetatable(o, self)
  self.__index = self
  o.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.8 }
  o.borderColor = { r = 0.2, g = 0.2, b = 0.2, a = 0.8 }
  return o
end

return ContextCleanerTabUI
