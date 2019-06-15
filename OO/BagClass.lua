-- --------------------------------------------------------------------------------------
-- BagClass.lua
-- UTHOR: Michael Peterson
-- ORIGINAL DATE: 28 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.BagClass = {}
bag = MTP.BagClass	

local L = MTP.L
local E = errors
--------------------------------------------------------------------------------------------------
--              - The bagSlot is the location of the bag. For example, 0 represents the player's
--                  backpack
--              - The bagSlot is used to obtain the inventoryId. Player bags begin at inventoryId = 20
--              - NUM_BAG_SLOTS = 4, BAG_SLOT0 = the player's backpack
--              - NUM_BANKBAGSLOTS = 7
--              - bagSlot 0 is inventoryId = 20
--              - bagSlot 3 is inventoryId = 24
--------------------------------------------------------------------------------------------------
local BACKPACK_SLOT_NUMBER = 0

-- bag types for Classical
local GENERAL_PURPOSE = 0 -- NOTE: for bags this means any item, for items it means no special bag type
local QUIVER = 1
local AMMO_POUCH = 2
local SOUL_SHARD = 4
local LEATHERWORKING = 8
local HERBALISM = 32
local ENCHANTING = 64 
local ENGINEERING = 128
local KEYRING = 256
local MINING = 1024
local UNKNOWN = 2048

local function getBagType( typeBitField )
  local bagType = "bad bit field"

  if typeBitField == QUIVER then
     bagType = "Quiver"
  elseif typeBitField == GENERAL_PURPOSE then
    bagType = "General Purpose"
  elseif typeBitField == AMMO_POUCH then
    bagType = "Ammo Pouch"
  elseif typeBitField == SOUL_SHARD then
    bagType = "Soul shard"
  elseif typeBitField == LEATHERWORKING then
    bagType = "Leather Working"
  elseif typeBitField == INSCRIPTION then
    bagType = "Inscription"
  elseif typeBitField == HERBALISM then
    bagType = "Herbalism"
  elseif typeBitField == ENCHANTING then
    bagType = "Enchanting"
  elseif typeBitField == ENGINEERING then
    bagType = "Engineering"
  elseif typeBitField == KEYRING then
    bagType = "Key Ring"
  elseif typeBitField == GEM then
    bagType = "Gem"
  elseif typeBitField == MINING then
    bagType = "Mining"
  elseif typeBitField == UNKNOWN then
    bagType = "Unknown"
  else 
    bagType = "Vanity"
  end 

  return bagType
end

local function validateBagNumber( bagSlot )
    local result = SUCCESSFUL_RESULT

	if bagSlot == nil then 
		result = errors:setErrorResult( L["ARG_NIL"], debugstack() )
    elseif type(bagSlot) ~= "number" then
		result = errors:setErrorResult( L["ARG_WRONGTYPE"],debugstack())
	elseif bagSlot < BACKPACK_SLOT_NUMBER then
		result = errors:setErrorResult( L["ARG_OUTOFRANGE"], debugstack() )
    elseif bagSlot > 4 then
		result = errors:setErrorResult( L["ARG_OUTOFRANGE"], debugstack() )
	else
		return result
	end
	return result
end
--***************************************************************************************************
--                                BAG CONSTRUCTOR
--***************************************************************************************************
Bag = MTP.BagClass
Bag.__index = Bag

setmetatable(Bag, {
    __index = Base,                		-- Makes the inheritance work
    __call = function (cls, ...)        --NOTE to me: 'cls' refers to the current table
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
function Bag:_init( bagSlot )   
        --          Inherited from the BaseClass parent
	Base._init(self)
    local result = SUCCESSFUL_RESULT
    self.is_a = "Bag"
	
	-- check that the input is a valid bag.	
	self.result = validateBagNumber( bagSlot )
	if self.result[1] ~= STATUS_SUCCESS then
      return
    end

	self.bagSlot = bagSlot
	
	--mf:postMsg( string.format("%s in empty bag slot\n", self.name ))
    
    -- -- see explanations here: 
    -- --      https://wow.gamepedia.com/API_ContainerIDToInventoryID and
    -- --      https://wow.gamepedia.com/API_GetBagName
    -- -- 
    -- --  Example USAGE:  Get the itemLink of the bag at bagSlot 1
    -- --      self.bagSlot = 1
    -- --      self.inventoryID = ContainerIDToInventoryID( self.bagSlot )  
    -- --      self.itemLink = GetInventoryItemLink("player",invID)
    if self.bagSlot ~= BACKPACK_SLOT_NUMBER then
		self.inventoryId = ContainerIDToInventoryID( self.bagSlot )    -- BLIZZ
		self.itemLink = GetInventoryItemLink("Player", self.inventoryId )   -- BLIZZ
		if self.itemLink == '' then
	  		E:setErrorResult(L["BAG_SLOT_UNOCCUPIED"], debugstack() )
		end 
	else
		self.inventoryId = nil
		self.itemLink = nil
	end

	self.name = GetBagName( bagSlot )   -- BLIZZ
	if self.name == 0 then
		self.name = nil
	end

	-- See https://wow.gamepedia.com/API_GetContainerNumSlots and
	-- see https://wow.gamepedia.com/API_GetContainerNumFreeSlots

    -- check the occupancy (free and occupied slots ) and get the bag type
	self.totalSlots = GetContainerNumSlots(self.bagSlot )   -- BLIZZ
    _, typeBitField = GetContainerNumFreeSlots( self.bagSlot )    -- BLIZZ
	self.type = getBagType( typeBitField )
		
	self.slotTable = {}
	--	Create the required number of Slot objects (self.totalSlots )
    for slotId = 1, self.totalSlots do
      self.slotTable[slotId] = Slot( self.bagSlot, slotId )
    end
end
--***********************************************************************************************
--									EVENT HANDLERS
--***********************************************************************************************
function Bag:bagUpdate( bagSlot )
	local result = STATUS_SUCCESSFUL
	local msg = string.format("[BAG_UPDATE] - bag slot %d\n", bagSlot )
	mf:postMsg( msg )
	return result
end

local itemIsPickedUp = 1
local eventCount = 1
function Bag:itemLockChanged( bagSlot, slotId)
	local result = STATUS_SUCCESSFUL

	if itemIsPickedUp == 1 then
		local msg = string.format("Item picked up by cursor.\n")
		--mf:postMsg(msg)
		itemIsPickedUp = 2
	elseif itemIsPickedUp == 2 then
		local msg = string.format("Item released from cursor.\n")
		itemIsPickedUp = 1
		local slot = self.slotTable[slotId]
		slot:getItemCount()
		--mf:postMsg(msg)
	else
		print("We should not be here.")
	end
	
	local msg = string.format("[%d] ITEM_LOCK_CHANGED - bag slot %d, slot %d\n", eventCount, bagSlot, slotId )
	--mf:postMsg( msg )
	eventCount = eventCount + 1

	return result
end

function Bag:getResult()
	return self.result
end
function Bag:getSlot( slotId )
  return self.slotTable[slotId]
end
--							GET/SET METHODS
function Bag:bagType()    -- returns string value associated with self.type
  return self.type
end
function Bag:itemLink()
    return self.itemLink
end
function Bag:inventoryId()
    return self.inventoryId
end
function Bag:bagName()
    return self.name
end
function Bag:getTotalSlots()
    return self.totalSlots
end
function Bag:getNumFreeSlots()
    return GetContainerNumFreeSlots( self.bagSlot )    -- BLIZZ
end
function Bag:getBagSlot()
  return self.bagSlot
end