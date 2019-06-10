--------------------------------------------------------------------------------------
-- SandBox.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 18 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.SandBox = {}
sb = MTP.SandBox

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
function sb:getAddonName()
    return ADDON_C_NAME
end
function sb:getGameVersion()           -- e.g., 8.1.0
    return infoTable[VERSION]
end
function sb:getGameBuildNumber()       -- eg., 28833
    return infoTable[BUILD_NUMBER]
end
function sb:getBuildDate()             -- e.g., Dec 19 2018
    return infoTable[BUILD_DATE]
end
function sb:getAddonVersion()          -- e.g., 80100
    return infoTable[ADDON_VERSION]
end

function sb:isFileLoaded()
    return true
end

function sb:isClassic()
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
function sb:getPlayerInfo( unit )

    if unit == nil then
        unit = "Player"
    end

    playerGuid = UnitGUID( unit)
    playerClass, _, _, _, _, playerName  = GetPlayerInfoByGUID( playerGuid ) -- BLIZZ

    return  playerName, playerClass, playerGuid, playerPetGuid
end
function sb:setPlayerPetGuid( guid )
    playerPetGuid = guid
end
function sb:getPlayerPetGuid()
    return playerPetGuid
end

------------------------------------------------------------------------------------------
--                      Tests
------------------------------------------------------------------------------------------
-- local s1 = sb:getGameVersion()
-- local s2 = sb:getGameBuildNumber()
-- local s3 = sb:getBuildDate()
-- local s4 = sb:getAddonVersion()

-- local s = string.format("Game Version = %s, Build Number = %s, Date = %s,\n AddOn Name and Version = %s:TOC = %d", 
--                         sb:getGameVersion(), 
--                         sb:getGameBuildNumber(), 
--                         sb: getBuildDate(), 
--                         sb:getAddonName(),
--                         sb:getAddonVersion() )
-- DEFAULT_CHAT_FRAME:AddMessage( s )

