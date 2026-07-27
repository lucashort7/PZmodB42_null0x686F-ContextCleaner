# null0x686F Context Cleaner (Standalone)

High-performance $O(1)$ context menu cleaner for Project Zomboid Build 42.

## Features
- Synchronous context menu filtering on `OnFillInventoryObjectContextMenu` and `OnFillWorldObjectContextMenu`.
- Zero-GC allocations during menu rendering.
- Dedicated `ContextCleanerWindow` UI (open with **Numpad 7** by default, remappable — no context menu entry) with dual filtering (Hide List / Fold List).
- Each rule matches by **Type** (`exact`, `wildcard`, `luapattern`), applies an **Action** (`hide`, `fold`), and can be limited to a **Scope** (`all`, `inventory`, `world`).
- Global disk config persisted to `Zomboid/Lua/ContextCleaner_preset_default.txt`.
