dofile("tests/mock_wow_api.lua")
dofile("Locales/enUS.lua") -- pose le global WhatTodo_L attendu par SeasonTemplates
loadfile("Core/Reset.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/Themes.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/DisplaySettings.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/Tasks.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/SeasonTemplates.lua")("WhatTodo", _G.WhatTodo)

local Tasks = _G.WhatTodo.Tasks
local SeasonTemplates = _G.WhatTodo.SeasonTemplates
local L = _G.WhatTodo_L

local function loadFrenchOnly()
    local savedL, savedGetLocale = _G.WhatTodo_L, _G.GetLocale
    _G.WhatTodo_L = {}
    _G.GetLocale = function() return "frFR" end
    dofile("Locales/frFR.lua")
    local frFR = _G.WhatTodo_L
    _G.WhatTodo_L, _G.GetLocale = savedL, savedGetLocale
    return frFR
end

local function freshDb()
    local db = {
        char = { dbVersion = 1, display = {}, minimap = {} },
        profile = { tasks = {}, nextId = 1 },
        global = { tasks = {}, nextId = 1, dbVersion = 0 },
    }
    Tasks.Init(db)
    return db
end

local function seasonByKey(seasonKey)
    for _, season in ipairs(SeasonTemplates.GetSeasons()) do
        if season.key == seasonKey then return season end
    end
end

local function categoryOf(seasonKey, categoryKey)
    for _, category in ipairs(SeasonTemplates.GetCategories(seasonKey)) do
        if category.key == categoryKey then return category end
    end
end

local function itemsOf(seasonKey)
    local out = {}
    for _, category in ipairs(SeasonTemplates.GetCategories(seasonKey)) do
        for _, item in ipairs(category.items) do out[#out + 1] = item end
    end
    return out
end

-- Saison factice qui partage le libellé du Grand Coffre avec les Essentiels :
-- sert à vérifier la déduplication et la protection inter-saisons sans
-- dépendre du contenu d'un patch donné.
local TEST_SEASON = {
    key = "test_season",
    label = "Test season",
    categories = {
        {
            key = "pve",
            label = "Test PvE",
            items = {
                { labelKey = "TPL_GREAT_VAULT", frequency = "weekly", scope = "char" },
                { labelKey = "TEST_ONLY_ITEM",  frequency = "daily",  scope = "char" },
            },
        },
    },
}

local function withTestSeason()
    L.TEST_ONLY_ITEM = "Test-only item"
    table.insert(SeasonTemplates.seasons, TEST_SEASON)
end

local function withoutTestSeason()
    L.TEST_ONLY_ITEM = nil
    for i, season in ipairs(SeasonTemplates.seasons) do
        if season == TEST_SEASON then table.remove(SeasonTemplates.seasons, i) end
    end
end

describe("SeasonTemplates — structure des saisons", function()
    it("ne propose plus les saisons Midnight S1 et S2", function()
        assert.is_nil(seasonByKey("midnight_s1"))
        assert.is_nil(seasonByKey("midnight_s2"))
    end)

    it("propose le template Essentiels", function()
        assert.is_table(seasonByKey("essentials"))
    end)

    it("la saison par défaut existe et GetCategories sans argument la renvoie", function()
        assert.is_table(seasonByKey(SeasonTemplates.defaultSeason))
        assert.same(
            SeasonTemplates.GetCategories(SeasonTemplates.defaultSeason),
            SeasonTemplates.GetCategories()
        )
    end)

    it("GetCategories sur une saison inconnue renvoie une table vide", function()
        assert.equals(0, #SeasonTemplates.GetCategories("midnight_s99"))
    end)

    it("chaque libellé existe en anglais et en français", function()
        local frFR = loadFrenchOnly()
        for _, season in ipairs(SeasonTemplates.GetSeasons()) do
            assert.is_string(season.label, season.key)
            for _, category in ipairs(season.categories) do
                assert.is_string(category.label, category.key)
                for _, item in ipairs(category.items) do
                    assert.is_string(L[item.labelKey], "enUS " .. item.labelKey)
                    assert.is_string(frFR[item.labelKey], "frFR " .. item.labelKey)
                end
            end
        end
    end)

    it("n'utilise que des fréquences et des portées valides", function()
        local freqs = { daily = true, weekly = true, monthly = true }
        local scopes = { char = true, account = true }
        for _, season in ipairs(SeasonTemplates.GetSeasons()) do
            for _, category in ipairs(season.categories) do
                for _, item in ipairs(category.items) do
                    assert.is_true(freqs[item.frequency], item.labelKey)
                    assert.is_true(scopes[item.scope], item.labelKey)
                end
            end
        end
    end)

    it("aucun libellé n'apparaît deux fois dans une même saison", function()
        for _, season in ipairs(SeasonTemplates.GetSeasons()) do
            local seen = {}
            for _, item in ipairs(itemsOf(season.key)) do
                assert.is_nil(seen[item.labelKey], season.key .. " " .. item.labelKey)
                seen[item.labelKey] = true
            end
        end
    end)
end)

describe("SeasonTemplates — contenu des Essentiels", function()
    local function contentOf(categoryKey)
        local out = {}
        for _, item in ipairs(categoryOf("essentials", categoryKey).items) do
            out[#out + 1] = { item.labelKey, item.frequency, item.scope }
        end
        return out
    end

    it("Donjons & Raid : Grand Coffre, Mythique+ et Gouffres abondants", function()
        assert.same({
            { "TPL_GREAT_VAULT",     "weekly", "char" },
            { "TPL_MYTHIC_PLUS",     "weekly", "char" },
            { "TPL_BOUNTIFUL_DELVE", "weekly", "char" },
        }, contentOf("pve"))
    end)

    it("Monde : événement mondial, logement et Comptoir", function()
        assert.same({
            { "TPL_WORLD_EVENT",  "weekly",  "char" },
            { "TPL_HOUSING",      "weekly",  "account" },
            { "TPL_TRADING_POST", "monthly", "account" },
        }, contentOf("world"))
    end)

    it("ne contient que ces deux catégories", function()
        assert.equals(2, #SeasonTemplates.GetCategories("essentials"))
    end)
end)

describe("SeasonTemplates.Import", function()
    after_each(withoutTestSeason)

    it("ajoute les tâches de la catégorie cochée et route selon la portée", function()
        local db = freshDb()
        local added = SeasonTemplates.Import("essentials", { world = true })

        assert.equals(3, added)
        assert.equals(1, #db.profile.tasks)
        assert.equals(2, #db.global.tasks)
    end)

    it("marque chaque tâche importée avec sa saison d'origine", function()
        local db = freshDb()
        SeasonTemplates.Import("essentials", { pve = true, world = true })
        for _, task in ipairs(Tasks.GetAll()) do
            assert.equals("essentials", task.templateSeason)
        end
        assert.is_true(#db.profile.tasks > 0)
    end)

    it("ne réimporte pas une catégorie déjà importée", function()
        freshDb()
        SeasonTemplates.Import("essentials", { pve = true })
        assert.equals(0, SeasonTemplates.Import("essentials", { pve = true }))
    end)

    it("ne duplique pas un libellé déjà importé par une autre saison", function()
        local db = freshDb()
        withTestSeason()
        SeasonTemplates.Import("test_season", { pve = true })
        SeasonTemplates.Import("essentials", { pve = true })

        local count = 0
        for _, task in ipairs(db.profile.tasks) do
            if task.label == L.TPL_GREAT_VAULT then count = count + 1 end
        end
        assert.equals(1, count)
    end)

    it("renvoie 0 pour une saison inconnue ou sans sélection", function()
        freshDb()
        assert.equals(0, SeasonTemplates.Import("midnight_s99", { pve = true }))
        assert.equals(0, SeasonTemplates.Import("essentials", {}))
        assert.equals(0, SeasonTemplates.Import("essentials", nil))
    end)
end)

describe("SeasonTemplates.Remove", function()
    after_each(withoutTestSeason)

    it("retire exactement les tâches de la catégorie visée", function()
        local db = freshDb()
        SeasonTemplates.Import("essentials", { pve = true, world = true })

        assert.equals(3, SeasonTemplates.Remove("essentials", { pve = true }))
        assert.equals(1, #db.profile.tasks) -- il reste l'événement mondial
        assert.equals(L.TPL_WORLD_EVENT, db.profile.tasks[1].label)
        assert.equals(2, #db.global.tasks)
    end)

    it("préserve un libellé commun appartenant à une autre saison", function()
        local db = freshDb()
        withTestSeason()
        SeasonTemplates.Import("test_season", { pve = true })
        SeasonTemplates.Import("essentials", { pve = true })

        SeasonTemplates.Remove("essentials", { pve = true })

        local remaining = {}
        for _, task in ipairs(db.profile.tasks) do
            remaining[task.label] = task.templateSeason
        end
        assert.equals("test_season", remaining[L.TPL_GREAT_VAULT])
        assert.equals("test_season", remaining[L.TEST_ONLY_ITEM])
        assert.is_nil(remaining[L.TPL_MYTHIC_PLUS])
        assert.is_nil(remaining[L.TPL_BOUNTIFUL_DELVE])
    end)

    it("retire aussi les tâches sans marqueur au libellé identique", function()
        local db = freshDb()
        Tasks.Add(L.TPL_GREAT_VAULT, "weekly", "char")
        assert.is_nil(db.profile.tasks[1].templateSeason)

        assert.equals(1, SeasonTemplates.Remove("essentials", { pve = true }))
        assert.equals(0, #db.profile.tasks)
    end)

    it("ne touche pas aux tâches saisies à la main hors template", function()
        local db = freshDb()
        Tasks.Add("Vider la boîte aux lettres", "daily", "char")
        SeasonTemplates.Import("essentials", { pve = true })

        SeasonTemplates.Remove("essentials", { pve = true })
        assert.equals(1, #db.profile.tasks)
        assert.equals("Vider la boîte aux lettres", db.profile.tasks[1].label)
    end)

    it("supprime dans le bon store selon la portée", function()
        local db = freshDb()
        SeasonTemplates.Import("essentials", { world = true })

        assert.equals(3, SeasonTemplates.Remove("essentials", { world = true }))
        assert.equals(0, #db.profile.tasks)
        assert.equals(0, #db.global.tasks)
    end)

    it("renvoie 0 sur une catégorie non importée, une saison inconnue ou sans sélection", function()
        freshDb()
        assert.equals(0, SeasonTemplates.Remove("essentials", { pve = true }))
        assert.equals(0, SeasonTemplates.Remove("midnight_s99", { pve = true }))
        assert.equals(0, SeasonTemplates.Remove("essentials", {}))
        assert.equals(0, SeasonTemplates.Remove("essentials", nil))
    end)
end)
