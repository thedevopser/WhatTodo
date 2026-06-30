local ADDON_NAME, WhatTodo = ...
local AdminPanel = {}
WhatTodo.AdminPanel = AdminPanel

local AceGUI = LibStub("AceGUI-3.0")
local Tasks = WhatTodo.Tasks
local L = WhatTodo_L

local FREQ_LABELS = {
  daily = L.FREQ_DAILY,
  weekly = L.FREQ_WEEKLY,
  monthly = L.FREQ_MONTHLY,
}
local FREQ_ORDER = { "daily", "weekly", "monthly" }

local SCOPE_LABELS = {
  char = L.SCOPE_CHAR,
  account = L.SCOPE_ACCOUNT,
}
local SCOPE_ORDER = { "char", "account" }

local frame -- fenêtre AceGUI
local list  -- ScrollFrame contenant les tâches existantes
local newFreq = "daily"
local newScope = "char"

-- on diffère la reconstruction : éviter de libérer un widget pendant son propre callback
local function scheduleRefresh()
  C_Timer.After(0, function() AdminPanel.Refresh() end)
end

local function buildRow(task)
  local id = task.id
  local row = AceGUI:Create("SimpleGroup")
  row:SetFullWidth(true)
  row:SetLayout("Flow")

  local nameBox = AceGUI:Create("EditBox")
  nameBox:SetText(task.label)
  nameBox:SetWidth(190)
  nameBox:SetCallback("OnEnterPressed", function(_, _, value)
    value = strtrim(value)
    if value ~= "" then
      Tasks.Update(id, { label = value })
      scheduleRefresh()
    end
  end)
  row:AddChild(nameBox)

  local freqDD = AceGUI:Create("Dropdown")
  freqDD:SetList(FREQ_LABELS, FREQ_ORDER)
  freqDD:SetValue(task.frequency)
  freqDD:SetWidth(130)
  freqDD:SetCallback("OnValueChanged", function(_, _, value)
    Tasks.Update(id, { frequency = value })
    scheduleRefresh()
  end)
  row:AddChild(freqDD)

  -- badge de portée : les tâches account-wide sont partagées entre persos
  local badge = AceGUI:Create("Label")
  if task.scope == "account" then
    badge:SetText("|cff66bbff[" .. L.SCOPE_ACCOUNT_TAG .. "]|r")
  else
    badge:SetText("")
  end
  badge:SetWidth(70)
  row:AddChild(badge)

  local del = AceGUI:Create("Button")
  del:SetText(L.DELETE)
  del:SetWidth(90)
  del:SetCallback("OnClick", function()
    Tasks.Remove(id)
    scheduleRefresh()
  end)
  row:AddChild(del)

  return row
end

local function refreshList()
  if not list then return end
  list:ReleaseChildren()
  for _, freq in ipairs(FREQ_ORDER) do
    local tasks = Tasks.GetByFrequency(freq)
    if #tasks > 0 then
      local heading = AceGUI:Create("Heading")
      heading:SetText(FREQ_LABELS[freq])
      heading:SetFullWidth(true)
      list:AddChild(heading)
      for _, task in ipairs(tasks) do
        list:AddChild(buildRow(task))
      end
    end
  end
end

function AdminPanel.Open()
  if frame then
    frame:Show()
    refreshList()
    return
  end

  frame = AceGUI:Create("Frame")
  frame:SetTitle(L.ADMIN_TITLE)
  frame:SetStatusText(L.ADMIN_STATUS)
  frame:SetLayout("Flow")
  frame:SetWidth(460)
  frame:SetHeight(520)
  frame:SetCallback("OnClose", function(widget)
    AceGUI:Release(widget)
    frame = nil
    list = nil
  end)

  -- ligne d'ajout
  local freqDropdown = AceGUI:Create("Dropdown")
  freqDropdown:SetLabel(L.FREQUENCY)
  freqDropdown:SetList(FREQ_LABELS, FREQ_ORDER)
  freqDropdown:SetValue(newFreq)
  freqDropdown:SetWidth(150)
  freqDropdown:SetCallback("OnValueChanged", function(_, _, value) newFreq = value end)
  frame:AddChild(freqDropdown)

  local scopeDropdown = AceGUI:Create("Dropdown")
  scopeDropdown:SetLabel(L.SCOPE)
  scopeDropdown:SetList(SCOPE_LABELS, SCOPE_ORDER)
  scopeDropdown:SetValue(newScope)
  scopeDropdown:SetWidth(150)
  scopeDropdown:SetCallback("OnValueChanged", function(_, _, value) newScope = value end)
  frame:AddChild(scopeDropdown)

  local labelBox = AceGUI:Create("EditBox")
  labelBox:SetLabel(L.LABEL)
  labelBox:SetWidth(200)
  labelBox:DisableButton(true) -- pas de coche : on a notre bouton Ajouter
  frame:AddChild(labelBox)

  local addBtn = AceGUI:Create("Button")
  addBtn:SetText(L.ADD)
  addBtn:SetWidth(90)
  local function doAdd()
    local text = strtrim(labelBox:GetText() or "")
    if text ~= "" then
      Tasks.Add(text, newFreq, newScope)
      labelBox:SetText("")
      labelBox:ClearFocus()
      scheduleRefresh()
    end
  end
  addBtn:SetCallback("OnClick", doAdd)
  -- confort : Entrée dans le champ ajoute aussi
  labelBox:SetCallback("OnEnterPressed", doAdd)
  frame:AddChild(addBtn)

  -- section profils : copier la liste perso d'un autre personnage vers le courant
  local profilesHeading = AceGUI:Create("Heading")
  profilesHeading:SetText(L.PROFILES)
  profilesHeading:SetFullWidth(true)
  frame:AddChild(profilesHeading)

  local selectedProfile
  local profileDD = AceGUI:Create("Dropdown")
  profileDD:SetLabel(L.PROFILE_COPY_FROM)
  profileDD:SetWidth(200)
  -- autres profils que le courant (chaque perso connu = un profil copiable)
  local current = WhatTodo.db:GetCurrentProfile()
  local choices, order = {}, {}
  for _, name in ipairs(WhatTodo.db:GetProfiles()) do
    if name ~= current then
      choices[name] = name
      order[#order + 1] = name
    end
  end
  table.sort(order)
  profileDD:SetList(choices, order)
  profileDD:SetCallback("OnValueChanged", function(_, _, value) selectedProfile = value end)
  frame:AddChild(profileDD)

  local copyBtn = AceGUI:Create("Button")
  copyBtn:SetText(L.PROFILE_COPY)
  copyBtn:SetWidth(90)
  copyBtn:SetCallback("OnClick", function()
    if selectedProfile then
      WhatTodo.db:CopyProfile(selectedProfile)
      print(L.PROFILE_COPIED:format(selectedProfile))
      scheduleRefresh()
    end
  end)
  frame:AddChild(copyBtn)

  local heading = AceGUI:Create("Heading")
  heading:SetText(L.EXISTING_TASKS)
  heading:SetFullWidth(true)
  frame:AddChild(heading)

  -- conteneur scrollable qui occupe la hauteur restante
  local scrollContainer = AceGUI:Create("SimpleGroup")
  scrollContainer:SetFullWidth(true)
  scrollContainer:SetFullHeight(true)
  scrollContainer:SetLayout("Fill")
  frame:AddChild(scrollContainer)

  list = AceGUI:Create("ScrollFrame")
  list:SetLayout("List")
  scrollContainer:AddChild(list)

  refreshList()
end

function AdminPanel.Refresh()
  refreshList()
  if WhatTodo.Display then WhatTodo.Display.Refresh() end
end

function AdminPanel.Setup()
  -- rien à enregistrer : la fenêtre est créée à la demande via Open()
end
