# null0x686F ContextCleaner

![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-B42-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Performance](https://img.shields.io/badge/Performance-O(1)-brightgreen)

## Overview
O(1) context menu cleaner for Project Zomboid Build 42. Hide clutter from right-click menus in real time, no lag (native monkeypatch on `ISContextMenu:addOption`). Dedicated `ContextCleanerWindow` UI with a 4-variable rule registry (Pattern, Type, Action, Scope) lets you build your own hide/fold rules without touching a config file.

## Requires
- **null0x686F CoreLib** (hard dependency).

## Features
- Synchronous filtering on `OnFillInventoryObjectContextMenu` and `OnFillWorldObjectContextMenu`.
- Zero-GC allocations during menu rendering.
- Dedicated `ContextCleanerWindow` UI with dual filtering (Hide List / Fold List), wildcard and Lua pattern support.
- Global disk config persisted to `Zomboid/Lua/ContextCleaner_preset_default.txt`.
- **Native keybind (`Numpad 7` by default) to open the config window** — this is the only way to open it, there's no context menu entry for it.

## HOWTO: Building a Rule
Each rule in the `ContextCleanerWindow` has 4 fields:

| Field | Values | Meaning |
| :--- | :--- | :--- |
| **Pattern** | any text | the string matched against a context menu option's name. |
| **Type** | `exact`, `wildcard`, `luapattern` | how `Pattern` is matched — literal substring, `*`-style wildcard, or a raw Lua pattern. |
| **Action** | `hide`, `fold` | `hide` removes the matched option outright; `fold` moves it into a collapsible submenu instead of removing it. |
| **Scope** | `all`, `inventory`, `world` | which context menu the rule applies to — inventory right-click, world object right-click, or both. |

## Installation (Manual)
1. Download the latest `.zip` from [Releases](../../releases).
2. Extract the `null0x686F_ContextCleaner` folder into `C:\Users\YOUR_USER\Zomboid\mods\`.
3. Install **null0x686F CoreLib** too.
4. Enable both mods in the main menu.
