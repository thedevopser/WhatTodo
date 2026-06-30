local ADDON_NAME, WhatTodo = ...
local SeasonTemplates = {}
WhatTodo.SeasonTemplates = SeasonTemplates

local Tasks = WhatTodo.Tasks
local L = WhatTodo_L

-- Contenu de la saison courante (Midnight S1, 12.0.7). Les libellés passent par des
-- clés L.TPL_* pour rester corrigeables en jeu sans toucher à la logique. Chaque item :
-- { labelKey, frequency, scope }. Catégories ordonnées pour un affichage stable.
SeasonTemplates.categories = {
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
}

function SeasonTemplates.GetCategories()
  return SeasonTemplates.categories
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
function SeasonTemplates.Import(categoryKeys)
  local seen = existingLabels()
  local added = 0
  for _, category in ipairs(SeasonTemplates.categories) do
    if categoryKeys[category.key] then
      for _, item in ipairs(category.items) do
        local label = L[item.labelKey]
        if label and not seen[label] then
          Tasks.Add(label, item.frequency, item.scope)
          seen[label] = true
          added = added + 1
        end
      end
    end
  end
  return added
end
