local ItemDistribution = LibStub("AceAddon-3.0"):NewAddon("ItemDistribution", "AceConsole-3.0", "AceEvent-3.0")

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

function ItemDistribution:CHAT_MSG_LOOT(eventName, text)

  local lootName = nil

  if NoLootUtil:isEmpty(text) then
    lootName = self.previousLootName
  else
    lootName = string.match(text, '%[(.*)%]')
  end

  if NoLootUtil:isEmpty(lootName) then
    print("No loot item name to process")
    return
  end

  local activeLootList = self.db.profile.activeLootList
  local lootDistributionList = self.db.profile.lootDistributionList[activeLootList]

  if lootDistributionList[lootName] then
    local playersToRoll, priorityToRoll = NoLootUtil:getNextInLinePlayers(lootDistributionList[lootName])
    self.previousLootName = lootName
    self:openItemChooser(lootName, playersToRoll, priorityToRoll)
  else
    print(lootName .. " is not in the current loot list")
  end

end

function ItemDistribution:updateActiveLootList(activeLootList)
  self.activeLootList = activeLootList
end

function ItemDistribution:openItemChooser(lootName, playerNames, priorityLevel)

  -- Frame is open, dont open another one
  if self.isOpen then return end

  --------------------------------- Main Frame ---------------------------------
  local mainFrame = CreateFrame("Frame", "LootDistribution", UIParent, "BackdropTemplate")

  if (self.db.profile.framePoint == nil) then
    mainFrame:SetPoint("TOPLEFT")
  else
    mainFrame:SetPoint(self.db.profile.framePoint,
                       self.db.profile.frameRelativeTo,
                       self.db.profile.frameRelativePoint,
                       self.db.profile.frameOffsetX,
                       self.db.profile.frameOffsetY)
  end

  mainFrame:SetWidth(180)
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

  --------------------------------- Loot Name ----------------------------------
  if priorityLevel ~= nil then
    local title = mainFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    title:SetPoint("TOPLEFT", 7, -10)

    local frameTitle = lootName
    local lootNameStringLength = string.len(frameTitle)
    if lootNameStringLength > 15 then
      frameTitle = string.sub(frameTitle, 1, 13) .. "..."
    end

    title:SetText(frameTitle .. " [Prio: " .. priorityLevel .. "]")
  end

  -------------------------------- Close button --------------------------------
  local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
  closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0 , 0)
  closeButton:SetScript("OnClick", function()
    mainFrame:Hide()
    ItemDistribution.isOpen = false
  end)

  --------------------------------- Item Icon ---------------------------------
  local _, lootNameItemLink = GetItemInfo(lootName)
  local bag, slot = NoLootUtil:GetBagPosition(lootNameItemLink)
  local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)

  try(function()
    C_Item.DoesItemExist(itemLocation)
  end, function(e)
    print("item location invalid")
    print("bag: " .. bag)
    print("slot: " .. slot)
  end)

  local itemID = C_Item.GetItemID(itemLocation)
  local fileDataID = C_Item.GetItemIcon(itemLocation)

  local itemIcon = CreateFrame("Frame", nil, mainFrame)
  itemIcon:SetPoint("CENTER", -55, -10)
  itemIcon:SetSize(50, 50)
  itemIcon.tex = itemIcon:CreateTexture()
  itemIcon.tex:SetAllPoints(itemIcon)
  itemIcon.tex:SetTexture(fileDataID)
  itemIcon:SetScript("OnEnter", function(self)
    --GameTooltip:SetOwner(mainFrame, "ANCHOR_TOP")
    -- How do I change the tooltip anchor froum mouse?
    GameTooltip:SetOwner(mainFrame, "ANCHOR_CURSOR", 0, 0)
    GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0")
    GameTooltip:Show()
  end)
  itemIcon:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -------------------------------- Player Button -------------------------------
  if priorityLevel == nil then
    local openRollString = mainFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    openRollString:SetPoint("TOP", 25, -40)
    openRollString:SetText("Open Roll!")
    mainFrame:SetHeight(85)
  else
    local yPosition = -30
    local playerNamesCount = 0
    for _, playerName in ipairs(playerNames) do
      local playerButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
      playerButton.playerName = playerName
      playerButton:SetPoint("TOP", mainFrame, 25, yPosition)
      playerButton:SetSize(100, 20)
      playerButton:SetText(playerName)
      playerButton:SetScript("OnClick", function(self, button)
        ItemDistribution:markPlayerRecievedItem(lootName, priorityLevel, self.playerName)
        ItemDistribution.isOpen = false
        mainFrame:Hide()
      end)

      yPosition = yPosition - 20
      playerNamesCount = playerNamesCount + 1
    end

    local heightToAdd = 0
    if playerNamesCount > 2 then
      heightToAdd = (playerNamesCount - 2) * 20
    end
    mainFrame:SetHeight(85 + heightToAdd - 5)
  end

  self.isOpen = true

end

function ItemDistribution:markPlayerRecievedItem(lootName, priorityLevel, playerName)

  local activeLootList = self.db.profile.activeLootList
  local lootDistributionList = self.db.profile.lootDistributionList[activeLootList]
  local lootPriorities = lootDistributionList[lootName]

  for key, lootPriority in pairs(lootPriorities) do
    local priority = lootPriority["priority"]
    if priority == priorityLevel then
      for key, player in pairs(lootPriority["players"]) do
        if playerName == player["playerName"] then
          player["has"] = true
          break
        end
      end
      break
    end
  end

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

