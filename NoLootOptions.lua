local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local JSON = LibStub("JSON")

NoLootOptions = {}
NoLootOptions.__index = NoLootOptions;
function NoLootOptions:getInstance(NoLootDB)

  local self = {};
  setmetatable(self, NoLootOptions);

  if self._instance then
    return self._instance
  end

  self.db = NoLootDB
  self.newLootListName = "";
  self.newLootListValue = "";
  self.options = {
    name = "NoLoot",
    handler = self,
    type = "group",
    args = {
      activeLootList = {
        type = "select",
        name = "Active Loot List",
        desc = "Choose the loot list to currently have active",
        values = "GetLootListValues",
        get = "GetActiveLootList",
        set = "ActivateLootList",
        style = "dropdown",
        disabled = "CheckForNoLootList",
        order = 0
      },
      deleteLootList = {
        type = "execute",
        name = "Delete",
        desc = "Delete the selected active Loot List",
        func = "DeleteLootList",
        width = 0.5,
        confirm = function() return "Are you sure you want to delete: " .. self.db.profile.activeLootList end,
        --disabled = "CheckForNoLootList",
        order = 1
      },
      addNewListHeader = {
        type = "header",
        name = "Add/Edit Loot List",
        order = 2
      },
      newLootListName = {
        type = "input",
        name = "Loot List Name",
        desc = "Name of the new Loot list",
        get = "GetNewLootListName",
        set = "SetNewLootListName",
        order = 3
      },
      newLootListValue = {
        type = "input",
        name = "Loot List JSON",
        desc = "Enter JSON here",
        multiline = 20,
        get = "GetNewLootListValue",
        set = "SetNewLootListValue",
        validate = "ValidateNewLootListValue",
        width = "full",
        order = 4
      },
    },
  }

  self._instance = self
  return self._instance
end

-- Loot list values on top
function NoLootOptions:GetLootListValues(info)

  local dropDownValues = {}

  for key, value in pairs(self.db.profile.lootDistributionList) do
    dropDownValues[key] = key
  end

  return dropDownValues
end

function NoLootOptions:DeleteLootList(info)
  self.db.profile.lootDistributionList[self.db.profile.activeLootList] = nil
  self.db.profile.activeLootList = nil
end

function NoLootOptions:GetActiveLootList()
  return self.db.profile.activeLootList
end

function NoLootOptions:CheckForNoLootList()
  if self.db.profile.lootDistributionList == nil then
    return true
  end

  return false
end

function NoLootOptions:ActivateLootList(key, value)
  if value ~= "" then
    self.newLootListName = ""
    self.db.profile.activeLootList = value
  end
end

-- creating or editing loot list
function NoLootOptions:GetNewLootListName(info)
  if self.newLootListName ~= "" then
    return self.newLootListName
  else
    return self.db.profile.activeLootList
  end
end

function NoLootOptions:SetNewLootListName(info, value)
  self.newLootListName = value
end

function NoLootOptions:GetNewLootListValue(info)
  return self.db.profile.lootDistributionList[self.db.profile.activeLootList]
end

function NoLootOptions:ValidateNewLootListValue(info, value)
  -- Try to parse the json to see if it blows up
  local jsonParse = nil
  try(function()
    jsonParse = JSON:parse(value)
  end, function(e)
    jsonParse = nil
  end)

  if jsonParse == nil then
    return "Invalid JSON"
  else
    return true
  end
end

function NoLootOptions:SetNewLootListValue(info, value)

  local key = nil
  local parsedJson = JSON:parse(value)

  if self.newLootListName ~= "" then
    key = self.newLootListName
  else
    key = self.db.profile.activeLootList
  end

  print("saving with key: " .. key)
  self.db.profile.lootDistributionList[key] = value

  self.newLootListName = ""
  self.newLootListValue = ""

  --AceConfigRegistry:NotifyChange("NoLoot_options")
end
