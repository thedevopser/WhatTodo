dofile("tests/mock_wow_api.lua")
dofile("Locales/enUS.lua") -- pose le global WhatTodo_L attendu par SeasonTemplates
loadfile("Core/Reset.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/Tasks.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/SeasonTemplates.lua")("WhatTodo", _G.WhatTodo)

local Tasks = _G.WhatTodo.Tasks
local SeasonTemplates = _G.WhatTodo.SeasonTemplates
local L = _G.WhatTodo_L

local function freshDb()
    local db = {
        char = { dbVersion = 1, display = {}, minimap = {} },
        profile = { tasks = {}, nextId = 1 },
        global = { tasks = {}, nextId = 1, dbVersion = 0 },
    }
    Tasks.Init(db)
    return db
end

local function categoryOf(seasonKey, categoryKey)
    for _, category in ipairs(SeasonTemplates.GetCategories(seasonKey)) do
        if category.key == categoryKey then return category end
    end
end

local function labelsOf(seasonKey, categoryKey)
    local out = {}
    for _, item in ipairs(categoryOf(seasonKey, categoryKey).items) do
        out[#out + 1] = L[item.labelKey]
    end
    return out
end

describe("SeasonTemplates — structure des saisons", function()
    it("expose Midnight S2 puis S1, dans cet ordre", function()
        local seasons = SeasonTemplates.GetSeasons()
        assert.equals(2, #seasons)
        assert.equals("midnight_s2", seasons[1].key)
        assert.equals("midnight_s1", seasons[2].key)
    end)

    it("GetCategories sans argument renvoie la saison par défaut", function()
        assert.equals("midnight_s2", SeasonTemplates.defaultSeason)
        assert.same(
            SeasonTemplates.GetCategories("midnight_s2"),
            SeasonTemplates.GetCategories()
        )
    end)

    it("GetCategories sur une saison inconnue renvoie une table vide", function()
        assert.equals(0, #SeasonTemplates.GetCategories("midnight_s99"))
    end)

    it("chaque labelKey déclaré a une entrée de localisation", function()
        for _, season in ipairs(SeasonTemplates.GetSeasons()) do
            for _, category in ipairs(season.categories) do
                assert.is_string(category.label)
                for _, item in ipairs(category.items) do
                    assert.is_string(L[item.labelKey], item.labelKey .. " manquant")
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

    it("la S2 couvre les trois fréquences", function()
        local seen = {}
        for _, category in ipairs(SeasonTemplates.GetCategories("midnight_s2")) do
            for _, item in ipairs(category.items) do
                seen[item.frequency] = true
            end
        end
        assert.is_true(seen.daily)
        assert.is_true(seen.weekly)
        assert.is_true(seen.monthly)
    end)
end)

describe("SeasonTemplates.Import", function()
    it("ajoute les tâches de la catégorie cochée et route selon la portée", function()
        local db = freshDb()
        local category = categoryOf("midnight_s2", "world")
        local added = SeasonTemplates.Import("midnight_s2", { world = true })

        assert.equals(#category.items, added)
        assert.equals(#db.profile.tasks + #db.global.tasks, added)
        -- TPL_HOUSING et TPL_S2_ENDEAVOR sont account-wide
        assert.equals(2, #db.global.tasks)
    end)

    it("marque chaque tâche importée avec sa saison d'origine", function()
        local db = freshDb()
        SeasonTemplates.Import("midnight_s2", { pvp = true })
        for _, task in ipairs(db.profile.tasks) do
            assert.equals("midnight_s2", task.templateSeason)
        end
    end)

    it("ne réimporte pas une catégorie déjà importée", function()
        freshDb()
        SeasonTemplates.Import("midnight_s2", { pve = true })
        assert.equals(0, SeasonTemplates.Import("midnight_s2", { pve = true }))
    end)

    it("ne duplique pas les libellés partagés entre S1 et S2", function()
        local db = freshDb()
        SeasonTemplates.Import("midnight_s1", { pve = true })
        SeasonTemplates.Import("midnight_s2", { pve = true })

        local count = 0
        for _, task in ipairs(db.profile.tasks) do
            if task.label == L.TPL_GREAT_VAULT then count = count + 1 end
        end
        assert.equals(1, count)
    end)

    it("renvoie 0 pour une saison inconnue ou sans sélection", function()
        freshDb()
        assert.equals(0, SeasonTemplates.Import("midnight_s99", { pve = true }))
        assert.equals(0, SeasonTemplates.Import("midnight_s2", {}))
        assert.equals(0, SeasonTemplates.Import("midnight_s2", nil))
    end)
end)

describe("SeasonTemplates.Remove", function()
    it("retire exactement les tâches de la catégorie et de la saison visées", function()
        local db = freshDb()
        SeasonTemplates.Import("midnight_s1", { world = true, rep = true })
        local worldCount = #categoryOf("midnight_s1", "world").items

        assert.equals(worldCount, SeasonTemplates.Remove("midnight_s1", { world = true }))
        assert.equals(1, #db.profile.tasks) -- il reste la tâche de la catégorie rep
        assert.equals(L.TPL_RENOWN, db.profile.tasks[1].label)
        assert.equals(0, #db.global.tasks)
    end)

    it("préserve les libellés communs appartenant à une autre saison", function()
        local db = freshDb()
        SeasonTemplates.Import("midnight_s2", { pve = true })
        SeasonTemplates.Import("midnight_s1", { pve = true })

        SeasonTemplates.Remove("midnight_s1", { pve = true })

        local remaining = {}
        for _, task in ipairs(db.profile.tasks) do
            remaining[task.label] = task.templateSeason
        end
        -- importés sous S2, donc épargnés malgré le libellé partagé
        assert.equals("midnight_s2", remaining[L.TPL_GREAT_VAULT])
        assert.equals("midnight_s2", remaining[L.TPL_MYTHIC_PLUS])
        -- propres à la S1, donc supprimés
        assert.is_nil(remaining[L.TPL_RAID_SPOREFALL])
        assert.is_nil(remaining[L.TPL_DELVE])
    end)

    it("retire aussi les tâches sans marqueur (imports 1.4.0, saisie manuelle)", function()
        local db = freshDb()
        Tasks.Add(L.TPL_RENOWN, "weekly", "char") -- pas de templateSeason
        assert.is_nil(db.profile.tasks[1].templateSeason)

        assert.equals(1, SeasonTemplates.Remove("midnight_s1", { rep = true }))
        assert.equals(0, #db.profile.tasks)
    end)

    it("ne touche pas aux tâches saisies à la main hors template", function()
        local db = freshDb()
        Tasks.Add("Vider la boîte aux lettres", "daily", "char")
        SeasonTemplates.Import("midnight_s2", { craft = true })

        SeasonTemplates.Remove("midnight_s2", { craft = true })
        assert.equals(1, #db.profile.tasks)
        assert.equals("Vider la boîte aux lettres", db.profile.tasks[1].label)
    end)

    it("supprime dans le bon store selon la portée", function()
        local db = freshDb()
        SeasonTemplates.Import("midnight_s2", { event = true })
        assert.equals(1, #db.profile.tasks) -- TPL_TIMEWALKING
        assert.equals(1, #db.global.tasks)  -- TPL_S2_TRADING_POST

        assert.equals(2, SeasonTemplates.Remove("midnight_s2", { event = true }))
        assert.equals(0, #db.profile.tasks)
        assert.equals(0, #db.global.tasks)
    end)

    it("supprime toutes les tâches visées sans en sauter (table.remove)", function()
        local db = freshDb()
        SeasonTemplates.Import("midnight_s2", { world = true, pve = true })
        local expected = #categoryOf("midnight_s2", "pve").items

        assert.equals(expected, SeasonTemplates.Remove("midnight_s2", { pve = true }))
        for _, task in ipairs(db.profile.tasks) do
            for _, label in ipairs(labelsOf("midnight_s2", "pve")) do
                assert.are_not.equals(label, task.label)
            end
        end
    end)

    it("renvoie 0 sur une catégorie non importée, une saison inconnue ou sans sélection", function()
        freshDb()
        assert.equals(0, SeasonTemplates.Remove("midnight_s2", { pvp = true }))
        assert.equals(0, SeasonTemplates.Remove("midnight_s99", { pve = true }))
        assert.equals(0, SeasonTemplates.Remove("midnight_s2", {}))
        assert.equals(0, SeasonTemplates.Remove("midnight_s2", nil))
    end)
end)
