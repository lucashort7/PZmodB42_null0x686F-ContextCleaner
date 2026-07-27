# null0x686F Context Cleaner (Standalone)

High-performance $O(1)$ context menu cleaner for Project Zomboid Build 42.

## Features
- Synchronous context menu filtering on `OnFillInventoryObjectContextMenu` and `OnFillWorldObjectContextMenu`.
- Zero-GC allocations during menu rendering.
- Configurable rules via native UI / ModOptions.
