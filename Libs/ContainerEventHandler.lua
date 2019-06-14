--------------------------------------------------------------------------------------
-- ContainerEventHandler.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 8 June, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.CombatLog = {}
container = MTP.ContainerEventHandler

local L = MTP.L
local E = errors

-- ************************************************************************************
--										Container Events
-- ************************************************************************************ 
--[[ 

BAG_CLOSED
BAG_NEW_ITEMS_UPDATED
BAG_OPEN
BAG_OVERFLOW_WITH_FULL_INVENTORY
BAG_SLOT_FLAGS_UPDATED
BAG_UPDATE
BAG_UPDATE_COOLDOWN
BAG_UPDATE_DELAYED
EQUIP_BIND_TRADEABLE_CONFIRM
INVENTORY_SEARCH_UPDATE
ITEM_LOCK_CHANGED
ITEM_LOCKED
ITEM_UNLOCKED 
]]

local errorMsgFrame = nil
-- Display the Header Test ID

local function postMsg( msg )
	if errorMsgFrame == nil then
		errorMsgFrame = emf:createErrorMsgFrame()
	end

	if errorMsgFrame:IsVisible() == false then
		errorMsgFrame:Show()
	end
		
	errorMsgFrame.Text:Insert( msg )
end

--********************************************************************************
--						EVENT HANDLERS
--********************************************************************************
local function eventBagUpdate( bagSlot )
	local result = STATUS_SUCCESS
	local msg = string.format("Bag[%d] updated!\n", bagSlot )
	mf:postMsg( msg )
	return result
end

--********************************************************************************
--						CREATES THE EVENT HANDLING FRAME AND CALLS
--						THE APPROPRIATE EVENT HANDLERS (see above)
--********************************************************************************

local eventFrame = CreateFrame("Frame" )
	eventFrame:RegisterEvent("BAG_OPEN") 
	eventFrame:RegisterEvent("BAG_CLOSED")
	eventFrame:RegisterEvent("BAG_UPDATE")
	eventFrame:RegisterEvent("ITEM_LOCKED") -- arg1 bagSlot, arg2 slotId of item

	-- if arg2 ~= nil, arg1 is bagSlot, arg2 is slotId
	-- if arg2 is nil, arg1 is equipment slot of item
-- 	Usually fires in pairs when an item is swapping with another.
-- Empty slots do not lock.
-- GetContainerItemInfo and IsInventoryItemLocked can be used to query lock status.
-- This does NOT fire on ammo pickups.
	eventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
	eventFrame:RegisterEvent("ITEM_UNLOCKED")
	eventFrame:RegisterEvent("ITEM_PUSH") 
	eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	eventFrame:RegisterEvent("BAG_UPDATE")
	
	eventFrame:SetScript("OnEvent", 
	function( self, event, ... )
		local bagSlot, slotId = ...

		-- if event == "BAG_UPDATE" then
		-- 	local b = Bag( bagSlot )
		-- 	b:bagUpdate( bagSlot )
		-- end

		-- BAG_UPDATE is fired when a bags inventory changes, including items
		-- being moved from one slot to another.  Bag zero, the 
		-- sixteen slot default backpack, may not fire on login. Upon login 
		-- (or reloading the console) this event fires even for bank bags. 
		-- When moving an item in your inventory, this fires multiple 
		-- times: once each for the source and destination bag. If the bag 
		-- involved is the default backpack, this event will also fire with 
		-- a container ID of "-2" (twice if you are moving the item inside 
		-- the same bag)
		-- if event == "BAG_UPDATE" then
		-- 	mf:postMsg( msg )
		-- 	result = eventBagUpdate( bagSlot )
		-- 	if result[1] ~= STATUS_SUCCESS then
		-- 		E:postResult( result )
		-- 	end
		-- 	return
		-- end
		if event == "ITEM_LOCK_CHANGED" then
			local b = Bag( bagSlot )
			b:itemLockChanged( bagSlot, slotId )
		end
	end)
