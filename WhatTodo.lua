local ADDON_NAME, WhatTodo = ...

local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("WhatTodo", "AceConsole-3.0", "AceEvent-3.0")
WhatTodo.addon = addon

local dbDefaults = {
  char = {
    dbVersion = 0,
    display = { shown = true, point = "CENTER", x = 0, y = 0, collapsed = {} },
    minimap = { hide = false },
  },
  profile = {
    tasks = {},
    nextId = 1,
  },
  global = {
    tasks = {},
    nextId = 1,
    dbVersion = 0,
    lastSeenVersion = nil,
    display = CopyTable(WhatTodo.DisplaySettings.DEFAULTS),
  },
}

function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("WhatTodoDB", dbDefaults)
  WhatTodo.db = self.db
  -- chaque personnage a son propre profil (liste perso isolée + copiable entre persos).
  -- les versions <= 1.2 épinglaient un profil "Default" partagé : on rebascule ce
  -- personnage sur son profil dédié avant toute migration de données.
  local charProfile = self.db.keys.char
  if self.db:GetCurrentProfile() ~= charProfile then
    self.db:SetProfile(charProfile)
  end
  WhatTodo.Migrations.Run(self.db)
  WhatTodo.Tasks.Init(self.db)
  WhatTodo.AdminPanel.Setup()
  WhatTodo.Minimap.Setup(self.db)
  WhatTodo.Options.Setup(self.db)
  self:RegisterChatCommand("wt", "HandleSlash")
  self:RegisterChatCommand("whattodo", "HandleSlash")
end

function addon:OnEnable()
  WhatTodo.Display.Build(self.db)
  WhatTodo.ChangelogPopup.Initialize(self.db)
  self:RegisterEvent("PLAYER_ENTERING_WORLD", function() WhatTodo.Display.Refresh() end)
  self.ticker = C_Timer.NewTicker(60, function() WhatTodo.Display.Refresh() end)
  if self.db.char.display.shown then
    WhatTodo.Display.Show()
  else
    WhatTodo.Display.Hide()
  end
end

function addon:HandleSlash(input)
  input = strtrim(input or ""):lower()
  if input == "config" then
    WhatTodo.AdminPanel.Open()
  elseif input == "options" then
    WhatTodo.Options.Open()
  else
    WhatTodo.Display.Toggle()
  end
end
