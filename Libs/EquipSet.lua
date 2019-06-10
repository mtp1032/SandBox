--------------------------------------------------------------------------------------
-- EquipSet.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 30 July, 2018

local _, MTP = ...
MTP.EquipSet = {}
eqs = MTP.EquipSet

local playerName = GetUnitName("Player", true )

local SET_NAME = 1
local SET_TEXTURE = 2
local SET_ID = 3
local SET_IS_EQUIPPED = 4
local SET_NUM_ITEMS = 5
local SET_ITEMS_EQUIPPED = 6
local SET_ITEMS_AVAILABLE = 7
local SET_ITEMS_NOT_AVAILABLE = 8
local SET_SLOTS_IGNORED = 9

-----------------------------------------------------------------------------------------------
--                      returns the number of equipment sets configured by the player
-----------------------------------------------------------------------------------------------
function eqs.getNumEquipmentSets()
    return C_EquipmentSet.GetNumEquipmentSets()     -- BLIZZ API ENTRY
end

-----------------------------------------------------------------------------------------------------------
-- 						Given the equipment set name (setName) get the correspoding equipment set ID (setID)
-----------------------------------------------------------------------------------------------------------
function eqs.getEquipmentSetID( setName, setIDs ) 
	local result = DEFAULT_RESULT
	
	if utils.isEmpty(setName) == true then
 		result = errors.setErrorResult(  ARG_C_NIL, debugstack() )
 		return result
	end
	if type(setName) ~= "string" then
		result = errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
		return result
   	end
   	if setIDs == nil then
		result = errors.setErrorResult(  ARG_C_NIL, debugstack() )
		return result
	end
    if type(setIDs) ~= "table" then
		result = errors.setErrorResult(  ARG_C_WRONGTYPE, debugstack() )
		return result
	end    
	if C_EquipmentSet.GetNumEquipmentSets() == 0 then                                   -- BLIZZ API ENTRY
		result = errors.setErrorResult(  RESULT_C_NOT_FOUND, debugstack() )
		return result
    end
		
	setIDs[1] = C_EquipmentSet.GetEquipmentSetID( setName ) -- BLIZZ API ENTRY
	if setIDs[1] == nil then
		result = errors.setErrorResult(  ARG_C_INVALID, debugstack() )
		return result
    end
	return result
end

-------------------------------------------------------------------------------------------------------------
-- 						Get a table of setIDs and setNames (equipSetRefs[setID] = setName)
-------------------------------------------------------------------------------------------------------------
function eqs.getEquipmentSetRefs( equipSetRefs )
	result = DEFAULT_RESULT

	if equipSetRefs == nil then
		result = errors.setErrorResult( ARG_C_NIL, debugstack() )
		return result
	end
	if type(equipSetRefs) ~= "table" then
		result = errors.setErrorResult( ARG_C_WRONGTYPE, debugstack() )
		return result
	end
	local num = C_EquipmentSet.GetNumEquipmentSets()     -- BLIZZ API ENTRY
	if num == 0 then
		result = errors.setErrorResult( "Player has no equipment sets", debugstack())
		return result
	end	

	local equipSetIDs = C_EquipmentSet.GetEquipmentSetIDs()					-- BLIZZ API ENTRY
	for key, value in pairs( equipSetIDs ) do
		local setID = equipSetIDs[key]
		local setName  = C_EquipmentSet.GetEquipmentSetInfo( setID ) -- BLIZZ API ENTRY
		equipSetRefs[setID] = setName
	end
	return result
end
function eqs.isEquipSetValid( setName )
	local result = DEFAULT_RESULT

	local isValid = false
	local equipSetRefs = {}
	result = eqs.getEquipmentSetRefs( equipSetRefs )
	if result[1] ~= SUCCESS then
		emf.postErrorMessage(result)
	end
	for id, value in pairs( equipSetRefs ) do
		if equipSetRefs[id] == setName then
			isValid = true
		end
	end
	return isValid		
end

---------------------------------------------------------------------------------
--                      Given a set ID return the setName in the equipSetName[1]
---------------------------------------------------------------------------------
function eqs.getEquipmentSetName( setID, equipSetName )
    local result = DEFAULT_RESULT
	
	-- Standard Parameter Validity Checking
    if type( setID ) ~= "number" then
		return errors.setErrorResult( ARG_C_WRONGTYPE, debugstack() )
	end
    
    if type( equipSetName ) ~= "table" then
		return errors.setErrorResult( ARG_C_WRONGTYPE, debugstack() )
	end
    
    if C_EquipmentSet.GetNumEquipmentSets() == 0 then           -- BLIZZ API ENTRY
        return errors.setErrorResult(  ERROR_C_NO_EQUIPMENT_SETS, debugstack() )
    end
	
	-- Parameters are valid. Get the setID's corresponding setName
	local setName = C_EquipmentSet.GetEquipmentSetInfo( setID ) -- BLIZZ API ENTRY
	if setName == nil then 
		return errors.setErrorResult(SEVERITY_C_WARNING, RETURN_C_NIL, debugstack())
	end
 
    equipSetName[1] = setName  -- this works
	return result
end
---------------------------------------------------------------------------------------------------
--						Returns an equipment set descriptor
---------------------------------------------------------------------------------------------------
function eqs.getEquipmentSetDescr( setID, equipSetDescr )
    local result = DEFAULT_RESULT

	-- error checking
  	if type(equipSetDescr) ~= "table" then
		return errors.setErrorResult(  errorMsg, debugstack() )
	end

    if C_EquipmentSet.GetNumEquipmentSets() == 0 then                                   -- BLIZZ API ENTRY
        return display.postMessage(playerName.." has no equipment sets.")
    end

    -- this should never be triggered since we checked whether the player has no equipment sets
	if utils.isEmpty(setID) then
		return errors.setErrorResult( ERROR_C_NOT_FOUND, debugstack())
	end

	local setName, 
	setTexture, 
	setID, 
	isEquipped, 		-- true if all non-ignored slots in the set are currently equipped.
	numItems,			-- total items in the set 
	numEquipped, 		-- number of equipped items
	availableItems, 	-- number of items not equipped, but otherwise available (bank, bags)
	missingItems, 		-- number of items not available to this player
	ignoredSlots 		= C_EquipmentSet.GetEquipmentSetInfo( setID ) -- BLIZZ API ENTRY
	
	equipSetDescr[SET_NAME] = setName
    equipSetDescr[SET_TEXTURE] = setTexture	
    equipSetDescr[SET_ID] = setID	
    equipSetDescr[SET_IS_EQUIPPED] = isEquipped	
    equipSetDescr[SET_NUM_ITEMS] = numItems	
    equipSetDescr[SET_ITEMS_EQUIPPED] = numEquipped	
    equipSetDescr[SET_ITEMS_AVAILABLE] = availableItems	
	equipSetDescr[SET_ITEMS_NOT_AVAILABLE] = missingItems	
	equipSetDescr[SET_SLOTS_IGNORED] = ignoredSlots

	return result
end
---------------------------------------------------------------------------------------------
--                      For debugging purposes
---------------------------------------------------------------------------------------------
local DEBUG_C_ENABLED = errors.isDebugEnabled()

function eqs.isFileLoaded()
	return true
end

--**************************************** TEST 1 -----------------------------------------------------

-- NOTE: use "/sets" to get the name of the player's sets
SLASH_TESTENUM1 = "/enum"
SlashCmdList["TESTENUM"] = function( setName )
	local result = DEFAULT_RESULT

	--if setName == nil or setName == "" then
	if utils.isEmpty( setName ) == true then
		result = errors.setErrorResult(ARG_C_MISSING, debugstack() )
		emf.postErrorMsg( result )
		return
	end
	if eqs.getNumEquipmentSets() == 0 then
		result = errors.setErrorResult(ERROR_C_NO_EQUIPMENT_SETS, debugstack() )
		emf.postErrorMsg( result )
		return
	end
	if type(setName) ~= "string" then
		result = errors.setErrorResult(ARG_C_WRONGTYPE, debugstack() )
		emf.postErrorMsg( result )
		return
	end
	if eqs.isEquipSetValid( setName ) == false then
		result = errors.setErrorResult( "Input setName not found", debugstack() )
		emf.postErrorMsg( result )
		return
	end

	-- Error checking done. Now use the setName to get the corresponding setID
	setName = string.upper( setName )
	local tableSetID = {}
	result = eqs.getEquipmentSetID( setName, tableSetID )	
	if result[1] ~= SUCCESS then
		emf.postErrorMsg( result )
		return
	end
	local setID = tableSetID[1]

	-- Now use the setID to get the descriptor table for this set

	local descrTable = {}
	result = eqs.getEquipmentSetDescr( setID, descrTable )
	if result[1] ~= SUCCESS then
		emf.postErrorMsg( result )
		return
	end
	
	local setDescriptor = string.format("%s: setID %d, items equipped %d of %d items", 
										descrTable[SET_NAME], 
										descrTable[SET_ID],
										descrTable[SET_ITEMS_EQUIPPED], 
										descrTable[SET_ITEMS_AVAILABLE] )

	display.postMessage( setDescriptor )
end

SLASH_TESTSETS1 = "/sets"
SlashCmdList["TESTSETS"] = function( msg )
	local result = DEFAULT_RESULT
	local playerName = GetUnitName("Player", true )
	
	local numSets = eqs.getNumEquipmentSets()
	if numSets == 0 then
		result = errors.setErrorResult( ERROR_C_NO_EQUIPMENT_SETS, debugstack() )
		emf.postErrorMessage(result)
		return
	end

	local equipSetRefs = {}
	result = eqs.getEquipmentSetRefs( equipSetRefs )
	if result[1] ~= SUCCESS then
		errors.postErrorMessage( result )
		return
	end
	
	for setID, setName in pairs( equipSetRefs ) do
		local msgString = string.format("  setID %d, setName %s", setID, setName )
		display.postMessage( msgString )
	end
	local s = string.format("%s Equipment Sets:", playerName )
	display.postMessage( s )
end


