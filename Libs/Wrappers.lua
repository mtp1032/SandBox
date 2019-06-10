--------------------------------------------------------------------------------------
-- Wrappers.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 18 December, 2018

------------------------------------------------------------------------------------------------------------
--                      This file encapsulates all of the Blizzard specific API services used in
--                      this AddOn that require Blizzard prefixes (e.g., "C_Item", "C_EquipmentSet", etc.,)
------------------------------------------------------------------------------------------------------------

local ADDON_C_NAME, MTP = ...
MTP.Wrappers = {}	
WRAP = MTP.SandBox

local P = errors.L   -- used to get line, function, and filepath info
local IS_CLASSIC = sbx.isClassic()

--------------------------------------------------------------------------------------------------------------------------------------
--                      The item and location mixin APIs are described at the two links below
--
--                          https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/ObjectAPI/Item.lua
--                          https://github.com/tomrus88/BlizzardInterfaceCode/blob/46d53f88664c14d16a702c0f68c1cd215d9efd14/Interface/FrameXML/ObjectAPI/ItemLocation.lua
--
--                      Item mixins can be created by the following 4 methods illustrated below
--
--                          local itemMixin = Item:CreateFromBagAndSlot( bagID, slotIndex )
--                          local itemMixin = Item:CreateFromEquipmentSlot( paperDollIndex )
--                          local itemMixin = Item:CreateFromItemLink( itemLink )
--                          local itemMixin = Item:CreateFromItemID( itemID )
--
--                      Item location mixins are
--                          local itemLocationMixin = ItemLocation:Create

-------------------------------------------------------------------------------------------------
--                      The Equipment Set Functions
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------
--                      The armor Item Functions
-------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
--                      Enable, disable, and query status of this file's debugstate
-------------------------------------------------------------------------------------------------
local SANDBOX_C_DEBUG_ENABLED = true
function WRAP.disableDebug()
    SANDBOX_C_DEBUG_ENABLED = false
end
function WRAP.enableDebug()
    SANDBOX_C_DEBUG_ENABLED = true
end    
function WRAP.isDebugEnabled()
    return SANDBOX_C_DEBUG_ENABLED
end

------------------------------------------------------------------------------------------------
--                      Called by DebugState.lua, if this function does not return then 
--                      this file failed to load
-------------------------------------------------------------------------------------------------
function WRAP.isFileLoaded()
    return true
end

---------------------------------------------------------------------------------------------------
--                      Tests
---------------------------------------------------------------------------------------------------

-- Get the name of an item in a bag slot
local bagLocation = Item:CreateFromBagAndSlot(0, 1)
local name = bagLocation:GetItemName()
DEFAULT_CHAT_FRAME:AddMessage( name )

local equippedLocation = Item:CreateFromEquipmentSlot( 1 )
name = equippedLocation:GetItemName()
DEFAULT_CHAT_FRAME:AddMessage(name)

--  If you know the Bag and slot where your item resides
local function iLevelBybagLocation( bagID, slotID )
    local iLevel = 0
    local bagLocation = Item:CreateFromBagAndSlot(bagID, slotID)
    if bagLocation then
        iLevel = bagLocation:GetCurrentItemLevel()
    end
    return iLevel
end

iLevel = iLevelBybagLocation(0, 1)
DEFAULT_CHAT_FRAME:AddMessage( string.format("iLevel %d", iLevel ))

local function iLevelByEquipmentSlot( slotIndex )    
    iLevel = 0
    local equippedLocation = Item:CreateFromEquipmentSlot( slotIndex )
    if equippedLocation then
        iLevel = equippedLocation:GetCurrentItemLevel()
    end
    return iLevel
end

iLevel = iLevelByEquipmentSlot( 1 )
DEFAULT_CHAT_FRAME:AddMessage( string.format("iLevel %d", iLevel ))

function items.getInventoryItemLink( inventorySlotName,    
    unit,
    itemLinkTable )
local result = DEFAULT_RESULT

-- check that args are correctly typed and initialized
if inventorySlotName == nil then
return errors.setErrorResult( ARG_C_NIL, debugstack() )
end
if type(inventorySlotName) ~= "string" then
return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
end
if unit == nil then
return errors.setErrorResult( ARG_C_NIL, debugstack() )
end
if type(unit) ~= "string" then
return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
end
if itemLinkTable == nil then
return errors.setErrorResult( ARG_C_NIL, debugstack() )
end
if type( itemLinkTable ) ~= "table" then
return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
end

local slotID, textureName = GetInventorySlotInfo( inventorySlotName )       -- BLIZZ API END
local itemLink = GetInventoryItemLink(unit, slotID )                        -- BLIZZ API ENTRY

if itemLink == nil then   
return errors.setErrorResult( EMPTY_C_SLOT, debugstack())
end

itemLinkTable[1] = itemLink
itemLinkTable[2] = textureName
itemLinkTable[3] = slotID

return result
end

Armor = {}

local ITEM_NAME = 1
local ITEM_LINK = 2
local ITEM_RARITY = 3
local ITEM_LEVEL = 4
local ITEM_MIN_LEVEL = 5
local ITEM_TYPE = 6
local ITEM_SUBTYPE = 7
local ITEM_STACKCOUNT = 8
local ITEM_EQUIP_LOC = 9
local ITEM_ICON = 10
local ITEM_SELL_PRICE = 11
local ITEM_CLASS_ID = 12
local ITEM_SUBCLASS = 13
local ITEM_BIND_TYPE = 14
local ITEM_EXPAC_ID = 15
local ITEM_SETID = 16
local ITEM_IS_CRAFTING_AGENT = 17

function Armor:EquippedItemInfo( inventorySlotIndex )
    local result = DEFAULT_RESULT
    
    -- check that itemSlotIndex is correct
    if inventorySlotIndex == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack())
    end
    if type(inventorySlotIndex) ~= "number" then
        return errors.setErrorResult(ARG_C_WRONGTYPE, debugstack() )
    end
    if inventorySlotIndex < HEAD_C_SLOT and inventorySlotIndex > BAGS_C_SLOT then
        return errors.setErrorResult(ARG_C_INVALID, debugstack() )
    end
    
    local slotID = GetInventorySlotInfo( inventorySlotName )       -- BLIZZ API END
    local itemLink = GetInventoryItemLink("player", slotID )                        -- BLIZZ API ENTRY
    
    itemInfoTable = {GetItemInfo(itemLink)}

    self.itemName = itemInfoTable[ITEM_NAME]
    self.itemName = itemInfoTable[ITEM_LINK]
    self.itemRarity = itemInfoTable[ITEM_RARITY]

    return( Armor )
end


function Armor:CreateFromEquipmentSlot( slotIndex )
    local equippedLocation = Item:CreateFromEquipmentSlot( slotIndex )
    if equippedLocation then
        iLevel = equippedLocation:GetCurrentItemLevel()
    end

end


