local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local defaults = {
  profile = {
    lootDistributionList = nil,
  },
}

local NoLootConfiguration = LibStub("AceAddon-3.0"):NewAddon("NoLootConfiguration", "AceConsole-3.0", "AceEvent-3.0")

function NoLootConfiguration:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("NoLootDB", defaults, true)

  local NoLootOptions = NoLootOptions:getInstance(self.db)
  AceConfig:RegisterOptionsTable("NoLoot_options", NoLootOptions.options)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions("NoLoot_options", "NoLoot")

  local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  AceConfig:RegisterOptionsTable("NoLoot_Profiles", profiles)
  AceConfigDialog:AddToBlizOptions("NoLoot_Profiles", "Profiles", "NoLoot")

  self:RegisterChatCommand("noloot", "SlashCommand")
  self:RegisterChatCommand("cum", "SlashCommand")
end
function NoLootConfiguration:SlashCommand()
  -- https://github.com/Stanzilla/WoWUIBugs/issues/89
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
  InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

