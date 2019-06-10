--------------------------------------------------------------------------------------
-- ShadowPriest.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 15 January, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.AffWarlock= {}
lock = MTP.AffWarlock
local L = MTP.L
local P = errors


-- --                      Indices into an eventStats table
-- --
-- --      For further into see this URL: https://wow.gamepedia.com/COMBAT_LOG_EVENT
-- --
-- --      These are indices into the stats table returned by the Combat log event. These
-- --       constants are already publically defined in CombatLog.lua.

local accumulatedDmg = 0
local accumulatedCritDmg = 0
local accumulatedCasts = 0

-- Track the number of times nightFallProcs
local nightFallProcs = 0

-- Track how much time is spent in Shadow Embrace
local beginShadowEmbrace = 0
local endShadowEmbrace = 0
local timeInShadowEmbrace = 0
local function shadowEmbraceStart( timeStamp )
	beginShadowEmbrace = timeStamp
end
local function shadowEmbraceStop( timeStamp )
	endShadowEmbrace = timeStamp
	timeInShadowEmbrace = timeInShadowEmbrace + (endShadowEmbrace - beginShadowEmbrace)
end
local function getTimeInShadowEmbrace()
	return timeInShadowEmbrace
end

-- Track how much time is spent in Misery
local beginMisery = 0 
local stopMisery = 0
local timeInMisery = 0
local function miseryStart( timeStamp )
	beginMisery = timeStamp
end
local function miseryStop( timeStamp )
	stopMisery = timeStamp
	timeInMisery = timeInMisery + (stopMisery - beginMisery)
end
local function getTimeInMisery()
	return timeInMisery
end

-- 						INDICES INTO THE SPELL DAMAGE TABLES
local DMG_TOTAL 	= 1 -- number
local DMG_CRIT 		= 2 -- number
local DMG_TIME 		= 3 -- number
local DMG_TICKS		= 4
local DMG_SPELL_ID	= 5	-- number This is set to -1 if the source is the pet
local DMG_CASTS		= DMG_TICKS

--						SPELL DAMAGE TABLES
local agony 	        	= {0, 0, 0, 0, 0}
local corruption 			= {0, 0, 0, 0, 0}
local shadowBolt 			= {0, 0, 0, 0, 0}
local unstableAffliction	= {0, 0, 0, 0, 0}
local siphonLife			= {0, 0, 0, 0, 0}
local darkGlare 			= {0, 0, 0, 0, 0}
local deathBolt 			= {0, 0, 0, 0, 0}
local phantom 				= {0, 0, 0, 0, 0}
local vileTaint 			= {0, 0, 0, 0, 0}
local drainSoul				= {0, 0, 0, 0, 0}
local drainLife				= {0, 0, 0, 0, 0}
local haunt					= {0, 0, 0, 0, 0}
local seed 	        		= {0, 0, 0, 0, 0}
local fireBolt				= {0, 0, 0, 0, 0}
local consumingShadows		= {0, 0, 0, 0, 0}
local lashOfPain			= {0, 0, 0, 0, 0}
local shadowBite			= {0, 0, 0, 0, 0}

local function isUnitPet( guid )
	local unitIsPet = false
	local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid )
	if unitType == "Creature" then
		unitIsPet = true
	end
	return unitIsPet
end
local function getUnitType( guid )
	local unitType, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid )
	return unitType
end

--                      Called by CombatLogDisplay.lua when <Reset> button in pressed 
function lock:resetStats()
	agony 				= {0, 0, 0, 0, 0}
	corruption 			= {0, 0, 0, 0, 0}
	shadowBolt	 		= {0, 0, 0, 0, 0}
	unstableAffliction	= {0, 0, 0, 0, 0}
	siphonLife			= {0, 0, 0, 0, 0}
	darkGlare 			= {0, 0, 0, 0, 0}
	deathBolt 			= {0, 0, 0, 0, 0}
	phantom 			= {0, 0, 0, 0, 0}
	vileTaint 			= {0, 0, 0, 0, 0}
	drainSoul			= {0, 0, 0, 0, 0}
	drainLife			= {0, 0, 0, 0, 0}
	seed 				= {0, 0, 0, 0, 0}
	haunt				= {0, 0, 0, 0, 0}
	fireBolt			= {0, 0, 0, 0, 0}
	consumingShadows	= {0, 0, 0, 0, 0}
	lashOfPain			= {0, 0, 0, 0, 0}
	shadowBite			= {0, 0, 0, 0, 0}

	accumulatedDmg = 0
	accumulatedCritDmg = 0
	accumulatedTicks = 0

	beginMisery = 0
	stopMisery = 0
	timeInMisery =0

	beginShadowEmbrace = 0
	endShadowEmbrace = 0
	timeInShadowEmbrace = 0
end
local function accumSpellTimer( dmgTable, timeStamp )
	dmgTable[DMG_TIME] = dmgTable[DMG_TIME] + timeStamp
end
--************************************************************************************
--							COLLATES, SUMMARIZES, AND REPORTS RESULTS
--							FROM ALL SPELL DAMAGE EVENTS
--************************************************************************************
local function generateEventsSummary()
	local totalDmg = accumulatedDmg
	local totalCritDmg = accumulatedCritDmg
	local totalCombatTime = log:getTotalCombatTime()

	local percentInShadowEmbrace = 0.000
	local timeInShadowEmbrace = getTimeInShadowEmbrace()
	if timeInShadowEmbrace > 0 then
		percentInShadowEmbrace = (timeInShadowEmbrace/totalCombatTime)*100
	end 

	local percentInMisery = 0
	timeInMisery = getTimeInMisery()
	if timeInMisery > 0 then
		percentInMisery = (timeInMisery/totalCombatTime)*100
	end

	local percentCrit = 0.000
	if totalDmg > 0 then
		percentCrit = (totalCritDmg/totalDmg)*100
	end

	local totalDPS = totalDmg/totalCombatTime

	local s1 = string.format("\nSUMMARY (All Spells):\n")
	local s2 = string.format("Total Damage: %d\n", totalDmg )
	local s3 = string.format("Total Crit Damage: %d\n", totalCritDmg )
	local s4 = string.format("%% of Total Crit Damage: %.02f%%\n", percentCrit )
	local s5 = string.format("Total Combat Time (sec): %.02f\n", totalCombatTime )
	local s6 = string.format("Time in Shadow Embrace (sec): %.02f\n", timeInShadowEmbrace)
	local s7 = string.format("%% of Time in Shadow Embrace: %.02f%%\n", percentInShadowEmbrace )
	local s8 = string.format("Time in Misery (sec): %0.03f\n", timeInMisery )
	local s9 = string.format("%% of Time in Shadow Misery: %.02f%%\n", percentInMisery )
	local s10 = string.format("Total DPS: %.02f\n", totalDPS )

	local logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 )
	return logEntry
end
--************************************************************************************
--							COLLATES, SUMMARIZES, AND REPORTS RESULTS
--							OF A SINGLE SPELL
--************************************************************************************
local function generateEventSummary( dmgTable )

	local totalCombatTime 	= log:getTotalCombatTime()
	local totalDPS 			= accumulatedDmg/totalCombatTime
	local totalDamage 		= accumulatedDmg
	local totalCritDamage 	= accumulatedCritDmg
	
	local totalSpellDmg 	= dmgTable[DMG_TOTAL]
	local totalSpellCritDmg = dmgTable[DMG_CRIT]
	local totalSpellTicks 	= dmgTable[DMG_TICKS]
	local totalSpellTime 	= dmgTable[DMG_TIME]

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

	local spellName = GetSpellInfo( dmgTable[DMG_SPELL_ID])
	if spellName == nil then
		spellName = "Pet"
	end

	local s1 = string.format("\nSUMMARY (%s):\n", spellName )
	local s2 = string.format("Total Damage: %d\n", totalSpellDmg)
	local s3 = string.format("Damage Events (casts, ticks): %d\n", totalSpellTicks)

	local s4 = string.format("Total Crit Damage: %d\n", totalSpellCritDmg)
	local s5 = string.format("%% Crit Damage: %.02f%%\n", percentSpellCrit )
	local s6 = string.format("Total Combat Time: %.02f\n", totalCombatTime)
	local s7 = string.format("%% Spell Uptime: %.02f%%\n", percentUptime )
	local s8 = string.format("DPS: %.02f\n", spellDPS )
	local s9 = string.format("%% of Total DPS: %.02f%%\n", contributionDPS )

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
function lock:reportEventSummaries()

	if accumulatedDmg > 0 then
		log:postEntry( generateEventsSummary() )
	end

	if agony[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( agony) )
	end
	if corruption[DMG_TOTAL] > 0 then 
		log:postEntry( generateEventSummary( corruption) )
	end
	if shadowBolt[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( shadowBolt) )
	end
	if unstableAffliction[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( unstableAffliction) )
	end
	if siphonLife[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( siphonLife) )
	end
	if deathBolt[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( deathBolt ) )
	end
	if phantom[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( phantom ) )
	end
	if vileTaint[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( vileTaint ) )
	end
	if drainSoul[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( drainSoul))
	end
	if haunt[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( haunt ) )
	end
	if drainLife[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( drainLife ))
	end
	if seed[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( seed))
	end
	if fireBolt[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( fireBolt ))
	end
	if consumingShadows[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( consumingShadows ))
	end
	if lashOfPain[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( lashOfPain ))
	end
	if shadowBite[DMG_TOTAL] > 0 then
		log:postEntry( generateEventSummary( shadowBite ))
	end

end
--******************************************************************************************
--									GET LOG SUFFIX
--			This method reads data from the stats block into the appropriate
--			fields of the spell's damage table.
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
		-- local petDamage = stats[12] -- spellName

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
function lock:getLogEntry( stats )

	local spellName = stats[EVENT_SPELLNAME]
	local eventType = stats[EVENT_TYPE]
	local timeStamp = stats[EVENT_TIMESTAMP]
	local logPrefix = string.format("%.02f, %s, %s", timeStamp, eventType, spellName )
	local logSuffix = string.format(" \n")

	if eventType == "SPELL_ENERGIZE" then
		log:dumpEvent(stats, eventType)
		-- do something
	end
	if eventType == "SPELL_LEECH" then
		-- do something
			log:dumpEvent(stats, eventType)
		end
	if eventType == "SPELL_MISSED" then
		-- do something
			log:dumpEvent(stats, eventType)
		end
	if eventType == "SPELL_FAILED" then
		-- do something
			log:dumpEvent(stats, eventType)
		end
	if eventType == "SPELL_AURA_APPLIED_DOSE" then
		-- do someting
			log:dumpEvent(stats, eventType)
		end
	if eventType == "SPELL_AURA_REMOVED_DOSE" then
		-- do something
			log:dumpEvent(stats, eventType)
		end
	if eventType == "SPELL_AURA_REFRESH" then
		-- do something
			log:dumpEvent(stats, eventType)
		end
	if eventType == "SPELL_AURA_APPLIED" then
		if stats[15] ~= nil then
			if stats[15] == string.upper( L["BUFF"]) then
				logPrefix = string.format("%.02f, %s, %s (%s)", timeStamp, eventType, spellName, L["BUFF"] )
			elseif stats[15] == string.upper( L["DEBUFF"]) then
				logPrefix = string.format("%.02f, %s, %s (%s)", timeStamp, eventType, spellName, L["DEBUFF"] )
			else
				logPrefix = string.format("%.02f, %s, %s (%s)", timeStamp, eventType, spellName, stats[15] )
			end
		end
		if spellName == "Dark Soul: Misery" then
			miseryStart( timeStamp )
			logSuffix = string.format(" (%s)\n", L["HASTE"])
		end
		if spellName == "Shadow Embrace" then
			shadowEmbraceStart( timeStamp )
		end
		if spellName == "Want for Nothing" then
			logSuffix = string.format(" (%s)\n", L["MASTERY"])
		end
		if spellName == "Wracking Brilliance" then
			logSuffix = string.format(" (%s)\n", L["INTELLECT"] )
		end
		if spellName == "Nightfall" then
			nightFallProcs = nightFallProcs + 1
		end
		if spellName == "Acceleration" then
			logSuffix = string.format(" (%s)\n", L["HASTE"])
		end
	end
	if eventType == "SPELL_AURA_REMOVED" then
		if spellName == "Dark Soul: Misery" then
			miseryStop( timeStamp )
		end
		if spellName == "Shadow Embrace" then
			shadowEmbraceStop( timeStamp )
		end
	end
	-- 	Now, we parse the spells
	if spellName == "Agony" then
		 logSuffix = getLogSuffix(agony, stats )
	end
	if spellName == "Corruption" then
		logSuffix = getLogSuffix(corruption, stats )
	end
	if spellName == "Shadow Bolt" then
		logSuffix = getLogSuffix(shadowBolt, stats )
	end
	if spellName == "Unstable Affliction" then
		logSuffix = getLogSuffix( unstableAffliction, stats )
	end
	if spellName == "Siphon Life" then
		logSuffix = getLogSuffix( siphonLife, stats )
	end
	if spellName == "Deathbolt" then
		logSuffix = getLogSuffix( deathBolt, stats )
	end
	if spellName == "Phantom Singularity" then
		logSuffix = getLogSuffix( phantom, stats )
	end
	if spellName == "Vile Taint" then
		logSuffix = getLogSuffix( vileTaint, stats )
	end
	if spellName == "Drain Soul" then
		logSuffix = getLogSuffix( drainSoul, stats )
	end
	if spellName == "Haunt" then
		logSuffix = getLogSuffix( haunt, stats )
	end
	if spellName == "Drain Life" then
		logSuffix = getLogSuffix( drainLife, stats )
	end
	if spellName == "Seed of Corruption" then
		logSuffix = getLogSuffix( seed, stats )
	end
	--****************************************************
	-- 					PET CASTS BELOW HERE
	--****************************************************
	if spellName == "Summon Darkglare" then			-- Dark Glare?
		logSuffix = getLogSuffix( darkGlare, stats )
	end

	-- IMP
	if spellName =="Firebolt" then
		logSuffix = getLogSuffix( fireBolt, stats )
	end
	-- VOID WALKER
	if spellName =="Consuming Shadows" then
		logSuffix = getLogSuffix( consumingShadows, stats )
	end
	-- FEL HUNTER
	if spellName =="Shadow Bite" then
		logSuffix = getLogSuffix( shadowBite, stats )
	end
	-- SUCCUBUS
	if spellName =="Lash of Pain" then
		logSuffix = getLogSuffix( lashOfPain, stats )
	end

	-- VOID WALKER

	-- FEL HUNTER

	-- SEDUCTRESS

	
	return logPrefix..logSuffix
end
