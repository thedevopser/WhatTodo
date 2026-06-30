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

-- Compteurs de reset
L.RESET_IN_DAYS     = "reset dans %dj %dh"
L.RESET_IN_HOURS    = "reset dans %dh %02dmin"

-- Infobulle du bouton minimap
L.TOOLTIP_COUNT     = "%s : %d"
L.TOOLTIP_LEFT      = "Clic gauche : afficher/masquer"
L.TOOLTIP_RIGHT     = "Clic droit : configurer"

-- Popup de nouveautés
L.CHANGELOG_TITLE   = "WhatTodo — Nouveautés (1.3.0)"
L.CHANGELOG_BODY    = "Nouveau : une tâche peut désormais être « Compte » (partagée entre tous tes personnages) ou par personnage. Choisis la portée au moment de l'ajouter.\n\nNouveau : une section « Profils » dans la config permet de copier ta liste de tâches depuis un autre personnage.\n\nBon à savoir : chaque personnage conserve maintenant sa propre liste. Tes tâches existantes sont migrées automatiquement — rien n'est perdu."
L.CHANGELOG_CLOSE   = "Compris"
