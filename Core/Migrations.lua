local _, WhatTodo = ...
local Migrations = {}
WhatTodo.Migrations = Migrations

local L = WhatTodo_L

-- Libellés des templates Midnight S1 et S2 (1.4.0 à 1.6.0), figés en anglais et
-- en français : le joueur a pu importer sous l'une ou l'autre langue, et les clés
-- de locale correspondantes n'existent plus. Valeur = clé du template Essentiels
-- qui reprend la tâche, ou false si elle disparaît.
local RETIRED_TEMPLATE_LABELS = {
  ["Great Vault"] = "TPL_GREAT_VAULT",
  ["Grand Coffre"] = "TPL_GREAT_VAULT",
  ["Mythic+ (best keys)"] = "TPL_MYTHIC_PLUS",
  ["Mythique+ (meilleures clés)"] = "TPL_MYTHIC_PLUS",
  ["Bountiful Delves (keys)"] = "TPL_BOUNTIFUL_DELVE",
  ["Gouffres abondants (clés)"] = "TPL_BOUNTIFUL_DELVE",
  ["World event weekly quest"] = "TPL_WORLD_EVENT",
  ["Quête hebdo d'événement mondial"] = "TPL_WORLD_EVENT",
  ["Housing weekly quest"] = "TPL_HOUSING",
  ["Quête hebdo de logement"] = "TPL_HOUSING",
  ["Trading Post / Traveler's Log"] = "TPL_TRADING_POST",
  ["Comptoir d'échange / Journal du voyageur"] = "TPL_TRADING_POST",
  ["Void Assault (weekly)"] = false,
  ["Assaut du Vide (hebdo)"] = false,
  ["Ritual Sites"] = false,
  ["Sites rituels"] = false,
  ["Showdown zones (Naigtal / Val)"] = false,
  ["Zones d'affrontement (Naigtal / Val)"] = false,
  ["3 Nightmare Prey hunts"] = false,
  ["3 chasses « Proie de cauchemar »"] = false,
  ["Sporefall raid (Rotmire)"] = false,
  ["Raid Sporefall (Rotmire)"] = false,
  ["At least one T11 Delve"] = false,
  ["Au moins une Faille T11"] = false,
  ["Weekly Renown activities"] = false,
  ["Activités de Renommée hebdo"] = false,
  ["Timewalking weekly quest"] = false,
  ["Quête hebdo Marche du temps"] = false,
  ["Curse Surges & rares (Coiled Isle)"] = false,
  ["Résurgences maudites & rares (Île Annelée)"] = false,
  ["Cursed Fishing (Capt. Tokka)"] = false,
  ["Pêche maudite (cap. Tokka)"] = false,
  ["Ral'kala daily bonus"] = false,
  ["Bonus quotidien de Ral'kala"] = false,
  ["Vaults of Atal'Utek public event"] = false,
  ["Événement public : Vaults of Atal'Utek"] = false,
  ["Special Assignment (Coiled Isle)"] = false,
  ["Assignation spéciale (Île Annelée)"] = false,
  ["Prey hunts (15/week cap)"] = false,
  ["Chasses de la Traque (cap 15/sem.)"] = false,
  ["Housing Endeavor"] = false,
  ["Mythic 0 (daily reset)"] = false,
  ["Mythique 0 (reset quotidien)"] = false,
  ["The Venomous Abyss raid"] = false,
  ["Raid de l'Abîme Venimeux"] = false,
  ["Lair: The Tidebound Grotto"] = false,
  ["Repaire de la Grotte des Marées"] = false,
  ["Nebulous Voidcore bonus roll"] = false,
  ["Relance Noyau du Vide nébuleux"] = false,
  ["Delve T8+ (Vault World slot)"] = false,
  ["Gouffre T8+ (ligne Monde du Coffre)"] = false,
  ["Weekly crest cap (100/type)"] = false,
  ["Cap hebdo d'écus (100/type)"] = false,
  ["Weekly Conquest objective"] = false,
  ["Objectif Conquête hebdo"] = false,
  ["Rated Solo Shuffle / Blitz"] = false,
  ["Mêlée cotée / Blitz coté"] = false,
  ["Zul'jarra's Forces renown"] = false,
  ["Renom Forces de Zul'jarra"] = false,
  ["Corrosive Souls (Altar of Corrosion)"] = false,
  ["Âmes corrosives (Autel de la corrosion)"] = false,
  ["Delver's Journey"] = false,
  ["Périple des Gouffres"] = false,
  ["Preyhunter's Journey"] = false,
  ["Périple de la Traque"] = false,
  ["Profession treatise"] = false,
  ["Traité de métier"] = false,
  ["Crafting orders"] = false,
  ["Commandes de craft"] = false,
}

-- La 1.4.0 importait la S1 sans poser de marqueur templateSeason : une tâche sans
-- marqueur n'est reconnue comme template que si son libellé vient de la S1.
local UNMARKED_S1_LABELS = {
  ["Void Assault (weekly)"] = true, ["Assaut du Vide (hebdo)"] = true,
  ["Ritual Sites"] = true, ["Sites rituels"] = true,
  ["Showdown zones (Naigtal / Val)"] = true, ["Zones d'affrontement (Naigtal / Val)"] = true,
  ["3 Nightmare Prey hunts"] = true, ["3 chasses « Proie de cauchemar »"] = true,
  ["World event weekly quest"] = true, ["Quête hebdo d'événement mondial"] = true,
  ["Housing weekly quest"] = true, ["Quête hebdo de logement"] = true,
  ["Sporefall raid (Rotmire)"] = true, ["Raid Sporefall (Rotmire)"] = true,
  ["Mythic+ (best keys)"] = true, ["Mythique+ (meilleures clés)"] = true,
  ["At least one T11 Delve"] = true, ["Au moins une Faille T11"] = true,
  ["Great Vault"] = true, ["Grand Coffre"] = true,
  ["Weekly Renown activities"] = true, ["Activités de Renommée hebdo"] = true,
  ["Timewalking weekly quest"] = true, ["Quête hebdo Marche du temps"] = true,
}

local RETIRED_SEASONS = { midnight_s1 = true, midnight_s2 = true }

local function isRetiredTemplateTask(task)
  if RETIRED_SEASONS[task.templateSeason] then return true end
  return task.templateSeason == nil and UNMARKED_S1_LABELS[task.label] == true
end

-- Une tâche marquée S1/S2 dont le libellé est inconnu a été renommée par le
-- joueur : elle lui appartient désormais et reste, sans marqueur.
local function migrateRetiredTemplates(tasks)
  local kept, keptLabels = {}, {}
  for _, task in ipairs(tasks) do
    if not isRetiredTemplateTask(task) then
      kept[#kept + 1] = task
    else
      local replacement = RETIRED_TEMPLATE_LABELS[task.label]
      if replacement == nil then
        task.templateSeason = nil
        kept[#kept + 1] = task
      elseif replacement and not keptLabels[replacement] then
        keptLabels[replacement] = true
        task.label = L[replacement]
        task.templateSeason = "essentials"
        kept[#kept + 1] = task
      end
    end
  end
  return kept
end

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
  {
    version = 2,
    scope = "char",
    apply = function(db)
      db.profile.tasks = migrateRetiredTemplates(db.profile.tasks)
    end,
  },
  {
    version = 1,
    scope = "global",
    apply = function(db)
      db.global.tasks = migrateRetiredTemplates(db.global.tasks)
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
