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
  self.scrollingTable = nil
  self.historyFrame = nil
  self._instance = self
  return self._instance
end

function HistoryService:showHistoryWindow()

  if self.historyFrame == nil then
    local historyFrame = AceGUI:Create("Frame")
    historyFrame:SetTitle("NoLoot Distrubution History")
    historyFrame:SetLayout("Fill")
    historyFrame:EnableResize(false)
    --historyFrame.frame:SetHeight(470);
    --historyFrame.frame:SetWidth(580);
    self.historyFrame = historyFrame
  end

  local cols = {
    { name= "Date", width = 140, defaultsort = "dsc"},
    { name = "Item",  width = 300, defaultsort = "dsc" },
    { name = "Player", width = 100, defaultsort = "dsc" }
  }

  if self.historyFrame.scrollingTable == nil then
    local scrollingTable = ScrollingTable:CreateST(cols, 15, 15, nil, self.historyFrame.frame)
    scrollingTable.frame:SetPoint("BOTTOMLEFT", self.historyFrame.frame, 15, 45)
    scrollingTable.frame:SetPoint("TOP", self.historyFrame.frame, 0, -60)
    scrollingTable.frame:SetPoint("RIGHT", self.historyFrame.frame, -27, 0)
    self.historyFrame.scrollingTable = scrollingTable
  end
  self.historyFrame.scrollingTable:Show()

  local data = {}
  for _, lootHistoryEntry in ipairs(self.db.profile.lootHistory) do
    table.insert(data, { lootHistoryEntry["date"], lootHistoryEntry["item"], lootHistoryEntry["player"] })
  end

  self.historyFrame.scrollingTable:SetData(data, true);
  self.historyFrame:SetCallback("OnClose", function(widget)
    --AceGUI:Release(widget)
    self.historyFrame.scrollingTable:Hide()
  end)
end