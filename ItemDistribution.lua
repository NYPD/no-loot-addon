local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local NoLootConfiguration = LibStub("AceAddon-3.0"):GetAddon("NoLootConfiguration")

local ItemDistribution = LibStub("AceAddon-3.0"):NewAddon("ItemDistribution", "AceConsole-3.0", "AceEvent-3.0")

-- local frame = AceGUI:Create("Frame")
-- frame:SetTitle("Example Frame")
-- frame:SetStatusText("AceGUI-3.0 Example Container Frame")

function ItemDistribution:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("NoLootDB")
  self.activeLootList = self.db.profile.activeLootList
  self.lootDistributionList = self.db.profile.lootDistributionList[self.activeLootList]
end

function ItemDistribution:OnEnable()
  -- Do more initialization here, that really enables the use of your addon.
  -- Register Events, Hook functions, Create Frames, Get information from
  -- the game that wasn't available in OnInitialize
  self:RegisterEvent("ITEM_PUSH")
  self:RegisterEvent("CHAT_MSG_LOOT")

end

function ItemDistribution:ITEM_PUSH(eventName, bagSlot, iconFileID)
  -- print(eventName)
  -- print(bagSlot)
  -- print(iconFileID)
end

function ItemDistribution:CHAT_MSG_LOOT(eventName, text, playerName)
  local lootName = string.match(text, '%[(.*)%]')

  if self.lootDistributionList[lootName] then
    local priorityLevel = 1 -- get the actual priorityLevel
    self:openItemChooser(lootName, priorityLevel)
  end

end

function ItemDistribution:updateActiveLootList(activeLootList)
  self.activeLootList = activeLootList
end

function ItemDistribution:openItemChooser(lootName, priorityLevel)
  -- local frame = AceGUI:Create("Frame")
  -- frame:SetTitle("No Loot")
  -- frame:SetStatusText("Wool Cloth [Priority 1]")
  -- frame:SetWidth(200)
  -- frame:SetHeight(50)
  -- frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
  -- frame:SetResizable(false)

  local framePoint = self.db.profile.framePoint;
  local frameRelativeTo = self.db.profile.frameRelativeTo;
  local frameRelativePoint = self.db.profile.frameRelativePoint;
  local frameOffsetX = self.db.profile.frameOffsetX;
  local frameOffsetY = self.db.profile.frameOffsetY;

  local mainFrame = CreateFrame("Frame", "LootDistribution", UIParent, "BackdropTemplate")

  if(framePoint == nil) then
    mainFrame:SetPoint("TOPLEFT")
  else
    mainFrame:SetPoint(framePoint, frameRelativeTo, frameRelativePoint, frameOffsetX, frameOffsetY)
  end

  mainFrame:SetSize(180, 100)
  mainFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  mainFrame:SetBackdropColor(0, 0, 0, .69)
  mainFrame:EnableMouse(true)
  mainFrame:SetMovable(true)
  mainFrame:RegisterForDrag("LeftButton")
  mainFrame:SetScript("OnMouseDown", function(self, button)
    self:StartMoving()
  end)
  mainFrame:SetScript("OnMouseUp", function(self, motion)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
    ItemDistribution.db.profile.framePoint = point;
    ItemDistribution.db.profile.frameRelativeTo = relativeTo;
    ItemDistribution.db.profile.frameRelativePoint = relativePoint;
    ItemDistribution.db.profile.frameOffsetX = offsetX;
    ItemDistribution.db.profile.frameOffsetY = offsetY;
  end)

  -- Loot Name
  local title = mainFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
  title:SetPoint("TOPLEFT", 7, -10)
  title:SetText(lootName .. " [Priority: " .. priorityLevel .. "]")

  -- Close button
  local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
  closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0 , 0)
  closeButton:SetScript("OnClick", function()
    mainFrame:Hide()
  end)

  -- Item Icon
  local _, lootNameItemLink = GetItemInfo(lootName)
  local bag, slot = GetBagPosition(lootNameItemLink)
  local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
  local itemID = C_Item.GetItemID(itemLocation)
  local fileDataID = C_Item.GetItemIcon(itemLocation)
 

  local itemIcon = CreateFrame("Frame", nil, mainFrame)
  itemIcon:SetPoint("CENTER", -55, -5)
  itemIcon:SetSize(50, 50)
  itemIcon.tex = itemIcon:CreateTexture()
  itemIcon.tex:SetAllPoints(itemIcon)
  itemIcon.tex:SetTexture(fileDataID)
  itemIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(mainFrame, "ANCHOR_TOP")
    GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0")
    GameTooltip:Show()
  end)
  itemIcon:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)


  -- local playerButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
  -- playerButton:SetPoint("TOP", mainFrame, 25 -25)
  -- playerButton:SetSize(100, 20)
  -- playerButton:SetText("Nyfdasdflpks")
  -- playerButton:SetScript("OnClick", function(self, button)
  --   print("You clicked me with " .. button)
  -- end)

  local playerButton2 = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
  playerButton2:SetPoint("TOP", mainFrame, 25, -25)
  playerButton2:SetSize(100, 20)
  playerButton2:SetText("Danage")
  playerButton2:SetScript("OnClick", function(self, button)
    print("You clicked me with " .. button)
  end)
end

--Left and rigjt lines
-- local left = mainFrame:CreateTexture(nil, "BACKGROUND")
-- left:SetHeight(8)
-- left:SetPoint("LEFT", 3, 0)
-- left:SetPoint("RIGHT", label, "LEFT", -5, 0)
-- left:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
-- left:SetTexCoord(0.81, 0.94, 0.5, 1)

-- local right = mainFrame:CreateTexture(nil, "BACKGROUND")
-- right:SetHeight(8)
-- right:SetPoint("RIGHT", -3, 0)
-- right:SetPoint("LEFT", label, "RIGHT", 5, 0)
-- right:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
-- right:SetTexCoord(0.81, 0.94, 0.5, 1)

