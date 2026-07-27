# null0x686F ContextCleaner

![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-B42-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Performance](https://img.shields.io/badge/Performance-O(1)-brightgreen)

O(1) context menu cleaner for Project Zomboid Build 42. Hide clutter from right-click menus in real time, no lag (native monkeypatch on `ISContextMenu:addOption`).

## Requires
- **null0x686F CoreLib** (hard dependency).

## Features
- Synchronous filtering on `OnFillInventoryObjectContextMenu` and `OnFillWorldObjectContextMenu`.
- Zero-GC allocations during menu rendering.
- Configurable rules via native UI / ModOptions — hide or fold into a submenu, with wildcard and Lua pattern support.
- Presets saved to disk (`Zomboid/Lua/ContextCleaner_preset_default.txt`).
- Native keybind (`Numpad 7` by default) to open the config window.

## Installation (Manual)
1. Download the latest `.zip` from [Releases](../../releases).
2. Extract the `null0x686F_ContextCleaner` folder into `C:\Users\YOUR_USER\Zomboid\mods\`.
3. Install **null0x686F CoreLib** too.
4. Enable both mods in the main menu.
