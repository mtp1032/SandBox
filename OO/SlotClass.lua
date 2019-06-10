-- --------------------------------------------------------------------------------------
-- SlotClass.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 28 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.SlotClass = {}	

local L = MTP.L
local E = errors


------------------------------------- LOCAL CONSTANTS -----------------------------------------------------
SLOT_IS_EMPTY = 0

-- indices into the itemDescr[iptor] - the table returned by Blizzard's GetContainerItemInfo()
ICON        = 1 --  Number - The fileID, a.k.a. the icon texture for the item in the specified bag slot.
ITEM_COUNT  = 2 --  Number - The number of items in the specified bag slot.
LOCKED      = 3 --  Boolean - True if the item is locked by the server, false otherwise.
QUALITY     = 4 --  Number - The Quality of the item.
READABLE    = 5 --  Boolean - True if the item can be "read" (as in a book), false otherwise.
LOOTABLE    = 6 --  Boolean - True if the item is a temporary container containing items that can be looted, false otherwise.
ITEM_LINK   = 7 --  String - The itemLink of the item in the specified bag slot.
IS_FILTERED = 8 --  Boolean - True if the item is grayed-out during the current inventory search, false otherwise.
NO_VALUE    = 9  -- Boolean - True if the item has no gold value, false otherwise.
ITEM_ID     = 10 -- Number - The unique ID for the item in the specified bag slot.


local QUALITY_GREY = 0
local QUALITY_COMMON = 1
local QUALITY_UNCOMMON = 2
local QUALITY__RARE = 3
local QUALITY__EPIC = 4
local QUALITY_LEGENDARY = 5
local QUALITY_ARTIFACT = 6
local QUALITY_HEIRLOOM = 7


--------------------------------------------------------------------------------------------------
--                      The Slot - an abstract class
--------------------------------------------------------------------------------------------------
local function validateSlotId (slotId, numBagSlots )
    local result = DEFAULT_RESULT

	if slotId == nil then
        return E:setErrorResult(L["ARG_NIL"], debugstack() )
    end
	if type(slotId) ~= "number" then
        return E:setErrorResult(L["ARG_WRONGTYPE"], debugstack() )
    end
	if slotId < 1 then
        return E:setErrorResult(L["ARG_OUTOFRANGE"], debugstack() )
    end
    if slotId > numBagSlots then
        return E:setErrorResult(L["ARG_OUTOFRANGE"], debugstack() )
    end
    return result
end
local function validateBagId( bagId )
    local result = DEFAULT_RESULT

    if bagId == nil then 
        return E:setErrorResult(L["ARG_NIL"], debugstack() )
    end
    if type(bagId) ~= "number" then
        return E:setErrorResult( L["ARG_WRONGTYPE"], debugstack() )
    end
    if bagId < 0 then
        return E:setErrorResult(L["ARG_OUTOFRANGE"], debugstack() )
    end 
    if bagId > 4 then
      return E:setErrorResult(L["ARG_OUTOFRANGE"], debugstack() )
    end

    return result
end

--***************************************************************************************************
--                                SLOT CONSTRUCTOR
--***************************************************************************************************
Slot = MTP.SlotClass
Slot.__index = Slot

setmetatable(Slot, {
    __index = Base,        -- makes the inheritance work
    __call = function (cls, ...)   --NOTE to me: 'cls' refers to the current table
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
function Slot:_init(bagId, slotId )

    Base._init(self)               -- call the base class constructor

	-- check that the bagId and slotId parameters are valid
	self.result = validateBagId( bagId )
	if self.result[1] ~= STATUS_SUCCESS then
		return
	end
	local numBagSlots = GetContainerNumSlots( bagId )			-- BLIZZ
	local numFreeSlots = GetContainerNumFreeSlots( bagId )		-- BLIZZ
	self.result  = validateSlotId( slotId, numBagSlots )
	if self.result[1] ~= STATUS_SUCCESS then
        return
    end

    self.is_a 		= "Bag Slot"
    self.bagId 		= bagId
    self.slotId		= slotId
    self.bagId 		= bagId
	self.itemDescr 	=  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
end

-----------------------------------------------------------------------------------------------------
--                                          CLASS METHODS
-----------------------------------------------------------------------------------------------------
function Slot:getBagNumber()
    return self.bagId
end
function Slot:getSlotId()
    return self.slotId
end
function Slot:getSlotType()
    return self.is_a
end
--                      SLOT CONTENT GET METHODS
--					( returns nil if slot is empty )
--
-- 	see https://wow.gamepedia.com/API_GetContainerItemInfo for additional detail
function Slot:getItemCount()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]
	return self.itemCount
end
function Slot:isEmpty()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	local isEmpty = true
	if self.itemCount > 0 then
		isEmpty = false
	end
	return isEmpty
end
function Slot:getItemIcon()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[ICON]
    end
    return nil
end
function Slot:isItemLocked()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[LOCKED]
    end
    return nil
end
function Slot:getItemQuality()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[QUALITY]
    end
    return nil
end
function Slot:isItemReadable()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then
        return self.itemDescr[READABLE]
    end
    return nil
end
function Slot:isItemLootable()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[LOOTABLE]
    end
    return nil
end
function Slot:getItemLink()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[ITEM_LINK]
    end
    return nil
end
function Slot:isItemFiltered()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[IS_FILTERED]
    end
    return nil
end
function Slot:isItemOfNoValue()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[NO_VALUE]
    end
    return nil
end
function Slot:getSalesPriceOfItems()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount == 0 then
		return nil
	end 
	
	if self.isItemOfNoValue == true then
		return nil
	end

	local itemInfo = {GetItemInfo( self.itemDescr[ITEM_LINK] )}
	itemSellPrice = itemInfo[11] * self.itemCount
	return itemSellPrice
end
function Slot:getItemRarity()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount == 0 then
		return nil
	end 
	
	if self.isItemOfNoValue == true then
		return nil
	end

	local itemInfo = {GetItemInfo( self.itemDescr[ITEM_LINK] )}
	itemRarity = itemInfo[3]
	
	return itemRarity
end
function Slot:getItemId()
	self.itemDescr =  { GetContainerItemInfo( self.bagId, self.slotId ) } -- BLIZZ 
	if self.itemDescr[ITEM_COUNT] == nil then
		self.itemDescr[ITEM_COUNT] = 0
	end
	self.itemCount = self.itemDescr[ITEM_COUNT]

	if self.itemCount ~= SLOT_IS_EMPTY then        
        return self.itemDescr[ITEM_ID]
    end
    return nil
end
function Slot:getResult()
    return self.result
end
