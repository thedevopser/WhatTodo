local ADDON_NAME, WhatTodo = ...
local Tasks = {}
WhatTodo.Tasks = Tasks
local Reset = WhatTodo.Reset
local DisplaySettings = WhatTodo.DisplaySettings

local db

function Tasks.Init(database)
  db = database
end

local function now()
  return GetServerTime()
end

local function offset()
  return Reset.GetServerOffset()
end

local function weeklyResetWday()
  return Reset.GetWeeklyResetWeekday(Reset.GetCurrentRegion())
end

-- Deux portées : "char" -> db.profile.tasks (liste copiable entre persos via les
-- profils AceDB), "account" -> db.global.tasks (partagée, complétion partagée).
-- La table de stockage est déterminée par le préfixe d'id : "t" = char, "a" = account.
local function storeFor(scope)
  if scope == "account" then return db.global, "a" end
  return db.profile, "t"
end

local function storeForId(id)
  if id:sub(1, 1) == "a" then return db.global end
  return db.profile
end

function Tasks.GetAll()
  local out = {}
  for _, task in ipairs(db.profile.tasks) do out[#out + 1] = task end
  for _, task in ipairs(db.global.tasks) do out[#out + 1] = task end
  return out
end

function Tasks.GetByFrequency(frequency)
  local out = {}
  for _, task in ipairs(Tasks.GetAll()) do
    if task.frequency == frequency then
      out[#out + 1] = task
    end
  end
  table.sort(out, function(a, b) return (a.order or 0) < (b.order or 0) end)
  return out
end

-- templateSeason : clé de la saison d'origine quand la tâche vient d'un template
-- (nil pour une saisie manuelle). Sert au retrait groupé par saison.
function Tasks.Add(label, frequency, scope, templateSeason)
  label = strtrim(label or "")
  if label == "" then return end
  scope = scope == "account" and "account" or "char"
  local store, prefix = storeFor(scope)
  local id = prefix .. store.nextId
  store.nextId = store.nextId + 1
  store.tasks[#store.tasks + 1] = {
    id = id,
    label = label,
    frequency = frequency,
    scope = scope,
    templateSeason = templateSeason,
    lastCompleted = nil,
    order = #store.tasks + 1,
  }
  return id
end

local function indexOf(id)
  local store = storeForId(id)
  for i, task in ipairs(store.tasks) do
    if task.id == id then return i, task, store end
  end
end

function Tasks.Remove(id)
  local i, _, store = indexOf(id)
  if i then table.remove(store.tasks, i) end
end

function Tasks.Update(id, fields)
  local _, task = indexOf(id)
  if not task then return end
  for k, v in pairs(fields) do
    task[k] = v
  end
end

function Tasks.SetCompleted(id, done)
  local _, task = indexOf(id)
  if not task then return end
  task.lastCompleted = done and now() or nil
end

function Tasks.IsDone(task)
  return Reset.IsDone(task.lastCompleted, task.frequency, now(), offset(), weeklyResetWday())
end

function Tasks.Progress(frequency)
  local list = Tasks.GetByFrequency(frequency)
  local done = 0
  for _, task in ipairs(list) do
    if Tasks.IsDone(task) then done = done + 1 end
  end
  return done, #list
end

function Tasks.RemainingCount(frequency)
  local done, total = Tasks.Progress(frequency)
  return total - done
end

function Tasks.VisibleForDisplay(list, completedStyle)
  if not DisplaySettings.IsCompletedStyle(completedStyle) then
    error("Tasks.VisibleForDisplay: unknown completed style " .. tostring(completedStyle), 2)
  end
  local out = {}
  for _, task in ipairs(list) do
    if completedStyle ~= "hide" or not Tasks.IsDone(task) then
      out[#out + 1] = task
    end
  end
  return out
end
