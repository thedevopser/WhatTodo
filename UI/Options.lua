local ADDON_NAME, WhatTodo = ...
local Options = {}
WhatTodo.Options = Options
local DisplaySettings = WhatTodo.DisplaySettings
local L = WhatTodo_L

local APP_NAME = "WhatTodo"
local SLIDER_STEP = 0.05

local db
local categoryID

local function settings()
  return db.global.display
end

local function setAndApply(key, value)
  settings()[key] = value
  WhatTodo.Display.ApplySettings()
end

local function buildOptionsTable()
  return {
    type = "group",
    name = APP_NAME,
    args = {
      locked = {
        order = 1,
        type = "toggle",
        name = L.OPT_LOCKED,
        desc = L.OPT_LOCKED_DESC,
        width = "full",
        get = function() return DisplaySettings.Normalize(settings()).locked end,
        set = function(_, value) setAndApply("locked", value) end,
      },
      scale = {
        order = 2,
        type = "range",
        name = L.OPT_SCALE,
        desc = L.OPT_SCALE_DESC,
        min = DisplaySettings.SCALE_MIN,
        max = DisplaySettings.SCALE_MAX,
        step = SLIDER_STEP,
        isPercent = true,
        get = function() return DisplaySettings.Normalize(settings()).scale end,
        set = function(_, value) setAndApply("scale", value) end,
      },
      backgroundAlpha = {
        order = 3,
        type = "range",
        name = L.OPT_BACKGROUND_ALPHA,
        desc = L.OPT_BACKGROUND_ALPHA_DESC,
        min = DisplaySettings.ALPHA_MIN,
        max = DisplaySettings.ALPHA_MAX,
        step = SLIDER_STEP,
        isPercent = true,
        get = function() return DisplaySettings.Normalize(settings()).backgroundAlpha end,
        set = function(_, value) setAndApply("backgroundAlpha", value) end,
      },
    },
  }
end

function Options.Setup(database)
  db = database
  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(APP_NAME, buildOptionsTable)
  local _, id = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(APP_NAME, APP_NAME)
  categoryID = id
end

function Options.Open()
  if categoryID then
    Settings.OpenToCategory(categoryID)
  end
end
