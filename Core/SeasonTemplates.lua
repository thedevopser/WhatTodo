local ADDON_NAME, WhatTodo = ...
local SeasonTemplates = {}
WhatTodo.SeasonTemplates = SeasonTemplates

local Tasks = WhatTodo.Tasks
local L = WhatTodo_L

-- Contenu prérempli, une entrée par saison. Les libellés passent par des clés
-- L.TPL_* pour rester corrigeables en jeu sans toucher à la logique. Chaque item :
-- { labelKey, frequency, scope }. Saisons, catégories et items sont ordonnés pour
-- un affichage stable ; la saison la plus récente vient en premier.
--
-- Les items partagés entre saisons (Grand Coffre, Mythique+, logement…) réutilisent
-- volontairement la même clé : libellé identique = déduplication automatique.
SeasonTemplates.seasons = {
  {
    key = "midnight_s2",
    label = L.TPL_SEASON_MIDNIGHT_S2,
    categories = {
      {
        key = "world",
        label = L.TPL_CAT_WORLD,
        items = {
          { labelKey = "TPL_S2_CURSE_SURGE",         frequency = "daily",  scope = "char" },
          { labelKey = "TPL_S2_CURSED_FISHING",      frequency = "daily",  scope = "char" },
          { labelKey = "TPL_S2_RALKALA",             frequency = "daily",  scope = "char" },
          { labelKey = "TPL_S2_VAULTS_ATALUTEK",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_SPECIAL_ASSIGNMENT",  frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_PREY_HUNTS",          frequency = "weekly", scope = "char" },
          { labelKey = "TPL_WORLD_EVENT",            frequency = "weekly", scope = "char" },
          { labelKey = "TPL_HOUSING",                frequency = "weekly", scope = "account" },
          { labelKey = "TPL_S2_ENDEAVOR",            frequency = "weekly", scope = "account" },
        },
      },
      {
        key = "pve",
        label = L.TPL_CAT_PVE,
        items = {
          { labelKey = "TPL_S2_MYTHIC_ZERO",         frequency = "daily",  scope = "char" },
          { labelKey = "TPL_S2_RAID_VENOMOUS_ABYSS", frequency = "weekly", scope = "char" },
          { labelKey = "TPL_MYTHIC_PLUS",            frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_LAIR_TIDEBOUND",      frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_VOIDCORE",            frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_DELVE_T8",            frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_BOUNTIFUL_DELVE",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_GREAT_VAULT",            frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_CRESTS",              frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "pvp",
        label = L.TPL_CAT_PVP,
        items = {
          { labelKey = "TPL_S2_CONQUEST", frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_RATED",    frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "rep",
        label = L.TPL_CAT_REP,
        items = {
          { labelKey = "TPL_S2_RENOWN_ZULJARRA",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_CORROSIVE_SOULS",     frequency = "weekly", scope = "account" },
          { labelKey = "TPL_S2_DELVERS_JOURNEY",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_PREYHUNTER_JOURNEY",  frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "craft",
        label = L.TPL_CAT_CRAFT,
        items = {
          { labelKey = "TPL_S2_TREATISE",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_S2_CRAFT_ORDERS", frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "event",
        label = L.TPL_CAT_EVENT,
        items = {
          { labelKey = "TPL_TIMEWALKING",     frequency = "weekly",  scope = "char" },
          { labelKey = "TPL_S2_TRADING_POST", frequency = "monthly", scope = "account" },
        },
      },
    },
  },
  {
    key = "midnight_s1",
    label = L.TPL_SEASON_MIDNIGHT_S1,
    categories = {
      {
        key = "world",
        label = L.TPL_CAT_WORLD,
        items = {
          { labelKey = "TPL_VOID_ASSAULT",   frequency = "weekly", scope = "char" },
          { labelKey = "TPL_RITUAL_SITES",   frequency = "weekly", scope = "char" },
          { labelKey = "TPL_SHOWDOWN",       frequency = "weekly", scope = "char" },
          { labelKey = "TPL_NIGHTMARE_PREY", frequency = "weekly", scope = "char" },
          { labelKey = "TPL_WORLD_EVENT",    frequency = "weekly", scope = "char" },
          { labelKey = "TPL_HOUSING",        frequency = "weekly", scope = "account" },
        },
      },
      {
        key = "pve",
        label = L.TPL_CAT_PVE,
        items = {
          { labelKey = "TPL_RAID_SPOREFALL", frequency = "weekly", scope = "char" },
          { labelKey = "TPL_MYTHIC_PLUS",    frequency = "weekly", scope = "char" },
          { labelKey = "TPL_DELVE",          frequency = "weekly", scope = "char" },
          { labelKey = "TPL_GREAT_VAULT",    frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "rep",
        label = L.TPL_CAT_REP,
        items = {
          { labelKey = "TPL_RENOWN", frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "event",
        label = L.TPL_CAT_EVENT,
        items = {
          { labelKey = "TPL_TIMEWALKING", frequency = "weekly", scope = "char" },
        },
      },
    },
  },
}

SeasonTemplates.defaultSeason = "midnight_s2"

local EMPTY = {}

local function seasonFor(seasonKey)
  seasonKey = seasonKey or SeasonTemplates.defaultSeason
  for _, season in ipairs(SeasonTemplates.seasons) do
    if season.key == seasonKey then return season end
  end
end

function SeasonTemplates.GetSeasons()
  return SeasonTemplates.seasons
end

-- seasonKey optionnel : retombe sur la saison courante.
function SeasonTemplates.GetCategories(seasonKey)
  local season = seasonFor(seasonKey)
  return season and season.categories or EMPTY
end

-- Ensemble des libellés déjà présents, pour éviter d'empiler des doublons à la
-- réimportation (l'utilisateur peut réimporter une catégorie sans risque).
local function existingLabels()
  local seen = {}
  for _, task in ipairs(Tasks.GetAll()) do
    seen[task.label] = true
  end
  return seen
end

-- categoryKeys : table sous forme d'ensemble { world = true, pve = true, ... }.
-- Renvoie le nombre de tâches réellement ajoutées.
function SeasonTemplates.Import(seasonKey, categoryKeys)
  local season = seasonFor(seasonKey)
  if not season or not categoryKeys then return 0 end
  local seen = existingLabels()
  local added = 0
  for _, category in ipairs(season.categories) do
    if categoryKeys[category.key] then
      for _, item in ipairs(category.items) do
        local label = L[item.labelKey]
        if label and not seen[label] then
          Tasks.Add(label, item.frequency, item.scope, season.key)
          seen[label] = true
          added = added + 1
        end
      end
    end
  end
  return added
end

-- Retrait groupé, symétrique de Import. Une tâche n'est retirée que si son libellé
-- correspond à un item des catégories cochées ET qu'elle appartient à cette saison
-- (marqueur templateSeason) ou n'a aucun marqueur — cas des imports faits avant la
-- 1.4.x et des saisies manuelles au libellé identique. Une tâche marquée d'une
-- *autre* saison est préservée : c'est ce qui protège les libellés communs S1/S2.
function SeasonTemplates.Remove(seasonKey, categoryKeys)
  local season = seasonFor(seasonKey)
  if not season or not categoryKeys then return 0 end

  local targets = {}
  for _, category in ipairs(season.categories) do
    if categoryKeys[category.key] then
      for _, item in ipairs(category.items) do
        local label = L[item.labelKey]
        if label then targets[label] = true end
      end
    end
  end

  -- on collecte avant de supprimer : Tasks.Remove fait un table.remove, retirer
  -- pendant l'itération décalerait les index et sauterait des tâches.
  local doomed = {}
  for _, task in ipairs(Tasks.GetAll()) do
    if targets[task.label]
      and (task.templateSeason == season.key or task.templateSeason == nil) then
      doomed[#doomed + 1] = task.id
    end
  end

  for _, id in ipairs(doomed) do
    Tasks.Remove(id)
  end
  return #doomed
end
