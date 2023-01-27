NoLootUtil = {}
NoLootUtil.__index = NoLootUtil;

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


function NoLootUtil:GetBagPosition(itemLink)
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      if (C_Container.GetContainerItemLink(bag, slot) == itemLink) then
        return bag, slot
      end
    end
  end
end

function NoLootUtil:getNextInLinePlayers(lootPrioritiesArray)

  local playersByPriority = {}
  local maxPriority = 0

  for key, lootPriority in pairs(lootPrioritiesArray) do
    local priority = lootPriority["priority"]
    playersByPriority[priority] = lootPriority["players"]
    if priority > maxPriority then maxPriority = priority end
  end

  local playersToRoll = {}
  local priorityToRoll = 0

  for i = 1, maxPriority do
    local players = playersByPriority[i]
    priorityToRoll = i

    for key, player in pairs(players) do
      local playerName = player["playerName"]
      local playerHasItem = player["has"]
      if not playerHasItem then table.insert(playersToRoll, playerName) end
    end

    if next(playersToRoll) ~= nil then return playersToRoll, priorityToRoll end

  end

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
