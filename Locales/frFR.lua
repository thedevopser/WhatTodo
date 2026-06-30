if GetLocale() ~= "frFR" then return end

local L = WhatTodo_L

-- Fréquences (singulier, sélecteur du panel)
L.FREQ_DAILY        = "Quotidienne"
L.FREQ_WEEKLY       = "Hebdomadaire"
L.FREQ_MONTHLY      = "Mensuelle"

-- Fréquences (titres de section de l'affichage + infobulle)
L.SECTION_DAILY     = "Quotidiennes"
L.SECTION_WEEKLY    = "Hebdomadaires"
L.SECTION_MONTHLY   = "Mensuelles"

-- Panel de gestion
L.ADMIN_TITLE       = "WhatTodo — Gestion des tâches"
L.ADMIN_STATUS      = "Choisis une fréquence, saisis un libellé puis clique sur Ajouter"
L.FREQUENCY         = "Fréquence"
L.LABEL             = "Libellé"
L.ADD               = "Ajouter"
L.EXISTING_TASKS    = "Tâches existantes"
L.DELETE            = "Supprimer"

-- Portée des tâches (perso vs compte)
L.SCOPE             = "Portée"
L.SCOPE_CHAR        = "Personnage"
L.SCOPE_ACCOUNT     = "Compte"
L.SCOPE_ACCOUNT_TAG = "compte"

-- Profils (copie de liste entre personnages)
L.PROFILES          = "Profils"
L.PROFILE_COPY_FROM = "Copier la liste depuis"
L.PROFILE_COPY      = "Copier"
L.PROFILE_COPIED    = "Liste copiée depuis %s"

-- Templates de saison (import prérempli)
L.SEASON_TEMPLATES  = "Templates de saison"
L.SEASON_IMPORT     = "Importer la sélection"
L.SEASON_IMPORTED   = "%d tâche(s) importée(s)"

L.TPL_CAT_WORLD     = "Monde — Saison"
L.TPL_CAT_PVE       = "Donjons & Raid"
L.TPL_CAT_REP       = "Réputation"
L.TPL_CAT_EVENT     = "Événements temporaires"

L.TPL_VOID_ASSAULT  = "Assaut du Vide (hebdo)"
L.TPL_RITUAL_SITES  = "Sites rituels"
L.TPL_SHOWDOWN      = "Zones d'affrontement (Naigtal / Val)"
L.TPL_NIGHTMARE_PREY = "3 chasses « Proie de cauchemar »"
L.TPL_WORLD_EVENT   = "Quête hebdo d'événement mondial"
L.TPL_HOUSING       = "Quête hebdo de logement"
L.TPL_RAID_SPOREFALL = "Raid Sporefall (Rotmire)"
L.TPL_MYTHIC_PLUS   = "Mythique+ (meilleures clés)"
L.TPL_DELVE         = "Au moins une Faille T11"
L.TPL_GREAT_VAULT   = "Grand Coffre"
L.TPL_RENOWN        = "Activités de Renommée hebdo"
L.TPL_TIMEWALKING   = "Quête hebdo Marche du temps"

-- Compteurs de reset
L.RESET_IN_DAYS     = "reset dans %dj %dh"
L.RESET_IN_HOURS    = "reset dans %dh %02dmin"

-- Infobulle du bouton minimap
L.TOOLTIP_COUNT     = "%s : %d"
L.TOOLTIP_LEFT      = "Clic gauche : afficher/masquer"
L.TOOLTIP_RIGHT     = "Clic droit : configurer"

-- Popup de nouveautés
L.CHANGELOG_TITLE   = "WhatTodo — Nouveautés (1.4.0)"
L.CHANGELOG_BODY    = "Nouveau : une section « Templates de saison » dans la config permet d'importer des listes de tâches préremplies pour la saison en cours, groupées par catégorie (Monde, Donjons & Raid, Réputation, Événements). Coche les catégories voulues puis clique sur Importer.\n\nBon à savoir : survole une catégorie pour prévisualiser les tâches ajoutées, et une réimportation ne crée jamais de doublon."
L.CHANGELOG_CLOSE   = "Compris"
