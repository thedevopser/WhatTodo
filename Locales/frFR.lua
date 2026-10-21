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
L.SEASON_TEMPLATES  = "Templates de tâches"
L.SEASON_IMPORT     = "Importer la sélection"
L.SEASON_IMPORTED   = "%d tâche(s) importée(s)"
L.SEASON_REMOVE     = "Retirer la sélection"
L.SEASON_REMOVE_CONFIRM = "Retirer les tâches des catégories sélectionnées ? Cette action est irréversible."
L.SEASON_REMOVED    = "%d tâche(s) retirée(s)"

-- Templates proposés par le sélecteur
L.TPL_SEASON        = "Template"
L.TPL_SEASON_ESSENTIALS = "Essentiels"

L.TPL_CAT_PVE       = "Donjons & Raid"
L.TPL_CAT_WORLD     = "Monde"

-- Essentiels : activités stables d'un patch à l'autre
L.TPL_GREAT_VAULT   = "Grand Coffre"
L.TPL_MYTHIC_PLUS   = "Mythique+ (meilleures clés)"
L.TPL_BOUNTIFUL_DELVE = "Gouffres abondants (clés)"
L.TPL_WORLD_EVENT   = "Quête hebdo d'événement mondial"
L.TPL_HOUSING       = "Quête hebdo de logement"
L.TPL_TRADING_POST  = "Comptoir"

-- Midnight 12.1.5. « L'invasion des Aqir » et « Vénithe ascendante » viennent du
-- client FR ; les autres noms propres restent à confirmer en jeu.
L.TPL_SEASON_MIDNIGHT_12_1_5 = "Midnight 12.1.5"
L.TPL_CAT_AQIR      = "L'invasion des Aqir"
L.TPL_CAT_LABYRINTH = "Labyrinthe de Kindo'jan"
L.TPL_CAT_RAID      = "Raid"
L.TPL_CAT_ORIN      = "Recherches d'Orin"
L.TPL_1215_AQIR_BOSS       = "L'invasion des Aqir : 1er boss Monstruosité (sacoche)"
L.TPL_1215_AQIR_REPUTATION = "L'invasion des Aqir (réputation Enclave)"
L.TPL_1215_WAHDU           = "Quête de Wah'du (salle désignée, T8+)"
L.TPL_1215_LABYRINTH       = "Labyrinthe de Kindo'jan : 9 salles + Kindo'jan"
L.TPL_1215_RAID_KITHIX     = "Raid : la Libération de Kith'ix"
L.TPL_1215_VOIDCORE        = "Noyau du Vide nébuleux (Orin)"
L.TPL_1215_VENOMSTONES     = "Vénithe ascendante (10 par amélioration)"

-- Titre de section : libellé, tâches faites, total
L.SECTION_PROGRESS  = "%s %d/%d"

-- Compteurs de reset
L.RESET_IN_DAYS     = "reset dans %dj %dh"
L.RESET_IN_HOURS    = "reset dans %dh %02dmin"

-- Infobulle du bouton minimap
L.TOOLTIP_COUNT     = "%s : %d"
L.TOOLTIP_LEFT      = "Clic gauche : afficher/masquer"
L.TOOLTIP_RIGHT     = "Clic droit : configurer"

-- Options (Échap > Options > AddOns)
L.OPT_LOCKED        = "Verrouiller la position de la fenêtre"
L.OPT_LOCKED_DESC   = "Empêche de déplacer la fenêtre de liste."
L.OPT_SCALE         = "Échelle"
L.OPT_SCALE_DESC    = "Taille de la fenêtre de liste."
L.OPT_BACKGROUND_ALPHA = "Opacité du fond"
L.OPT_BACKGROUND_ALPHA_DESC = "Opacité du fond et du bord de la fenêtre de liste. Le texte reste entièrement opaque."
L.OPT_COMPLETED_STYLE = "Tâches faites"
L.OPT_COMPLETED_STYLE_DESC = "Apparence dans la liste des tâches déjà faites pour la période en cours."
L.OPT_COMPLETED_SHOW = "Afficher normalement"
L.OPT_COMPLETED_DIM = "Griser et barrer"
L.OPT_COMPLETED_HIDE = "Masquer"
L.OPT_HIDE_IN_COMBAT = "Masquer en combat"
L.OPT_HIDE_IN_COMBAT_DESC = "Masque la liste pendant les combats et la réaffiche ensuite."
L.OPT_THEME         = "Thème"
L.OPT_THEME_DESC    = "Apparence de la fenêtre de liste."
L.THEME_PARCHMENT   = "Parchemin"
L.THEME_PARCHMENT_DARK = "Parchemin sombre"
L.THEME_DARK        = "Sombre minimaliste"
L.THEME_BLIZZARD    = "Blizzard"
L.THEME_TRANSPARENT = "Transparent"

-- Popup de nouveautés
L.CHANGELOG_TITLE   = "WhatTodo — Nouveautés (1.6.0)"
L.CHANGELOG_BODY    = "La liste se règle désormais à votre goût. Ouvrez les options avec /wt options (ou Échap > Options > AddOns) pour choisir parmi cinq thèmes, griser ou masquer les tâches faites, régler l'échelle et l'opacité du fond, verrouiller la fenêtre ou la masquer en combat.\n\nChaque en-tête de section affiche votre avancement (3/7) et se replie d'un clic. Dans le panneau de gestion, les flèches à côté de chaque tâche changent son ordre."
L.CHANGELOG_CLOSE   = "Compris"
