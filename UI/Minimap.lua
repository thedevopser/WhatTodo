local ADDON_NAME, WhatTodo = ...
local Minimap = {}
WhatTodo.Minimap = Minimap
local Tasks = WhatTodo.Tasks
local L = WhatTodo_L

function Minimap.Setup(db)
  local LDB = LibStub("LibDataBroker-1.1", true)
  local LDBIcon = LibStub("LibDBIcon-1.0", true)
  if not LDB or not LDBIcon then return end

  local dataObj = LDB:NewDataObject("WhatTodo", {
    type = "launcher",
    icon = "Interface\\AddOns\\WhatTodo\\Textures\\icon",
    OnClick = function(_, button)
      if button == "RightButton" then
        WhatTodo.AdminPanel.Open()
      else
        WhatTodo.Display.Toggle()
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:AddLine("WhatTodo")
      tooltip:AddLine(L.TOOLTIP_COUNT:format(L.SECTION_DAILY, Tasks.RemainingCount("daily")), 1, 1, 1)
      tooltip:AddLine(L.TOOLTIP_COUNT:format(L.SECTION_WEEKLY, Tasks.RemainingCount("weekly")), 1, 1, 1)
      tooltip:AddLine(L.TOOLTIP_COUNT:format(L.SECTION_MONTHLY, Tasks.RemainingCount("monthly")), 1, 1, 1)
      tooltip:AddLine(L.TOOLTIP_LEFT, 0.7, 0.7, 0.7)
      tooltip:AddLine(L.TOOLTIP_RIGHT, 0.7, 0.7, 0.7)
    end,
  })

  LDBIcon:Register("WhatTodo", dataObj, db.char.minimap)
end
