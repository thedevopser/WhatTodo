dofile("tests/mock_wow_api.lua")
-- Core/Changelog.lua attend le vararg (ADDON_NAME, WhatTodo) ; on l'injecte
-- via loadfile pour tester le vrai câblage du module.
loadfile("Core/Changelog.lua")("WhatTodo", _G.WhatTodo)

describe("Changelog.ShouldShow", function()
    it("affiche si aucune version vue", function()
        assert.is_true(_G.WhatTodo.Changelog.ShouldShow(nil, "1.1.0"))
    end)

    it("n'affiche pas si version vue = version courante", function()
        assert.is_false(_G.WhatTodo.Changelog.ShouldShow("1.1.0", "1.1.0"))
    end)

    it("affiche si version vue différente", function()
        assert.is_true(_G.WhatTodo.Changelog.ShouldShow("1.0.3", "1.1.0"))
    end)
end)
