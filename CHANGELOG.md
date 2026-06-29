# Changelog

All notable changes to WhatTodo are documented here.

---

## [1.2.1]

### Fixed
- No more `[ADDON_ACTION_FORBIDDEN] ClearTarget()` taint error on login after an update: the changelog popup no longer reassigns the global `StaticPopupDialogs`. The dialog is now registered at file load time (writing a single key) with `preferredIndex = 3` (`UI/ChangelogPopup.lua`)

---

## [1.2.0]

### Fixed
- Weekly reset day is now region-aware instead of being hardcoded to Wednesday: auto-detected via `GetCurrentRegion()` — Tuesday on US, Wednesday on EU, Thursday on KR/TW/CN (fallback Wednesday) (`Core/Reset.lua`). Daily (5:00) and monthly (1st) are unchanged

### Added
- `Reset.GetWeeklyResetWeekday(region)` (pure region→weekday mapping) and `Reset.GetCurrentRegion()`; `GetResetBoundary`/`GetNextReset`/`IsDone` take an optional `weeklyResetWday` argument so the reset day stays injectable and testable (`Core/Reset.lua`, wired in `Core/Tasks.lua` and `UI/Display.lua`)
- `tests/Reset_test.lua` Busted coverage for the region mapping and weekly boundaries; `_G.date` stub added to `tests/mock_wow_api.lua`
- `docs/ROADMAP.md` documenting the publication roadmap and per-feature status

---

## [1.1.0]

### Added
- Changelog popup shown once per account on the first login after an update, localized FR/EN from the client locale (`Core/Changelog.lua`, `UI/ChangelogPopup.lua`, `L.CHANGELOG_*` keys in `Locales/enUS.lua` and `Locales/frFR.lua`)
- Account-wide `db.global.lastSeenVersion` (first use of an AceDB global root) to track the last announced version; compared against the `CHANGELOG_VERSION` constant
- Unit-test infrastructure: Busted suite run under Docker (`Dockerfile.test`, `tests/mock_wow_api.lua`, `tests/Changelog_test.lua`)
- Packaging guard `tools/check-packaging.py` ensuring every script referenced in the `.toc` is shipped in the zip

### Changed
- `Makefile` switched from blind directory globbing to an explicit `ADDON_FILES` list (with a recursive `Libs/` walk), gated by the packaging guard before each build

---

## [1.0.3]

### Changed
- bump wow versikon

---

## [1.0.2]

### Changed
- Display window now resizes dynamically to fit the number of tasks instead of using a fixed height, and is capped at 80% of the screen height (`UI/Display.lua`)
- Beyond the cap, the task list becomes scrollable with the mouse wheel — tasks no longer overflow outside the frame when many are added

---

## [1.0.1]

### Added
- Localization (EN/FR): the UI language now follows the WoW client locale — English by default, French when `GetLocale() == "frFR"` (`Locales/enUS.lua`, `Locales/frFR.lua`)
- `## Notes-frFR` entry in the `.toc` for the French addon-list description
- Custom parchment icon (`Textures/icon.tga`) used for the addon list and the minimap button

### Changed
- All user-facing strings moved out of the UI code into the locale tables

---

## [1.0.0] — Initial release

### Added
- Per-character to-do list with three task frequencies: daily, weekly, monthly
- Automatic reset at 5:00 server time:
  - daily tasks reset every day,
  - weekly tasks reset every Wednesday,
  - monthly tasks reset on the 1st of each month
- Completion state derived from the last completion time versus the current reset boundary — tasks re-arm by themselves when a reset passes, no cleanup needed
- Admin panel (AceGUI) to add, rename, re-categorize and delete tasks, with a real "Add" button
- Parchment-style display window: draggable, position persisted, tasks grouped by frequency with a per-section reset countdown and checkboxes
- Minimap button (LibDBIcon) — left-click toggles the display, right-click opens the admin panel, tooltip shows remaining tasks per frequency
- Slash commands: `/wt` (toggle display) and `/wt config` (open admin panel)
- Embedded libraries: Ace3 (AceAddon, AceDB, AceConsole, AceEvent, AceGUI, AceConfig), LibDataBroker-1.1, LibDBIcon-1.0
