dofile("tests/mock_wow_api.lua")
dofile("Locales/enUS.lua") -- la migration des templates réaligne les libellés sur la locale
-- Core/Migrations.lua attend le vararg (ADDON_NAME, WhatTodo) ; on l'injecte via loadfile.
loadfile("Core/Migrations.lua")("WhatTodo", _G.WhatTodo)

local Migrations = _G.WhatTodo.Migrations
local L = _G.WhatTodo_L

-- Fabrique une db neuve telle qu'AceDB la présenterait après application des defaults.
local function freshDb()
    return {
        char = { dbVersion = 0, display = {}, minimap = {} },
        profile = { tasks = {}, nextId = 1 },
        global = { tasks = {}, nextId = 1, dbVersion = 0, lastSeenVersion = nil },
    }
end

-- Fabrique une db « legacy » : ancien schéma (tâches dans db.char, pas de
-- dbVersion) mais avec les nouveaux defaults AceDB déjà appliqués au chargement.
local function legacyDb()
    return {
        char = {
            tasks = { { id = "t1", label = "Old", frequency = "daily", order = 1 } },
            nextId = 5,
            display = { shown = true },
            minimap = { hide = false },
        },
        profile = { tasks = {}, nextId = 1 },
        global = { tasks = {}, nextId = 1, lastSeenVersion = "1.2.0" },
    }
end

describe("Migrations.Run — fresh install", function()
    it("ne casse rien et porte les versions au dernier niveau", function()
        local db = freshDb()
        Migrations.Run(db)
        assert.equals(Migrations.LatestCharVersion(), db.char.dbVersion)
        assert.equals(Migrations.LatestGlobalVersion(), db.global.dbVersion)
        assert.same({}, db.profile.tasks)
    end)
end)

describe("Migrations.Run — montée depuis l'ancien schéma (legacy)", function()
    it("déplace db.char.tasks vers db.profile.tasks", function()
        local db = legacyDb()
        Migrations.Run(db)
        assert.equals(1, #db.profile.tasks)
        assert.equals("Old", db.profile.tasks[1].label)
        assert.equals(5, db.profile.nextId)
    end)

    it("vide l'ancien emplacement db.char", function()
        local db = legacyDb()
        Migrations.Run(db)
        assert.is_nil(db.char.tasks)
        assert.is_nil(db.char.nextId)
    end)

    it("préserve display/minimap dans db.char", function()
        local db = legacyDb()
        Migrations.Run(db)
        assert.is_true(db.char.display.shown)
        assert.is_false(db.char.minimap.hide)
    end)

    it("initialise le stockage account-wide", function()
        local db = legacyDb()
        Migrations.Run(db)
        assert.same({}, db.global.tasks)
        assert.equals(1, db.global.nextId)
    end)
end)

describe("Migrations.Run — idempotence", function()
    it("rejouer ne modifie pas les données", function()
        local db = legacyDb()
        Migrations.Run(db)
        local snapshot = db.profile.tasks[1].label
        Migrations.Run(db)
        assert.equals(1, #db.profile.tasks)
        assert.equals(snapshot, db.profile.tasks[1].label)
    end)
end)

describe("Migrations.Run — char et global indépendants", function()
    it("un perso déjà à jour côté global migre quand même ses données char", function()
        -- global déjà migré par un autre perso, mais ce perso a encore l'ancien schéma
        local db = legacyDb()
        db.global.dbVersion = Migrations.LatestGlobalVersion()
        db.global.tasks = {}
        db.global.nextId = 1
        Migrations.Run(db)
        assert.equals(1, #db.profile.tasks)
        assert.equals(Migrations.LatestCharVersion(), db.char.dbVersion)
    end)
end)

describe("Migrations.Run — retrait des templates Midnight S1 et S2", function()
    -- db au niveau 1.6.0 : schéma déjà migré, versions char 1 et global 0
    local function db160(profileTasks, globalTasks)
        return {
            char = { dbVersion = 1, display = {}, minimap = {} },
            profile = { tasks = profileTasks or {}, nextId = 50 },
            global = { tasks = globalTasks or {}, nextId = 50, dbVersion = 0 },
        }
    end

    local function task(id, label, templateSeason, extra)
        local t = { id = id, label = label, frequency = "weekly", templateSeason = templateSeason, order = 1 }
        for k, v in pairs(extra or {}) do t[k] = v end
        return t
    end

    local function labels(tasks)
        local out = {}
        for i, t in ipairs(tasks) do out[i] = t.label end
        return out
    end

    it("supprime une tâche S2 qui n'existe plus dans les templates", function()
        local db = db160({ task("t1", "The Venomous Abyss raid", "midnight_s2") })
        Migrations.Run(db)
        assert.same({}, db.profile.tasks)
    end)

    it("garde une tâche reprise par les Essentiels, avec son état et son ordre", function()
        local db = db160({
            task("t1", "Great Vault", "midnight_s2", { lastCompleted = 1234, order = 7 }),
        })
        Migrations.Run(db)
        local kept = db.profile.tasks[1]
        assert.equals(L.TPL_GREAT_VAULT, kept.label)
        assert.equals("essentials", kept.templateSeason)
        assert.equals(1234, kept.lastCompleted)
        assert.equals(7, kept.order)
    end)

    it("réaligne le libellé d'une tâche reprise dont le libellé a changé", function()
        local db = db160({}, { task("a1", "Trading Post / Traveler's Log", "midnight_s2") })
        Migrations.Run(db)
        assert.same({ L.TPL_TRADING_POST }, labels(db.global.tasks))
        assert.equals("essentials", db.global.tasks[1].templateSeason)
    end)

    it("reconnaît un libellé importé sous le client français", function()
        local db = db160({
            task("t1", "Grand Coffre", "midnight_s2"),
            task("t2", "Raid de l'Abîme Venimeux", "midnight_s2"),
        })
        Migrations.Run(db)
        assert.same({ L.TPL_GREAT_VAULT }, labels(db.profile.tasks))
    end)

    it("traite une tâche S1 sans marqueur (import 1.4.0) comme une tâche de template", function()
        local db = db160({
            task("t1", "Sporefall raid (Rotmire)", nil),
            task("t2", "Mythic+ (best keys)", nil),
        })
        Migrations.Run(db)
        assert.same({ L.TPL_MYTHIC_PLUS }, labels(db.profile.tasks))
        assert.equals("essentials", db.profile.tasks[1].templateSeason)
    end)

    it("ne touche pas à une saisie manuelle au libellé inconnu", function()
        local manual = task("t1", "Vider la boîte aux lettres", nil)
        local db = db160({ manual })
        Migrations.Run(db)
        assert.same({ manual }, db.profile.tasks)
    end)

    it("ne touche pas à une saisie manuelle qui reprend un libellé propre à la S2", function()
        local db = db160({ task("t1", "Crafting orders", nil) })
        Migrations.Run(db)
        assert.same({ "Crafting orders" }, labels(db.profile.tasks))
        assert.is_nil(db.profile.tasks[1].templateSeason)
    end)

    it("garde comme saisie manuelle une tâche S2 dont le joueur a changé le libellé", function()
        local db = db160({ task("t1", "Mon raid du mardi", "midnight_s2") })
        Migrations.Run(db)
        assert.same({ "Mon raid du mardi" }, labels(db.profile.tasks))
        assert.is_nil(db.profile.tasks[1].templateSeason)
    end)

    it("ne touche pas aux tâches des templates en production", function()
        local current = task("t1", L.TPL_1215_LABYRINTH or "Labyrinth", "midnight_12_1_5")
        local db = db160({ current })
        Migrations.Run(db)
        assert.same({ current }, db.profile.tasks)
    end)

    it("ne garde qu'une tâche quand deux imports donnent le même libellé", function()
        local db = db160({
            task("t1", "Great Vault", "midnight_s1"),
            task("t2", "Grand Coffre", "midnight_s2"),
        })
        Migrations.Run(db)
        assert.same({ L.TPL_GREAT_VAULT }, labels(db.profile.tasks))
        assert.equals("t1", db.profile.tasks[1].id)
    end)

    it("nettoie les tâches de compte par le step global", function()
        local db = db160({}, {
            task("a1", "Housing weekly quest", "midnight_s2"),
            task("a2", "Housing Endeavor", "midnight_s2"),
        })
        Migrations.Run(db)
        assert.same({ L.TPL_HOUSING }, labels(db.global.tasks))
    end)

    it("le step global ne rejoue pas pour un perso arrivé après", function()
        local db = db160({}, { task("a1", "Housing Endeavor", "midnight_s2") })
        db.global.dbVersion = Migrations.LatestGlobalVersion()
        Migrations.Run(db)
        assert.equals(1, #db.global.tasks)
    end)

    it("rejouer la migration ne change plus rien", function()
        local db = db160({
            task("t1", "Great Vault", "midnight_s2"),
            task("t2", "Vider la boîte aux lettres", nil),
        })
        Migrations.Run(db)
        local before = labels(db.profile.tasks)
        Migrations.Run(db)
        assert.same(before, labels(db.profile.tasks))
    end)
end)
