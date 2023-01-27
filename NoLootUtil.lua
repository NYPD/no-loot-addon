function tprint(tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint .. k .. "= "
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent - 2) .. "}"
  return toprint
end

function try(f, catch_f)
  local status, exception = pcall(f)
  if not status then
    catch_f(exception)
  end
end

function isEmpty(string)
  return string == nil or string == ""
end

function GetBagPosition(itemLink)
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      if (C_Container.GetContainerItemLink(bag, slot) == itemLink) then
        return bag, slot
      end
    end
  end
end

-- Get bag position of the Hearthstone
-- local _, itemLink = GetItemInfo(6948)
-- local bag, slot = GetBagPosition(itemLink)
-- print("bag: " .. bag)
-- print("slot: " .. slot)
-- print(C_Item.GetItemID(ItemLocation:CreateFromBagAndSlot(bag, slot)))
