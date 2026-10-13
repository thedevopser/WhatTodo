std = "lua51"
exclude_files = { "Libs/" }
max_line_length = false
-- AceAddon calls handlers as methods, whether or not they use self.
self = false

globals = {
    "WhatTodo_L",
    -- Addons register their popups by adding entries to this table.
    "StaticPopupDialogs",
}

read_globals = {
    "C_DateAndTime",
    "C_Timer",
    "CopyTable",
    "CreateFrame",
    "GameTooltip",
    "GetCurrentRegion",
    "GetLocale",
    "GetServerTime",
    "InCombatLockdown",
    "LibStub",
    "NO",
    "Settings",
    "StaticPopup_Show",
    "UIParent",
    "YES",
    "date",
    "strtrim",
    "wipe",
}

files["tests/"] = { std = "+busted" }
