WhatTodo_L = {}
local L = WhatTodo_L

-- Fréquences (singulier, sélecteur du panel)
L.FREQ_DAILY        = "Daily"
L.FREQ_WEEKLY       = "Weekly"
L.FREQ_MONTHLY      = "Monthly"

-- Fréquences (titres de section de l'affichage + infobulle)
L.SECTION_DAILY     = "Daily"
L.SECTION_WEEKLY    = "Weekly"
L.SECTION_MONTHLY   = "Monthly"

-- Panel de gestion
L.ADMIN_TITLE       = "WhatTodo — Task management"
L.ADMIN_STATUS      = "Pick a frequency, type a label, then click Add"
L.FREQUENCY         = "Frequency"
L.LABEL             = "Label"
L.ADD               = "Add"
L.EXISTING_TASKS    = "Existing tasks"
L.DELETE            = "Delete"

-- Portée des tâches (perso vs compte)
L.SCOPE             = "Scope"
L.SCOPE_CHAR        = "Character"
L.SCOPE_ACCOUNT     = "Account"
L.SCOPE_ACCOUNT_TAG = "account"

-- Profils (copie de liste entre personnages)
L.PROFILES          = "Profiles"
L.PROFILE_COPY_FROM = "Copy list from"
L.PROFILE_COPY      = "Copy"
L.PROFILE_COPIED    = "List copied from %s"

-- Templates de saison (import prérempli)
L.SEASON_TEMPLATES  = "Task templates"
L.SEASON_IMPORT     = "Import selected"
L.SEASON_IMPORTED   = "Imported %d task(s)"
L.SEASON_REMOVE     = "Remove selected"
L.SEASON_REMOVE_CONFIRM = "Remove the tasks of the selected categories? This cannot be undone."
L.SEASON_REMOVED    = "Removed %d task(s)"

-- Templates proposés par le sélecteur
L.TPL_SEASON        = "Template"
L.TPL_SEASON_ESSENTIALS = "Essentials"

L.TPL_CAT_PVE       = "Dungeons & Raid"
L.TPL_CAT_WORLD     = "World"

-- Essentiels : activités stables d'un patch à l'autre
L.TPL_GREAT_VAULT   = "Great Vault"
L.TPL_MYTHIC_PLUS   = "Mythic+ (best keys)"
L.TPL_BOUNTIFUL_DELVE = "Bountiful Delves (keys)"
L.TPL_WORLD_EVENT   = "World event weekly quest"
L.TPL_HOUSING       = "Housing weekly quest"
L.TPL_TRADING_POST  = "Trading Post"

-- Titre de section : libellé, tâches faites, total
L.SECTION_PROGRESS  = "%s %d/%d"

-- Compteurs de reset
L.RESET_IN_DAYS     = "reset in %dd %dh"
L.RESET_IN_HOURS    = "reset in %dh %02dmin"

-- Infobulle du bouton minimap
L.TOOLTIP_COUNT     = "%s: %d"
L.TOOLTIP_LEFT      = "Left click: show/hide"
L.TOOLTIP_RIGHT     = "Right click: configure"

-- Options (Échap > Options > AddOns)
L.OPT_LOCKED        = "Lock window position"
L.OPT_LOCKED_DESC   = "Prevents the list window from being dragged."
L.OPT_SCALE         = "Scale"
L.OPT_SCALE_DESC    = "Size of the list window."
L.OPT_BACKGROUND_ALPHA = "Background opacity"
L.OPT_BACKGROUND_ALPHA_DESC = "Opacity of the list window background and border. Text stays fully opaque."
L.OPT_COMPLETED_STYLE = "Completed tasks"
L.OPT_COMPLETED_STYLE_DESC = "How tasks already done for the current period appear in the list."
L.OPT_COMPLETED_SHOW = "Show normally"
L.OPT_COMPLETED_DIM = "Grey out and strike through"
L.OPT_COMPLETED_HIDE = "Hide"
L.OPT_HIDE_IN_COMBAT = "Hide in combat"
L.OPT_HIDE_IN_COMBAT_DESC = "Hides the list while you are in combat and brings it back afterwards."
L.OPT_THEME         = "Theme"
L.OPT_THEME_DESC    = "Look of the list window."
L.THEME_PARCHMENT   = "Parchment"
L.THEME_PARCHMENT_DARK = "Dark parchment"
L.THEME_DARK        = "Minimal dark"
L.THEME_BLIZZARD    = "Blizzard"
L.THEME_TRANSPARENT = "Transparent"

-- Popup de nouveautés
L.CHANGELOG_TITLE   = "WhatTodo — What's new (1.6.0)"
L.CHANGELOG_BODY    = "The list is now yours to shape. Open the settings with /wt options (or Esc > Options > AddOns) to pick one of five themes, grey out or hide completed tasks, change the scale and background opacity, lock the window or hide it in combat.\n\nEach section header shows your progress (3/7) and folds away with a click. In the management panel, the arrows next to each task change its order."
L.CHANGELOG_CLOSE   = "Got it"
