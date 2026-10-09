local ADDON_NAME, WhatTodo = ...
local Display = {}
WhatTodo.Display = Display
local Tasks = WhatTodo.Tasks
local Reset = WhatTodo.Reset
local DisplaySettings = WhatTodo.DisplaySettings
local L = WhatTodo_L

-- écart entre hauteur du cadre et hauteur du viewport (marge haute 36 + marge basse 12)
local CHROME = 48
-- hauteur minimale du cadre quand peu ou pas de tâches
local MIN_HEIGHT = 120
-- largeur minimale (garde le titre et le bouton fermer lisibles)
local MIN_WIDTH = 280
-- plafond de largeur, proportionnel à l'écran
local MAX_WIDTH_RATIO = 0.4
-- marges gauche/droite du viewport (cf. SetPoint du ScrollFrame)
local SIDE_MARGIN = 12
-- décalage X des lignes dans le contenu
local ROW_INSET = 4
-- écart entre la case à cocher et son libellé
local TEXT_GAP = 4
-- arrondi de la largeur : évite que le cadre respire quand le compteur change de longueur
local WIDTH_STEP = 10
local BORDER_R, BORDER_G, BORDER_B = 0.7, 0.6, 0.4
local TEXT_COLOR = { 0.12, 0.1, 0.08 }
local MUTED_COLOR = { 0.45, 0.4, 0.33 }
local HEADER_HEIGHT = 18
-- les polices du jeu n'ont pas de glyphes ▸/▾ : icônes plus/moins natives en ligne
local ICON_COLLAPSED = "|TInterface\\Buttons\\UI-PlusButton-Up:14:14|t"
local ICON_EXPANDED = "|TInterface\\Buttons\\UI-MinusButton-Up:14:14|t"

local FREQ_ORDER = { "daily", "weekly", "monthly" }
local FREQ_TITLES = {
  daily = L.SECTION_DAILY,
  weekly = L.SECTION_WEEKLY,
  monthly = L.SECTION_MONTHLY,
}

local frame
local db
local inCombat = false

local function formatCountdown(seconds)
  if seconds < 0 then seconds = 0 end
  local h = math.floor(seconds / 3600)
  if h >= 24 then
    local d = math.floor(h / 24)
    return L.RESET_IN_DAYS:format(d, h % 24)
  end
  local m = math.floor((seconds % 3600) / 60)
  return L.RESET_IN_HOURS:format(h, m)
end

local function acquireRow(index)
  local row = frame.rows[index]
  if not row then
    row = CreateFrame("CheckButton", nil, frame.content, "UICheckButtonTemplate")
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.text:SetPoint("LEFT", row, "RIGHT", TEXT_GAP, 0)
    -- ombre coupée : sur texte sombre elle rend le rendu flou
    row.text:SetShadowColor(0, 0, 0, 0)
    row.text:SetShadowOffset(0, 0)
    -- une seule ligne : au-delà de la largeur imposée, le texte est tronqué par « … »
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(false)
    row:SetScript("OnEnter", function(self)
      -- infobulle uniquement quand le libellé est effectivement tronqué
      if self.fullLabel and self.text:GetStringWidth() > self.text:GetWidth() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.fullLabel, 1, 1, 1, true)
        GameTooltip:Show()
      end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:SetScript("OnClick", function(self)
      Tasks.SetCompleted(self.taskId, self:GetChecked())
      Display.Refresh()
    end)
    -- les FontString ne gèrent pas le barré : trait de 1 px posé sur le texte
    row.strike = row:CreateTexture(nil, "OVERLAY")
    row.strike:SetHeight(1)
    row.strike:SetPoint("LEFT", row.text, "LEFT", 0, 0)
    frame.rows[index] = row
  end
  row:Show()
  return row
end

local function isCollapsed(frequency)
  return db.char.display.collapsed[frequency] == true
end

local function acquireHeader(index)
  frame.headers = frame.headers or {}
  local header = frame.headers[index]
  if not header then
    header = CreateFrame("Button", nil, frame.content)
    header:SetHeight(HEADER_HEIGHT)
    header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header.text:SetAllPoints()
    header.text:SetShadowColor(0, 0, 0, 0)
    header.text:SetShadowOffset(0, 0)
    header.text:SetJustifyH("LEFT")
    header.text:SetWordWrap(false)
    header:RegisterForClicks("LeftButtonUp")
    header:SetScript("OnClick", function(self)
      db.char.display.collapsed[self.frequency] = not isCollapsed(self.frequency) or nil
      Display.Refresh()
    end)
    -- le bouton capte la souris : on relaie le glisser au cadre pour qu'il reste déplaçable
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() frame:GetScript("OnDragStart")(frame) end)
    header:SetScript("OnDragStop", function() frame:GetScript("OnDragStop")(frame) end)
    frame.headers[index] = header
  end
  header:Show()
  return header
end

function Display.Build(database)
  db = database
  if frame then return end

  -- un /reload en plein combat ne déclenche pas PLAYER_REGEN_DISABLED
  inCombat = InCombatLockdown()
  frame = CreateFrame("Frame", "WhatTodoFrame", UIParent, "BackdropTemplate")
  frame:SetSize(280, 360)
  frame:SetPoint(db.char.display.point, UIParent, db.char.display.point,
    db.char.display.x, db.char.display.y)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self)
    if not self.locked then self:StartMoving() end
  end)
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    db.char.display.point = point
    db.char.display.x = x
    db.char.display.y = y
  end)

  -- fond parchemin natif
  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal")
  frame.bg = bg

  frame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  frame:SetBackdropBorderColor(BORDER_R, BORDER_G, BORDER_B)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -10)
  title:SetText("WhatTodo")

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function() Display.Hide() end)

  local scroll = CreateFrame("ScrollFrame", nil, frame)
  scroll:SetPoint("TOPLEFT", 12, -36)
  scroll:SetPoint("BOTTOMRIGHT", -12, 12)
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local maxScroll = self:GetVerticalScrollRange()
    local new = math.max(0, math.min(maxScroll, self:GetVerticalScroll() - delta * 24))
    self:SetVerticalScroll(new)
  end)

  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(scroll:GetWidth())
  content:SetHeight(1)
  scroll:SetScrollChild(content)

  frame.scroll = scroll
  frame.content = content
  frame.rows = {}

  Display.ApplySettings()
  Display.Refresh()
end

function Display.ApplySettings()
  if not frame then return end
  local settings = DisplaySettings.Normalize(db.global.display)
  frame.locked = settings.locked
  frame:SetScale(settings.scale)
  frame.bg:SetAlpha(settings.backgroundAlpha)
  frame:SetBackdropBorderColor(BORDER_R, BORDER_G, BORDER_B, settings.backgroundAlpha)
  Display.UpdateVisibility()
end

-- applique la visibilité effective sans toucher à db.char.display.shown,
-- qui reste le choix du joueur (le masquage en combat est temporaire)
function Display.UpdateVisibility()
  if not frame then return end
  local hideInCombat = DisplaySettings.Normalize(db.global.display).hideInCombat
  if DisplaySettings.IsListVisible(db.char.display.shown, inCombat, hideInCombat) then
    frame:Show()
    Display.Refresh()
  else
    frame:Hide()
  end
end

function Display.SetInCombat(value)
  inCombat = value
  Display.UpdateVisibility()
end

function Display.Refresh()
  -- masquée : rien à recalculer, Show() rafraîchit à l'affichage
  if not frame or not frame:IsShown() then return end
  local now = GetServerTime()
  local offset = Reset.GetServerOffset()
  local wday = Reset.GetWeeklyResetWeekday(Reset.GetCurrentRegion())
  local completedStyle = DisplaySettings.Normalize(db.global.display).completedStyle

  for _, row in ipairs(frame.rows) do row:Hide() end
  if frame.headers then
    for _, h in ipairs(frame.headers) do h:Hide() end
  end

  local y = 0
  local rowIndex = 0
  local headerIndex = 0
  -- bord droit du contenu le plus large rencontré, sert à dimensionner le cadre
  local maxRight = 0

  for _, freq in ipairs(FREQ_ORDER) do
    local all = Tasks.GetByFrequency(freq)
    local list = Tasks.VisibleForDisplay(all, completedStyle)
    -- en mode masqué, une section entièrement faite garde son en-tête
    if #all > 0 then
      headerIndex = headerIndex + 1
      local header = acquireHeader(headerIndex)
      local nextReset = Reset.GetNextReset(freq, now, offset, wday)
      local collapsed = isCollapsed(freq)
      local done, total = Tasks.Progress(freq)
      header.frequency = freq
      header:ClearAllPoints()
      header:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, y)
      -- titre en brun très foncé (lisible sur parchemin clair), compteur en gris foncé
      header.text:SetTextColor(0.2, 0.1, 0.02)
      header.text:SetText(("%s %s  |cff4d4439(%s)|r"):format(
        collapsed and ICON_COLLAPSED or ICON_EXPANDED,
        L.SECTION_PROGRESS:format(FREQ_TITLES[freq], done, total),
        formatCountdown(nextReset - now)))
      maxRight = math.max(maxRight, header.text:GetStringWidth())
      y = y - 20

      for _, task in ipairs(collapsed and {} or list) do
        rowIndex = rowIndex + 1
        local row = acquireRow(rowIndex)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", ROW_INSET, y)
        -- tâches account-wide : marqueur discret pour les distinguer des tâches perso
        if task.scope == "account" then
          row.text:SetText(("%s  |cff4d4439(%s)|r"):format(task.label, L.SCOPE_ACCOUNT_TAG))
          row.fullLabel = ("%s (%s)"):format(task.label, L.SCOPE_ACCOUNT_TAG)
        else
          row.text:SetText(task.label)
          row.fullLabel = task.label
        end
        maxRight = math.max(maxRight,
          ROW_INSET + row:GetWidth() + TEXT_GAP + row.text:GetStringWidth())
        local done = Tasks.IsDone(task)
        row:SetChecked(done)
        row.taskId = task.id
        row.dimmed = done and completedStyle == "dim"
        row.text:SetTextColor(unpack(row.dimmed and MUTED_COLOR or TEXT_COLOR))
        y = y - 24
      end
      y = y - 6
    end
  end

  local contentHeight = -y

  -- largeur : ajustée au libellé le plus long, arrondie, bornée par l'écran
  local maxWidth = math.floor(UIParent:GetWidth() * MAX_WIDTH_RATIO)
  local wantedWidth = math.ceil((maxRight + 2 * SIDE_MARGIN) / WIDTH_STEP) * WIDTH_STEP
  local w = math.max(MIN_WIDTH, math.min(wantedWidth, maxWidth))
  frame:SetWidth(w)

  -- largeur du viewport déduite du cadre : l'ancrage du ScrollFrame n'est pas encore propagé
  local contentWidth = w - 2 * SIDE_MARGIN
  frame.content:SetWidth(contentWidth)
  frame.content:SetHeight(math.max(contentHeight, 1))

  -- passe d'application : contraint les textes, ce qui déclenche la troncature si besoin
  for i = 1, rowIndex do
    local row = frame.rows[i]
    row.text:SetWidth(contentWidth - ROW_INSET - row:GetWidth() - TEXT_GAP)
    if row.dimmed then
      row.strike:SetColorTexture(unpack(MUTED_COLOR))
      row.strike:SetWidth(math.min(row.text:GetStringWidth(), row.text:GetWidth()))
      row.strike:Show()
    else
      row.strike:Hide()
    end
  end
  for i = 1, headerIndex do
    frame.headers[i]:SetWidth(contentWidth)
  end

  local maxHeight = math.floor(UIParent:GetHeight() * 0.8)
  local wanted = contentHeight + CHROME
  local h = math.max(MIN_HEIGHT, math.min(wanted, maxHeight))
  frame:SetHeight(h)

  -- tout tient dans le cadre : on remet le scroll en haut
  if wanted <= h then
    frame.scroll:SetVerticalScroll(0)
  end
end

function Display.Show()
  db.char.display.shown = true
  Display.UpdateVisibility()
end

function Display.Hide()
  db.char.display.shown = false
  Display.UpdateVisibility()
end

-- bascule le choix du joueur ; en combat avec masquage actif, il s'applique à la sortie
function Display.Toggle()
  if db.char.display.shown then
    Display.Hide()
  else
    Display.Show()
  end
end
