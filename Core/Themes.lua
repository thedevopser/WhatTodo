local ADDON_NAME, WhatTodo = ...
local Themes = {}
WhatTodo.Themes = Themes

local GOLD = { 1, 0.82, 0 }
local SOLID = "Interface\\Buttons\\WHITE8X8"

-- background : { texture, color } (texture teintée) ; absent = pas de fond.
-- border : { edgeFile, edgeSize, inset, color } ; absent = pas de bord. inset = retrait
-- du fond sous le bord, propre à chaque texture de bord.
-- L'opacité réglée par le joueur se multiplie à l'alpha du fond et du bord.
Themes.list = {
  {
    key = "parchment",
    labelKey = "THEME_PARCHMENT",
    background = {
      texture = "Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal",
      color = { 1, 1, 1, 1 },
    },
    border = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, inset = 4, color = { 0.7, 0.6, 0.4, 1 } },
    titleColor = GOLD,
    headerColor = { 0.2, 0.1, 0.02 },
    textColor = { 0.12, 0.1, 0.08 },
    mutedColor = { 0.45, 0.4, 0.33 },
    countdownColor = { 0.3, 0.27, 0.22 },
    -- ombre coupée : sur texte sombre elle rend le rendu flou
    textShadow = false,
  },
  {
    key = "parchment_dark",
    labelKey = "THEME_PARCHMENT_DARK",
    background = {
      texture = "Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal",
      color = { 0.35, 0.3, 0.24, 1 },
    },
    border = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, inset = 4, color = { 0.45, 0.38, 0.25, 1 } },
    titleColor = GOLD,
    headerColor = { 1, 0.85, 0.55 },
    textColor = { 0.95, 0.9, 0.8 },
    mutedColor = { 0.6, 0.55, 0.45 },
    countdownColor = { 0.8, 0.75, 0.65 },
    textShadow = true,
  },
  {
    key = "dark",
    labelKey = "THEME_DARK",
    background = { texture = SOLID, color = { 0.05, 0.05, 0.05, 0.85 } },
    border = { edgeFile = SOLID, edgeSize = 1, inset = 1, color = { 0, 0, 0, 1 } },
    titleColor = { 1, 1, 1 },
    headerColor = GOLD,
    textColor = { 0.9, 0.9, 0.9 },
    mutedColor = { 0.5, 0.5, 0.5 },
    countdownColor = { 0.6, 0.6, 0.6 },
    textShadow = false,
  },
  {
    key = "blizzard",
    labelKey = "THEME_BLIZZARD",
    background = { texture = "Interface\\DialogFrame\\UI-DialogBox-Background", color = { 1, 1, 1, 1 } },
    border = { edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16, inset = 4, color = { 1, 1, 1, 1 } },
    titleColor = GOLD,
    headerColor = GOLD,
    textColor = { 1, 1, 1 },
    mutedColor = { 0.5, 0.5, 0.5 },
    countdownColor = { 0.7, 0.7, 0.7 },
    textShadow = true,
  },
  {
    key = "transparent",
    labelKey = "THEME_TRANSPARENT",
    titleColor = GOLD,
    headerColor = GOLD,
    textColor = { 1, 1, 1 },
    mutedColor = { 0.6, 0.6, 0.6 },
    countdownColor = { 0.8, 0.8, 0.8 },
    -- sans fond, l'ombre garde le texte lisible sur n'importe quel décor
    textShadow = true,
  },
}

Themes.DEFAULT_KEY = "parchment"

function Themes.Find(key)
  for _, theme in ipairs(Themes.list) do
    if theme.key == key then return theme end
  end
  return nil
end

function Themes.Get(key)
  return Themes.Find(key) or Themes.Find(Themes.DEFAULT_KEY)
end
