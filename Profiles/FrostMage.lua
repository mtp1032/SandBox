--------------------------------------------------------------------------------------
-- FrostMage.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 28 January, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.FrostMage = {}
mage = MTP.FrostMage
local L = MTP.L
--[[ 
		NOTE THE DUPLICATE SPELL IDs. This is why we must take care to
		never hard code a spell-name with a spell-id.

WATERBOLT				31707
TIME WARP				80353
TEMPORAL DISPLACEMENT	80354
RAY OF FROST			205021
MIRROR IMAGE			58833
MIRROR IMAGE			58831
MIRROR IMAGE			58834
MIRROR IMAGE			55342
ICY VEINS				12472
ICICLES					205473
ICE NOVA				157997
ICE LANCE				30455
ICE LANCE				228598
ICE FLOES				108839
FROSTBOLT				116
FROSTBOLT				228597
FROST NOVA				122
FLURRY					44614
FLURRY					228354
FINGERS OF FROST		44544
COMET STORM				153595
COMET STORM				153596
CHILLED					205708
BRAIN FREEZE			190446
BONE CHILLING			205766
BLIZZARD				190357

 ]]

-- --                      Indices into an eventStats table
-- --
-- --      For further into see this URL: https://wow.gamepedia.com/COMBAT_LOG_EVENT
-- --
-- --      These are indices into the stats table returned by the Combat log event. These
-- --       constants are already publically defined in CombatLog.lua.

local accumulatedDmg = 0
local accumulatedCritDmg = 0
local accumulatedCasts = 0

-- 						INDICES INTO SPELL INFO TABLES 
local INFO_SPELL_NAME 			= 1	-- string
local INFO_SPELL_ID 			= 2 -- number
local INFO_CAST_TIME 			= 3 -- number
local INFO_CAST_START_TIME 		= 4 -- number
local INFO_SPELL_COOLDOWN 		= 5 -- number
local INFO_COOLDOWN_IS_ENABLED	= 6 -- 0 if the spell is in-progress (Stealth, Shadowmeld, Presence of Mind, etc) and the cooldown will begin as soon as the spell is used/cancelled; 1 otherwise.
local INFOR_UPDATE_RATE			= 7 -- number

--						INDICES INTO THE SPELL DAMAGE TABLES
local TOTAL_DMG 	= 1
local CRIT_DMG 		= 2
local TIME  		= 3
local TICKS 		= 4  
local CASTS			= 4
local PETNAME       = 5

-- 						SPELL INFO TABLES (obtained from GetSpellInfo() and GetSpellCooldown())
local frostBoltInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local ebonBoltInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local iceLanceInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local frostNovaInfo 	= {nil, nil, nil, nil, nil, nil, nil }
local blizzardInfo 		= {nil, nil, nil, nil, nil, nil, nil }
local petInfo 			= {nil, nil, nil, nil, nil, nil, nil }
local coneInfo	 		= {nil, nil, nil, nil, nil, nil, nil }
local flurryInfo	 	= {nil, nil, nil, nil, nil, nil, nil }
local rayInfo	 		= {nil, nil, nil, nil, nil, nil, nil }
local frozenInfo	 	= {nil, nil, nil, nil, nil, nil, nil }
local iceNovaInfo	 	= {nil, nil, nil, nil, nil, nil, nil }
local spikeInfo	 		= {nil, nil, nil, nil, nil, nil, nil }
local cometInfo	 		= {nil, nil, nil, nil, nil, nil, nil }
local waterBoltInfo	 	= {nil, nil, nil, nil, nil, nil, nil }
local icicleInfo 	    = {nil, nil, nil, nil, nil, nil, nil }
local mirrorImageInfo 	= {nil, nil, nil, nil, nil, nil, nil }

-- 						Spell-specific damage tables
local frostBolt 	    = {0, 0, 0, 0}
local ebonBolt	 	    = {0, 0, 0, 0}
local iceLance	 	    = {0, 0, 0, 0}
local frostNova	 	    = {0, 0, 0, 0}
local blizzard			= {0, 0, 0, 0}
local pet				= {0, 0, 0, 0, 0}
local cone				= {0, 0, 0, 0, 0}
local flurry			= {0, 0, 0, 0, 0}
local ray				= {0, 0, 0, 0, 0}
local frozen			= {0, 0, 0, 0, 0}
local iceNova			= {0, 0, 0, 0, 0}
local glacialSpike		= {0, 0, 0, 0, 0}
local cometStorm		= {0, 0, 0, 0, 0}
local waterBolt			= {0, 0, 0, 0, 0}
local icicle			= {0, 0, 0, 0, 0}
local mirrorImage		= {0, 0, 0, 0, 0}

-- Proc counters
local brainFreezeProcs = 0
local fingersProcs = 0

-- tracks the uptime spent in Time Warp
local beginTimeWarp = 0 
local stopTimeWarp = 0
local uptimeTimeWarp = 0
local function timeWarpStart( timeStamp )
	beginTimeWarp = timeStamp
end
local function timeWarpStop( timeStamp )
	stopTimeWarp = timeStamp
	uptimeTimeWarp = uptimeTimeWarp + (stopTimeWarp - beginTimeWarp)
end
-- tracks uptime spent in Icy Veins
local beginIcyVeins = 0 
local stopIcyVeins = 0
local uptimeIcyVeins = 0
local function icyVeinsStart( timeStamp )
	beginIcyVeins = timeStamp
end
local function icyVeinsStop( timeStamp )
	stopIcyVeins = timeStamp
	uptimeIcyVeins = uptimeIcyVeins + (stopIcyVeins - beginIcyVeins)
end
-- tracks the uptime of Frozen Orb
local beginFrozenOrb = 0 
local stopFrozenOrb = 0
local uptimeFrozenOrb = 0
local function frozenOrbStart( timeStamp )
	beginFrozenOrb = timeStamp
end
local function frozenOrbStop( timeStamp )
	stopFrozenOrb = timeStamp
	uptimeFrozenOrb = uptimeFrozenOrb + (stopFrozenOrb - beginFrozenOrb)
end
--                      Called by CombatLogDisplay.lua when <Reset> button in pressed 
function mage:resetStats()
	brainFreezeProcs = 0
	fingersProcs = 0

	beginTimeWarp = 0 
	stopTimeWarp = 0
	uptimeTimeWarp = 0

	beginIcyVeins = 0 
	stopIcyVeins = 0
	uptimeIcyVeins = 0

	beginFrozenOrb = 0 
	stopFrozenOrb = 0
	uptimeFrozenOrb = 0
	
	frostBolt 			= {0, 0, 0, 0}
	ebonBolt		    = {0, 0, 0, 0}
	iceLance			= {0, 0, 0, 0}
	frostNova	 	    = {0, 0, 0, 0}
	blizzard			= {0, 0, 0, 0}
	pet					= {0, 0, 0, 0, 0}
	cone				= {0, 0, 0, 0, 0}
	flurry				= {0, 0, 0, 0, 0}
	ray			= {0, 0, 0, 0, 0}
	frozen				= {0, 0, 0, 0, 0}
	iceNova				= {0, 0, 0, 0, 0}
	glacialSpike				= {0, 0, 0, 0, 0}
	cometStorm				= {0, 0, 0, 0, 0}
	waterBolt				= {0, 0, 0, 0, 0}

	frostBoltInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	ebonBoltInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	iceLanceInfo 		= {nil, nil, nil, nil, nil, nil, nil }
	frostNovaInfo 		= {nil, nil, nil, nil, nil, nil, nil }
    blizzardInfo		= {nil, nil, nil, nil, nil, nil, nil }
    coneInfo				= {nil, nil, nil, nil, nil, nil, nil }
    flurryInfo				= {nil, nil, nil, nil, nil, nil, nil }
    rayInfo				= {nil, nil, nil, nil, nil, nil, nil }
    frozenInfo				= {nil, nil, nil, nil, nil, nil, nil }
    iceNovaInfo				= {nil, nil, nil, nil, nil, nil, nil }
    spikeInfo				= {nil, nil, nil, nil, nil, nil, nil }
    cometInfo				= {nil, nil, nil, nil, nil, nil, nil }
    waterBoltInfo				= {nil, nil, nil, nil, nil, nil, nil }

	accumulatedDmg = 0
	accumulatedCritDmg = 0
	accumulatedTicks = 0

	log:resetStats()
end
local function accumSpellTimer( spellDmgTbl, timeStamp )
	spellDmgTbl[TIME] = spellDmgTbl[TIME] + timeStamp
end
--******************************************************************************************
--						INITIALIZE A SPELL INFO TABLE
--******************************************************************************************
local function initSpellInfoTbl( stats )
	
	local spellName, _, _, castTime, _, _, spellId = GetSpellInfo( stats[SPELLID] )
	local startTime, coolDown, isEnabled, modRate = GetSpellCooldown( spellId )
	return spellName, spellId, castTime, startTime, coolDown, isEnabled, modRate 
end
--******************************************************************************************
--						SUMMARIZE THE SPELL DAMAGE INCLUDING ALL PLAYER AND PET SPELLS
--******************************************************************************************
local function summaryTotals()
	local totalDmg = accumulatedDmg
	local totalCombatTime = log:getTotalCombatTime()
	local totalCritDmg = accumulatedCritDmg
	local percentIcyVeins = (uptimeIcyVeins/totalCombatTime)*100
	local percentTimeWarp = (uptimeTimeWarp/totalCombatTime)*100
	local percentFrozenOrb = (uptimeFrozenOrb/totalCombatTime)*100

	local percentCrit = 0.000
	if accumulatedCritDmg > 0 then
		percentCrit = (accumulatedCritDmg/accumulatedDmg)*100
	end

	local totalDPS = totalDmg/totalCombatTime

	local s1 = string.format("\n%s\n", L["SUMMARY_ALL_SPELLS"] )
	local s2 = string.format("Total Damage: %d\n", totalDmg)
	local s3 = string.format("Total Crit Damage: %d\n", totalCritDmg)
	local s4 = string.format("%% Crit Damage: %.03f%%\n", percentCrit )
	local s5 = string.format("Icy Veins (%% of Total Time): %.03f%%\n", percentIcyVeins )
	local s6 = string.format("Time Warp (%% of Total Time): %.03f%%\n", percentTimeWarp )
	local s7 = string.format("Frozen Orb (%% of Total Time): %.03f%%\n", percentFrozenOrb )
	local s8 = string.format("Brain Freeze Procs: %d\n", brainFreezeProcs )
	local s9 = string.format("Fingers of Frost Procs: %d\n", fingersProcs )
	local s10 = string.format("Total Combat Time: %.03f\n", totalCombatTime)
	local s11 = string.format("Total DPS: %.03f\n", totalDPS )

	local logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s", s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11)

	return logEntry
end
-- ****************************************************************************************
--						SUMMARIZE A SPELL
-- ****************************************************************************************
local function summary( spellDmgTbl, spellInfoTbl )
	local totalCombatTime = log:getTotalCombatTime()
	local totalDPS = accumulatedDmg/totalCombatTime
	local uptimePercent = (spellDmgTbl[TIME] / totalCombatTime) * 100

	local spellDmg = spellDmgTbl[TOTAL_DMG]
	local spellCritDmg = spellDmgTbl[CRIT_DMG]
	local totalTicks = spellDmgTbl[TICKS]

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
	local spellName = spellInfoTbl[INFO_SPELL_NAME]
	local sOrb = nil
	local percentFrozenOrb = 0.00
	if spellId == FROZEN_ORB_ID then
		percentFrozenOrb = (uptimeFrozenOrb/totalCombatTime)*100
		sOrb = string.format("Frozen Orb (%% of Total Time): %.03f%%\n", percentFrozenOrb )
	end

	local s1 = string.format("\nSUMMARY (%s):\n", spellName )
	local s2 = string.format("Total Damage: %d\n", spellDmg)
	local s3 = string.format("Total Crit Damage: %d\n", spellCritDmg)
	local s4 = string.format("%% Crit Damage: %.03f%%\n", percentSpellCrit )
	local s5 = string.format("Total Combat Time: %.03f\n", totalCombatTime)
	local s6 = string.format("Damage per tick/cast: %.03f\n", dmgPerTick )
	local s7 = string.format("DPS: %.03f\n", spellDPS )
	local s8 = string.format("%% of Total DPS: %.03f%%\n", contributionDPS )

	if percentFrozenOrb == 0.00 then
		logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, s5, s6, s7, s8 )
	else
		logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, sOrb, s5, s6, s7, s8 )
	end
	return logEntry	
end
-- ****************************************************************************************
--						SUMMARIZE ALL OF THE SPELLS
-- ****************************************************************************************
function mage:summarizeCombatStats()

	if accumulatedDmg > 0 then
		log:postEntry( summaryTotals() )
	end
	if frostBolt[TOTAL_DMG] > 0 then
		log:postEntry( summary( frostBolt, frostBoltInfo ))
	end
	if ebonBolt[TOTAL_DMG] > 0 then
		log:postEntry( summary( ebonBolt, ebonBoltInfo ))
	end
	if iceLance[TOTAL_DMG] > 0 then
		log:postEntry( summary( iceLance, iceLanceInfo ))
	end
	if frostNova[TOTAL_DMG] > 0 then
		log:postEntry( summary( frostNova, frostNovaInfo ))
	end
	if blizzard[TOTAL_DMG] > 0 then
		log:postEntry( summary( blizzard, blizzardInfo ))
	end
	if cone[TOTAL_DMG] > 0 then
		log:postEntry( summary( cone, coneInfo ))
	end
	if flurry[TOTAL_DMG] > 0 then
		log:postEntry( summary( flurry, flurryInfo ))
	end
	if ray[TOTAL_DMG] > 0 then
		log:postEntry( summary( ray, rayInfo ))
	end
	if frozen[TOTAL_DMG] > 0 then
		log:postEntry( summary( frozen, frozenInfo ))
	end
	if iceNova[TOTAL_DMG] > 0 then
		log:postEntry( summary( iceNova, iceNovaInfo ))
	end
	if glacialSpike[TOTAL_DMG] > 0 then
		log:postEntry( summary( glacialSpike, spikeInfo ))
	end
	if cometStorm[TOTAL_DMG] > 0 then
		log:postEntry( summary( cometStorm, cometInfo ))
	end
	if waterBolt[TOTAL_DMG] > 0 then
		log:postEntry( summary( waterBolt, waterBoltInfo ))
	end

end
--******************************************************************************************
--						PARSE THE COMBAT EVENT (i.e., the stats table )
--						CALLED BY ONE OF THE PARSE SPELL METHODS
--******************************************************************************************
local function parseSpell( spellDmgTbl, stats )
	local timeStamp		= stats[TIMESTAMP]
	local spellName		= stats[SPELLNAME]
	local eventType		= stats[EVENT_TYPE]
	local spellDamage	= stats[DAMAGE]
	local isCrit 		= stats[CRITICAL]
	local logSuffix		= string.format("\n")
	
	if eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
		accumSpellTimer( spellDmgTbl, timeStamp )
		accumulatedDmg = accumulatedDmg + spellDamage
		spellDmgTbl[TICKS] = spellDmgTbl[TICKS] + 1
		spellDmgTbl[TOTAL_DMG] = spellDmgTbl[TOTAL_DMG] + spellDamage
		spellDmgTbl[TIME] = timeStamp

		if isCrit then
			spellDmgTbl[CRIT_DMG] = spellDmgTbl[CRIT_DMG] + spellDamage
			accumulatedCritDmg = accumulatedCritDmg + spellDamage
			logSuffix = string.format(" (%s), %d\n", L["CRIT"], spellDamage )
		else
			logSuffix = string.format(", %d\n", spellDamage)
		end
	end

	return logSuffix
end
--******************************************************************************************
--									PARSE FROSTBOLT
--******************************************************************************************
local function parseFrostBolt( stats )

	if frostBoltInfo[1] == nil then
		frostBoltInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( frostBolt, stats )
end
--******************************************************************************************
--									PARSE EBONBOLT
--******************************************************************************************
local function parseEbonBolt( stats )
	if ebonBoltInfo[1] == nil then
		ebonBoltInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( ebonBolt, stats )
end
--******************************************************************************************
--									PARSE ICE LANCE
--******************************************************************************************
local function parseIceLance( stats )
	if iceLanceInfo[1] == nil then
		iceLanceInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( iceLance, stats )
end
--******************************************************************************************
--									PARSE FROST NOVA
--******************************************************************************************
local function parseFrostNova( stats )
	if frostNovaInfo[1] == nil then
		frostNovaInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( frostNova, stats )
end
--******************************************************************************************
--									PARSE BLIZZARD
--******************************************************************************************
local function parseBlizzard( stats )
	if blizzardInfo[1] == nil then
		blizzardInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( blizzard, stats )
end
--******************************************************************************************
--									PARSE CONE OF COLD
--******************************************************************************************
local function parseCone( stats )
	if coneInfo[1] == nil then
		coneInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( cone, stats )
end
--******************************************************************************************
--									PARSE FLURRY
--******************************************************************************************
local function parseFlurry( stats )
	if flurryInfo[1] == nil then
		flurryInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( flurry, stats )
end
--******************************************************************************************
--									PARSE RAY OF FROST
--******************************************************************************************
local function parseRayOfFrost( stats )
	if rayInfo[1] == nil then
		rayInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( ray, stats )
end
--******************************************************************************************
--									PARSE FROZEN ORB
--******************************************************************************************
local function parseFrozenOrb( stats )
	if frozenInfo[1] == nil then
		frozenInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( frozen, stats )
end
--******************************************************************************************
--									PARSE ICE NOVA
--******************************************************************************************
local function parseIceNova( stats )
	if iceNovaInfo[1] == nil then
		iceNovaInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( iceNova, stats )
end
--******************************************************************************************
--									PARSE GLACIAL SPIKE
--******************************************************************************************
local function parseGlacialSpike( stats )
	if spikeInfo[1] == nil then
		spikeInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( glacialSpike, stats )
end
--******************************************************************************************
--									PARSE COMET STORM
--******************************************************************************************
local function parseCometStorm( stats )
	if cometInfo[1] == nil then
		cometInfo = { initSpellInfoTbl( stats ) }
	end
	
	return parseSpell( cometStorm, stats )
end
--******************************************************************************************
--									PARSE PET'S WATERBOLT
--******************************************************************************************
local function parseWaterBolt( stats )
	if waterBoltInfo[1] == nil then
		waterBoltInfo = { initSpellInfoTbl( stats ) }
	end
	return parseSpell( waterBolt, stats )
end
local function parseMirrorImage( stats )
	if mirrorImageInfo[1] == nil then
		mirrorImageInfo = { initSpellInfoTbl( stats )}
	end
	return parseSpell( mirrorImage, stats )
end
local function parseIcicle( stats )
	if icicleInfo[1] == nil then
		icicleInfo = { initSpellInfoTbl( stats )}
	end
	return parseSpell( icicle, stats )
end


--***********************************************************************************************
--                      PARSE COMBAT EVENTS (Called by OnEvent in CombatLog.lua)
--***********************************************************************************************
function mage:parseCombatEvents( stats )

	local spellName = stats[SPELLNAME]
	local timeStamp = stats[TIMESTAMP]
	local eventType = stats[EVENT_TYPE]
	local logPrefix = string.format("%.02f, %s, %s", timeStamp, eventType, spellName )
	local logSuffix = string.format(" \n")


	if  eventType ~= "SPELL_AURA_APPLIED" and 
		eventType ~= "SPELL_AURA_REMOVED" and
		eventType ~= "SPELL_ENERGIZE" and
		eventType ~= "SPELL_DAMAGE" and
		eventType ~= "SPELL_PERIODIC_DAMAGE" then
			return nil
	end
	-- see https://wow.gamepedia.com/API_UnitPowerType
	if eventType == "SPELL_ENERGIZE" then
		local powerType, powerName = UnitPowerType( "Player" )
		local amount = stats[15]
		logSuffix = string.format(", %s %d %s\n", L["GAINED"], amount, powerName )
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
				

	--	IcyVeins and Time Warp are auras/buffs that 
	--  apply temporary buffs to the player. So we 
	--  have to be cognizant of their start/stop times.
	if spellName == "Time Warp" then
		if eventType == "SPELL_AURA_APPLIED" then
			timeWarpStart( timeStamp )
			logSuffix = string.format(" (%s)\n", L["HASTE"] )
		end
		if eventType == "SPELL_AURA_REMOVED" then
			timeWarpStop( timeStamp )
		end
	end
	if spellName ==  "Icy Veins" then
		if eventType == "SPELL_AURA_APPLIED" then
			icyVeinsStart( timeStamp )
			logSuffix = string.format(" (%s)\n", L["HASTE"])
		end
		if eventType == "SPELL_AURA_REMOVED" then
			icyVeinsStop( timeStamp )
		end
	end
	if spellName == "Frozen Orb" then
		if eventType == "SPELL_AURA_APPLIED" then
			frozenOrbStart( timeStamp )
		end
		if eventType == "SPELL_AURA_REMOVED" then
			frozenOrbStop( timeStamp )
		end
	end
	if spellName == "Brain Freeze" then
		brainFreezeProcs = brainFreezeProcs + 1
	end
	if spellName == "Fingers of Frost" then
		fingersProcs = fingersProcs + 1
	end

	-- Now, we parse the spells
	if spellName == "Frostbolt" then
		 logSuffix = parseFrostBolt( stats )
	end
	if spellName == "Ebonbolt" then
		logSuffix = parseEbonBolt( stats )
	end
	if spellName ==  "Ice Lance" then
		logSuffix = parseIceLance( stats )
	end
	if spellName ==  "Frost Nova" then
		logSuffix = parseFrostNova( stats )
	end
	if spellName ==  "Blizzard" then
		logSuffix = parseBlizzard( stats )
	end
	if spellName ==  "Cone of Cold" then
		logSuffix = parseCone( stats )
	end
	if spellName ==  "Flurry" then
		logSuffix = parseFlurry( stats )
	end
	if spellName ==  "Ray of Frost" then
		logSuffix = parseRayOfFrost( stats )
	end
	if spellName ==  "Frozen Orb" then
		logSuffix = parseFrozenOrb( stats )
	end
	if spellName ==  "Ice Nova" then
		logSuffix = parseIceNova( stats )
	end
	if spellName ==  "Glacial Spike" then
		logSuffix = parseGlacialSpike( stats )
	end
	if spellName ==  "Comet Storm" then
		logSuffix = parseCometStorm( stats )
	end
	if spellName == "Mirror Image" then
		logSuffix = parseMirrorImage( stats )
	end
	if spellName == "Icicle" then
		logSuffix = parseIcicle( stats )
	end
	if spellName ==  "Waterbolt" then
		logSuffix = parseWaterBolt( stats )
	end

    return logPrefix..logSuffix
end
