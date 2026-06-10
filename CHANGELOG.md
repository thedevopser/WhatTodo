# Changelog

All notable changes to WhatTodo are documented here.

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
- Minimap button (LibDBIcon) using the native scroll icon — left-click toggles the display, right-click opens the admin panel, tooltip shows remaining tasks per frequency
- Slash commands: `/wt` (toggle display) and `/wt config` (open admin panel)
- Localization (EN/FR): the UI language follows the WoW client locale — English by default, French when `GetLocale() == "frFR"` (`Locales/enUS.lua`, `Locales/frFR.lua`)
- `## Notes-frFR` entry in the `.toc` for the French addon-list description
- Embedded libraries: Ace3 (AceAddon, AceDB, AceConsole, AceEvent, AceGUI, AceConfig), LibDataBroker-1.1, LibDBIcon-1.0
