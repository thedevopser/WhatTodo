local ADDON_NAME, WhatTodo = ...
local Changelog = {}
WhatTodo.Changelog = Changelog

function Changelog.ShouldShow(seenVersion, currentVersion)
  return seenVersion ~= currentVersion
end
