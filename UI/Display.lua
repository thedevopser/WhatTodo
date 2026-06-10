local ADDON_NAME, WhatTodo = ...
local Display = {}
WhatTodo.Display = Display
local Tasks = WhatTodo.Tasks
local Reset = WhatTodo.Reset
local L = WhatTodo_L

local FREQ_ORDER = { "daily", "weekly", "monthly" }
local FREQ_TITLES = {
  daily = L.SECTION_DAILY,
  weekly = L.SECTION_WEEKLY,
  monthly = L.SECTION_MONTHLY,
}

local frame
local db

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
    row.text:SetPoint("LEFT", row, "RIGHT", 4, 0)
    row.text:SetTextColor(0.12, 0.1, 0.08)
    -- ombre coupée : sur texte sombre elle rend le rendu flou
    row.text:SetShadowColor(0, 0, 0, 0)
    row.text:SetShadowOffset(0, 0)
    frame.rows[index] = row
  end
  row:Show()
  return row
end

local function acquireHeader(index)
  frame.headers = frame.headers or {}
  local header = frame.headers[index]
  if not header then
    header = frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetShadowColor(0, 0, 0, 0)
    header:SetShadowOffset(0, 0)
    frame.headers[index] = header
  end
  header:Show()
  return header
end

function Display.Build(database)
  db = database
  if frame then return end

  frame = CreateFrame("Frame", "WhatTodoFrame", UIParent, "BackdropTemplate")
  frame:SetSize(280, 360)
  frame:SetPoint(db.char.display.point, UIParent, db.char.display.point,
    db.char.display.x, db.char.display.y)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
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

  frame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  frame:SetBackdropBorderColor(0.7, 0.6, 0.4)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -10)
  title:SetText("WhatTodo")

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function() Display.Hide() end)

  local content = CreateFrame("Frame", nil, frame)
  content:SetPoint("TOPLEFT", 12, -36)
  content:SetPoint("BOTTOMRIGHT", -12, 12)
  frame.content = content
  frame.rows = {}

  Display.Refresh()
end

function Display.Refresh()
  if not frame then return end
  local now = GetServerTime()
  local offset = Reset.GetServerOffset()

  for _, row in ipairs(frame.rows) do row:Hide() end
  if frame.headers then
    for _, h in ipairs(frame.headers) do h:Hide() end
  end

  local y = 0
  local rowIndex = 0
  local headerIndex = 0

  for _, freq in ipairs(FREQ_ORDER) do
    local list = Tasks.GetByFrequency(freq)
    if #list > 0 then
      headerIndex = headerIndex + 1
      local header = acquireHeader(headerIndex)
      local nextReset = Reset.GetNextReset(freq, now, offset)
      header:ClearAllPoints()
      header:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, y)
      -- titre en brun très foncé (lisible sur parchemin clair), compteur en gris foncé
      header:SetTextColor(0.2, 0.1, 0.02)
      header:SetText(("%s  |cff4d4439(%s)|r"):format(
        FREQ_TITLES[freq], formatCountdown(nextReset - now)))
      y = y - 20

      for _, task in ipairs(list) do
        rowIndex = rowIndex + 1
        local row = acquireRow(rowIndex)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 4, y)
        row.text:SetText(task.label)
        row:SetChecked(Tasks.IsDone(task))
        row.taskId = task.id
        row:SetScript("OnClick", function(self)
          Tasks.SetCompleted(self.taskId, self:GetChecked())
        end)
        y = y - 24
      end
      y = y - 6
    end
  end
end

function Display.Show()
  if frame then
    frame:Show()
    db.char.display.shown = true
    Display.Refresh()
  end
end

function Display.Hide()
  if frame then
    frame:Hide()
    db.char.display.shown = false
  end
end

function Display.Toggle()
  if frame and frame:IsShown() then
    Display.Hide()
  else
    Display.Show()
  end
end
