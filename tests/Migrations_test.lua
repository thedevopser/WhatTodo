dofile("tests/mock_wow_api.lua")
-- Core/Migrations.lua attend le vararg (ADDON_NAME, WhatTodo) ; on l'injecte via loadfile.
loadfile("Core/Migrations.lua")("WhatTodo", _G.WhatTodo)

local Migrations = _G.WhatTodo.Migrations

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
