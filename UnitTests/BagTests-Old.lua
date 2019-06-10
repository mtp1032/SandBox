--------------------------------------------------------------------------------------
-- UnitTestsBAGClass.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 29 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.BagTests = {}
BagTests = MTP.BagTests
-----------------------------------------------------------------------------------------
--                      BAG CLASS TESTS
-----------------------------------------------------------------------------------------
DEFAULT_CHAT_FRAME:AddMessage("************************* BAG TESTS ***********************")

--                      *** ERROR TESTS *****

local errMsg
local result = DEFAULT_RESULT
local bagNumber = 1

local successCount = 0
for bagNumber = 1, 4 do
    local b = Bag( bagNumber )
    local result = b:checkResult()
    if result[1] ~= SUCCESS then
        emf.postErrorMsg( result )
    else
        successCount = successCount + 1
    end
end
if successCount == 4 then
    errMsg = string.format("TEST 1: SUCCESS")
    print(errMsg )
end

bagNumber = 85
local b = Bag( bagNumber )
local result = b:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

bagNumber = 0
local b = Bag( bagNumber )
local result = b:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
else
    print("TEST 3: SUCCESS")
end

b = Bag()
local result = b:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

bagNumber = "1"
local b = Bag( bagNumber )
local result = b:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

--              *** SEMANTIC TESTS ***
result = DEFAULT_RESULT
local errMsg

for bagNumber = 0, 4 do
    local b = Bag( bagNumber)
    result = b:checkResult()
    if result[1] ~= SUCCESS then
        emf.postErrorMsg( result )
    end

    local s1 = string.format("%s %d is of type %s\n", b:getName(), b:getBagNumber(), b:getKind() )
    local s2 = string.format("%s has %d total slots and %d free slots", b:getName(), b:getTotalSlots(), b:getFreeSlots() )
    print( s1 )   
    print( s2 )                
end
