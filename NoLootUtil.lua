NoLootUtil = {}
NoLootUtil.__index = NoLootUtil;
NoLootUtil.waitTable = {}
NoLootUtil.waitFrame = nil
NoLootUtil.count = 0

function NoLootUtil:isEmpty(value)
  return value == nil or value == ""
end

function NoLootUtil:stringTrim(value)
  local isEmpty = self:isEmpty(value)

  if isEmpty then
    return value
  else
    return value:gsub("%s+", "")
  end
end


function NoLootUtil:GetBagPositionForItemName(itemName)

  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do

      local itemLink = C_Container.GetContainerItemLink(bag, slot)
      if itemLink ~= nil then
        local matches = string.match(itemLink, '%[(.*)%]') == itemName
        if matches then return bag, slot end
      end
    end
  end

  return -69, -69
end

function NoLootUtil:isThereMorePriorities(lootPrioritiesArray, startingPriority, lower)

  local playersByPriority = {}
  local minPriority = 0
  local maxPriority = 0

  for key, lootPriority in pairs(lootPrioritiesArray) do
    local priority = lootPriority["priority"]
    playersByPriority[priority] = lootPriority["players"]
    if priority > maxPriority then maxPriority = priority end
    if priority < minPriority then minPriority = priority end
  end

  local endingPriority = minPriority
  local incrementValue = -1

  if lower then
    endingPriority = maxPriority
    incrementValue = 1
  end

  for i = startingPriority, endingPriority, incrementValue do

    local players = playersByPriority[i]

    --What programming language does not have a continue? So stupid
    if players ~= nil then
      for key, player in pairs(players) do
        local playerHasItem = player["has"]
        if not playerHasItem then
          return true
        end
      end
    end

  end

  return false

end

function NoLootUtil:getNextInLinePlayers(lootPrioritiesArray, startingPriority, reverse)

  local playersByPriority = {}
  local minPriority = 0
  local maxPriority = 0

  for key, lootPriority in pairs(lootPrioritiesArray) do
    local priority = lootPriority["priority"]
    playersByPriority[priority] = lootPriority["players"]
    if priority > maxPriority then maxPriority = priority end
    if priority < minPriority then minPriority = priority end
  end

  local playersToRoll = {}
  local priorityToRoll = 0

  local startingPoint = (startingPriority or minPriority)
  local endingPoint = maxPriority
  local incrementValue = 1 --wish there was a ternery operator in Lua, so trash

  if reverse then
    endingPoint = minPriority
    incrementValue = -1
  end

  for i = startingPoint, endingPoint, incrementValue do

    local players = playersByPriority[i]
    priorityToRoll = i

    --What programming language does not have a continue? So stupid
    if players ~= nil then
      for key, player in pairs(players) do
        local playerName = player["playerName"]
        local playerHasItem = player["has"]
        if not playerHasItem then table.insert(playersToRoll, playerName) end
      end

      if next(playersToRoll) ~= nil then return playersToRoll, priorityToRoll end
    end

  end

  return playersToRoll, startingPoint

end

function NoLootUtil:isItemLink(value)
  return string.match(value, "item[%-?%d:]+") ~= nil
end

function NoLootUtil:log(value)
  print(YELLOW_FONT_COLOR:WrapTextInColorCode("[NoLoot] ") .. value)
end

function NoLootUtil:wait(delay, func, ...)
  if (type(delay) ~= "number" or type(func) ~= "function") then
    return false
  end
  if not NoLootUtil.waitFrame then
    NoLootUtil.waitFrame = CreateFrame("Frame", nil, UIParent)
    NoLootUtil.waitFrame:SetScript("OnUpdate", function(self, elapse)
      for i = 1, #NoLootUtil.waitTable do
        local waitRecord = tremove(NoLootUtil.waitTable, i)
        local d = tremove(waitRecord, 1)
        local f = tremove(waitRecord, 1)
        local p = tremove(waitRecord, 1)
        if d > elapse then
          tinsert(NoLootUtil.waitTable, i, { d - elapse, f, p })
          i = i + 1
        else
          NoLootUtil.count = NoLootUtil.count - 1
          f(unpack(p))
        end
      end
    end)
  end
  tinsert(NoLootUtil.waitTable, { delay, func, { ... } })
  return true
end



local f -- the OnUpdate frame.
local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice

-- #table only works if all the indexes are in sequential order and there are no breaks.
-- This function 1 if there are more than 0 elements. It does not return the actual number of elements. This is to save processing time.
local function count(tab)
  for _ in pairs(tab) do
    return 1
  end
  return 0
end

-- Data processor.
-- self == f
local function process(self, item, ...)
  itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc,
      itemTexture, itemSellPrice = ...
  if itemName then
    -- This is where you want to do stuff to the information you requested.
    -- Change this line and leave everything else as-is.
    print(itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc,
      itemTexture, itemSellPrice)

    -- remove the item from the queue
    self.itemQueue[item] = nil
  end
end

-- OnUpdate function.
-- self == f
local function update(self, e)
  self.updateTimer = self.updateTimer - e
  if self.updateTimer <= 0 then
    for _, item in pairs(self.itemQueue) do
      process(self, item, GetItemInfo(item))
    end
    self.updateTimer = 1

    -- Hide the OnUpdate frame if there are no items in the queue.
    if count(self.itemQueue) == 0 then
      self:Hide()
    end
  end
end

-- Add the requested item to the queue.
-- If the item is in the local cache, it will be available immediately.
-- If the item is not in the local cache, wait in one second increments and try again.
-- Call this in place of GetItemInfo(item).
-- This function does not return any data.
function GetItemInfoDelayed(item)
  -- Create the frame only when it's needed and don't create it again.
  if not f then
    f = CreateFrame("Frame")
    f:SetScript("OnUpdate", update)
    f.itemQueue = {}
  end

  -- Set the timer to 0, add the item to the queue, and show the OnUpdate frame.
  f.updateTimer = 0
  f.itemQueue[item] = item
  f:Show()
end

-- Get bag position of the Hearthstone
-- local _, itemLink = GetItemInfo(6948)
-- local bag, slot = GetBagPosition(itemLink)
-- print("bag: " .. bag)
-- print("slot: " .. slot)
-- print(C_Item.GetItemID(ItemLocation:CreateFromBagAndSlot(bag, slot)))

-- print(parsedJson["Silk Cloth"])
-- print(parsedJson["Silk Clotwwh"])

-- for key, value in pairs(parsedJson) do
--    print("Loot distribution item: " .. key)
--     for key, value2 in pairs(value) do
--     print("priority level: " .. value2["priority"])
--     for key, value3 in pairs(value2["players"]) do
--       print("playerName : " .. value3["playerName"])
--       print("has : " .. tostring(value3["has"]))
--     end
--   end
-- end
