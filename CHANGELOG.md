# Changelog

All notable changes to WhatTodo are documented here.

---

## [1.5.0]

### Added
- **Midnight Season 2 templates** (patch 12.1.0, *Curse of Ula'tek* — live 12 Aug 2026 EU, season start 19 Aug 2026 EU): 28 tasks across six categories, covering the three frequencies. Daily: Curse Surges & rares on the Coiled Isle, Cursed Fishing, Ral'kala bonus, Mythic 0 (which switches to a daily reset when the season opens). Weekly: The Venomous Abyss raid, Mythic+, the Tidebound Grotto lair, Nebulous Voidcore bonus roll, T8+ and Bountiful Delves, Great Vault, crest cap, Prey hunts, Zul'jarra's Forces renown, Corrosive Souls, Delver's / Preyhunter's Journeys, Conquest objective, profession treatise. Monthly: Trading Post / Traveler's Log
- **Season selector**: `Core/SeasonTemplates.lua` now holds an ordered list of seasons (`SeasonTemplates.seasons`, most recent first) instead of a single flat category list. A Dropdown in the config window switches between Midnight S2 and S1; the category checkboxes are rebuilt for the selected season (`UI/AdminPanel.lua`, `L.TPL_SEASON*` keys)
- **Two new template categories**: PvP and Professions (`L.TPL_CAT_PVP`, `L.TPL_CAT_CRAFT`)
- **Bulk removal of season tasks**: a "Remove selected" button deletes, behind a `StaticPopup` confirmation, the tasks matching the selected season and categories — the missing counterpart to Import when rolling from one season to the next (`SeasonTemplates.Remove`, `L.SEASON_REMOVE*` keys)
- **Template provenance**: `Tasks.Add` takes an optional fourth argument `templateSeason`, persisted on the task. Removal only targets tasks carrying the season's marker, or none at all (tasks imported with 1.4.0, or typed by hand with an identical label) — a task marked with a *different* season is always preserved, which is what protects the labels shared between S1 and S2 (Great Vault, Mythic+, housing weekly, world event, Timewalking)
- Busted coverage for season templates: structure, localization completeness, import dedup across seasons, and every removal path (`tests/SeasonTemplates_test.lua`, 18 specs)

### Changed
- `SeasonTemplates.GetCategories(seasonKey)` takes an optional season key (defaults to `SeasonTemplates.defaultSeason`); `SeasonTemplates.Import(seasonKey, categoryKeys)` gained a leading season argument. Both return empty / 0 for an unknown season
- Config window height raised to 600 to fit the season selector and the six categories

### Notes
- French labels reuse the official in-game names (Île Annelée, Abîme Venimeux, Autel des crochets, Grotte des Marées, Gouffres / Gouffres abondants, la Traque, Résurgences maudites, Pêche maudite, Forces de Zul'jarra, Noyau du Vide nébuleux, Âmes corrosives / Autel de la corrosion). Where no official French name was found, the English term is kept as-is (Vaults of Atal'Utek, Housing Endeavor)
- Season 2 wording is based on pre-patch information and should be checked against the live client; every label lives in the locale files. The crest terminology and the target Delve tier (T8) are the most likely to need adjusting
- `## Interface` deliberately stays at `120007` so the addon keeps loading on the live 12.0.7 client; it is to be bumped to `120100` when patch 12.1.0 goes live
- No SavedVariables migration is required: `templateSeason` is a new optional field, absent on existing tasks and handled as such

---

## [1.4.0]

### Added
- **Season task templates**: a "Season templates" section in the config window imports preset to-do lists for the current season (Midnight S1, 12.0.7), grouped into four categories — World, Dungeons & Raid, Reputation, Limited-time events. The user ticks the categories to import and clicks Import; re-importing is idempotent (existing labels are skipped, no duplicates). Hovering a category checkbox shows a `GameTooltip` previewing the tasks it would add (new `Core/SeasonTemplates.lua`, wired into `UI/AdminPanel.lua`, `L.SEASON_*` and `L.TPL_*` keys in both locales)
- `Core/SeasonTemplates.lua` keeps the curated content as pure data (ordered categories of `{ labelKey, frequency, scope }`) separate from the UI, reusing `Tasks.Add` / `Tasks.GetAll`; template labels go through `L.TPL_*` so the in-game wording can be corrected without touching logic
- `Core/SeasonTemplates.lua` added to the `.toc` (after `Core/Tasks.lua`) and to the Makefile `ADDON_FILES` packaging list

### Notes
- The Season 1 activity names are a best-effort starting point and may need adjusting to match live in-game wording — they are centralized in the locale files for easy editing. No SavedVariables migration is required (templates only call `Tasks.Add`)

---

## [1.3.0]

### Added
- **Account-wide tasks**: each task now has a `scope` (`char` or `account`). Account-wide tasks are shared across all characters with shared completion, stored in `db.global.tasks`; per-character tasks live in `db.profile.tasks`. Scope is picked from a dropdown when adding a task and shown as a badge in the panel and on the list (`Core/Tasks.lua`, `UI/AdminPanel.lua`, `UI/Display.lua`, new `L.SCOPE_*` keys)
- **Copy list between characters**: a "Profiles" section in the config window copies another character's task list onto the current one, using AceDB's native per-character profiles (`db:GetProfiles` / `db:CopyProfile`) (`UI/AdminPanel.lua`, `L.PROFILE_*` keys)
- **SavedVariables schema migration framework**: ordered, scope-aware migrations with per-scope version tracking (`db.char.dbVersion` replayed per character, `db.global.dbVersion` run once per account), run at init before any module reads the DB (`Core/Migrations.lua`, wired in `WhatTodo.lua`)
- Busted coverage for migrations and multi-scope tasks (`tests/Migrations_test.lua`, `tests/Tasks_test.lua`; `strtrim`/`GetServerTime`/`GetCurrentRegion` stubs added to `tests/mock_wow_api.lua`)

### Changed
- The database now uses **per-character profiles** instead of the shared `"Default"` profile (the `true` default-profile argument was dropped from `AceDB:New`). On upgrade, each character is switched to its own profile and its existing `db.char.tasks` are migrated into `db.profile.tasks` — **existing lists are preserved**. This is what makes per-character isolation and the copy-between-characters feature possible (`WhatTodo.lua`, migration v1 in `Core/Migrations.lua`)

### Upgrade notes
- Your current task list is kept automatically; it simply becomes your character's own profile. From now on, lists are per-character — create **Account** tasks for chores you want shared across every character, and use the **Profiles → Copy** action to clone a list onto another character.

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
