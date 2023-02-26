local AceGUI = LibStub("AceGUI-3.0")
local ScrollingTable = LibStub("ScrollingTable");

HistoryService = {}
HistoryService.__index = HistoryService;
function HistoryService:getInstance(NoLootDB)
  local self = {};
  setmetatable(self, HistoryService);

  if self._instance then
    return self._instance
  end

  self.db = NoLootDB
  self._instance = self
  return self._instance
end

function HistoryService:showHistoryWindow()

  local historyFrame = AceGUI:Create("Frame")
  historyFrame:SetTitle("NoLoot Distrubution History")
  historyFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
  historyFrame:SetLayout("Fill")
  historyFrame:EnableResize(false)
  --historyFrame.frame:SetHeight(470);
  --historyFrame.frame:SetWidth(580);

  local cols = {
    { name= "Date", width = 140, defaultsort = "dsc"},
    { name= "Item", width = 300},
    { name= "Player", width = 100}
  }

  local scrollingTable = ScrollingTable:CreateST(cols, 15, 15, nil, historyFrame.frame)
  scrollingTable.frame:SetPoint("BOTTOMLEFT", historyFrame.frame, 15, 45)
  scrollingTable.frame:SetPoint("TOP", historyFrame.frame, 0, -60)
  scrollingTable.frame:SetPoint("RIGHT", historyFrame.frame, -27, 0)

  local data = {}
  for _, lootHistoryEntry in ipairs(self.db.profile.lootHistory) do
    table.insert(data, { lootHistoryEntry["date"], lootHistoryEntry["item"], lootHistoryEntry["player"] })
  end

  scrollingTable:SetData(data, true);
end