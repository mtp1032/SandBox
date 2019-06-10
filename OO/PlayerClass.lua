-- --------------------------------------------------------------------------------------
-- PlayerClass.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 5 January, 2019

local ADDON_C_NAME, MTP = ...
local L = MTP.L
local P = errors

--***************************************************************************************************
--                      PLAYER CLASS
--***************************************************************************************************
MTP.PlayerClass = {}
Player = MTP.PlayerClass

Player.__index = Player

setmetatable(Player, {
    __index = Base,                     -- Makes the inheritance work
    __call = function (cls, ...)        -- NOTE to me: 'cls' refers to the current table
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

--                      Indices into the self.playerInfo table
local CLASSNAME = 1 -- String - Localized class name, suitable for use in user interfaces.
local CLASSID   = 2 -- String - Localization-independent class ID, suitable for use as table keys.
local RACE_NAME = 3 -- String - Localized race name, suitable for use in user interfaces.
local RACEID    = 4 -- String - Localization-independent race ID, suitable for use as table keys.
local GENDER    = 5 -- String - Gender ID of the character, as a number. 2 for male, or 3 for female.
local NAME      = 6 --  String - Full name of the specified character. The realm is appended with a dash if it differs from the player's.
local REALM     = 7 -- String - Realm of the character in question. The empty string "" is returned if the specified character is from the same realm as the player.

function Player:_init( unitType )
--[[
    -- inherited from the Base class
    self.is_a
    self.result

]]    
    Base._init(self)
    self.result = {SUCCESS, nil, nil }

    if unit == nil then
        self.unitType = "Player"
    end

    if type(unitType) ~= "string" then
        self.result = errors.setErrorResult(ARG_C_INVALID, debugstack() )
        return
    end
       
    if UnitPlayerControlled(unitType) ~= true then
        self.result = errors.setErrorResult(ARG_C_INVALID.." target must be a player", debugstack() )
        self.unitType = nil
        return
    end

    self.unitType = unitType    -- see https://wow.gamepedia.com/API_TYPE_UnitId

    -- guid = UnitGUID("unit") - see https://wow.gamepedia.com/API_UnitGUID
    self.guid = UnitGUID( self.unitType )
    self.name = UnitName( unitType )

    local typeOf = {strsplit( "-", self.guid, 4)}
    if typeOf[1] ~= "Player" then
        errors.L(debugstack())
        local n = string.format("%s is not a player unit", self.name )
        self.result = errors.setErrorResult( ARG_C_INVALID.." "..n, debugstack())
        return
    end

    -- className, classId, raceName, raceId, gender, name, realm = GetPlayerInfoByGUID("guid")
    -- https://wow.gamepedia.com/API_GetPlayerInfoByGUID
    self.playerInfo = {GetPlayerInfoByGUID( self.guid )}
    if self.playerInfo == nil then
        errors.L(debugstack())
        self.result = errors.setErrorResult( ARG_C_INVALID.."Entity is not a player", debugstack())
        return
    end
      
    if self.playerInfo[CLASSNAME] == nil then
        errors.L(debugstack())
        self.result = errors.setErrorResult( ARG_C_INVALID.."Entity is not a player", debugstack())
        return
    end
end

function Player:getName()
    return self.playerInfo[NAME]
end
function Player:getResult()
    return self.result
end
function Player:unitType()
    return self.unitType
end

function Player:dump()
    local str1 = string.format("%s is a %s\n", self.playerInfo[NAME], self.unitType )
    local str2 = string.format("     %s is a %s", self.playerInfo[CLASSID], self.playerInfo[GENDER] )
    print( str1..str2 )
end

--***************************************************************************************************
--                      PRIEST CLASS
--***************************************************************************************************
MTP.PriestClass = {}
Priest = MTP.PriestClass

Priest.__index = Priest

setmetatable(Priest, {
    __index = Base,                     -- Makes the inheritance work
    __call = function (cls, ...)        -- NOTE to me: 'cls' refers to the current table
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Priest:_init( talentSpec)
    Player._init(self)              -- initialize the parent [Player] class
--[[
    self.is_a       -- inherits from Base
    self.result     -- inherits from Base

    -- inherits from Player class
    self.unitType   -- see https://wow.gamepedia.com/API_TYPE_UnitId
    self.guid       -- see https://wow.gamepedia.com/API_UnitGUID
    self.name       -- UnitName()
    self.playerInfo -- see -- https://wow.gamepedia.com/API_GetPlayerInfoByGUID

    -- What needs to be done
    (1) determine spell school from talentSpec parameter
    (2) get talentTree, i.e., self.talentTree = {}
    (3) get armor sets and calculate the priest's spell/healing power
]]    
    self.is_a = "Priest"
    self.talentSpec = talentSpec
    self.spellSchool = nil
end

-----------------------------------------------------------------------------------------------------
--                      PRIEST METHODS
-----------------------------------------------------------------------------------------------------
--[[
                        Inherits these methods from Base and Player
    Player.dump()
    Player.is_a()
    Player.unitType()
    Player:getName()
    Player:getResult()

    -- Add these services
    Priest:swapArmorSet( currentSet, replacemenSet )
]]