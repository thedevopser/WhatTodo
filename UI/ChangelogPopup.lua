local ADDON_NAME, WhatTodo = ...
local ChangelogPopup = {}
WhatTodo.ChangelogPopup = ChangelogPopup
local Changelog = WhatTodo.Changelog
local L = WhatTodo_L

-- bumper à la main à chaque annonce ; doit rester égal à ## Version du .toc
local CHANGELOG_VERSION = "1.3.0"

-- Définition enregistrée au chargement du fichier : on n'écrit qu'une nouvelle
-- clé, sans jamais réassigner la globale StaticPopupDialogs (réassigner taint
-- l'UI sécurisée → ToggleGameMenu/ClearTarget bloqués à l'appui sur Échap).
StaticPopupDialogs["WHATTODO_CHANGELOG"] = {
  text = L.CHANGELOG_TITLE .. "\n\n" .. L.CHANGELOG_BODY,
  button1 = L.CHANGELOG_CLOSE,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  showAlert = true,
  preferredIndex = 3,
}

local function showPopup()
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
