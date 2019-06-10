--------------------------------------------------------------------------------------

-- UnitTests.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 29 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.UnitTests = {}
unit = MTP.UnitTests

---------------------------------------------------------------------------------------
--                      CONTAINER CLASS TESTS
---------------------------------------------------------------------------------------

DEFAULT_CHAT_FRAME:AddMessage("************************* CONTAINER TESTS ***********************")

local c = Container()
local result = c:checkResult()
if result[1] == FAILURE then
    postErrorMsg( result )
    return
end

c:print()

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

-----------------------------------------------------------------------------------------
--                      SLOT CLASS TESTS
-----------------------------------------------------------------------------------------
--                      Error in input Bag Number
local result = DEFAULT_RESULT
local bagNum = "1"
local slot = Slot(bagNum, 1)
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local bagNum = -1
local slot = Slot(bagNum, 1)
result = slot:checkResult()
if result == nil then
    emf.postErrorMsg( result )
end
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local slot = Slot()
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local bagNum = 4
local slot = Slot(bagNum)
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local bagNum = 4
local slotIndex = "1"
local slot = Slot(bagNum, slotIndex )
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local bagNum = 4
local slotIndex = 85
local slot = Slot(bagNum, slotIndex )
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local bagNum = 4
local slotIndex = 0
local slot = Slot(bagNum, slotIndex )
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end

local bagNum = 4
local slotIndex = 85
local slot = Slot()
result = slot:checkResult()
if result[1] ~= SUCCESS then
    emf.postErrorMsg( result )
end
 
for bagNum = 1, 4 do
    local numSlots = GetContainerNumSlots( bagNum )
    for slotIndex = 1, numSlots do
        local slot = Slot(bagNum, slotIndex)
        result = slot:checkResult()
        if result[1] == FAILURE then
            emf.postErrorMsg( result )
            return
        end

        local itemCount = slot:getItemCount()
        if itemCount > 0 then
            slot:dump()
        end
    end
end