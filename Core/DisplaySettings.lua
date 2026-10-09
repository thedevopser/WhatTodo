local ADDON_NAME, WhatTodo = ...
local DisplaySettings = {}
WhatTodo.DisplaySettings = DisplaySettings

DisplaySettings.SCALE_MIN = 0.5
DisplaySettings.SCALE_MAX = 2
DisplaySettings.ALPHA_MIN = 0
DisplaySettings.ALPHA_MAX = 1

DisplaySettings.COMPLETED_STYLES = { "show", "dim", "hide" }

-- Schéma complet des réglages compte (db.global.display) ; les champs pas encore
-- exposés dans les options sont figés ici pour éviter une migration plus tard.
DisplaySettings.DEFAULTS = {
  scale = 1,
  backgroundAlpha = 1,
  locked = false,
  theme = "parchment",
  completedStyle = "dim",
  hideInCombat = false,
}

local function isCompletedStyle(value)
  for _, style in ipairs(DisplaySettings.COMPLETED_STYLES) do
    if style == value then return true end
  end
  return false
end

DisplaySettings.IsCompletedStyle = isCompletedStyle

local function clampNumber(value, min, max, fallback)
  -- value ~= value : NaN
  if type(value) ~= "number" or value ~= value then return fallback end
  return math.max(min, math.min(max, value))
end

function DisplaySettings.Normalize(raw)
  if type(raw) ~= "table" then
    error("DisplaySettings.Normalize: settings must be a table, got " .. type(raw), 2)
  end
  local defaults = DisplaySettings.DEFAULTS
  return {
    scale = clampNumber(raw.scale, DisplaySettings.SCALE_MIN, DisplaySettings.SCALE_MAX, defaults.scale),
    backgroundAlpha = clampNumber(raw.backgroundAlpha, DisplaySettings.ALPHA_MIN, DisplaySettings.ALPHA_MAX,
      defaults.backgroundAlpha),
    locked = raw.locked == true,
    completedStyle = isCompletedStyle(raw.completedStyle) and raw.completedStyle or defaults.completedStyle,
    hideInCombat = raw.hideInCombat == true,
  }
end

function DisplaySettings.IsListVisible(shown, inCombat, hideInCombat)
  return shown and not (inCombat and hideInCombat)
end
