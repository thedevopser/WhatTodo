local _, WhatTodo = ...
local SeasonTemplates = {}
WhatTodo.SeasonTemplates = SeasonTemplates

local Tasks = WhatTodo.Tasks
local L = WhatTodo_L

-- Contenu prérempli, une entrée par template. Les libellés passent par des clés
-- L.TPL_* pour rester corrigeables en jeu sans toucher à la logique. Chaque item :
-- { labelKey, frequency, scope }. Templates, catégories et items sont ordonnés
-- pour un affichage stable : le template de patch vient en premier, les
-- Essentiels (activités stables d'un patch à l'autre) ensuite.
SeasonTemplates.seasons = {
  {
    key = "midnight_12_1_5",
    label = L.TPL_SEASON_MIDNIGHT_12_1_5,
    categories = {
      {
        key = "aqir",
        label = L.TPL_CAT_AQIR,
        items = {
          { labelKey = "TPL_1215_AQIR_BOSS",       frequency = "weekly", scope = "char" },
          { labelKey = "TPL_1215_AQIR_REPUTATION", frequency = "daily",  scope = "char" },
        },
      },
      {
        key = "labyrinth",
        label = L.TPL_CAT_LABYRINTH,
        items = {
          { labelKey = "TPL_1215_WAHDU",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_1215_LABYRINTH", frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "raid",
        label = L.TPL_CAT_RAID,
        items = {
          { labelKey = "TPL_1215_RAID_KITHIX", frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "orin",
        label = L.TPL_CAT_ORIN,
        items = {
          { labelKey = "TPL_1215_VOIDCORE",    frequency = "weekly", scope = "char" },
          { labelKey = "TPL_1215_VENOMSTONES", frequency = "weekly", scope = "char" },
        },
      },
    },
  },
  {
    key = "essentials",
    label = L.TPL_SEASON_ESSENTIALS,
    categories = {
      {
        key = "pve",
        label = L.TPL_CAT_PVE,
        items = {
          { labelKey = "TPL_GREAT_VAULT",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_MYTHIC_PLUS",     frequency = "weekly", scope = "char" },
          { labelKey = "TPL_BOUNTIFUL_DELVE", frequency = "weekly", scope = "char" },
        },
      },
      {
        key = "world",
        label = L.TPL_CAT_WORLD,
        items = {
          { labelKey = "TPL_WORLD_EVENT",  frequency = "weekly",  scope = "char" },
          { labelKey = "TPL_HOUSING",      frequency = "weekly",  scope = "account" },
          { labelKey = "TPL_TRADING_POST", frequency = "monthly", scope = "account" },
        },
      },
    },
  },
}

SeasonTemplates.defaultSeason = "midnight_12_1_5"

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
-- *autre* saison est préservée : c'est ce qui protège les libellés communs à
-- plusieurs templates.
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
