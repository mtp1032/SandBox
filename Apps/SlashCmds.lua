-- SlashCmds.lua
local addonName, MTP = ... 
MTP.SlashCmds = {}
slash = MTP.SlashCmds
local L = MTP.L
local P = errors

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

--  SLASH_ENABLE_DEBUG1 = "/dbg"
--  SLASH_ENABLE_DEBUG2 = "/dbgenable"
--  SLASH_ENABLE_DEBUG3 = "/enabledbg"
--  SLASH_ENABLE_DEBUG4 = "/debug"
--  SlashCmdList[ENABLE_DEBUG] = function(msg)
-- 	enableDebug()
--  end


SLASH_SELLGREY1 = "/sellgrey"
SlashCmdList["SELLGREY"] = function( msg )
	setItemQuality( QUALITY_GREY )
end
SLASH_SELLCOMMON1 = "/sellcommon"
SlashCmdList["SELLCOMMON"] = function( msg )
	setItemQuality( QUALITY_COMMON )
end