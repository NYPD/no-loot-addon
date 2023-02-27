local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local ItemDistribution = LibStub("AceAddon-3.0"):GetAddon("ItemDistribution")

local defaults = {
  profile = {
    lootDistributionList = {},
    lootHistory = {},
    autoOpenGui = true
  },
}

local NoLootConfiguration = LibStub("AceAddon-3.0"):NewAddon("NoLootConfiguration", "AceConsole-3.0", "AceEvent-3.0")

function NoLootConfiguration:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("NoLootDB", defaults, true)

  local NoLootMainOptions = NoLootMainOptions:getInstance(self.db)
  AceConfig:RegisterOptionsTable("NoLoot_options", NoLootMainOptions.options)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions("NoLoot_options", "NoLoot")

  local NoLootSubOptions = NoLootSubOptions:getInstance(self.db)
  AceConfig:RegisterOptionsTable("NoLoot_Addon_Options", NoLootSubOptions.options)
  AceConfigDialog:AddToBlizOptions("NoLoot_Addon_Options", "Addon Options", "NoLoot")

  local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  AceConfig:RegisterOptionsTable("NoLoot_Profiles", profiles)
  AceConfigDialog:AddToBlizOptions("NoLoot_Profiles", "Profiles", "NoLoot")

  self:RegisterChatCommand("noloot", "SlashCommand")
  self:RegisterChatCommand("cum", "SlashCommand")
  self:RegisterChatCommand("debug", "debug")

  -- Run any cleanup or update requirements needed here for future version updates
  local shouldRunConfigUpdate = self.db.profile.versionUpdate ~= NoLootVersion
  if shouldRunConfigUpdate then
    self.db.profile.clearItemOnCloseState = nil
    self.db.profile.versionUpdate = NoLootVersion
  end

end

function NoLootConfiguration:debug(arg)
  for _, playerName in ipairs(ItemDistribution.itemsToDistribute) do
    print(playerName)
  end
end
function NoLootConfiguration:SlashCommand(arg)

  if NoLootUtil:isEmpty(arg) then
    -- https://github.com/Stanzilla/WoWUIBugs/issues/89
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    return
  end

  local isTrigger = arg == "trigger" or arg == "trig" or arg == "t"
  local isClear = arg == "clear"
  local isShowHistory = arg == "history" or arg == "h"
  local isHistoryPurge = arg == "purge"

  if isTrigger then
    ItemDistribution:manualProcess(nil)
  elseif isClear then
    ItemDistribution:clearTempVariables()
  elseif isHistoryPurge then
    self.db.profile.lootHistory = {}
  elseif isShowHistory then
    local historyService = HistoryService:getInstance(self.db)
    historyService:showHistoryWindow()
  else

    local itemId = tonumber(arg)
    local itemLink = NoLootUtil:isItemLink(arg) and arg or nil

    if itemId ~= nil then
      local item = Item:CreateFromItemID(itemId)
      item:ContinueOnItemLoad(function()
                                  ItemDistribution:manualProcess(item:GetItemLink())
                              end)
    elseif itemLink ~= nil then
      ItemDistribution:manualProcess(itemLink)
    else
      ItemDistribution:manualProcess(arg)
    end

  end
end