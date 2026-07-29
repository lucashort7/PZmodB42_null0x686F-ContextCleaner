# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1](https://github.com/lucashort7/PZmodB42_null0x686F-ContextCleaner/compare/v0.2.0...v0.2.1) (2026-07-29)


### Miscellaneous Chores

* test previewFile fork + refresh Workshop preview ([d5dee8d](https://github.com/lucashort7/PZmodB42_null0x686F-ContextCleaner/commit/d5dee8d957d5f73d1fd435a0751142e94f0f1b9d))

## [0.2.0](https://github.com/lucashort7/PZmodB42_null0x686F-ContextCleaner/compare/v0.1.1...v0.2.0) (2026-07-29)


### Features

* migrate to release-please + reusable Steam Workshop deploy ([1d694ac](https://github.com/lucashort7/PZmodB42_null0x686F-ContextCleaner/commit/1d694ac5c98b60fcb6f03194e1cd48d843a9bcfa))

## [0.1.1] - 2026-07-27

### Changed

-   `name=` now displays as `[null0x686F] ContextCleaner` in the in-game mod list, grouping it with the rest of the null0x686F suite (previously matched the raw mod id).
-   `mod.info` now explicitly declares `versionMin=42.0`.

## [0.1.0] - 2026-07-27

### Added

-   Late-execution event engine with dual filtering (Hide List / Fold List), wildcard and Lua pattern support.
-   Dedicated `ContextCleanerWindow` UI with 4-variable rule registry.
-   Global disk config persisted to `Zomboid/Lua/ContextCleaner_preset_default.txt`.
-   Remappable native keybind (`Numpad 7` default, via Mod Options) to open the config window — the only way to open it.

### Fixed

-   Parent context menu no longer keeps its old, larger size after options are hidden or folded away.
-   Keybind is now actually remappable via Mod Options (previously silently ignored any remap).
-   Context menu processing could double-fire on the same menu open, producing duplicate log lines and redundant work.
-   Log lines no longer repeat the mod name twice.
