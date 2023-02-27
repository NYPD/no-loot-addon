local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

NoLootSubOptions = {}
NoLootSubOptions.__index = NoLootSubOptions;
function NoLootSubOptions:getInstance(NoLootDB)
  local self = {};
  setmetatable(self, NoLootSubOptions);

  if self._instance then
    return self._instance
  end

  self.db = NoLootDB
  self.options = {
    name = "NoLoot Addon Options",
    handler = self,
    type = "group",
    args = {
      autoOpenGuiCheckbox = {
        type = "toggle",
        name = "Auto Open Item Distribution Window",
        desc = "Whether or not the Item distribution window should open when looting items",
        get = "GetAutoOpenGuiState",
        set = "SetAutoOpenGuiState",
        tristate = false,
        width = "full"
      }
    }
  }
  self._instance = self
  return self._instance
end

-----------------------------  Clear Item On Close -----------------------------
function NoLootSubOptions:GetAutoOpenGuiState()
  return self.db.profile.autoOpenGui
end

function NoLootSubOptions:SetAutoOpenGuiState(info, value)
  if value ~= "" then
    self.db.profile.autoOpenGui = value
  end
end