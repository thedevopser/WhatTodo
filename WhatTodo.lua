local ADDON_NAME, WhatTodo = ...

local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("WhatTodo", "AceConsole-3.0", "AceEvent-3.0")
WhatTodo.addon = addon

local dbDefaults = {
  char = {
    tasks = {},
    nextId = 1,
    display = { shown = true, point = "CENTER", x = 0, y = 0 },
    minimap = { hide = false },
  },
}

function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("WhatTodoDB", dbDefaults, true)
  WhatTodo.db = self.db
  WhatTodo.Tasks.Init(self.db)
  WhatTodo.AdminPanel.Setup()
  WhatTodo.Minimap.Setup(self.db)
  self:RegisterChatCommand("wt", "HandleSlash")
  self:RegisterChatCommand("whattodo", "HandleSlash")
end

function addon:OnEnable()
  WhatTodo.Display.Build(self.db)
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
  else
    WhatTodo.Display.Toggle()
  end
end
