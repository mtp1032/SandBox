--------------------------------------------------------------------------------------
-- CombatLog.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 January, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.CombatLog = {}
log = MTP.CombatLog
local L = MTP.L
local P = errors

local combatLog = nil

--                      Indices into an eventStats table
--
--      For further into see this URL: https://wow.gamepedia.com/COMBAT_LOG_EVENT
--
--                      These are indices into the stats table returned by the Combat log event
EVENT_TIMESTAMP       = 1 
EVENT_TYPE      	  = 2 	-- Subevent
EVENT_HIDECASTER      = 3
EVENT_SOURCEGUID      = 4 
EVENT_SOURCENAME      = 5 
EVENT_SOURCEFLAGS     = 6 
EVENT_SOURCERAIDFLAGS = 7 
EVENT_DESTGUID        = 8 
EVENT_DESTNAME        = 9 
EVENT_DESTFLAGS       = 10 
EVENT_DESTRAIDFLAGS   = 11

-- Used for SPELL and SPELL_PERIODIC prefixes. 
-- For the SWING prefix these events these are nil
EVENT_SPELLID         = 12 
EVENT_SPELLNAME       = 13 
EVENT_SPELLSCHOOL     = 14

-- These indices are determined by the suffix.
EVENT_AMOUNT          = 15 	-- Amount for _DAMAGE, _HEAL, _ENERGIZE, _DRAIN, and _LEECH Events
EVENT_OVERKILL        = 16 
EVENT_SCHOOL          = 17
EVENT_RESISTED        = 18 
EVENT_BLOCKED         = 19 
EVENT_ABSORBED        = 20 
EVENT_CRITICAL        = 21
EVENT_GLANCING        = 22 
EVENT_CRUSHING        = 23

local COMBAT_EVENT_COUNT 	= 0
local COMBAT_START_TIME 	= 0		-- Timestamp of the player's first cast
local COMBAT_END_TIME 		= 0		-- Timestamp of the player's latest or last cast
local COLLECT_EVENT_DATA 	= true
local UNIT_PET_EVENT_COUNT	= 0

local PLAYER_NAME 		= 1
local PLAYER_GUID 		= 2
local PLAYER_PET_GUID	= 3

local playerName = nil
local playerClass = nil
local playerGuid = nil
local playerPetGuid = nil

local MINDBENDER_TALENT_TAKEN = 10

local shadowPet = "Shadowfiend"

-- return wheter the guid represents a 'pet', 'player', or 'creature'... nil if none
-- of these
local function getUnitType( guid )
	local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
	local unit = string.lower( unitType)
	if unit ~= "pet" then 				-- it's not a pet
		if unit ~= "player" then 		-- it's not a player
			if unit ~= "creature" then	-- it's not a creature (Priest pet)
				return nil
			end
		end
	end
	return unitType
end

-- Only called when PLAYER_ENTERING_WORLD fires or log:resetStats() is called
local function setPlayerInfo()

	playerGuid = UnitGUID("Player")
	playerClass, _, _, _, _, playerName = GetPlayerInfoByGUID( playerGuid )
	
	if playerClass == "Warlock" or playerClass == "Mage" then
		playerPetGuid = UnitGUID("Pet")
	end

	if playerClass == "Priest" then
		playerPetGuid = nil
		-- 3rd spec, 6th row, 2 talent
		local talent = { GetTalentInfoBySpecialization( 3, 6, 2 )}
		if talent[MINDBENDER_TALENT_TAKEN] then
			shadowPet = "Mindbender"
		else
			shadowPet = "Shadowfiend"
		end
	end
end

local PowerTypes = {		-- use see https://wow.gamepedia.com/World_of_Warcraft_API#Unit_Functions
	[0] = "Mana",			--		UnitPower("unit"[,type]) - Returns current power of the specified unit 
	[1] = "Rage",			-- 		UnitPowerMax("unit"[,type]) - Returns max power of the specified unit
	[2] = "Focus",			--		UnitPowerType("unit") - Returns a number corresponding to the power type
	[3] = "Energy",
	[4] = "Combo Points",
	[5] = "Runes",
	[6] = "Runic Power",
	[7] = "Soul Shards",
	[8] = "Lunar Power",
	[9] = "Holy Power",
	[10] = "Alternate",
	[11] = "Maelstrom",
	[12] = "Chi",
	[13] = "Insanity",
	[14] = "Obsolte",
	[15] = "Obsolete2",
	[16] = "Arcane Charges",
	[17] = "Fury",
	[18] = "Pain",
}
function timeStamp()
	return debugprofilestop() / 1000
end
-- sets COLLECT_EVENT_DATA to false (not collecting)
local function stopCollecting()
	if COLLECT_EVENT_DATA == false then		-- it's already not collecting data so just return
		return
	else -- else COLLECT_EVENT_DATA is true and must be stopped
		COLLECT_EVENT_DATA = false
		COMBAT_END_TIME = 	timeStamp() - COMBAT_START_TIME
		local stopStr = string.format("[%.03f] *************** Logging stopped ***************\n", COMBAT_END_TIME )
		log:postEntry( stopStr )
	end
end
-- sets COLLECT_EVENT_DATA to true (collecting is enabled)
local function resumeCollecting()
	if COLLECT_EVENT_DATA == true then	-- it's already collecting data so just return
		return
	else -- COLLECT_EVENT_DATA is true and must be stopped
		COLLECT_EVENT_DATA = true
		COMBAT_START_TIME = timeStamp() - COMBAT_START_TIME
		local resumeStr = string.format("[%.03f] *************** Logging resumed ***************\n", COMBAT_START_TIME )
		log:postEntry( resumeStr )
	end
end
function log:dumpEvent( stats, eventType )

	if eventType ~= nil then
		if stats[EVENT_TYPE] ~= eventType then
			P:dbg(debugstack(), "******* OOPS! We are not supposed to be here? *******")
			return
		end
	else
		eventType = stats[EVENT_TYPE]
	end

	local s13 = tostring(stats[13])
	local s14 = tostring(stats[14])
	local s15 = tostring(stats[15])
	local s16 = tostring(stats[16])
	local s17 = tostring(stats[17])
	local s18 = tostring(stats[18])

	if s13 ~= nil then s13 = tostring( stats[13] ) else s13 = "N/A" end
	if s14 ~= nil then s14 = tostring( stats[14] ) else s14 = "N/A" end
	if s15 ~= nil then s15 = tostring( stats[15] ) else s15 = "N/A" end
	if s16 ~= nil then s16 = tostring( stats[16] ) else	s16 = "N/A" end
	if s17 ~= nil then s17 = tostring( stats[17] ) else s17 = "N/A" end
	if s18 ~= nil then s18 = tostring( stats[18] ) else s18 = "N/A" end

	local sourceUnitType = getUnitType( stats[EVENT_SOURCEGUID] )
	local powerType, powerName = UnitPowerType( sourceUnitType )

	local spellName = string.upper( stats[EVENT_SPELLNAME])

	local sourceName = stats[EVENT_SOURCENAME]
	local sourceGuid = stats[EVENT_SOURCEGUID]
	local destName = stats[EVENT_DESTNAME]
	local destGuid = stats[EVENT_DESTGUID]
	local destGuid = stats[EVENT_DESTGUID]

	local firstLine 	= string.format("%s (by %s)\n", eventType, sourceUnitType )
	local secondLine 	= string.format("SOURCE NAME %s, SOURCE GUID %s\n", sourceName, sourceGuid )
	local thirdLine 	= string.format("TARGET NAME %s, TARGET GUID %s\n", destName, destGuid )
	local loadLine 		= "No Load"

	if eventType == "SPELL_SUMMON" then
		loadLine = string.format("%s: Damage Done %s, Overkill %s, Resisted %s\n", spellName, s15, s16, s18)
	end

	if eventType == "SWING_DAMAGE" then
		loadLine = string.format("MELEE: Damage Done %s, Overkill %s, Resisted %s\n", s15, s16, s18)
	end
	if eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
		loadLine = string.format("%s: Damage Done %s, Overkill %s, Resisted %s\n", spellName, s15, s16, s18)
	end
	if eventType == "SPELL_MISSED" then
		loadLine = string.format("%s: Type of miss %s, Amount Missed %s\n", spellName, s15, s17)
	end
	if eventType == "SPELL_HEAL" then
		loadLine = string.format("%s: Amount healed %s, Overhealed %s, Absorbed %s\n",spellName, s15, s16, s17 )
	end
	if eventType == "SPELL_ENERGIZE" then
		if stats[EVENT_SPELLNAME] == "Agony" then
			powerName = "Soul Shard(s)"
		end
		loadLine = string.format("%s: Amount %s, Over energized %s, Resource %s\n", spellName, s15, s16, powerName  )
	end
	if eventType == "SPELL_DRAIN" or eventType == "SPELL_LEECH" then
		loadLine = string.format("%s: Amount %s, Resource %s\n", spellName, s15, powerName  )
	end
	if eventType == "SPELL_AURA_APPLIED" then
		loadLine = string.format("%s: Aura Type %s, Amount applied %s\n", spellName, s15, s16)
	end
	if eventType == "SPELL_AURA_REMOVED" then
		loadLine = string.format("%s: Aura Type %s, Amount removed %s\n", spellName, s15, s16)
	end
	if eventType == "SPELL_AURA_APPLIED_DOSE" then
		loadLine = string.format("%s: Aura Type %s, Amount applied %s\n", spellName, s15, s16)
	end
	if eventType == "SPELL_AURA_REMOVED_DOSE" then
		loadLine = string.format("%s: Aura Type %s, Amount removed %s\n", spellName, s15, s16)
	end
	if eventType == "SPELL_AURA_REFRESHED" then
		loadLine = string.format("%s: Aura Type %s, Amount refreshed %s\n", spellName, s15, s16)
	end
		
	log:postEntry(string.format(" %s %s %s %s\n", firstLine, secondLine, thirdLine, loadLine ))
end
--********************************************************************************
--						PUBLIC / EXPORTED METHODS
--********************************************************************************
-- called by the functions in the class modules
function log:getTotalCombatTime()
	return COMBAT_END_TIME
end
function log:postEntry( logEntry )
	combatLog.Text:Insert( logEntry )
end
function log:resetStats()
	COMBAT_START_TIME = 0
	COMBAT_END_TIME = 0
	COMBAT_EVENT_COUNT = 0
	COLLECT_EVENT_DATA = true

	-- need to re-initialize the player data.
	-- because reset has the same semantics as
	-- a reloadUI
	setPlayerInfo()
end

--********************************************************************************
--						SLASH COMMANDS
--********************************************************************************
local function clearText()
	if combatLog == nil then
		return
	end
	combatLog.Text:EnableMouse( false )    
	combatLog.Text:EnableKeyboard( false )   
	combatLog.Text:SetText("") 
	combatLog.Text:ClearFocus()
end
local function hideMeter()
	if combatLog == nil then
		return
	end

	if combatLog:IsVisible() == true then
		combatLog:Hide()
	end
end
local function showMeter()
	if combatLog == nil then
		return
	end
	if combatLog:IsVisible() == false then
		combatLog:Show()
	end
end
local function printHelp()

	local titleStr = string.format("To start the combat logger just cast a spell\n\n")
	local str1 = string.format("USAGE:\n")
	local str2 = string.format(" /sb help or %s  - Print this message\n", "?")
	local str3 = string.format(" /sb show        - Show the log and its entries\n")
	local str4 = string.format(" /sb hide        - Hide hide the log and its entries (does not erase them)\n")
	local str5 = string.format(" /sb report      - Clears text and writes summary report\n")
	local str6 = string.format(" /sb clear       - Erases all log entries, does not erase stats\n")
	local str7 = string.format(" /sb reset       - Erases all log entries and clears stats\n")
	local str8 = string.format(" /sb toggle      - Toggles the the SandBox Menu Frame\n")
	local str9 = string.format(" /sb stop        - Stop collecting combat data\n")
	local str10 = string.format(" /sb resume      - Resume collecting combat data\n")

	local str = string.format("%s%s%s%s%s%s%s%s%s%s%s",  titleStr, str1,str2,
																		str3,str4,str5,
																		str6,str7,str8,
																		str9,str10)
	log:postEntry( str )
	DEFAULT_CHAT_FRAME:AddMessage( str )
end
SLASH_SANDBOX1 = "/sb"
SLASH_SANDBOX2 = "/sbox"
SLASH_SANDBOX3 = "/sandbox"
SlashCmdList["SANDBOX"] = function( msg )

	local prefix = string.format("\n[INFO] %s: ", msg )

	local errorOption 		= prefix.."Unknown or unsupported option"
	local errorClass 		= prefix.."Unknown or unsupported class"
	local errorLog 			= prefix.."Log not running"
	local errorUnsupported 	= prefix.."Option currently not implemented"

	if 	msg == nil or 
		msg == '' or
		msg == "help" or
		msg == "h" or 
		msg == "?" then
			printHelp()
			return
	end
	if combatLog == nil then
		message( errorLog )
		return
	end

	msg = strlower( msg )

	if msg == "toggle" then
		message( errorUnsupported )
		return
	end
	
	if msg == "hide" then
		hideMeter()
		return
	end
	if msg == "show" then
		showMeter()
		return
	end
	if msg == "stop" then
		stopCollecting() -- set COLLECT_EVENT_DATA to be TRUE
		return
	end
	if msg == "resume" then
		resumeCollecting() -- set COLLECT_EVENT_DATA to be FALSE
		return
	end
	if msg == "report" then
		if playerClass == "Priest" then
			priest:reportEventSummaries()
		elseif playerClass == "Warlock" then
			lock:reportEventSummaries()
		elseif playerClass == "Mage" then
			mage:reportEventSummaries()
		else
			message( errorClass )
		end
		return
	end
	if msg == "clear" then
		clearText()
		return
	end
	if msg == "reset" then
		priest:resetStats()
		lock:resetStats()
		return
	end	
	message( errorOption )
end
-- **************************************************************************
-- 		HANDLE EVENT: Called when the COMBAT_LOG_EVENTS_UNFILTERED is received
--
--	Examines the event status block ('stats') and determines which class parser
--	to call. At the moment, this service does no other filtering of the event,
--  but may elect to do so later.
-- **************************************************************************
local function handleEvent(self, stats )
	local logEntry = nil
	
	if playerClass == "Priest" then
		logEntry = priest:getLogEntry( stats )

	elseif playerClass == "Warlock" or stats[EVENT_SOURCEGUID] == petGuid then
		logEntry = lock:getLogEntry( stats )
	
	elseif playerClass == "Mage" or stats[EVENT_SOURCEGUID] == petGuid then
		logEntry = mage:parseCombatEvents(stats)
	else
		return nil
	end

	return logEntry
end
--********************************************************************************
--						CREATES THE EVENT HANDLING FRAME AND
--						REGISTERS ITS INTEREST IN THE THREE
--						EVENTS (SEE CODE)
--********************************************************************************
local eventFrame = CreateFrame("Frame" )
	eventFrame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED") 
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("UNIT_PET")
	eventFrame:SetScript("OnEvent", 
	function( self, event, ... )
--********************************************************************************
-- 						HANDLE PLAYER'S PET ENTERING THE WORLD
--	This event fires when a player...
--		switches to a different pet,
--		logs in with an existing pet
--		summons a pet
--		reloads the UI
--	Tested with a Warlock and a Hunter
--	The event DOES NOT fire when a priest summons a Shadowfiend
--	or a Mindbender
--********************************************************************************
	if event == "UNIT_PET" then
		playerPetGuid = UnitGUID("Pet")
		return
	end
--********************************************************************************
--						HANDLE 'PLAYER_ENTERING_WORLD;
--		Immediately unregister because we only need to handle one of these events
--		Event is fired on reloadUI as well following logging in.
--********************************************************************************
	if event == "PLAYER_ENTERING_WORLD" then

		if combatLog == nil then
			combatLog = createCombatLog() -- see CombatLogDisplay.lua
		end

		setPlayerInfo()

		if playerClass == "Priest" then
			local talentTaken = 10
			local mb = { GetTalentInfoBySpecialization( 3, 6, 2 )}
			if mb[talentTaken] then
				shadowPet = "Mindbender"
			end
		end

		eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		return
	end	
--********************************************************************************
--						HANDLE 'COMBAT_LOG_EVENT_UNFILTERED'
--********************************************************************************
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local stats = {CombatLogGetCurrentEventInfo()}		-- BLIZZ API
		local eventType = stats[EVENT_TYPE]

		-- Only process the following events.
		if 	eventType ~= "SWING_DAMAGE" and
			eventType ~= "SPELL_DAMAGE" and 
			eventType ~= "SPELL_PERIODIC_DAMAGE" and
			eventType ~= "SPELL_AURA_APPLIED" and
			eventType ~= "SPELL_AURA_REMOVED" and
			eventType ~= "SPELL_LEECH" and
			eventType ~= "SPELL_MISSED" and
			eventType ~= "SPELL_FAILED" and
			eventType ~= "SPELL_SUMMON" and
			eventType ~= "SPELL_APPLIED_DOSE" and
			eventType ~= "SPELL_AURA_REFRESH" and
			eventType ~= "SPELL_REMOVED_DOSE" and
			eventType ~= "SPELL_ENERGIZE" then
				return
		end
	
		eventSourceGuid = stats[EVENT_SOURCEGUID]
		eventSourceName = stats[EVENT_SOURCENAME] 

--******************************** BEGIN DEBUG BLOCK *****************************************************
		if playerName ~= eventSourceName and playerPetGuid ~= eventSourceGuid then
			-- log:postEntry( string.format("%s failed the filters\n", eventSourceName ))
			return
		end
		log:postEntry( stats[SOURCE_FLAGS])
			
		log:dumpEvent( stats, eventType )
		if 1 ~= 0 then
			return
		end
--********************************** END DEBUG BLOCK *****************************************************

		if eventType == "SPELL_SUMMON" then
print("SPELL_SUMMON - 493")
			if playerName ~= stats[EVENT_SOURCENAME] then
				return
			end
			
			if playerClass == "Priest" then
				playerPetGuid = stats[EVENT_DESTGUID]
			else
				return
			end
		end

		-- Gotta fix this later. As written it won't support melee players
		if eventType == "SWING_DAMAGE" then	-- it must be a pet (e.g., Mindbender, Voidwalker, etc.,)
			if stats[EVENT_SOURCEGUID] ~= playerPetGuid then
				return
			end
		end
	
		-- The logic of this if clause is to prevent EVENTS from other player's or
		-- pets from proceeding any further. Only the player or his/her pet may
		-- pass.
		eventSourceGuid = stats[EVENT_SOURCEGUID]
		eventSourceName = stats[EVENT_SOURCENAME] 
		if playerName ~= eventSourceName and playerPetGuid ~= eventSourceGuid then
			-- log:postEntry( string.format("%s failed the filters\n", eventSourceName ))
			return
		end

		-- if this is the first event (the start of combat), then
		-- then initialize the COMBAT_START_TIME
		if COMBAT_EVENT_COUNT == 0 then
			COMBAT_EVENT_COUNT = COMBAT_EVENT_COUNT + 1
			COMBAT_START_TIME = timeStamp()
		end
				
		-- COLLECT_EVENT_DATA is set true by default. However, when the the player
		-- issues a stop collecting command through the "/sb stop" slash
		-- command, collecting is stopped. The slash command, "/sb resume", 
		-- sets COLLECT_EVENT_DATA back to true, its default condition.
		if COLLECT_EVENT_DATA == false then
			return
		end
	
		-- NOTE: The stats timestamp was modified so that it measures the number of seconds 
		-- since the beginning of combat (i.e., when COMBAT_START_TIME was initialized
		-- (see above).
		stats[EVENT_TIMESTAMP] = timeStamp() - COMBAT_START_TIME

		-- OK, we're ready. The handleEvent() method simply passes the stat block to 
		-- the various class-specific event event handlers
		local logEntry = handleEvent(self, stats )
		if logEntry ~= nil then
			log:postEntry( logEntry )
		end

		-- By updating this timestamp at the end of every event, we're guaranteed that
		-- the COMBAT_END_TIME - COMBAT_START_TIME = the total elapsed time of this
		-- encounter.
		COMBAT_END_TIME = timeStamp() - COMBAT_START_TIME
	end
end)
