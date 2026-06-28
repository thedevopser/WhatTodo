local ADDON_NAME, WhatTodo = ...
local ChangelogPopup = {}
WhatTodo.ChangelogPopup = ChangelogPopup
local Changelog = WhatTodo.Changelog
local L = WhatTodo_L

-- bumper à la main à chaque annonce ; doit rester égal à ## Version du .toc
local CHANGELOG_VERSION = "1.1.0"

local function showPopup()
  StaticPopupDialogs = StaticPopupDialogs or {}
  StaticPopupDialogs["WHATTODO_CHANGELOG"] = {
    text = L.CHANGELOG_TITLE .. "\n\n" .. L.CHANGELOG_BODY,
    button1 = L.CHANGELOG_CLOSE,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    showAlert = true,
  }
  StaticPopup_Show("WHATTODO_CHANGELOG")
end

function ChangelogPopup.Initialize(db)
  -- pcall : ne jamais bloquer le login si une API change
  pcall(function()
    if Changelog.ShouldShow(db.global.lastSeenVersion, CHANGELOG_VERSION) then
      showPopup()
      db.global.lastSeenVersion = CHANGELOG_VERSION
    end
  end)
end
