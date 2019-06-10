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
local function eventBagOpened( bagId )
	local result = STATUS_SUCCESS
	local msg = string.format("Bag[%d] opened!\n", bagId )
	-- mf:postMsg( msg )
	return result
end
local function eventBagClosed( bagId )
	local result = STATUS_SUCCESS
	local msg = string.format("Bag[%d] closed!\n", bagId )
	-- mf:postMsg( msg )
	return result
end
local function eventBagUpdated( bagId )
	local result = STATUS_SUCCESS
	local msg = string.format("Bag[%d] updated!\n", bagId )
	-- mf:postMsg( msg )
	return result
end
local function eventBagUpdateCooldown( bagId )
	local result = STATUS_SUCCESS
	local msg = string.format("Bag[%d] updated!\n", bagId )
	-- mf:postMsg( msg )
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
	eventFrame:SetScript("OnEvent", 
	function( self, event, ... )
		local bagId = ...
		local result = SUCCESSFUL_RESULT

		-- BAG_OPEN IS Fired when a bag (NOTE: This is NOT fired for player containers, 
		-- it's for those bag-like objects that you can remove items from 
		-- but not put items into) is opened.
if event == "BAG_OPEN" then
			result = eventBagOpened( bagId )
			-- if result[1] ~= STATUS_SUCCESS then
			-- 	E:postResult( result )
			-- end
			return
		end

		-- BAG_CLOSED is fired when a bag is [re]moved from its bagslot. Fires
		-- for both player and bank bags
		if event == "BAG_CLOSED" then
			result = eventBagClosed( bagId )
			-- if result[1] ~= STATUS_SUCCESS then
			-- 	E:postResult( result )
			-- end
			return
		end

		-- BAG_UPDATE is fired when a bags inventory changes, including items
		-- being moved from slot to another.  Bag zero, the 
		-- sixteen slot default backpack, may not fire on login. Upon login 
		-- (or reloading the console) this event fires even for bank bags. 
		-- When moving an item in your inventory, this fires multiple 
		-- times: once each for the source and destination bag. If the bag 
		-- involved is the default backpack, this event will also fire with 
		-- a container ID of "-2" (twice if you are moving the item inside 
		-- the same bag)
		if event == "BAG_UPDATE" then
			result = eventBagUpdated( bagId )
			-- if result[1] ~= STATUS_SUCCESS then
			-- 	E:postResult( result )
			-- end
			return
		end

		-- BAG_UPDATE_COOLDOWN is fired when a cooldown update call is 
		-- sent to a bag. The container Id may be nil
		if event == "BAG_UPDATE_COOLDOWN" then
			result = eventBagUpdateCooldown( bagId )
			-- if result[1] ~= STATUS_SUCCESS then
			-- 	E:postResult( result )
			-- end
			return
		end
		mf:postMsg(event)
	end)
