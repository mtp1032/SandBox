--------------------------------------------------------------------------------------
-- Core.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 8 February, 2019  - Copied from Sandbox.lua

local ADDON_C_NAME, MTP = ...

MTP.Core = {}
core = MTP.Core

local L = MTP.L


-----------------------------------------------------------------------------------------------------------
--                      The infoTable
-----------------------------------------------------------------------------------------------------------

--                      Indices into the infoTable table
local VERSION = 1
local BUILD_NUMBER = 2
local BUILD_DATE = 3
local ADDON_VERSION = 4
local infoTable = { GetBuildInfo() }

------------------------------------------------------------------------------------------------------------
--                      Game/Build/AddOn Info (from Blizzard's GetBuildInfo()) - see above
------------------------------------------------------------------------------------------------------------
function core:getAddonName()
    return ADDON_C_NAME
end
function core:getGameVersion()           -- e.g., 8.1.0
    return infoTable[VERSION]
end
function core:getGameBuildNumber()       -- eg., 28833
    return infoTable[BUILD_NUMBER]
end
function core:getBuildDate()             -- e.g., Dec 19 2018
    return infoTable[BUILD_DATE]
end
function core:getAddonVersion()          -- e.g., 80100
    return infoTable[ADDON_VERSION]
end

function core:isFileLoaded()
    return true
end

function core:isClassic()
    local isClassic = false
    if infoTable[ADDON_VERSION] ~= "80100" then
        isClassic = true
    end

    return isClassic
end

--****************************************************************************************
--                          GET INFORMATION ABOUT THE PLAYER
--                          EXECUTING THIS INSTANCE
--****************************************************************************************
local PLAYER_NAME 		= 1
local PLAYER_CLASS 		= 2
local PLAYER_GUID 		= 3
local PLAYER_PET_GUID	= 4
-- local PLAYER_PET_GUID 	= 5

local playerName = nil
local playerClass = nil
local playerGuid = nil
local playerPetGuid = nil
-- local petGuid = nil
--                          EXPORT THIS FUNCTION
-- name = GetUnitName("unit", showServerName)
-- guid = UnitGUID("unit")
function core:getPlayerInfo( unit )

    if unit == nil then
        unit = "Player"
    end

    playerGuid = UnitGUID( unit)
    playerClass, _, _, _, _, playerName  = GetPlayerInfoByGUID( playerGuid ) -- BLIZZ

    return  playerName, playerClass, playerGuid, playerPetGuid
end
function core:setPlayerPetGuid( guid )
    playerPetGuid = guid
end
function core:getPlayerPetGuid()
    return playerPetGuid
end

------------------------------------------------------------------------------------------
--                      Tests
------------------------------------------------------------------------------------------
-- local s1 = mtp:getGameVersion()
-- local s2 = core:getGameBuildNumber()
-- local s3 = core:getBuildDate()
-- local s4 = core:getAddonVersion()

-- local s = string.format("Game Version = %s, Build Number = %s, Date = %s,\n AddOn Name and Version = %s:TOC = %d", 
--                        core:getGameVersion(), 
--                        core:getGameBuildNumber(), 
--                        core: getBuildDate(), 
--                        core:getAddonName(),
--                        core:getAddonVersion() )
-- DEFAULT_CHAT_FRAME:AddMessage( s )

print ("Core loaded")