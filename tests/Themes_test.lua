dofile("tests/mock_wow_api.lua")
dofile("Locales/enUS.lua")
loadfile("Core/Themes.lua")("WhatTodo", _G.WhatTodo)
loadfile("Core/DisplaySettings.lua")("WhatTodo", _G.WhatTodo)

local Themes = _G.WhatTodo.Themes
local DisplaySettings = _G.WhatTodo.DisplaySettings
local enUS = _G.WhatTodo_L

local function loadFrenchOnly()
    local savedL, savedGetLocale = _G.WhatTodo_L, _G.GetLocale
    _G.WhatTodo_L = {}
    _G.GetLocale = function() return "frFR" end
    dofile("Locales/frFR.lua")
    local frFR = _G.WhatTodo_L
    _G.WhatTodo_L, _G.GetLocale = savedL, savedGetLocale
    return frFR
end

local COLOR_FIELDS = { "titleColor", "headerColor", "textColor", "mutedColor", "countdownColor" }

describe("Themes — catalogue", function()
    it("propose les cinq thèmes, parchemin en premier", function()
        local keys = {}
        for i, theme in ipairs(Themes.list) do keys[i] = theme.key end
        assert.same({ "parchment", "parchment_dark", "dark", "blizzard", "transparent" }, keys)
    end)

    it("chaque thème déclare toutes ses couleurs en RVB", function()
        for _, theme in ipairs(Themes.list) do
            for _, field in ipairs(COLOR_FIELDS) do
                local color = theme[field]
                assert.is_table(color, theme.key .. "." .. field)
                assert.is_number(color[1])
                assert.is_number(color[2])
                assert.is_number(color[3])
            end
            assert.is_boolean(theme.textShadow, theme.key .. ".textShadow")
        end
    end)

    it("chaque libellé de thème existe en anglais et en français", function()
        local frFR = loadFrenchOnly()
        for _, theme in ipairs(Themes.list) do
            assert.is_string(enUS[theme.labelKey], "enUS " .. theme.labelKey)
            assert.is_string(frFR[theme.labelKey], "frFR " .. theme.labelKey)
        end
    end)
end)

describe("Themes.Get", function()
    it("renvoie le thème demandé", function()
        assert.equals("dark", Themes.Get("dark").key)
    end)

    it("retombe sur le parchemin pour une clé inconnue", function()
        assert.equals("parchment", Themes.Get("neon").key)
        assert.equals("parchment", Themes.Get(nil).key)
    end)
end)

describe("DisplaySettings.Normalize — thème", function()
    it("conserve un thème connu", function()
        assert.equals("transparent", DisplaySettings.Normalize({ theme = "transparent" }).theme)
    end)

    it("remplace un thème inconnu ou absent par le parchemin", function()
        assert.equals("parchment", DisplaySettings.Normalize({ theme = "neon" }).theme)
        assert.equals("parchment", DisplaySettings.Normalize({}).theme)
    end)
end)

describe("Themes — bords", function()
    it("chaque bord déclare sa texture, sa taille et le retrait du fond", function()
        for _, theme in ipairs(Themes.list) do
            if theme.border then
                assert.is_string(theme.border.edgeFile, theme.key)
                assert.is_number(theme.border.edgeSize, theme.key)
                assert.is_number(theme.border.inset, theme.key)
            end
        end
    end)
end)
