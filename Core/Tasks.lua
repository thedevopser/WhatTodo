local ADDON_NAME, WhatTodo = ...
local Tasks = {}
WhatTodo.Tasks = Tasks
local Reset = WhatTodo.Reset

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

function Tasks.GetAll()
  return db.char.tasks
end

function Tasks.GetByFrequency(frequency)
  local out = {}
  for _, task in ipairs(db.char.tasks) do
    if task.frequency == frequency then
      out[#out + 1] = task
    end
  end
  table.sort(out, function(a, b) return (a.order or 0) < (b.order or 0) end)
  return out
end

function Tasks.Add(label, frequency)
  label = strtrim(label or "")
  if label == "" then return end
  local id = "t" .. db.char.nextId
  db.char.nextId = db.char.nextId + 1
  db.char.tasks[#db.char.tasks + 1] = {
    id = id,
    label = label,
    frequency = frequency,
    lastCompleted = nil,
    order = #db.char.tasks + 1,
  }
  return id
end

local function indexOf(id)
  for i, task in ipairs(db.char.tasks) do
    if task.id == id then return i, task end
  end
end

function Tasks.Remove(id)
  local i = indexOf(id)
  if i then table.remove(db.char.tasks, i) end
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
  return Reset.IsDone(task.lastCompleted, task.frequency, now(), offset())
end

function Tasks.RemainingCount(frequency)
  local count = 0
  for _, task in ipairs(Tasks.GetByFrequency(frequency)) do
    if not Tasks.IsDone(task) then count = count + 1 end
  end
  return count
end
