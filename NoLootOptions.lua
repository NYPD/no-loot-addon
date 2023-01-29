local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

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
      activeLootListInput = {
        type = "select",
        name = "Active Loot List",
        desc = "Choose the loot list to currently have active",
        values = "GetLootListValues",
        get = "GetActiveLootList",
        set = "SetActiveLootList",
        disabled = "DisableActiveLootList",
        style = "dropdown",
        order = 0
      },
      deleteLootListButton = {
        type = "execute",
        name = "Delete",
        desc = "Delete the selected active Loot List",
        func = "DeleteLootList",
        width = 0.5,
        confirm = function() return "Are you sure you want to delete: " .. self.db.profile.activeLootList end,
        order = 1
      },
      addNewListHeader = {
        type = "header",
        name = "Add/Edit Loot List",
        order = 2
      },
      newLootListNameInput = {
        type = "input",
        name = "Loot List Name",
        desc = "Name of the new Loot list",
        get = "GetNewLootListName",
        set = "SetNewLootListName",
        order = 3
      },
      newLootListValueInput = {
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
      saveLootListButton = {
        type = "execute",
        name = function()
          local lootListName = self:GetNewLootListName()
          if lootListName == nil then
            return "Add"
          end

          for key, value in pairs(self.db.profile.lootDistributionList) do
            if key == lootListName then
              return "Edit " .. lootListName
            end
          end

          return "Add " .. lootListName
        end,
        desc = nil,
        hidden = function()
          local lootListName = self:GetNewLootListName()
          if lootListName == nil then
            return true
          end
          
          return false
        end,
        func = "SaveLootList",
        disabled = "CheckSaveLootListDisabled",
        width = nil,
        order = 5
      },
    },
  }

  self._instance = self
  return self._instance
end

-------------------------  Active Loot List DropDown -------------------------
function NoLootOptions:GetLootListValues(info)

  local dropDownValues = {}

  for key, value in pairs(self.db.profile.lootDistributionList) do
    dropDownValues[key] = key
  end

  return dropDownValues
end
function NoLootOptions:GetActiveLootList()
  return self.db.profile.activeLootList
end
function NoLootOptions:SetActiveLootList(key, value)
  if value ~= "" then
    self.newLootListName = ""
    self.db.profile.activeLootList = value
  end
end
function NoLootOptions:DisableActiveLootList()
  if self.db.profile.lootDistributionList == nil then
    return true
  end

  return false
end

---------------------  Delete Active Loot List Button ---------------------
function NoLootOptions:DeleteLootList(info)
  self.db.profile.lootDistributionList[self.db.profile.activeLootList] = nil
  self.db.profile.activeLootList = nil
  self.newLootListName = ""
  self.newLootListValue = ""
end
---------------------  New Loot List Name Input ---------------------
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
---------------------  New Loot List Value Input ---------------------
function NoLootOptions:GetNewLootListValue(info)
  if self.newLootListValue ~= "" then
    return self.newLootListValue
  else

    local lootDistributionList = self.db.profile.lootDistributionList
    local activeLootListValue = lootDistributionList[self.db.profile.activeLootList]

    -- Brand new addon install, check to see if any lists are on there
    if activeLootListValue == nil or next(activeLootListValue) == nil then
      return ""
    else
      local stringifiedJson = JSON.stringify(activeLootListValue)
      return stringifiedJson == "null" and "" or stringifiedJson
    end

  end
end
function NoLootOptions:SetNewLootListValue(info, value)
  self.newLootListValue = value
end
function NoLootOptions:ValidateNewLootListValue(info, value)
  -- Try to parse the json to see if it blows up
  local jsonParse = nil
  try(function()
    jsonParse = JSON.parse(value)
  end, function(e)
    jsonParse = nil
  end)

  if jsonParse == nil then
    return "Invalid JSON"
  else
    return true
  end
end
---------------------  Save Loot List ---------------------
function NoLootOptions:SaveLootList(info)

  local lootListName = self:GetNewLootListName()
  local lootListValue= self:GetNewLootListValue()
  local lootListTable = nil

  if type(lootListValue) == "string" then
    lootListTable = JSON.parse(lootListValue)
  else
    lootListTable = lootListValue
  end

  self.db.profile.lootDistributionList[lootListName] = lootListTable

  if self.db.profile.activeLootList ~= self.newLootListName then
    self.newLootListName = ""
    self.newLootListValue = ""
  end
          
end
function NoLootOptions:CheckSaveLootListDisabled(info, value)

  local lootListName = self:GetNewLootListName()
  local lootListValue = self:GetNewLootListValue()

  if NoLootUtil:isEmpty(lootListName) or NoLootUtil:isEmpty(lootListValue) then
    return true
  end

  return false
end

