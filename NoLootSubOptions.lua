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
      activeLootListInput = {
        type = "toggle",
        name = "Clear Item On Close",
        desc = "Whether closing the current item to distribute window clear that item or not",
        get = "GetClearItemOnCloseState",
        set = "SetClearItemOnCloseState",
        tristate = false
      }
    }
  }
  self._instance = self
  return self._instance
end

-----------------------------  Clear Item On Close -----------------------------
function NoLootSubOptions:GetClearItemOnCloseState()
  return self.db.profile.clearItemOnCloseState
end

function NoLootSubOptions:SetClearItemOnCloseState(info, value)
  if value ~= "" then
    self.db.profile.clearItemOnCloseState = value
  end
end