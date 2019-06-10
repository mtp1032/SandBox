--------------------------------------------------------------------------------------
-- ArmorItems.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 4 November, 2018

local addonName, MTP = ...
MTP.ArmorItems = {}					-- The Snippets function library, initally an empty table.
armor = MTP.ArmorItems				-- prefix for ArmorItems API services

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


-- The table holding all of the slot names on the paper doll display
INVENTORY_SLOT_NAMES = {
        "HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"ShirtSlot",
		"ChestSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"WristSlot",
		"HandsSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"BackSlot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"TabardSlot",
		"Bag0Slot",
		"Bag1Slot",
		"Bag2Slot",
		"Bag3Slot"
		}
function armor:isSlotNameValid( slotName )

    local isValid = false
    
    for i,v in pairs(INVENTORY_SLOT_NAMES) do
        local validSlotName = string.upper( INVENTORY_SLOT_NAMES[i])
        local inputSlotName = string.upper( slotName )
        if validSlotName == inputSlotName then
            isValid = true
        end
    end
    
    return isValid
end
----------------------------------------------------------------------------------------------------------------
--                      Indices to use to obtain the slot names from the INVENTORY_SLOT_NAMES table
----------------------------------------------------------------------------------------------------------------
HEAD_C_SLOT		= 1
NECK_C_SLOT 	= 2
SHOULDER_C_SLOT = 3
SHIRT_C_SLOT 	= 4
CHEST_C_SLOT 	= 5
WAIST_C_SLOT 	= 6
LEGGINGS_C_SLOT = 7
FEET_C_SLOT 	= 8
BRACERS_C_SLOT 	= 9
HANDS_C_SLOT 	= 10
RING0_C_SLOT 	= 11
RING1_C_SLOT 	= 12
TRINKET0_C_SLOT	= 13
TRINKET1_C_SLOT = 14
CAPE_C_SLOT 	= 15
MAINHAND_C_SLOT = 16
OFFHAND_C_SLOT 	= 17
TABARD_C_SLOT 	= 19
BAG0_C_SLOT 	= 20
BAG1_C_SLOT 	= 21
BAG2_C_SLOT 	= 22
BAG3_C_SLOT 	= 23

-- indices into the elements of an itemLinkTable
ITEM_C_NAME		= 1
ITEM_C_LINK		= 2
ITEM_C_RARITY	= 3
ITEM_C_LEVEL	= 4
ITEM_C_MINLEVEL	= 5
ITEM_C_TYPE		= 6
ITEM_C_SUBTYPE	= 7 
ITEM_C_BINDTYPE	= 8

---------------------------------------------------------------------------------------------
--  Given the name of a player's inventory slot, return its item link
---------------------------------------------------------------------------------------------
function armor:getInventoryItemLink( inventorySlotName,    
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

function armor:isSlotEmpty( inventorySlotName )
    local result = DEFAULT_RESULT

    if inventorySlotName == nil then
        return( errors.setErrorResult( ARG_C_NIL, debugstack() ))
    end
    if type(inventorySlotName) ~= "string" then
        return( errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() ))
    end
    if armor:slotNameValid(inventorySlotName) == false then
        return( errors.setErrorResult( ARG_C_INVALID, debugstack()))
    end
           
    local isEmpty = false
    local itemLink = GetInventoryItemLink("Player", GetInventorySlotInfo( inventorySlotName ) )       -- BLIZZ API ENTRY
    if itemLink == nil then   
       isEmpty = true
    end

    return isEmpty
end

---------------------------------------------------------------------------------------------
--  Given an item link, return a table containing the item's level (iLvl)
---------------------------------------------------------------------------------------------
function armor:getArmorItemLevel( itemLink, itemLevelTable )
    local result = DEFAULT_RESULT
    
    -- validate the args
    if itemLink == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
    if type(itemLink) ~= "string" then
        return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
    end
    if itemLevelTable == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
    if type( itemLevelTable ) ~= "table" then
        return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
    end
    itemLevelTable = {GetDetailedItemLevelInfo(itemLink)}                           -- BLIZZ API
    if effectiveILvl == nil then
        return errors.setErrorResult( RESULT_C_BLIZZ_API, debugstack() )
    end
    if itemLevelTable[1] == nil then
        return errors.setErrorResult( RESULT_C_BLIZZ_API, debugstack() )
    end
	return( result )
end

---------------------------------------------------------------------------------------------
--  Given an item link, return a table with extensive information about that item
---------------------------------------------------------------------------------------------
function armor:getArmorItemInfo( itemLink, itemInfoTable  )
    local result = DEFAULT_RESULT
    
    -- check that args are correctly typed and initialized
    if itemLink == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
    if type(itemLink) ~= "string" then
        return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
    end
    if itemInfoTable == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
    if type(itemInfoTable) ~= "table" then
        return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
    end	
        
    itemInfoTable = {GetItemInfo(itemLink)}
    return( result )
end

---------------------------------------------------------------------------------------------
--                      Given an item link, return a table containing the item's stats (Intellect, Stamina, etc)
--                      NOTE: See https://wow.gamepedia.com/API_getInventoryItemStats for explanation of the stat table
------------------------------------------------------------------------------------------------
function armor:getArmorItemStats( itemLink, statTable ) 
    local result = DEFAULT_RESULT
    
    -- validate the args
    if itemLink == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
    if type(itemLink) ~= "string" then
        return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
    end
    if statTable == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
    if type( statTable ) ~= "table" then
        return errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
    end
    
    table.wipe(statTable)     -- clear the stat table
	local dummy = GetItemStats( itemLink, statTable )		-- BLIZZ API ENTRY
    if dummy == nil then
        return errors.setErrorResult( ARG_C_NIL, debugstack() )
    end
	return result
end

---------------------------------------------------------------------------------------------
--                      For debugging purposes
---------------------------------------------------------------------------------------------
function armor:isFileLoaded()
	return Defaults[DEBUG_ENABLED]
end

--*****************************************************************************
-- TESTING SLASH COMMANDS
--*****************************************************************************
local function displayItemInfo( tbl )
    local line1 = string.format("%s\n", tbl[ITEM_LINK] )
    local line2 = string.format(" Type: %s, Subtype: %s, Sales price: %d silver",  tbl[ITEM_TYPE], tbl[ITEM_SUBTYPE], tbl[ITEM_SELL_PRICE]/100 )
    local line3 = string.format(" Item level: %d, Bind Type: %d Item set id: %d", tbl[ITEM_LEVEL], tbl[ITEM_BIND_TYPE], tbl[ITEM_SET_ID]  )
    display.postMessage( line3 )
    display.postMessage( line2 )
    display.postMessage( line1 )

end

SLASH_TESTFOUR1 = "/four"
SLASH_TESTFOUR2 = "/test4"
SlashCmdList["TESTFOUR"] = function( slotName )
    
    local result = DEFAULT_RESULT
   
    if slotName == nil then
        result = errors.setErrorResult( ARG_C_NIL, debugstack())
        emf.postErrorMsg( result )
        return
    end
    if slotName == "" then
        result = errors.setErrorResult( ARG_C_NIL, debugstack())
        emf.postErrorMsg( result )
        return
    end

    errors.L(debugstack())        
    if type(slotName) ~= "string" then
        result = errors.setErrorResult( ARG_C_WRONGTYPE, debugstack())
        emf.postErrorMsg( result )
        return
    end
    if armor:isSlotNameValid( slotName ) == false then
        result = errors.setErrorResult( ARG_C_INVALID, debugstack())
        emf.postErrorMsg( result )
        return
    end
    if armor:isSlotEmpty( slotName ) == true then 
        result = errors.setErrorResult( EMPTY_C_SLOT, debugstack())
        emf.postErrorMsg( result )
        return
    end
    local itemLinkTable = {}    
    result = armor:getInventoryItemLink( slotName, "Player", itemLinkTable )
    if result[1] == FAILURE then
        emf.postErrorMsg( result )
        return
    end

    local itemInfoTable = {}
    result = armor:getArmorItemInfo( itemLinkTable[1], itemInfoTable )
    if result[1] ~= SUCCESS then
        errors.postErrorMsg( result )
        return
    end

    armor:displayItemInfo( itemInfoTable )
end

-------------------------------------------------------------------------------------------------
--                      For debugging purposes
-------------------------------------------------------------------------------------------------
local DEBUG_C_ENABLED = errors.isDebugEnabled()

function armor:isFileLoaded()
    return true
end



---------------------------------------------------------------------------------------------------
--                      Snippet: HOWTO Tool Tip Scanning
---------------------------------------------------------------------------------------------------
-- function mnkDurability.GetItemLevel(slotID)
--     local tip = CreateFrame("GameTooltip", "scanTip", UIParent, "GameTooltipTemplate")
--     tip:ClearLines()
--     tip:SetOwner(UIParent,"ANCHOR_NONE")
--     tip:SetInventoryItem("player", slotID)
--     for i=1, 5 do
--         local l = _G["scanTipTextLeft"..i]:GetText()
--         if l and l:find('Item Level') then
--             local _, i = string.find(l, 'Item Level%s%d')
--             -- check for boosted levels ie Chromeie scenarios.
--             local _, x = string.find(l, " (", 1, true)
--             --print(t, ' ', x)
--             if x then
--                 return string.sub(l, i, x-2) or '-'
--             end
--             return string.sub(l, i) or -'-'            
--         end 
--     end
 
--     return '-'
-- end