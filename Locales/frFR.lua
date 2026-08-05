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
L.SEASON_REMOVE     = "Retirer la sélection"
L.SEASON_REMOVE_CONFIRM = "Retirer les tâches des catégories sélectionnées ? Cette action est irréversible."
L.SEASON_REMOVED    = "%d tâche(s) retirée(s)"

-- Saisons proposées par le sélecteur
L.TPL_SEASON        = "Saison"
L.TPL_SEASON_MIDNIGHT_S1 = "Midnight S1"
L.TPL_SEASON_MIDNIGHT_S2 = "Midnight S2 — La malédiction d'Ula'tek"

L.TPL_CAT_WORLD     = "Monde — Saison"
L.TPL_CAT_PVE       = "Donjons & Raid"
L.TPL_CAT_PVP       = "JcJ"
L.TPL_CAT_REP       = "Réputation"
L.TPL_CAT_CRAFT     = "Métiers"
L.TPL_CAT_EVENT     = "Événements temporaires"

-- Midnight S1 (12.0.7)
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

-- Midnight S2 (12.1.0 — La malédiction d'Ula'tek).
-- Noms propres repris du client FR ; ceux sans traduction officielle connue
-- restent en anglais (Vaults of Atal'Utek, Housing Endeavor).
L.TPL_S2_CURSE_SURGE    = "Résurgences maudites & rares (Île Annelée)"
L.TPL_S2_CURSED_FISHING = "Pêche maudite (cap. Tokka)"
L.TPL_S2_RALKALA        = "Bonus quotidien de Ral'kala"
L.TPL_S2_VAULTS_ATALUTEK = "Événement public : Vaults of Atal'Utek"
L.TPL_S2_SPECIAL_ASSIGNMENT = "Assignation spéciale (Île Annelée)"
L.TPL_S2_PREY_HUNTS     = "Chasses de la Traque (cap 15/sem.)"
L.TPL_S2_ENDEAVOR       = "Housing Endeavor"
L.TPL_S2_MYTHIC_ZERO    = "Mythique 0 (reset quotidien)"
L.TPL_S2_RAID_VENOMOUS_ABYSS = "Raid de l'Abîme Venimeux"
L.TPL_S2_LAIR_TIDEBOUND = "Repaire de la Grotte des Marées"
L.TPL_S2_VOIDCORE       = "Relance Noyau du Vide nébuleux"
L.TPL_S2_DELVE_T8       = "Gouffre T8+ (ligne Monde du Coffre)"
L.TPL_S2_BOUNTIFUL_DELVE = "Gouffres abondants (clés)"
L.TPL_S2_CRESTS         = "Cap hebdo d'écus (100/type)"
L.TPL_S2_CONQUEST       = "Objectif Conquête hebdo"
L.TPL_S2_RATED          = "Mêlée cotée / Blitz coté"
L.TPL_S2_RENOWN_ZULJARRA = "Renom Forces de Zul'jarra"
L.TPL_S2_CORROSIVE_SOULS = "Âmes corrosives (Autel de la corrosion)"
L.TPL_S2_DELVERS_JOURNEY = "Périple des Gouffres"
L.TPL_S2_PREYHUNTER_JOURNEY = "Périple de la Traque"
L.TPL_S2_TREATISE       = "Traité de métier"
L.TPL_S2_CRAFT_ORDERS   = "Commandes de craft"
L.TPL_S2_TRADING_POST   = "Comptoir d'échange / Journal du voyageur"

-- Compteurs de reset
L.RESET_IN_DAYS     = "reset dans %dj %dh"
L.RESET_IN_HOURS    = "reset dans %dh %02dmin"

-- Infobulle du bouton minimap
L.TOOLTIP_COUNT     = "%s : %d"
L.TOOLTIP_LEFT      = "Clic gauche : afficher/masquer"
L.TOOLTIP_RIGHT     = "Clic droit : configurer"

-- Popup de nouveautés
L.CHANGELOG_TITLE   = "WhatTodo — Nouveautés (1.5.0)"
L.CHANGELOG_BODY    = "La saison 2 de Midnight est là. La section « Templates de saison » a désormais un sélecteur de Saison : choisis Midnight S2 (La malédiction d'Ula'tek) ou reviens à la S1, puis coche les catégories à importer. Deux nouvelles catégories : JcJ et Métiers.\n\nAussi nouveau : « Retirer la sélection » supprime d'un coup les tâches importées pour la saison et les catégories choisies — pratique pour faire le ménage de la saison 1. Les tâches que tu as saisies toi-même ne sont jamais touchées."
L.CHANGELOG_CLOSE   = "Compris"
