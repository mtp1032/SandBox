--------------------------------------------------------------------------------------
-- Talents.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 30 July, 2018 

local addonName, MTP = ...
MTP.Talents = {}
talents = MTP.Talents

local L = MTP.L
local PRINT = errors.where

--	Indices into the playerTalent table.
--	see https://wow.gamepedia.com/API_GetTalentInfo for further info
local TALENT_ID		= 1
local TALENT_NAME	= 2
local TEXTURE		= 3
local IS_SELECTED	= 4
local IS_AVAILABLE	= 5
local SPELL_ID		= 6
local UNKNOWN		= 7
local ROW			= 8
local COLUMN		= 9
local UNKNOWN		= 10
local IS_KNOWN		= 11

--===================================================================================================================
--						RETURN THE ID, NAME, AND DESCRIPTION OF A PLAYER'S ACTIVE SPECIALIZATION
--	PARAMETERS
--		unit
--
--	RETURNS
--		currentSpecId
--		specName
--		description
--		nil
--===================================================================================================================
function talents:getSpecId( unit )
	local result = SUCCESSFUL_RESULT
	if unit ~= nil then
		errors.where()
		result = errors:setErrorResult(  L["ARG_NIL"], debugstack() )
		errors:postResult( result )
		return nil
	end
	if type(unit) ~= "string" then
		errors.where()
		result = errors:setErrorResult(  L["ARG_WRONGTYPE"], debugstack() )
		errors:postResult( result )
		return nil
	end
	
	local currentSpecId = GetInspectSpecialization( unit )		-- BLIZZ API
	local _, specName, description = GetSpecializationInfoByID( currentSpecId )
	return currentSpecId, specName, description
end

--===================================================================================================================
--						RETURN THE PLAYER'S ACTIVE TALENTS
--	PARAMETERS
--		specId
--		unitId
--		playerTalents
--
--	RETURNS
--		result
--===================================================================================================================
function talents:getPlayerTalents( specId, unitId, playerTalents )
	local result = SUCCESSFUL_RESULT

	-- Make sure the input parameters are properly formed.
	if playerTalents == nil then
		errors.where()
		return errors:setErrorResult(  L["ARG_NIL"], debugstack() )
	end
	if type( playerTalents ) ~= "table" then
		errors.where()
		return errors:setErrorResult( L["ARG_WRONGTYPE"], debugstack() )
	end
	if specId == nil then
		errors.where()
		return errors:setErrorResult(  L["ARG_NIL"], debugstack() )
	end
	if type( specId ) ~= "number" then
		errors.where()
		return errors:setErrorResult( L["ARG_WRONGTYPE"], debugstack() )
	end
	
	local tier = 1
	local column = 3

	-- see https://wow.gamepedia.com/API_GetTalentInfo()
	local playerTalents = { GetTalentInfo( tier, column, specId, 1, unitId ) }
	
	local isKnown = "False"
	local available = "False"
	if playerTalents[11] then isKnown = "True" end
	if playerTalents[5] then available = "True" end

	local s = string.format("%s: isKnown? %s, isAvaliable? %s", playerTalents[2], isKnown, available )
	print(s)

	return result
end
