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

-- Compteurs de reset
L.RESET_IN_DAYS     = "reset dans %dj %dh"
L.RESET_IN_HOURS    = "reset dans %dh %02dmin"

-- Infobulle du bouton minimap
L.TOOLTIP_COUNT     = "%s : %d"
L.TOOLTIP_LEFT      = "Clic gauche : afficher/masquer"
L.TOOLTIP_RIGHT     = "Clic droit : configurer"

-- Popup de nouveautés
L.CHANGELOG_TITLE   = "WhatTodo — Nouveautés"
L.CHANGELOG_BODY    = "Les tâches hebdomadaires se réinitialisent désormais le bon jour selon votre région : mardi sur les royaumes US, mercredi sur EU, jeudi sur KR/TW/CN."
L.CHANGELOG_CLOSE   = "Compris"
