--------------------------------------------------------------------------------------
-- Player.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 30 July, 2018 

local addonName, MTP = ...
MTP.Player = {}
player = MTP.Player

local L = MTP.L
local PRINT = errors.where

function player:getPlayerCoords()
	x = 0
	y = 0	
	mapID = C_Map.GetBestMapForUnit("Player")						-- BLIZZ API ENTRY
	if (mapID) then
		position = C_Map.GetPlayerMapPosition(mapID,"Player")		-- BLIZZ API ENTRY
		x = utils.round( position.x*100, 2)
		y = utils.round( position.y*100, 2)
	end
	return x, y
end
function player:getPlayerLocation()
	x = 0
	y = 0	
	mapID = C_Map.GetBestMapForUnit("Player")						-- BLIZZ API ENTRY
	if (mapID) then
		position = C_Map.GetPlayerMapPosition(mapID,"Player")		-- BLIZZ API ENTRY
		x = utils.round( position.x*100, 2)
		y = utils.round( position.y*100, 2)
	end
	
	locationStr = string.format("[%s, %s] x = %.1f, y = %.1f",GetZoneText(),GetSubZoneText(),x, y)
	return locationStr
end
function player:getPlayerRestXP()
	return( GetXPExhaustion("Player"))								-- BLIZZ API ENTRY
end
function player:getPlayerCurrentXP()								-- BLIZZ API ENTRY
	return UnitXP("Player")
end
function player:getPlayerLevelXP()									-- BLIZZ API ENTRY
	return UnitXPMax("Player")
end

-- returns the player's rest XP as a string of the form
-- N%, e.g., 150%
function player:getPercentPlayerRestXP()
	restXP = player:getPlayerRestXP()
	totalXP = player:getPlayerLevelXP()
	fractionXP = (restXP/totalXP)*100
	fractionXP = math.floor( utils.round(fractionXP,2 ))
	return string.format("%u%s", fractionXP, "%" )
end

--						INDICES INTO THE UNIT INFO TABLE
local CLASS_NAME    = 1     -- string
local CLASS_ID      = 2     -- string
local RACE_NAME     = 3     -- string
local RACE_ID       = 4     -- string
local GENDER        = 5     -- string
local PLAYER_NAME   = 6     -- string
local REALM         = 7     -- string
local PLAYER_LEVEL  = 8     -- string
local GUID          = 9     -- string
local SPEC_ID		= 10    -- number
local SPEC_NAME		= 11
local DESCRIPTION   = 12    -- string

local unitInfo = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

function player:getUnitInfo( unit, unitInfo )

    local result = SUCCESSFUL_RESULT

    if unitInfo == nil then
        errors.where()
        return errors:setErrorResult(  L["ARG_NIL"], debugstack() )
    end
    if type( unitInfo ) ~= "table" then
        errors.where()
        return errors:setErrorResult(  L["ARG_WRONGTYPE"], debugstack() )
    end
    if unit == nil then
        errors.where()
        return errors:setErrorResult(  L["ARG_NIL"], debugstack() )
    end
    if type( unit ) ~= "string" then
        errors.where()
        return errors:setErrorResult( L["ARG_WRONGTYPE"], debugstack() )
	end
	if UnitPlayerControlled( unit ) == false then
		errors.where()
		return errors:setErrorResult(  L["UNIT_NOT_PLAYER"], debugstack() )
	end

    local guid = UnitGUID(unit)                       -- BLIZZ ENTRY API/
    if guid == nil then
        errors.where()
        return errors:setErrorResult( L["RESULT_NOT_FOUND"], debugstack() )
    end
    
	local className, classId, raceName, raceId, gender, name, realm = GetPlayerInfoByGUID(guid)	-- bLIZZ API
	local specId, specName, description = talents:getSpecId( unit )

	unitInfo = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

	unitInfo[CLASS_NAME]    = className
    unitInfo[CLASS_ID]      = classId
    unitInfo[RACE_NAME]     = raceName
    unitInfo[RACE_ID]       = raceId
    unitInfo[GENDER]        = gender
    unitInfo[PLAYER_NAME]   = name 
	unitInfo[REALM]         = realm
	unitInfo[PLAYER_LEVEL]  = tostring( UnitLevel( unit ))	-- BLIZZ API
    unitInfo[GUID]          = guid
	unitInfo[SPEC_ID]		= specId
	unitInfo[SPEC_NAME] 	= specName
	unitInfo[DESCRIPTION]  	= description 

    return result
end

function player:dumpUnitInfo( unitInfo )
    local result = SUCCESSFUL_RESULT

    if unitInfo == nil then
        return errors:setErrorResult(  L["ARG_NIL"], debugstack() )
    end
    if type( unitInfo ) ~= "table" then
		return errors:setErrorResult( L["ARG_WRONGTYPE"], debugstack() )
    end
    if unitInfo[CLASS_NAME] == nil then
        return errors:setErrorResult(  L["ARG_NOT_INITIALIZED"], debugstack() )
    end

    local s1 = string.format("%s is a level %s %s %s %s\n",  unitInfo[PLAYER_NAME], 
                                                             unitInfo[PLAYER_LEVEL],
                                                             unitInfo[RACE_NAME], 
                                                             unitInfo[SPEC_NAME], 
                                                             unitInfo[CLASS_NAME] ) 
    local s2 = string.format("\n%s\n", unitInfo[DESCRIPTION] )                                                             
    errors:postMessage( s1..s2 )
end

------------------------------------------------------------------------------------------------
--						INSPECT_READY EVENT HANDLER
------------------------------------------------------------------------------------------------
local function handleNotifyInspect( targetGuid, unitId )
	local result = SUCCESSFUL_RESULT

	if targetGuid == nil then
		errors.where()
		result = errors:setErrorResult(L["ARG_NIL"], debugstack() )
		errors:postResult( result )
		return
	end
	if type( targetGuid ) ~= "string" then
		errors.where()
		result = errors:setErrorResult(L["ARG_WRONGTYPE"], debugstack() )
		errors:postResult( result )
		return
	end
	if unitId == nil then
		errors.where()
		result = errors:setErrorResult(L["ARG_NIL"], debugstack() )
		errors:postResult( result )
		return
	end
	if type( unitId ) ~= "string" then
		errors.where()
		result = errors:setErrorResult(L["ARG_WRONGTYPE"], debugstack() )
		errors:postResult( result )
		return
	end
	if UnitPlayerControlled( unitId ) ~= true then
		errors.where()
		return errors:setErrorResult(L["UNIT_NOT_PLAYER"]), debugstack()
	end
	if CheckInteractDistance(unitId, 1) ~= 1 then
		errors.where()
		return errors:setErrorResult( L["OUT_OF_RANGE"], debugstack() )
	end

    local unitInfo = {}
    result = player:getUnitInfo( unitId, unitInfo )
	if result == STATUS_FAILURE then
		errors.where()
        errors:postResult( result )
        return
    end    
    
    -- display the results
    player:dumpUnitInfo( unitInfo )

    -- get the active talents
    playerTalents = {}
	local specId = unitInfo[SPEC_ID]
	result = talents:getPlayerTalents( specId, unitId, playerTalents )
	if result == STATUS_FAILURE then
		errors.where()
        errors:postResult( result )
        return
    end    
end

------------------------------------------------------------------------------------------------
-- 						REGISTER FOR THE INSPECT_READY EVENT
------------------------------------------------------------------------------------------------
local inspectFrame = CreateFrame("Frame" )
	inspectFrame:RegisterEvent( "INSPECT_READY")          -- fired when NotifyInspect() is called
	inspectFrame:SetScript("OnEvent", 
    function( self, event, ... )
        local targetGuid = ...;
		handleNotifyInspect( targetGuid, "Target" )
		InspectUnit( "Target")
    end)

------------------------------------------------------------------------------------------------
--                      FOR TESTING PURPOSES
-------------------------------------------------------------------------------------------------

SLASH_INFO1 = "/info"
SlashCmdList["INFO"] = function( msg )
    NotifyInspect( "Target" )
end

-- SLASH_INSPECT1 = "/ins"
-- SLASH_INSPECT2 = "/inspect"
-- SlashCmdList[INSPECT] = function( msg )

--     if (UnitPlayerControlled("target") and 
--         CheckInteractDistance("target", 1) and not 
--         UnitIsUnit("player", "target")) then
--         InspectUnit("target")
--     end	
-- end
