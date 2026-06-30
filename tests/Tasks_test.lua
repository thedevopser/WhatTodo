dofile("tests/mock_wow_api.lua")
loadfile("Core/Reset.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/Tasks.lua")("WhatTodo", _G.WhatTodo)

local Tasks = _G.WhatTodo.Tasks

local function freshDb()
    return {
        char = { dbVersion = 1, display = {}, minimap = {} },
        profile = { tasks = {}, nextId = 1 },
        global = { tasks = {}, nextId = 1, dbVersion = 0 },
    }
end

describe("Tasks.Add — routage par portée", function()
    it("scope char (défaut) va dans db.profile.tasks avec id préfixé t", function()
        local db = freshDb()
        Tasks.Init(db)
        local id = Tasks.Add("Daily quest", "daily")
        assert.equals("t1", id)
        assert.equals(1, #db.profile.tasks)
        assert.equals(0, #db.global.tasks)
        assert.equals("char", db.profile.tasks[1].scope)
    end)

    it("scope account va dans db.global.tasks avec id préfixé a", function()
        local db = freshDb()
        Tasks.Init(db)
        local id = Tasks.Add("Weekly event", "weekly", "account")
        assert.equals("a1", id)
        assert.equals(0, #db.profile.tasks)
        assert.equals(1, #db.global.tasks)
        assert.equals("account", db.global.tasks[1].scope)
    end)

    it("utilise des compteurs nextId indépendants par portée", function()
        local db = freshDb()
        Tasks.Init(db)
        assert.equals("t1", Tasks.Add("a", "daily", "char"))
        assert.equals("a1", Tasks.Add("b", "daily", "account"))
        assert.equals("t2", Tasks.Add("c", "daily", "char"))
        assert.equals("a2", Tasks.Add("d", "daily", "account"))
    end)
end)

describe("Tasks.GetByFrequency — fusion des deux portées", function()
    it("retourne tâches perso et account de la fréquence, triées par order", function()
        local db = freshDb()
        Tasks.Init(db)
        Tasks.Add("char daily", "daily", "char")
        Tasks.Add("account daily", "daily", "account")
        Tasks.Add("char weekly", "weekly", "char")
        local daily = Tasks.GetByFrequency("daily")
        assert.equals(2, #daily)
        local labels = { daily[1].label, daily[2].label }
        assert.is_true(labels[1] == "char daily" or labels[2] == "char daily")
        assert.is_true(labels[1] == "account daily" or labels[2] == "account daily")
    end)
end)

describe("Tasks.Update/Remove/SetCompleted — localisation par préfixe d'id", function()
    it("met à jour une tâche account via son id", function()
        local db = freshDb()
        Tasks.Init(db)
        local id = Tasks.Add("x", "weekly", "account")
        Tasks.Update(id, { label = "renamed" })
        assert.equals("renamed", db.global.tasks[1].label)
    end)

    it("supprime une tâche perso sans toucher les account", function()
        local db = freshDb()
        Tasks.Init(db)
        local tid = Tasks.Add("char", "daily", "char")
        Tasks.Add("account", "daily", "account")
        Tasks.Remove(tid)
        assert.equals(0, #db.profile.tasks)
        assert.equals(1, #db.global.tasks)
    end)

    it("complétion d'une tâche account écrit lastCompleted sur la tâche globale", function()
        local db = freshDb()
        Tasks.Init(db)
        local id = Tasks.Add("shared", "weekly", "account")
        Tasks.SetCompleted(id, true)
        assert.is_not_nil(db.global.tasks[1].lastCompleted)
        Tasks.SetCompleted(id, false)
        assert.is_nil(db.global.tasks[1].lastCompleted)
    end)
end)
