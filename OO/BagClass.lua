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

function Bag:getSlot( slotId )
  return self.slotTable[slotId]
end

--							GET/SET METHODS
function Bag:getResult()
	return self.result
end
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
function Bag:getSlotId()
  return self.bagSlot
end

---------------------------------------- SELL GRAY I---------------------------------------------------

-- COMMENT: see https://wowwiki.fandom.com/wiki/API_GetItemInfo() for additional information
-- function SellGreyItems()
-- 	TotalPrice = 0
-- 	for myBags = 0,4 do
-- 		for bagSlots = 1, GetContainerNumSlots(myBags) do
-- 			CurrentItemLink = GetContainerItemLink(myBags, bagSlots)
-- 				if CurrentItemLink then
-- 					_, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(CurrentItemLink)
-- 					_, itemCount = GetContainerItemInfo(myBags, bagSlots)
-- 					if itemRarity == 0 and itemSellPrice ~= 0 then
-- 						TotalPrice = TotalPrice + (itemSellPrice * itemCount)
-- 						print("Sold: ".. CurrentItemLink .. " for " .. GetCoinTextureString(itemSellPrice * itemCount))
-- 						UseContainerItem(myBags, bagSlots)
-- 					end
-- 				end
-- 		end
-- 	end
-- 	if TotalPrice ~= 0 then
-- 		print("Total Price for all items: " .. GetCoinTextureString(TotalPrice))
-- 	else
-- 		print("No items were sold.")
-- 	end
-- end

-- local BtnSellGrey = CreateFrame( "Button" , "SellGreyBtn" , MerchantFrame, "UIPanelButtonTemplate" )
-- BtnSellGrey:SetText("Sell Grey")
-- BtnSellGrey:SetWidth(90)
-- BtnSellGrey:SetHeight(21)
-- BtnSellGrey:SetPoint("TopRight", -180, -30 )
-- BtnSellGrey:RegisterForClicks("AnyUp")
-- BtnSellGrey:SetScript("Onclick", SellGreyItems)

---------------------------------------- SELL GRAY II---------------------------------------------------
-- SellAllInBag = CreateFrame('Frame')
-- SellAllInBag.itemsToSell = {}
-- SellAllInBag.pendingBags = {}
 
-- function SellAllInBag:SetCurrentBag(bagID)
--     wipe(self.itemsToSell)
--     self.currentBagID = bagID
--     self.itemsSold = 0
 
--     local toggleEvent = (bagID ~= nil) and self.RegisterEvent or self.UnregisterEvent
 
--     toggleEvent(self, 'BAG_UPDATE')
--     toggleEvent(self, 'BAG_UPDATE_DELAYED')
-- end
 
-- function SellAllInBag:AttemptSellItems(index)
--     for i=index or 1, #self.itemsToSell do
--         UseContainerItem(self.currentBagID, self.itemsToSell[i])
--     end
-- end
 
-- function SellAllInBag:ProcessNextInQueue()
--     local bagInQueue = tremove(self.pendingBags, 1)
--     if bagInQueue then
--         self(bagInQueue)
--     end
-- end
 
-- function SellAllInBag:OnEvent(event)
--     if ( event == 'BAG_UPDATE' ) then
--         self.itemsSold = self.itemsSold + 1
--     elseif ( event == 'BAG_UPDATE_DELAYED' ) then
--         if ( self.itemsSold == #self.itemsToSell ) then
--             self:SetCurrentBag(nil)
--             self:ProcessNextInQueue()
--         else
--             self:AttemptSellItems(self.itemsSold)
--         end
--     elseif ( event == 'MERCHANT_SHOW' ) then
--         self.merchantAvailable = true
--     elseif ( event == 'MERCHANT_CLOSED' ) then
--         self.merchantAvailable = false
--         self:SetCurrentBag(nil)
--         wipe(self.pendingBags)
--     end
-- end
 
-- SellAllInBag:RegisterEvent('MERCHANT_SHOW')
-- SellAllInBag:RegisterEvent('MERCHANT_CLOSED')
-- SellAllInBag:SetScript('OnEvent', SellAllInBag.OnEvent)
 
-- setmetatable(SellAllInBag, {
--     __index = getmetatable(SellAllInBag).__index;
--     __call = function(self, bagID)
--     --------------------------------------------------
--         if self.merchantAvailable then
--             if not self.currentBagID then
--                 self:SetCurrentBag(bagID)
 
--                 local itemsToSell = self.itemsToSell
--                 for slot=1, GetContainerNumSlots(bagID) do
--                     local link = select(7, GetContainerItemInfo(bagID, slot))
--                     local sellPrice = (link and select(11, GetItemInfo(link))) or 0
 
--                     if sellPrice > 0 then
--                         itemsToSell[#itemsToSell + 1] = slot
--                     end
--                 end
 
--                 if #itemsToSell > 0 then
--                     self:AttemptSellItems()
--                 else
--                     self:SetCurrentBag(nil)
--                 end
--             else
--                 tinsert(self.pendingBags, bagID)
--             end
--         end
--     --------------------------------------------------
--     end;
-- })