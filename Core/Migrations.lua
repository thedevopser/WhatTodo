local ADDON_NAME, WhatTodo = ...
local Migrations = {}
WhatTodo.Migrations = Migrations

-- Framework de migration de schéma SavedVariables.
-- Chaque step déclare sa portée et reçoit la table AceDB complète pour pouvoir
-- déplacer des données entre sous-tables (ex : db.char -> db.profile).
-- Les versions sont suivies séparément par portée : db.char.dbVersion (rejoué par
-- chaque perso) et db.global.dbVersion (joué une fois par compte) — sinon le 1er
-- perso qui bump la version globale empêcherait les autres de migrer leur db.char.
Migrations.steps = {
  {
    version = 1,
    scope = "char",
    apply = function(db)
      -- Ancien schéma : les tâches vivaient dans db.char ; on les déplace vers
      -- db.profile pour rendre la liste copiable entre persos (profils AceDB).
      if db.char.tasks ~= nil then
        db.profile.tasks = db.char.tasks
        db.profile.nextId = db.char.nextId or 1
        db.char.tasks = nil
        db.char.nextId = nil
      end
    end,
  },
}

local function latestFor(scope)
  local latest = 0
  for _, step in ipairs(Migrations.steps) do
    if step.scope == scope and step.version > latest then
      latest = step.version
    end
  end
  return latest
end

function Migrations.LatestCharVersion()
  return latestFor("char")
end

function Migrations.LatestGlobalVersion()
  return latestFor("global")
end

local function currentVersion(db, scope)
  if scope == "char" then
    return db.char.dbVersion or 0
  end
  return db.global.dbVersion or 0
end

local function setVersion(db, scope, version)
  if scope == "char" then
    db.char.dbVersion = version
  else
    db.global.dbVersion = version
  end
end

function Migrations.Run(db)
  for _, scope in ipairs({ "char", "global" }) do
    for _, step in ipairs(Migrations.steps) do
      if step.scope == scope and step.version > currentVersion(db, scope) then
        step.apply(db)
        setVersion(db, scope, step.version)
      end
    end
  end
end
