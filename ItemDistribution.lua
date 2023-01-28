local ItemDistribution = LibStub("AceAddon-3.0"):NewAddon("ItemDistribution", "AceConsole-3.0", "AceEvent-3.0")

function ItemDistribution:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("NoLootDB")
  self.currentLootItem = nil
  self.itemsToDistribute = {}
end

function ItemDistribution:OnEnable()
  self:RegisterEvent("CHAT_MSG_LOOT")
  self:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function ItemDistribution:UNIT_INVENTORY_CHANGED(eventName, unitTarget, itemLink, startingPriority, reverse)

  local isPlayer = unitTarget == "player"
  local chatMessageLootExists = self.chatMessageLootName ~= nil

  if isPlayer and chatMessageLootExists then
    local lootDistributionList = self.db.profile.lootDistributionList[self.db.profile.activeLootList]
    local lootPriorities = lootDistributionList[self.chatMessageLootName]

    local playersToRoll, priorityToRoll = NoLootUtil:getNextInLinePlayers(lootPriorities,
                                                                          startingPriority,
                                                                          reverse
                                                                         )

    self:openItemChooser(self.chatMessageLootName, itemLink, playersToRoll, priorityToRoll, lootPriorities)
    self.chatMessageLootName = nil --TODO cleanup in seperate method
  end

end

function ItemDistribution:CHAT_MSG_LOOT(eventName, text)

  local lootName = nil

  if NoLootUtil:isEmpty(text) then
    lootName = self.currentLootItem
  else
    lootName = string.match(text, '%[(.*)%]')
  end

  if self:isLootInActiveLootList(lootName) then
    self.chatMessageLootName = lootName
  end

end

function ItemDistribution:isLootInActiveLootList(lootName)

  local activeLootList = self.db.profile.activeLootList
  local lootDistributionList = self.db.profile.lootDistributionList[activeLootList]

  -- Loot exists in the active loot list!
  if lootDistributionList[lootName] then
    return true
  else
    return false
  end

end

function ItemDistribution:manualProcess(lootName, startingPriority, reverse)

  if lootName == nil then lootName = self.currentLootItem end
  local noPreviousLoot = self.currentLootItem == nil

  if noPreviousLoot and lootName == nil then
    NoLootUtil:log("No Previous loot to process")
    return false
  end

  local itemLink = nil
  local isItemLink = NoLootUtil:isItemLink(lootName)
  if isItemLink then
    itemLink = lootName
    lootName = string.match(lootName, '%[(.*)%]')
  end

  if self:isLootInActiveLootList(lootName) then
    local fakeChatMessageLoot = "[" .. lootName .. "]"
    self:CHAT_MSG_LOOT("CHAT_MSG_LOOT", fakeChatMessageLoot)
    self:UNIT_INVENTORY_CHANGED("UNIT_INVENTORY_CHANGED", "player", itemLink, startingPriority, reverse)
    return true
  else
    NoLootUtil:log('Item "' .. lootName .. '"' .. " not found in active loot list")
    return false
  end
  
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

function ItemDistribution:openItemChooser(lootName, itemLink, playerNames, priorityLevel, lootPriorities)

  if playerNames == nil then playerNames = {} end
  local playerNamesCount = table.getn(playerNames)

  -- Frame is open, dont open another one, add the item to the stack
  if self.isOpen then
    table.insert(self.itemsToDistribute, lootName)
    return
  end

  self.currentLootItem = lootName

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
  if playerNamesCount ~= 0 then
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
  closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
  closeButton:SetScript("OnClick", function()
    mainFrame:Hide()
    ItemDistribution.isOpen = false
  end)

  --------------------------------- Item Icon ---------------------------------
  local bag, slot = NoLootUtil:GetBagPositionForItemName(lootName)

  local item

  if itemLink ~= nil then
    item = Item:CreateFromItemLink(itemLink)
  else
    item = Item:CreateFromBagAndSlot(bag, slot)
  end

  --TODO this shit wont work
  if item:IsItemEmpty() then
    --GetItemInfoDelayed(lootName)
    -- local _, lootNameItemLink = GetItemInfo(lootName)
    -- item = Item:CreateFromItemLink(lootNameItemLink)
    NoLootUtil:log("No icon to show since item is not cached")
  else
    item:ContinueOnItemLoad(function()
      local itemID = item:GetItemID()
      local name = item:GetItemName()
      local icon = item:GetItemIcon()

      local yOffset = 6
      if playerNamesCount < 4 then
        yOffset = -9
      end

      local itemIcon = CreateFrame("Frame", nil, mainFrame)
      itemIcon:SetPoint("CENTER", -55, yOffset)
      itemIcon:SetSize(50, 50)
      itemIcon.tex = itemIcon:CreateTexture()
      itemIcon.tex:SetAllPoints(itemIcon)
      itemIcon.tex:SetTexture(icon)
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

    end)
  end

  -------------------------------- Player Button -------------------------------
  if playerNamesCount == 0 then
    local openRollString = mainFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    openRollString:SetPoint("TOP", 25, -40)
    openRollString:SetText("Open Roll!")
    mainFrame:SetHeight(85)
  else
    local yPosition = -30
    
    for _, playerName in ipairs(playerNames) do
      local playerButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
      playerButton.playerName = playerName
      playerButton:SetPoint("TOP", mainFrame, 25, yPosition)
      playerButton:SetSize(100, 20)
      playerButton:SetText(playerName)
      playerButton:SetScript("OnClick", function(self, button)
        ItemDistribution:markPlayerRecievedItem(lootName, priorityLevel, self.playerName)
        ItemDistribution.isOpen = false
        ItemDistribution.currentLootItem = nil
        mainFrame:Hide()

        local stillItemsToDistribute = table.getn(ItemDistribution.itemsToDistribute) > 0
        if stillItemsToDistribute then
          ItemDistribution:manualProcess(table.remove(ItemDistribution.itemsToDistribute, 1))
        end
        
      end)

      yPosition = yPosition - 20
    end

    local heightToAdd = 0
    if playerNamesCount > 2 then
      heightToAdd = (playerNamesCount - 2) * 20
    end
    mainFrame:SetHeight(85 + heightToAdd)
  end
  -------------------------- Prev / Next Prio Buttons -------------------------
  local prevXOffset = 45
  local nextXOffset = -45

  if playerNamesCount < 4 then
    prevXOffset = 70
    nextXOffset = -20
  end

  --Check to see if there are higher priorities
  local hasHigherPrios = NoLootUtil:isThereMorePriorities(lootPriorities, priorityLevel - 1)
  if hasHigherPrios then
    local prevPrioButton = CreateFrame("Button", "prevPrioButton", mainFrame)
    prevPrioButton:SetPoint("BOTTOMLEFT", prevXOffset, 5)
    prevPrioButton:SetSize(32, 32)
    prevPrioButton.tex = prevPrioButton:CreateTexture()
    prevPrioButton.tex:SetAllPoints(prevPrioButton)
    prevPrioButton.tex:SetTexture(131168)
    prevPrioButton:SetScript("OnMouseDown", function(self)
      self.tex:SetTexture(131166)
    end)
    prevPrioButton:SetScript("OnMouseUp", function(self)
      self.tex:SetTexture(131168)
    end)
    prevPrioButton:SetScript("OnClick", function(self)
      ItemDistribution.isOpen = false
      ItemDistribution.currentLootItem = nil
      mainFrame:Hide()
      ItemDistribution:manualProcess(lootName, priorityLevel - 1, true)
    end)
  end

  --Check to see if there are lower priorities
  local hasLowerPrios = NoLootUtil:isThereMorePriorities(lootPriorities, priorityLevel + 1, true)
  if hasLowerPrios then
    local nextPrioButton = CreateFrame("Button", "nextPrioButton", mainFrame)
    nextPrioButton:SetPoint("BOTTOMRIGHT", nextXOffset, 5)
    nextPrioButton:SetSize(32, 32)
    nextPrioButton.tex = nextPrioButton:CreateTexture()
    nextPrioButton.tex:SetAllPoints(nextPrioButton)
    nextPrioButton.tex:SetTexture(131176)
    nextPrioButton:SetScript("OnMouseDown", function(self)
      self.tex:SetTexture(131174)
    end)
    nextPrioButton:SetScript("OnMouseUp", function(self)
      self.tex:SetTexture(131176)
    end)
    nextPrioButton:SetScript("OnClick", function(self)
      ItemDistribution.isOpen = false
      ItemDistribution.currentLootItem = nil
      mainFrame:Hide()
      ItemDistribution:manualProcess(lootName, priorityLevel + 1)
    end)
  end

  if hasHigherPrios or hasLowerPrios then
    mainFrame:SetHeight(mainFrame:GetHeight() + 32)
  end

  ------------------------------- Dialog is open ------------------------------
  self.isOpen = true
end

function ItemDistribution:clearTempVariables()
  self.currentLootItem = nil
  self.itemsToDistribute = {}
end