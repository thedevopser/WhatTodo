-- Stubs WoW API globaux pour busted
_G.WhatTodo   = {}
_G.print      = function() end
_G.GetLocale  = function() return "enUS" end
_G.date       = os.date
_G.strtrim    = function(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end
_G.GetServerTime = function() return os.time() end
_G.GetCurrentRegion = function() return 3 end
