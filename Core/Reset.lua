local ADDON_NAME, WhatTodo = ...
local Reset = {}
WhatTodo.Reset = Reset

local DAY = 86400

-- GetCurrentRegion(): 1=US, 2=KR, 3=EU, 4=TW, 5=CN
-- t.wday : 1=dimanche … 7=samedi  (mardi=3, mercredi=4, jeudi=5)
local WEEKLY_RESET_WDAY = {
  [1] = 3, -- US : mardi
  [3] = 4, -- EU : mercredi
  [2] = 5, -- KR : jeudi
  [4] = 5, -- TW : jeudi
  [5] = 5, -- CN : jeudi
}

function Reset.GetWeeklyResetWeekday(region)
  return WEEKLY_RESET_WDAY[region] or 4 -- fallback mercredi (EU) si région inconnue
end

function Reset.GetCurrentRegion()
  return GetCurrentRegion and GetCurrentRegion() or nil
end

-- offset (en secondes) entre l'heure murale du royaume et l'UTC
function Reset.GetServerOffset()
  local now = GetServerTime()
  local utc = date("!*t", now)
  local realm = C_DateAndTime.GetCurrentCalendarTime()
  local utcSecs = utc.hour * 3600 + utc.min * 60 + utc.sec
  local realmSecs = realm.hour * 3600 + realm.minute * 60
  local offset = realmSecs - utcSecs
  -- on ramène l'offset dans [-12h, +12h]
  if offset > 12 * 3600 then
    offset = offset - DAY
  elseif offset < -12 * 3600 then
    offset = offset + DAY
  end
  return offset
end

-- composantes de l'heure murale du royaume pour un epoch donné
local function realmTime(now, offset)
  return date("!*t", now + offset)
end

local function daysInMonth(year, month)
  local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
  if month == 2 and (year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)) then
    return 29
  end
  return days[month]
end

-- dernière borne 5h royaume déjà passée pour la fréquence
function Reset.GetResetBoundary(frequency, now, offset, weeklyResetWday)
  local t = realmTime(now, offset)
  local secsSinceMidnight = t.hour * 3600 + t.min * 60 + t.sec
  local today5h = now - secsSinceMidnight + 5 * 3600

  if frequency == "daily" then
    if now >= today5h then
      return today5h
    end
    return today5h - DAY

  elseif frequency == "weekly" then
    weeklyResetWday = weeklyResetWday or 4
    local daysSince = (t.wday - weeklyResetWday) % 7
    local boundary = today5h - daysSince * DAY
    if now < boundary then
      boundary = boundary - 7 * DAY
    end
    return boundary

  elseif frequency == "monthly" then
    local firstOfMonth5h = today5h - (t.day - 1) * DAY
    if now >= firstOfMonth5h then
      return firstOfMonth5h
    end
    -- 1er du mois précédent
    local prevPoint = firstOfMonth5h - DAY
    local tp = realmTime(prevPoint, offset)
    return prevPoint - (tp.day - 1) * DAY
  end
end

-- prochaine borne 5h royaume à venir
function Reset.GetNextReset(frequency, now, offset, weeklyResetWday)
  local boundary = Reset.GetResetBoundary(frequency, now, offset, weeklyResetWday)
  if frequency == "daily" then
    return boundary + DAY
  elseif frequency == "weekly" then
    return boundary + 7 * DAY
  elseif frequency == "monthly" then
    local t = realmTime(boundary, offset)
    return boundary + daysInMonth(t.year, t.month) * DAY
  end
end

-- une tâche est-elle faite pour la période courante ?
function Reset.IsDone(lastCompleted, frequency, now, offset, weeklyResetWday)
  if not lastCompleted then
    return false
  end
  return lastCompleted >= Reset.GetResetBoundary(frequency, now, offset, weeklyResetWday)
end
