--------------------------------------------------------------------------------------
-- ShadowPriest.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 15 January, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.AffWarlock= {}
lock = MTP.AffWarlock
local L = MTP.L


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
local stopShadowEmbrace = 0
local timeInShadowEmbrace = 0
local function shadowEmbraceStart( timeStamp )
	beginShadowEmbrace = timeStamp
end
local function shadowEmbraceStop( timeStamp )
	stopShadowEmbrace = timeStamp
	timeInShadowEmbrace = timeInShadowEmbrace + (stopShadowEmbrace - beginShadowEmbrace)
	return (stopShadowEmbrace - beginShadowEmbrace)
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
	return (stopMisery - beginMisery)
end
local function getTimeInMisery()
	return timeInMisery
end

-- 						INDICES INTO SPELL INFO TABLES 
local SPELL_NAME 	= 1	-- string
local SPELL_ID 		= 2 -- number
local CAST_TIME 	= 3 -- number
local START_TIME 	= 4 -- number
local COOLDOWN 		= 5 -- number
local IS_ENABLED	= 6 -- 0 if the spell is in-progress (Stealth, Shadowmeld, Presence of Mind, etc) and the cooldown will begin as soon as the spell is used/cancelled; 1 otherwise.
local MOD_RATE		= 7 -- number

-- 						SPELL INFO TABLES (obtained from GetSpellInfo() and GetSpellCooldown())
local agonyInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local corruptionInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local shadowBoltInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local unstableInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local siphonInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local darkGlareInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local deathBoltInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local phantomInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local vileTaintInfo		= {nil, nil, nil, nil, nil, nil, nil }
local drainSoulInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local drainLifeInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local hauntInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local seedInfo			= {nil, nil, nil, nil, nil, nil, nil }
local petInfo 			= {nil, nil, nil, nil, nil, nil, nil }

-- 						INDICES INTO THE SPELL DAMAGE TABLES
local TOTAL_DMG 	= 1
local CRIT_DMG 		= 2
local TIME  		= 3
local TICKS 		= 4  
local CASTS			= 4
local PETNAME       = 5

--						SPELL DAMAGE TABLES
local agony 	        	= {0, 0, 0, 0}
local corruption 			= {0, 0, 0, 0}
local shadowBolt 			= {0, 0, 0, 0}
local unstableAffliction	= {0, 0, 0, 0}
local siphonLife			= {0, 0, 0, 0}
local darkGlare 			= {0, 0, 0, 0}
local deathBolt 			= {0, 0, 0, 0}
local phantom 				= {0, 0, 0, 0}
local vileTaint 			= {0, 0, 0, 0}
local drainSoul				= {0, 0, 0, 0}
local drainLife				= {0, 0, 0, 0}
local haunt					= {0, 0, 0, 0}
local seed 	        		= {0, 0, 0, 0}
local pet					= {0, 0, 0, 0, 0}	-- 5th element contains the name of the active Pet

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
	agony 				= {0, 0, 0, 0}
	corruption 			= {0, 0, 0, 0}
	shadowBolt	 		= {0, 0, 0, 0}
	unstableAffliction	= {0, 0, 0, 0}
	siphonLife			= {0, 0, 0, 0}
	darkGlare 			= {0, 0, 0, 0}
	deathBolt 			= {0, 0, 0, 0}
	phantom 			= {0, 0, 0, 0}
	vileTaint 			= {0, 0, 0, 0}
	drainSoul			= {0, 0, 0, 0}
	drainLife			= {0, 0, 0, 0}
	seed 				= {0, 0, 0, 0}
	haunt				= {0, 0, 0, 0}
	pet					= {0, 0, 0, 0, 0}

	agonyInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	corruptionInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	shadowBoltInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	unstableInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	siphonInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	darkGlareInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	deathBoltInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	phantomInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	vileTaintInfo	= {nil, nil, nil, nil, nil, nil, nil }
	drainSoulInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	drainLifeInfo 	= {nil, nil, nil, nil, nil, nil, nil }
	seedInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	hauntInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	petInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	
	accumulatedDmg = 0
	accumulatedCritDmg = 0
	accumulatedTicks = 0

	beginMisery = 0
	stopMisery = 0
	timeInMisery =0

	beginShadowEmbrace = 0
	stopStopShadowEmbrace = 0
	timeInShadowEmbrace = 0
	log:resetStats()
end
local function accumSpellTimer( spellTbl, timeStamp )
	spellTbl[TIME] = spellTbl[TIME] + timeStamp
end
local function initSpellInfo( stats )
	local spellName, _, _, castTime, _, _, spellId = GetSpellInfo( stats[SPELLNAME] )
	local startTime, coolDown, isEnabled, modRate = GetSpellCooldown( spellId )
	return spellName, spellId, castTime, startTime, coolDown, isEnabled, modRate 
end
local function parseSpell( spellTbl, stats )
	local timeStamp		= stats[EVENT_TIMESTAMP]
	local eventType		= stats[EVENT_TYPE]
	local spellDamage	= stats[EVENT_DAMAGE]
	local isCrit 		= stats[EVENT_CRITICAL]
	local logSuffix		= string.format("\n")
	
	if eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
		accumSpellTimer( spellTbl, timeStamp )
		accumulatedDmg = accumulatedDmg + spellDamage
		spellTbl[TICKS] = spellTbl[TICKS] + 1
		spellTbl[TOTAL_DMG] = spellTbl[TOTAL_DMG] + spellDamage
		spellTbl[TIME] = timeStamp

		if isCrit then
			spellTbl[CRIT_DMG] = spellTbl[CRIT_DMG] + spellDamage
			accumulatedCritDmg = accumulatedCritDmg + spellDamage
			logSuffix = string.format(" (CRIT), %d\n", spellDamage )
		else
			logSuffix = string.format(", %d\n", spellDamage)
		end
	end

	return logSuffix
end

--						SUMMARIZE THE SPELL DAMAGE INCLUDING ALL PLAYER AND PET SPELLS
local function summaryTotals()
	local totalDmg = accumulatedDmg
	local totalCombatTime = log:getTotalCombatTime()
	local totalCritDmg = accumulatedCritDmg
	local timeInMisery = getTimeInMisery()
	local timeInShadowEmbrace = getTimeInShadowEmbrace()
	
	percentMisery = 0.000
	if timeInMisery > 0 then
		percentMisery = (timeInMisery/totalCombatTime)*100
	end

	local percentShadowEmbrace = 0.000
	if timeInShadowEmbrace > 0 then
		percentShadowEmbrace = (timeInShadowEmbrace/totalCombatTime)*100
	end

	local percentCrit = 0.000
	if accumulatedCritDmg > 0 then
		percentCrit = (accumulatedCritDmg/accumulatedDmg)*100
	end

	local totalDPS = totalDmg/totalCombatTime

	local s1 = string.format("\n%s\n", L["SUMMARY_ALL_SPELLS"])
	local s2 = string.format("Total Damage: %d\n", totalDmg)
	local s3 = string.format("Total Crit Damage: %d\n", totalCritDmg)
	local s4 = string.format("Percent Crit Damage: %.03f%%\n", percentCrit )
	local s5 = string.format("Percent Time in Misery: %.03f%%\n", percentMisery)
	local s6 = string.format("Percent Time in Shadow Embrace: %.03f%%\n", percentShadowEmbrace)
	local s7 = string.format("Nightfall Procs: %d\n", nightFallProcs )
	local s8 = string.format("Total Combat Time: %.03f\n", totalCombatTime)
	local s9 = string.format("Total DPS: %.03f\n", totalDPS )

	local logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s   %s", s1, s2, s3, s4, s5, s6, s7, s8, s9)

	return logEntry
end

local function summary( spellTbl, infoTbl )
	local totalCombatTime = log:getTotalCombatTime()
	local totalDPS = accumulatedDmg/totalCombatTime
	local uptimePercent = (spellTbl[TIME] / totalCombatTime) * 100

	local spellDmg = spellTbl[TOTAL_DMG]
	local spellCritDmg = spellTbl[CRIT_DMG]
	local totalTicks = spellTbl[TICKS]

	local tickDPS = 0.000
	if totalTicks > 0 then
		tickDPS = spellDmg/totalTicks
	end

	local percentSpellCrit = 0.000
	if spellDmg > 0 then
		percentSpellCrit = (spellCritDmg/spellDmg)*100
	end

	local dmgPerTick = 0.000
	if totalTicks > 0 then
		dmgPerTick = (spellDmg / totalTicks)
	end

	local spellDPS = 0.000
	if totalCombatTime > 0 then 
		spellDPS = spellDmg/totalCombatTime
	end

	local contributionDPS = 0.000
	if totalDPS > 0 then
		contributionDPS = (spellDPS/totalDPS)*100
	end

	local s1
	if spellTbl[PETNAME] ~= nil then
		s1 = string.format("\nSUMMARY (%s's, %s):\n", spellTbl[PETNAME],infoTbl[SPELL_NAME] )
	else
		s1 = string.format("\nSUMMARY (%s):\n", infoTbl[SPELL_NAME] )
	end

	local s2 = string.format("Total Damage: %d\n", spellDmg)
	local s3 = string.format("Total Crit Damage: %d\n", spellCritDmg)
	local s4 = string.format("Percent Crit Damage: %.03f%%\n", percentSpellCrit )
	local s5 = string.format("Uptime Efficiency: %.03f%%\n", uptimePercent )
	local s6 = string.format("Total Combat Time: %.03f\n", totalCombatTime)
	local s7 = string.format("Damage per tick/cast: %.03f\n", dmgPerTick )
	local s8 = string.format("DPS: %.03f\n", spellDPS )
	local s9 = string.format("Percent of Total DPS: %.03f%%\n", contributionDPS )

	local logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, s5, s6, s7, s8, s9)
	return logEntry	
end
function lock:summarizeCombatStats()

	if accumulatedDmg > 0 then
		log:postEntry( summaryTotals() )
	end
	if agony[TOTAL_DMG] > 0 then
		log:postEntry( summary( agony, agonyInfo) )
	end
	if corruption[TOTAL_DMG] > 0 then 
		log:postEntry( summary( corruption, corruptionInfo) )
	end
	if shadowBolt[TOTAL_DMG] > 0 then
		log:postEntry( summary( shadowBolt, shadowBoltInfo) )
	end
	if unstableAffliction[TOTAL_DMG] > 0 then
		log:postEntry( summary( unstableAffliction, unstableInfo) )
	end
	if siphonLife[TOTAL_DMG] > 0 then
		log:postEntry( summary( siphonLife, siphonInfo) )
	end
	if darkGlare[TOTAL_DMG] > 0 then
		log:postEntry( summary( darkGlare, darkGlareInfo) )
	end
	if deathBolt[TOTAL_DMG] > 0 then
		log:postEntry( summary( deathBolt, deathBoltInfo ) )
	end
	if phantom[TOTAL_DMG] > 0 then
		log:postEntry( summary( phantom, phantomInfo) )
	end
	if vileTaint[TOTAL_DMG] > 0 then
		log:postEntry( summary( vileTaint, vileTaintInfo ) )
	end
	if drainSoul[TOTAL_DMG] > 0 then
		log:postEntry( summary( drainSoul, drainSoulInfo))
	end
	if haunt[TOTAL_DMG] > 0 then
		log:postEntry( summary( haunt, hauntInfo ) )
	end
	if drainLife[TOTAL_DMG] > 0 then
		log:postEntry( summary( drainLife, drainLifeInfo))
	end
	if seed[TOTAL_DMG] > 0 then
		log:postEntry( summary( seed, seedInfo))
	end

	if pet[TOTAL_DMG] > 0 then
		log:postEntry( summary( pet, petInfo ) )
	end
end
--******************************************************************************************
--									SHADOW BOLT
--******************************************************************************************
local function parseShadowBolt( stats )
	-- the spellInfo table
	if shadowBoltInfo[1] == nil then
		shadowBoltInfo = { initSpellInfo( stats ) }
	end

	-- the spellDamage table
	return ( parseSpell( shadowBolt, stats ))

end
--******************************************************************************************
--									UNSTABLE AFFLICTION
--******************************************************************************************
local function parseUnstableAffliction( stats )
	-- the spellInfo table
	if unstableInfo[1] == nil then
		unstableInfo = { initSpellInfo( stats ) }
	end

	-- the spellDamage table
	return ( parseSpell( unstableAffliction, stats ))

end
--******************************************************************************************
--									CORRUPTION
--******************************************************************************************
local function parseCorruption( stats )
	-- the spellInfo table
	if corruptionInfo[1] == nil then
		corruptionInfo = { initSpellInfo( stats ) }
	end

	-- the spellDamage table
	return ( parseSpell( corruption, stats ))

end
--******************************************************************************************
--									AGONY
--******************************************************************************************
local function parseAgony( stats )
	-- the spellInfo table
	if agonyInfo[1] == nil then
		agonyInfo = { initSpellInfo( stats ) }
	end

	-- the spellDamage table
	return ( parseSpell( agony, stats ))

end
--******************************************************************************************
--									SIPHON LIFE
--******************************************************************************************
local function parseSiphonLife( stats )
	-- the spellInfo table
	if siphonInfo[1] == nil then
		siphonInfo = { initSpellInfo( stats ) }
	end
	return ( parseSpell( darkGlare, stats ))
end
--******************************************************************************************
--									SUMMON DARKGLARE
--******************************************************************************************
local function parseDarkGlare( stats )
	-- the spellInfo table
	if darkGlareInfo[1] == nil then
		darkGlare = { initSpellInfo( stats ) }
	end
	return ( parseSpell( darkGlare, stats ))

end
--******************************************************************************************
--									DEATH BOLT
--******************************************************************************************
local function parseDeathBolt( stats )
	-- the spellInfo table
	if deathBoltInfo[1] == nil then
		deathBoltInfo = { initSpellInfo( stats ) }
	end
	return ( parseSpell( deathBolt, stats ))

end
--******************************************************************************************
--									PHANTOM SINGULARITY
--******************************************************************************************
local function parsePhantomSingularity( stats )
	-- the spellInfo table
	if phantomInfo[1] == nil then
		phantomInfo = { initSpellInfo( stats ) }
	end
	-- the spellDamage table
	return ( parseSpell( phantom, stats ))

end
--******************************************************************************************
--									VILE TAINT
--******************************************************************************************
local function parseVileTaint( stats )
	if vileTaintInfo[1] == nil then
		vileTaintInfo = { initSpellInfo( stats ) }
	end
	return ( parseSpell( haunt, stats ))
end
--******************************************************************************************
--									DRAIN SOUL
--******************************************************************************************
local function parseDrainSoul( stats )

	if drainSoulInfo[1] == nil then
		drainSoulInfo = { initSpellInfo( stats ) }
	end

	return ( parseSpell( drainSoul, stats ))
end
--******************************************************************************************
--									DRAIN LIFE
--******************************************************************************************
local function parseDrainLife( stats )

	if drainLifeInfo[1] == nil then
		drainLifeInfo = { initSpellInfo( stats ) }
	end

	return ( parseSpell( drainLife, stats ))
end
--******************************************************************************************
--									HAUNT
--******************************************************************************************
local function parseHaunt( stats )

	if hauntInfo[1] == nil then
			hauntInfo = { initSpellInfo( stats ) }
		end
	
	return ( parseSpell( haunt, stats ))
end
--******************************************************************************************
--									SEED OF CORRUPTION
--******************************************************************************************
local function parseSeed( stats )
	if seedInfo[1] == nil then
		seedInfo = { initSpellInfo( stats ) }
	end

return ( parseSpell( seed, stats ))
end
--******************************************************************************************
--									PET
--******************************************************************************************
local function parsePet( stats )
	if petInfo[1] == nil then
		petInfo = { initSpellInfo(stats)}
	end
	
	pet[PETNAME] = stats[SOURCENAME]
	return parseSpell( pet, stats)
end
--***********************************************************************************************
--                      PARSE COMBAT EVENTS (Called by OnEvent in CombatLog.lua)
--***********************************************************************************************
function lock:parseCombatEvents( stats )

	local spellName = stats[EVENT_SPELLNAME]
	local eventType = stats[EVENT_TYPE]
	local timeStamp = stats[EVENT_TIMESTAMP]
	local elapsedTime = 0
	local logPrefix = string.format("%.02f, %s, %s", timeStamp, eventType, spellName )
	local logSuffix = string.format(" \n")

	if  eventType ~= "SPELL_AURA_APPLIED" and 
		eventType ~= "SPELL_AURA_REMOVED" and
		eventType ~= "SPELL_DAMAGE" and
		eventType ~= "SPELL_PERIODIC_DAMAGE" then
			return nil
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
	end

	-- These are procs and are independent of spells cast.
	if eventType == "SPELL_AURA_APPLIED" then
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
 	--	Misery and Shadow Embrace are timed procs so we have to be
	-- 	cognizant of their start/stop times.
	if spellName == "Dark Soul: Misery" then
		if eventType == "SPELL_AURA_APPLIED" then
			miseryStart( timeStamp )
			logSuffix = string.format(" (%s)\n", L["HASTE"])
		end
		if eventType == "SPELL_AURA_REMOVED" then
			miseryStop( timeStamp )
		end
	end
	if spellName == "Shadow Embrace" then
		if eventType == "SPELL_AURA_APPLIED" then
			shadowEmbraceStart( timeStamp )
		end
		if eventType == "SPELL_AURA_REMOVED" then
			elapsedTime = shadowEmbraceStop( timeStamp )
		end
	end
	-- 	Now, we parse the spells
	if spellName == "Agony" then
		 logSuffix = parseAgony(stats )
	end
	if spellName == "Corruption" then
		logSuffix = parseCorruption(stats )
	end
	if spellName == "Shadow Bolt" then
		logSuffix = parseShadowBolt(stats )
	end
	if spellName == "Unstable Affliction" then
		logSuffix = parseUnstableAffliction( stats )
	end
	if spellName == "Siphon Life" then
		logSuffix = parseSiphonLife( stats )
	end
	if spellName == "Eye Beam" then
		logSuffix = parseDarkGlare( stats )
	end
	if spellName == "Deathbolt" then
		logSuffix = parseDeathBolt( stats )
	end
	if spellName == "Phantom Singularity" then
		logSuffix = parsePhantomSingularity( stats )
	end
	if spellName == "Vile Taint	" then
		logSuffix = parseVileTaint( stats )
	end
	if spellName == "Drain Soul" then
		logSuffix = parseDrainSoul(stats )
	end
	if spellName == "Haunt" then
		logSuffix = parseHaunt( stats )
	end
	if spellName == "Drain Life" then
		logSuffix = parseDrainLife( stats )
	end
	if spellName == "Seed of Corruption" then
		logSuffix = parseSeed( stats )
	end
	if getUnitType(stats[EVENT_SOURCEGUID]) == "Pet" then
		logSuffix = parsePet( stats )
	end

    return logPrefix..logSuffix
end
