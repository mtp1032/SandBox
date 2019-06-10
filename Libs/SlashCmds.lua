-- SlashCmds.lua
local addonName, MTP = ... 
MTP.SlashCmds = {}
slash = MTP.SlashCmds
local L = MTP.L
local P = errors

--*****************************************************************************
-- Error Handling Tests
--*****************************************************************************
local function deepest()
    local result = errors:setErrorResult(L["ARG_NIL"], debugstack() )
    errors:postResult(result )
end
local function deeper()
    deepest()
end
local function deep()
    deeper()
end
local function stack()
    P.where()
    deep()
    P.where()
end

SLASH_STACKTRACE1 = "/stack"
SLASH_STACKTRACE2 = "/st"
SlashCmdList["STACKTRACE"] = function( msg )
     stack()
end

SLASH_ERRORHANDLER1 = "/err"
SlashCmdList["ERRORHANDLER"] = function( msg )
    local s = string.format(L["PREFIX_W_TEXT"], "A really bad bobo")
    result = errors:setErrorResult( s, debugstack() )     
    if result[1] ~= STATUS_SUCCESS then
        errors:postResult( result )
    end
end

--[[ SLASH_GETEXPANSION1 = "/expansion"
SlashCmdList["GETEXPANSION"] = function( msg )
    local Expansion = "Classic"
    if utils.isClassic() == true then
        Expansion = "BfA"
    end
    message( "Expansion is "..Expansion )
end

SLASH_INSPECTPLAYER1 = "/ins"
SlashCmdList["INSPECTPLAYER"] = function(msg)

	if (UnitPlayerControlled("target") 
    and CheckInteractDistance("target", 1) 
    and not UnitIsUnit("player", "target")) then
        InspectUnit("target")
	end	
end
 ]]
--*****************************************************************************
-- EquipSet.lua Slash Commands
--*****************************************************************************
--[[ SLASH_GETEQUIPSETS1 = "/enumsets"
SlashCmdList["GETEQUIPSETS"] = function(msg)
    
    local playerInfo = {}
	local result = player.getPlayerInfo("Player", playerInfo)
    if result[1] ~= SUCCESS then
        errors.simpleErrorHandler(result)
    end

    local playerName = playerInfo[6]
	local numSets = eqs.getNumEquipmentSets()
	if numSets == 0 then
		local str = string.format("[%s] %s has no equipment sets.", SEVERITY_C_INFO, playerName )
		message( str )
		return
	end
    
	local equipSetNameTable = {}
	local result = eqs.getEquipmentSets( equipSetNameTable )
	if result[1] ~= SUCCESS then
       errors.simpleErrorHandler(result)
	end
	-- player has one or more equipment sets. Print the equipment set names
    local msg = string.format("%s's Equipment sets:\n", playerName )
	for index, value in pairs( equipSetNameTable ) do
		local setName = value
        msg = msg.." "..setName
	end
    utils.displayInfo( msg )
end	
 ]]
--*****************************************************************************
-- Player.lua Slash Commands
--*****************************************************************************
--[[ SLASH_RESTXP1 = "/rxp"
SlashCmdList["RESTXP"] = function(msg)
    local location = string.format("%s XP:",UnitName("Player"))
	local percentXP = string.format("Current Rest XP: %u (%s)", player.getPlayerRestXP(), player.getPercentPlayerRestXP())
	local currentXP = string.format("XP to date: %u of %u", player.getPlayerCurrentXP(), player.getPlayerLevelXP())
    local displayStr = string.format("%s\n%s\n%s", location, percentXP, currentXP )
    
    --DEFAULT_CHAT_FRAME:AddMessage( displayStr )
    utils.displayInfo( displayStr )
end	


SLASH_PLAYERLOCATION1 = "/xy"
SlashCmdList["PLAYERLOCATION"] = function(msg)
	DEFAULT_CHAT_FRAME:AddMessage( format("%s",player.getPlayerLocation()))
end
 ]]
--**************************************************************
-- Utils.lua Slash Commands
--**************************************************************
