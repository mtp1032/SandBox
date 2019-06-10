--------------------------------------------------------------------------------------

-- SlotTests.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 29 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.SlotTests = {}
slotTests = MTP.SlotTests

local L = MTP.L
local E = errors

local RARITY_GREY 		= 0
local RARITY_COMMON 	= 1
local RARITY_UNCOMMON	= 2
local RARITY__RARE 		= 3
local RARITY__EPIC 		= 4
local RARITY_LEGENDARY 	= 5
local RARITY_ARTIFACT 	= 6
local RARITY_HEIRLOOM 	= 7

local function getRarityColor( rarityIndex )
	local rarity = nil
	if rarityIndex < 0 then 
		return nil
	end
	if rarityIndex == 0 then 
		 rarity = "Grey" 
	end 
	if rarityIndex == 1 then 
		rarity = "Common"
	end
	if rarityIndex == 2 then 
		rarity = "Uncommon"
	end 
	if rarityIndex == 3 then 
		rarity = "Rare"
	end 
	if rarityIndex == 4 then 
		rarity = "Epic"
	end
	if rarityIndex == 5 then 
		rarity = "Legendary"
	end
	if rarityIndex == 6 then
		 rarity = "Artifact"
	end
	if rarityIndex == 7 then 
		rarity = "Heirloom"
	end

	return rarity
end

local testName = string.format("%s\n\n", "**** BEGIN SLOT TESTS ****")
mf:postMsg( testName )

-----------------------------------------------------------------------------------------
--                      SLOT CLASS TESTS
--
--	NOTE:	The Slot constructor is always and only called by valid Bag object. This means
--			that we do not have to check the validity of the bagId in the slot
--			constructor.
-----------------------------------------------------------------------------------------
-- Check that the correct error message is returned when an invalide bag Id is supplied.

local result = nil
local bagId = 1
local Id = 1
local invalidSlotId = 52
local invalidBagId = 5
local slot = nil
local msg = nil

-- create a single slot object
slot = Slot( bagId, Id )
result = slot:getResult()
if result[1] ~= STATUS_SUCCESS then	
	E:postResult( result )
	return
end

msg = string.format("SUCCESS: Single Slot object created\n")
mf:postMsg( msg )

-- create all the slots of bag 4
bagId = 0
local numSlots = GetContainerNumSlots(bagId)
for Id = 1, numSlots do
	slot = Slot(bagId, Id )
	result = slot:getResult()
	if result[1] ~= STATUS_SUCCESS then
		E:postResult( result )
		return
	end
end

msg = string.format("SUCCESS: Created %d slots\n", numSlots )
mf:postMsg(msg)

slot = Slot(5, Id )
result = slot:getResult()
if result[1] ~= STATUS_SUCCESS then
	msg = string.format("SUCCESS: Slot creation failed - bagId out of range\n")
	mf:postMsg(msg)
else
	E:postResult( result )
	return
end

slot = Slot(bagId, 57 )
result = slot:getResult()
if result[1] ~= STATUS_SUCCESS then
	msg = string.format("SUCCESS: Slot creation failed - slotId out of range\n")
	mf:postMsg(msg)
else
	E:postResult( result )
	return
end

slot = Slot("1", Id )
result = slot:getResult()
if result[1] ~= STATUS_SUCCESS then
	msg = string.format("SUCCESS: Slot creation failed - bagId wrong type\n")
	mf:postMsg(msg)
else
	E:postResult( result )
	return
end

slot = Slot(bagId, "1" )
result = slot:getResult()
if result[1] ~= STATUS_SUCCESS then
	msg = string.format("SUCCESS: Slot creation failed - Id wrong type\n")
	mf:postMsg(msg)
else
	E:postResult( result )
	return
end

mf:postMsg( string.format("\n-- Testing slot query methods\n\n"))

--------------------------------------------------------------------
-- Test the slot query services
--------------------------------------------------------------------

--	Create the slot objects for bagId = 1
bagId = 4
local numSlots = GetContainerNumSlots(bagId)
local slots = {}
for Id = 1, numSlots do
	slots[Id] = Slot(bagId, Id )
	result = slots[Id]:getResult()
	if result[1] ~= STATUS_SUCCESS then
		E:postResult( result )
		return
	end
end

-- query each of the bag's slots for item(s)
local totalCopper = 0
for Id = 1, numSlots do
	local slot = slots[Id]
	local itemCount = slot:getItemCount()
	local isEmpty = slot:isEmpty()

	-- test for inconsistent states: 
	if itemCount > 0 and isEmpty == true then
		result = errors:setErrorResult(L["ERROR_INCONSISTENT_STATE"], debugstack() )
		E:postResult( result )
		return
	end
	if itemCount == 0 and isEmpty == false then
		result = errors:setErrorResult(L["ERROR_INCONSISTENT_STATE"], debugstack() )
		E:postResult( result )
		return
	end

	-- sales price of the slot's contents

	if 	itemCount > 0 then 
		local rarity = getRarityColor( slot:getItemRarity() )
		local salesPrice = slot:getSalesPriceOfItems()
		totalCopper = totalCopper + salesPrice

        local str0 = string.format("Item Descriptor for %s, Item Id is %d:", slot:getItemLink(), slot:getItemId() )
		local str1 = string.format("   Number of Items %d, (value = %d copper)", itemCount, salesPrice )
		local str2 = string.format("   Is locked? %s, Quality: %s", tostring( slot:isItemLocked()), rarity )
		local str3 = string.format("   Is Readable? %s, Is Lootable? %s", tostring(slot:isItemReadable()),tostring(slot:isItemLootable()))
		local str4 = string.format("   Is Filtered? %s, Of No Value? %s", tostring(slot:isItemFiltered()), tostring(slot:isItemOfNoValue()))

		msg = string.format("\n%s\n%s\n%s\n%s\n%s\n", str0, str1, str2, str3, str4 )
		mf:postMsg( msg )
	end
end
msg = string.format("\nTotal Copper: %d\n", totalCopper )
mf:postMsg( msg )


local endTestMsg = string.format("\n%s\n", "**** END SLOT TESTS ****")
mf:postMsg( endTestMsg )
