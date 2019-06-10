--------------------------------------------------------------------------------------
--
-- BagTests.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 29 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.BagTests = {}
bagTests = MTP.BagTests

local L = MTP.L
local E = errors

local testName = string.format("%s\n\n", "**** BEGIN BAG TESTS ****")
mf:postMsg( testName )

--                      *** ERROR TESTS *****
local result = SUCCESSFUL_RESULT
for bagNumber = 0, 4 do			-- bag slots 0,1,2,3 contain valid bags
	local b = Bag( bagNumber )
    result = b:getResult()
    if result[1] ~= STATUS_SUCCESS then
		mf:postMsg( string.format("TEST 1: Normal Creation Failed\n"))
	end
	if b:bagName() == nil then
		mf:postMsg(string.format("bag at slot %d Unoccupied\n", bagNumber ))
	else
		mf:postMsg(string.format("bag at slot %d %s\n", bagNumber, b:bagName()))
	end
end
mf:postMsg( string.format("TEST 1: Normal Creation Successful\n"))

local result =STATUS_SUCCESSFUL_RESULT
bagNumber = 5
local b = Bag( bagNumber )		-- bag number is out-of-range
result = b:getResult()
if result[1] ~= STATUS_SUCCESS then
	mf:postMsg( string.format("TEST 2: Successful: [%s]\n", result[2]))
else
	mf:postMsg( string.format("TEST 2: Failed: [%s]\n", result[2]))
end

local result =STATUS_SUCCESSFUL_RESULT
local b = Bag()						-- Required bag number missing
result = b:getResult()
if result[1] ~= STATUS_SUCCESS then
	mf:postMsg( string.format("TEST 3: Successful: [%s]\n", result[2]))
else
	mf:postMsg( string.format("TEST 3: Failed: [%s]\n", result[2]))
end

local result =STATUS_SUCCESSFUL_RESULT
bagNumber = "1"					-- bagNumber is non-numeric
local b = Bag( bagNumber )
result = b:getResult()
if result[1] ~= STATUS_SUCCESS then
	mf:postMsg( string.format("TEST 4: Successful: [%s]\n", result[2]))
else
	mf:postMsg( string.format("TEST 4: Failed: [%s]\n", result[2]))
end

b = Bag(1)
result = b:getResult()
if result[1] ~= STATUS_SUCCESS then
	E:postResult( result )
end

mf:postMsg(string.format("The %s in slot %d is a %s bag\n", b:bagName(), b:getSlotId(), b:bagType() ))

local endTestMsg = string.format("\n%s\n", "**** END BAG TESTS ****")
mf:postMsg( endTestMsg )
