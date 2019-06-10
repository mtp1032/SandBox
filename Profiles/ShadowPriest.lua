--------------------------------------------------------------------------------------
-- ShadowPriest.lua
-- AUTHOR: Michael peterson
-- ORIGINAL DATE: 15 January, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.ShadowPriest= {}
priest = MTP.ShadowPriest
local L = MTP.L
local P = errors

local accumulatedDmg = 0
local accumulatedCritDmg = 0
local accumulatedCasts = 0

local TALENT_ID_MINDBENDER = 19769

-- 						INDICES INTO THE SPELL INFO TABLE 
local INFO_SPELL_NAME 	= 1
local INFO_SPELL_ID 	= 2
local INFO_CAST_TIME 	= 3
local INFO_START_TIME 	= 4
local INFO_COOLDOWN 	= 5
local INFO_IS_ENABLED 	= 6
local INFO_MOD_RATE 	= 7

--						THE SPELL INFO TABLES
--	All elements are numbers
local vampiricTouchInfo 	= {nil, 0, 0, 0, 0, 0, 0}
local apparitionInfo		= {nil, 0, 0, 0, 0, 0, 0}
local shadowWordPainInfo 	= {nil, 0, 0, 0, 0, 0, 0}
local shadowWordVoidInfo 	= {nil, 0, 0, 0, 0, 0, 0}
local mindBlastInfo 		= {nil, 0, 0, 0, 0, 0, 0} 					
local mindFlayInfo 			= {nil, 0, 0, 0, 0, 0, 0} 					
local mindSearInfo 			= {nil, 0, 0, 0, 0, 0, 0} 
local darkVoidInfo 			= {nil, 0, 0, 0, 0, 0, 0} 
local shadowCrashInfo		= {nil, 0, 0, 0, 0, 0, 0} 
local darkAscensionInfo		= {nil, 0, 0, 0, 0, 0, 0} 
local shadowMendInfo		= {nil, 0, 0, 0, 0, 0, 0} 
local voidEruptionInfo  	= {nil, 0, 0, 0, 0, 0, 0}
local voidBoltInfo          = {nil, 0, 0, 0, 0, 0, 0} 
local voidTorrentInfo       = {nil, 0, 0, 0, 0, 0, 0} 
local mindBombInfo       	= {nil, 0, 0, 0, 0, 0, 0} 
local shadowWordDeathInfo   = {nil, 0, 0, 0, 0, 0, 0}
local apparitionInfo        = {nil, 0, 0, 0, 0, 0, 0}
local benderInfo  			= {nil, 0, 0, 0, 0, 0, 0}		-- Mindbender
local fiendInfo				= {nil, 0, 0, 0, 0, 0, 0}		-- Shadowfiend


-- 						INDICES INTO THE SPELL DAMAGE TABLE
local DMG_TOTAL 	= 1 -- number
local DMG_CRIT 		= 2 -- number
local DMG_TIME 		= 3 -- number
local DMG_TICKS		= 4
local DMG_SPELL_ID	= 5	-- number This is set to -1 if the source is the pet
local DMG_CASTS		= DMG_TICKS

-- 						THE SPELL DAMAGE TABLES
--	All elements are values
local bender 			= {0, 0, 0, 0, 0}		-- Mindbender
local fiend 			= {0, 0, 0, 0, 0}		-- Shadowfiend
local vampiricTouch 	= {0, 0, 0, 0, 0}
local shadowWordPain	= {0, 0, 0, 0, 0}
local shadowWordVoid 	= {0, 0, 0, 0, 0}
local shadowWordDeath 	= {0, 0, 0, 0, 0}
local shadowCrash		= {0, 0, 0, 0, 0}
local mindBlast 		= {0, 0, 0, 0, 0} 					
local mindFlay 			= {0, 0, 0, 0, 0} 					
local mindSear 			= {0, 0, 0, 0, 0} 
local darkVoid 			= {0, 0, 0, 0, 0} 
local voidTorrent		= {0, 0, 0, 0, 0}
local mindBomb 			= {0, 0, 0, 0, 0} 
local darkAscension		= {0, 0, 0, 0, 0} 
local shadowMend		= {0, 0, 0, 0, 0} 
local voidEruption  	= {0, 0, 0, 0, 0}
local apparition  		= {0, 0, 0, 0, 0}
local voidBolt          = {0, 0, 0, 0, 0} 

--                      Tracks the time spent in Void Form
local beginVoidForm = 0
local endVoidForm = 0
local timeInVoidForm = 0

local function isUnitPet( guid )
	local unitIsPet = false
	local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid )
	if unitType == "Creature" then
		unitIsPet = true
	end
	return unitIsPet
end
--                      Called by CombatLogDisplay.lua when <Reset> button in pressed
function priest:resetStats()

	vampiricTouchInfo 	= {nil, 0, 0, 0, 0, 0, 0}
	apparitionInfo		= {nil, 0, 0, 0, 0, 0, 0}
	shadowWordPainInfo 	= {nil, 0, 0, 0, 0, 0, 0}
	shadowWordVoidInfo	= {nil, 0, 0, 0, 0, 0, 0}
	mindBlastInfo 		= {nil, 0, 0, 0, 0, 0, 0} 					
	mindFlayInfo 		= {nil, 0, 0, 0, 0, 0, 0} 					
	mindSearInfo 		= {nil, 0, 0, 0, 0, 0, 0} 
	darkVoidInfo 		= {nil, 0, 0, 0, 0, 0, 0} 
	shadowCrashInfo		= {nil, 0, 0, 0, 0, 0, 0} 
	darkAscensionInfo	= {nil, 0, 0, 0, 0, 0, 0} 
	shadowMendInfo		= {nil, 0, 0, 0, 0, 0, 0} 
	voidEruptionInfo  	= {nil, 0, 0, 0, 0, 0, 0}
	voidBoltInfo        = {nil, 0, 0, 0, 0, 0, 0} 
	voidTorrentInfo     = {nil, 0, 0, 0, 0, 0, 0} 
	mindBombInfo       	= {nil, 0, 0, 0, 0, 0, 0} 
	shadowWordDeathInfo = {nil, 0, 0, 0, 0, 0, 0}
	apparitionInfo      = {nil, 0, 0, 0, 0, 0, 0}
	benderInfo  		= {nil, 0, 0, 0, 0, 0, 0}		-- Mindbender
	fiendInfo			= {nil, 0, 0, 0, 0, 0, 0}		-- Shadowfiend
	
	bender 			= {0, 0, 0, 0, 0}		-- Mindbender
	fiend 			= {0, 0, 0, 0, 0}		-- Shadowfiend
	vampiricTouch 	= {0, 0, 0, 0, 0}
	shadowWordPain 	= {0, 0, 0, 0, 0}
	shadowWordVoid	= {0, 0, 0, 0, 0}
	shadowWordDeath = {0, 0, 0, 0, 0}
	shadowCrash		= {0, 0, 0, 0, 0}
	mindBlast 		= {0, 0, 0, 0, 0} 					
	mindFlay 		= {0, 0, 0, 0, 0} 					
	mindSear 		= {0, 0, 0, 0, 0} 
	darkVoid 		= {0, 0, 0, 0, 0} 
	voidTorrent		= {0, 0, 0, 0, 0}
	mindBomb 		= {0, 0, 0, 0, 0} 
	darkAscension	= {0, 0, 0, 0, 0} 
	shadowMend		= {0, 0, 0, 0, 0} 
	voidEruption  	= {0, 0, 0, 0, 0}
	apparition  	= {0, 0, 0, 0, 0}
	voidBolt        = {0, 0, 0, 0, 0} 
	
	accumulatedDmg 		= 0
	accumulatedCritDmg 	= 0
	accumulatedCasts 	= 0

	beginVoidForm 	= 0
	endVoidForm 	= 0
	timeInVoidForm 	= 0
end
local function initSpellInfo( stats )	
	local spellName, _, _, castTime, _, _, spellId = GetSpellInfo( stats[EVENT_SPELLID] )
	local startTime, coolDown, isEnabled, modRate = GetSpellCooldown( spellId )
	return spellName, spellId, castTime, startTime, coolDown, isEnabled, modRate 
end
local function accumSpellTimer( damageTable, timeStamp )
	damageTable[DMG_TIME] = damageTable[DMG_TIME] + timeStamp
end
local function voidFormStart( timeStamp )
	beginVoidForm = timeStamp
end
local function voidFormStop( timeStamp )
	endVoidForm = timeStamp
	timeInVoidForm = timeInVoidForm + (endVoidForm - beginVoidForm)
	return (endVoidForm - beginVoidForm)
end
local function getTimeInVoidForm()
	return timeInVoidForm
end
--************************************************************************************
--							COLLATES, SUMMARIZES, AND REPORTS RESULTS
--							FROM ALL SPELL DAMAGE EVENTS
--************************************************************************************
local function generateEventsSummary()
	local totalDmg = accumulatedDmg
	local totalCritDmg = accumulatedCritDmg
	local totalCombatTime = log:getTotalCombatTime()

	local percentInVoidForm = 0.000
	local vfTime = getTimeInVoidForm()
	if vfTime > 0 then
		percentInVoidForm = (vfTime/totalCombatTime)*100
	end 

	local percentCrit = 0.000
	if totalDmg > 0 then
		percentCrit = (totalCritDmg/totalDmg)*100
	end

	local totalDPS = totalDmg/totalCombatTime

	local s1 = string.format("\nSUMMARY (All Spells):\n")
	local s2 = string.format("Total Damage: %d\n", totalDmg )
	local s3 = string.format("Total Crit Damage: %d\n", totalCritDmg )
	local s4 = string.format("Percent Crit Damage: %.03f\n", percentCrit )
	local s5 = string.format("Total Combat Time (sec): %.03f\n", totalCombatTime )
	local s6 = string.format("Time in Void Form (sec): %.03f\n", vfTime )
	local s7 = string.format("Percent Time in Void Form: %.03f%%\n", percentInVoidForm )
   	local s8 = string.format("Total DPS: %.03f\n", totalDPS )
	
	local logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, s5, s6, s7, s8 )
	return logEntry
end
--************************************************************************************
--							COLLATES, SUMMARIZES, AND REPORTS RESULTS
--							OF A SINGLE SPELL
--************************************************************************************
local function generateEventSummary( spellTable )

	local totalCombatTime 	= log:getTotalCombatTime()
	local totalDPS 			= accumulatedDmg/totalCombatTime
	local totalDamage 		= accumulatedDmg
	local totalCritDamage 	= accumulatedCritDmg
	
	local totalSpellDmg 	= spellTable[DMG_TOTAL]
	local totalSpellCritDmg = spellTable[DMG_CRIT]
	local totalSpellTicks 	= spellTable[DMG_TICKS]
	local totalSpellTime 	= spellTable[DMG_TIME]

	local percentUptime = 0.0
	if totalCombatTime > 0 then
		percentUptime = (totalSpellTime/ totalCombatTime) * 100
	end

	local percentSpellCrit = 0.000
	if totalSpellDmg > 0 then
		percentSpellCrit = (totalSpellCritDmg/totalSpellDmg)*100
	end

	local spellDPS = 0.000
	if totalCombatTime > 0 then 
		spellDPS = totalSpellDmg/totalCombatTime
	end

	local contributionDPS = 0.000
	if totalDPS > 0 then
		contributionDPS = (spellDPS/totalDPS)*100
	end

	local spellName = GetSpellInfo( spellTable[DMG_SPELL_ID])
	if spellName == nil then
		spellName = "Pet"
	end

	local s1 = string.format("\nSUMMARY (%s):\n", spellName )
	local s2 = string.format("Total Damage: %d\n", totalSpellDmg)
	local s3
	if spellName ~= "Mindbender" and spellName ~= "Shadowfiend" then
		s3 = string.format("Total Melee Attacks: %d\n", totalSpellTicks)
	else
		s3 = string.format("Damage Events (casts, ticks): %d\n", totalSpellTicks)
	end
	local s4 = string.format("Total Crit Damage: %d\n", totalSpellCritDmg)
	local s5 = string.format("%% Crit Damage: %.03f%%\n", percentSpellCrit )
	local s6 = string.format("Total Combat Time: %.03f\n", totalCombatTime)
	local s7 = string.format("%% Spell Uptime: %.03f%%\n", percentUptime )
	local s8 = string.format("DPS: %.03f\n", spellDPS )
	local s9 = string.format("%% of Total DPS: %.03f%%\n", contributionDPS )

	logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, s5, s6, s7, s8, s9  )
	return logEntry	
end
--************************************************************************************
--							PRODUCES REPORT WHEN CALLED BY USER
--							TO DO SO.
--
--	Calls generateEventsSummary() - Get the sum of all combat events
--	Calls generateEventSummary() - Gets the summary of each event
--************************************************************************************
function priest:reportEventSummaries()
	
	log:postEntry( generateEventsSummary() )

	if shadowWordPain[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( shadowWordPain) )
	end
	if apparition[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( apparition) )
	end
	if shadowWordDeath[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( shadowWordDeath) )
	end
	if mindBlast[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( mindBlast ) )
	end
	if vampiricTouch[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( vampiricTouch ) )
	end
	if mindFlay[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( mindFlay ) )
	end
	if mindSear[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( mindSear ) )
	end
	if mindBomb[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( mindBomb) )
	end
	if voidEruption[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( voidEruption ) )
	end
	if shadowWordVoid[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( shadowWordVoid ) )
	end
	if voidBolt[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( voidBolt) )
	end
	if darkAscension[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( darkAscension ) )
	end
	if voidTorrent[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( voidTorrent) )
	end
	if darkVoid[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( darkVoid ) )
	end
	if bender[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( bender ) )
	end
	if fiend[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( fiend ) )
	end
	if shadowCrash[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( shadowCrash) )
	end
end
--******************************************************************************************
--							GENERATE A LOG SUFFIX
--******************************************************************************************
local function getLogSuffix( dmgTable, stats )
	local timeStamp		= stats[EVENT_TIMESTAMP]
	local spellName		= stats[EVENT_SPELLNAME]
	local eventType		= stats[EVENT_TYPE]
	local spellDamage	= stats[EVENT_AMOUNT]
	local isCrit 		= stats[EVENT_CRITICAL]
	local logSuffix		= string.format("\n")
	
	if eventType == "SWING_DAMAGE" then
		dmgTable[DMG_SPELL_ID] = -1
		local petDamage = stats[12] -- spellName

		accumSpellTimer( dmgTable, timeStamp )
		accumulatedDmg = accumulatedDmg + petDamage
		
		dmgTable[DMG_TIME] = timeStamp
		dmgTable[DMG_TICKS] = dmgTable[DMG_TICKS] + 1
		dmgTable[DMG_TOTAL] = dmgTable[DMG_TOTAL] + petDamage

		if isCrit then
			dmgTable[DMG_CRIT] = dmgTable[DMG_CRIT] + petDamage
			accumulatedCritDmg = accumulatedCritDmg + petDamage
			logSuffix = string.format(", %s (%s), %d\n", stats[EVENT_SOURCENAME],L["CRIT"], petDamage )
		else
			logSuffix = string.format(", %s, %d\n", stats[EVENT_SOURCENAME], petDamage)
		end
	end

	if eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
		dmgTable[DMG_SPELL_ID] = stats[EVENT_SPELLID]

		accumSpellTimer( dmgTable, timeStamp )
		accumulatedDmg = accumulatedDmg + spellDamage
		
		dmgTable[DMG_TIME] = timeStamp
		dmgTable[DMG_CASTS] = dmgTable[DMG_CASTS] + 1
		dmgTable[DMG_TOTAL] = dmgTable[DMG_TOTAL] + spellDamage

		if isCrit then
			dmgTable[DMG_CRIT] = dmgTable[DMG_CRIT] + spellDamage
			accumulatedCritDmg = accumulatedCritDmg + spellDamage
			logSuffix = string.format(", (%s), %d\n", L["CRIT"], spellDamage )
		else
			logSuffix = string.format(", %d\n", spellDamage)
		end
	end

	return logSuffix
end
--******************************************************************************************
--							PRODUCES A COMBAT EVENT LOG ENTRY AND
--							SENDS IT BACK TO THE EVENT HANDLER
--******************************************************************************************
function priest:getLogEntry( stats )
	local spellName = stats[EVENT_SPELLNAME]
	local timeStamp = stats[EVENT_TIMESTAMP]
	local eventType = stats[EVENT_TYPE]
	local playerName = stats[EVENT_SOURCENAME]

	-- errors:dbg(debugstack(), eventType )

	local logPrefix = string.format("%.02f, %s, %s", timeStamp, eventType, spellName )
	local logSuffix = string.format(" \n")

	if eventType == "SPELL_ENERGIZE" then
	-- see https://wow.gamepedia.com/API_UnitPowerType
		local powerType, powerName = UnitPowerType( "Player" )
		local primaryAmt = stats[15]
		logSuffix = string.format(", %s %d %s\n", L["GAINED"], primaryAmt, powerName )
		return logPrefix..logSuffix
	end

	if eventType == "SPELL_AURA_APPLIED" then
		
		if spellName == "Voidform" then
			voidFormStart( timeStamp )
		end

		if spellName == "Bargain For Power" then
			logSuffix = string.format(", Primary stat increased by 252\n", amount )
		end
		if spellName == "Champion of Azeroth" then
			logSuffix = string.format(", %s\n", "All stats increased by 10")
		end	
		if spellName == "Intellect" then
			local auraType = stats[15]
			local amount = stats[16]
			if amount ~= nil then
				logSuffix = string.format(", %s, %d\n", auraType, amount)
			else
				logSuffix = string.format(" %s\n", auraType )
			end
		end
	end
	if eventType == "SPELL_AURA_REMOVED" then
		voidFormStop( timeStamp )
	end
	--errors:dbg(debugstack() )
	if eventType == "SWING_DAMAGE" then
		--errors:dbg(debugstack())
		if stats[EVENT_SOURCENAME] == "Mindbender" or
		   stats[EVENT_SOURCENAME] == "Shadowfiend" then
			logPrefix = string.format("%.02f, %s", timeStamp, eventType )
			logSuffix =  getLogSuffix( bender, stats )
		end		
	end

	if spellName == "Shadow Word: Void" then
		logSuffix =  getLogSuffix( shadowWordVoid, stats )
	end
	if spellName == "Mind Blast" then 
		logSuffix =  getLogSuffix( mindBlast, stats )
	end
	if spellName == "Shadow Word: Pain" then
		logSuffix =  getLogSuffix( shadowWordPain, stats )
	end
	if spellName == "Shadowy Apparition" then
		logSuffix =  getLogSuffix( apparition, stats )
	end
	if spellName == "Vampiric Touch" then
		logSuffix =  getLogSuffix( vampiricTouch, stats )
	end
    if spellName == "Mind Flay" then
		logSuffix =  getLogSuffix( mindFlay, stats )
	end
	if spellName == "Mind Sear" then
		logSuffix =  getLogSuffix( mindSear, stats )
	end
	if spellName == "Dark Void" then
		logSuffix =  getLogSuffix( darkVoid, stats)
	end
	if spellName == "Void Eruption" then
		logSuffix =  getLogSuffix( voidEruption, stats )
	end
	if spellName == "Void Bolt" then
		logSuffix =  getLogSuffix( voidBolt, stats )
	end
	if spellName == "Shadow Crash" then
		logSuffix =  getLogSuffix( shadowCrash, stats  )
	end
	if spellName == "Dark Ascension" then
		logSuffix =  getLogSuffix(darkAscension, stats )
	end
	if spellName == "Shadow Mend" then
		logSuffix =  getLogSuffix( shadowMend, stats )
	end
	if spellName == "Void Torrent" then
		logSuffix =  getLogSuffix( voidTorrent, stats )
	end
	if spellName == "Mind Bomb" then
		logSuffix =  getLogSuffix( mindBomb, stats )
	end
	if spellName == "Shadow Word: Death" then
		logSuffix =  getLogSuffix( shadowWordDeath, stats )
	end
	return logPrefix..logSuffix
end
