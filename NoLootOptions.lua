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
  self.options = {
    name = "NoLoot " .. NoLootVersion,
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
        order = 0,
        width = 1.5
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
      addLootListInput = {
        type = "input",
        name = "Add New Loot List",
        desc = "Name of the new Loot list",
        set = "AddNewLootList",
        validate = "NotEmptyString",
        order = 2,
        width = 1.5
      },
      addNewListHeader = {
        type = "header",
        name = "Edit Loot List",
        order = 3
      },
      editLootListNameInput = {
        type = "input",
        name = "Loot List Name",
        desc = "Edit the loot list name",
        get = "GetEditLootListName",
        set = "SetEditLootListName",
        validate = "NotEmptyString",
        order = 4
      },
      newLootListValueInput = {
        type = "input",
        name = "Loot List JSON",
        desc = "Enter JSON here",
        multiline = 20,
        get = "GetLootListJSON",
        set = "SetLootListJSON",
        validate = "ValidateNewLootListValue",
        width = "full",
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
end
--------------------------  Add New Loot List Button --------------------------
function NoLootOptions:AddNewLootList(info, value)
  self.db.profile.lootDistributionList[value] = {}
end
--------------------------  Edit Loot List Name Input --------------------------
function NoLootOptions:GetEditLootListName(info)
    return self.db.profile.activeLootList
end
function NoLootOptions:SetEditLootListName(info, value)

  local activeLootList = self.db.profile.activeLootList
  local oldLootListTable = self.db.profile.lootDistributionList[activeLootList]

  --Delete the old loot list
  self.db.profile.lootDistributionList[activeLootList] = nil
  -- Copy over the old table to the new name
  self.db.profile.lootDistributionList[value] = oldLootListTable
  -- Set the activeList to the new name
  self.db.profile.activeLootList = value
end
---------------------  New Loot List Value Input ---------------------
function NoLootOptions:GetLootListJSON(info)

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
function NoLootOptions:SetLootListJSON(info, value)

  local activeLootList = self.db.profile.activeLootList
  local lootListTable = JSON.parse(value)

  self.db.profile.lootDistributionList[activeLootList] = lootListTable
end

---------------------------------  Validators ---------------------------------
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

function NoLootOptions:NotEmptyString(info, value)
  if value == "" or value == nil then
    return "Name must not be blank"
  end

  return true
end
