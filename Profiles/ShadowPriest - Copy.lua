--------------------------------------------------------------------------------------
-- ShadowPriest.lua
-- AUTHOR: Michael peterson
-- ORIGINAL DATE: 15 January, 2019
--------------------------------------------------------------------------------------

local _, MTP = ...
MTP.ShadowPriest= {}
priest = MTP.ShadowPriest
local L = MTP.L

local accumulatedDmg = 0
local accumulatedCritDmg = 0
local accumulatedCasts = 0

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
local vampiricTouchInfo 	= {0, 0, 0, 0, 0, 0, 0}
local apparitionInfo		= {0, 0, 0, 0, 0, 0, 0}
local shadowWordPainInfo 	= {0, 0, 0, 0, 0, 0, 0}
local shadowWordVoidInfo 	= {0, 0, 0, 0, 0, 0, 0}
local mindBlastInfo 		= {0, 0, 0, 0, 0, 0, 0} 					
local mindFlayInfo 			= {0, 0, 0, 0, 0, 0, 0} 					
local mindSearInfo 			= {0, 0, 0, 0, 0, 0, 0} 
local darkVoidInfo 			= {0, 0, 0, 0, 0, 0, 0} 
local shadowCrashInfo		= {0, 0, 0, 0, 0, 0, 0} 
local darkAscensionInfo		= {0, 0, 0, 0, 0, 0, 0} 
local shadowMendInfo		= {0, 0, 0, 0, 0, 0, 0} 
local voidEruptionInfo  	= {0, 0, 0, 0, 0, 0, 0}
local voidBoltInfo          = {0, 0, 0, 0, 0, 0, 0} 
local voidTorrentInfo       = {0, 0, 0, 0, 0, 0, 0} 
local mindBombInfo       	= {0, 0, 0, 0, 0, 0, 0} 
local shadowWordDeathInfo   = {0, 0, 0, 0, 0, 0, 0}
local apparitionInfo        = {0, 0, 0, 0, 0, 0, 0}
local benderInfo  			= {0, 0, 0, 0, 0, 0, 0}		-- Mindbender
local fiendInfo				= {0, 0, 0, 0, 0, 0, 0}		-- Shadowfiend


-- 						INDICES INTO THE SPELL DAMAGE TABLE
local DMG_TOTAL 	= 1 -- number
local DMG_CRIT 		= 2 -- number
local DMG_TIME 		= 3 -- number
local DMG_TICKS		= 4
local DMG_SPELL_ID	= 5	-- number
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

	vampiricTouchInfo 	= {0, 0, 0, 0, 0, 0, 0}
	apparitionInfo		= {0, 0, 0, 0, 0, 0, 0}
	shadowWordPainInfo 	= {0, 0, 0, 0, 0, 0, 0}
	shadowWordVoidInfo	= {0, 0, 0, 0, 0, 0, 0}
	mindBlastInfo 		= {0, 0, 0, 0, 0, 0, 0} 					
	mindFlayInfo 		= {0, 0, 0, 0, 0, 0, 0} 					
	mindSearInfo 		= {0, 0, 0, 0, 0, 0, 0} 
	darkVoidInfo 		= {0, 0, 0, 0, 0, 0, 0} 
	shadowCrashInfo		= {0, 0, 0, 0, 0, 0, 0} 
	darkAscensionInfo	= {0, 0, 0, 0, 0, 0, 0} 
	shadowMendInfo		= {0, 0, 0, 0, 0, 0, 0} 
	voidEruptionInfo  	= {0, 0, 0, 0, 0, 0, 0}
	voidBoltInfo        = {0, 0, 0, 0, 0, 0, 0} 
	voidTorrentInfo     = {0, 0, 0, 0, 0, 0, 0} 
	mindBombInfo       	= {0, 0, 0, 0, 0, 0, 0} 
	shadowWordDeathInfo = {0, 0, 0, 0, 0, 0, 0}
	apparitionInfo      = {0, 0, 0, 0, 0, 0, 0}
	benderInfo  		= {0, 0, 0, 0, 0, 0, 0}		-- Mindbender
	fiendInfo			= {0, 0, 0, 0, 0, 0, 0}		-- Shadowfiend
	
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
--**************************************************************
---				VALIDATE THAT SPELL IS A SHADOW PRIEST SPELL
--**************************************************************
local function validateSpellName( spellName )
	local result = SUCCESSFUL_RESULT

	if spellName == nil then
		local s = errors:setErrorResult( L["ARG_NIL"], debugstack() )
		return emf:postErrorMsg( s )
	end
	if type(spellName) ~= "string" then
		return emf:postErrorMsg( errors:setErrorResult( ARG_C_NIL, debugstack() ))
	end

	-- Now, is spellName recognized as a valid Shadow Priest Spell

	if spellName == L["MIND_BLAST"] then 
		return result 
	end
	if spellName == L["VAMPIRIC_TOUCH"] then return result end
	if spellName == L["SHADOW_WORD_PAIN"] then return result end
	if spellName == L["SHADOW_WORD_VOID"] then return result end
	if spellName == L["SHADOW_MEND"] then return result end
	if spellName == L["MIND_FLAY"] then return result end
	if spellName == L["MIND_SEAR"] then return result end
	if spellName == L["DARK_VOID"] then return result end
	if spellName == L["SHADOW_CRASH"] then return result end
	if spellName == L["DARK_ASCENSION"] then return result end
	if spellName == L["SHADOW_MEND"] then return result end
	if spellName == L["VOID_ERUPTION"] then return result end
	if spellName == L["VOID_BOLT"] then return result end
	if spellName == L["AUSPICIOUS_SPIRITS"] then return result end
	if spellName == L["MIND_BENDER"] then return result end
	if spellName == L["SHADOW_CRASH"] then return result end
	if spellName == L["SHADOW_WORD_DEATH"] then return result end
	if spellName == L["SURRENDER_TO_MADNESS"] then return result end

	-- If we arrive here, the spell name was not recognized as a
	-- Shadow Priest spell.
	return result
end
--**************************************************************
---				VALIDATE THAT THE DAMAGE TABLE IS
--				PROPERLY FORMED AND INITIALIZED
--**************************************************************
local function validateSpellDmgTable( spellTable )
	local result = SUCCESSFUL_RESULT

	-- First, check that the input parameter is correctly formed.
	if spellTable == nil then
		return emf:postErrorMsg( errors:setErrorResult( L["ARG_NIL"], debugstack() ))
	end
	if type(spellTable) ~= "table" then
		return emf:postErrorMsg( errors:setErrorResult( L["ARG_NIL"], debugstack() ))
	end
	if spellTable[DMG_SPELL_ID] == 0 then
		return emf:postErrorMsg( errors:setErrorResult( L["ARG_NIL"], debugstack() ))
	end

	local spellNameFromId = GetSpellInfo( spellTable[DMG_SPELL_ID])
	if spellNameFromId == nil then
		return emf:postErrorMsg( errors:setErrorResult( L["ARG_NIL"], debugstack() ))
	end

	result = validateSpellName( spellNameFromId )
	if result[1] == STATUS_FAILURE then
		return emf:postErrorMsg( errors:setErrorResult( L["ERROR_UNKNOWN_SPELL"], debugstack() ))
	end	
	return result
end
local function initSpellInfo( stats )	
	local spellName, _, _, castTime, _, _, spellId = GetSpellInfo( stats[SPELLID] )
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
local function reportTotal()
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
--							KEEP RUNNING SUMMARY OF EACH SPELL
--************************************************************************************
local function reportSpell( spellTable )
	local result = SUCCESSFUL_RESULT

	result = validateSpellDmgTable( spellTable )
	if result[1] == FAILURE then
		emf.postErrorMsg( result )
		return nil
	end

	local totalCombatTime = log:getTotalCombatTime()
	local totalDPS = accumulatedDmg/totalCombatTime
	local totalDamage = accumulatedDmg
	local totalCritDamage = accumulatedCritDmg
	
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

	local s1 = string.format("\nSUMMARY (%s):\n", spellName )
	local s2 = string.format("Total Damage: %d\n", totalSpellDmg)
	local s3 = string.format("Total Crit Damage: %d\n", totalSpellCritDmg)
	local s4 = string.format("%% Crit Damage: %.03f%%\n", percentSpellCrit )
	local s5 = string.format("Total Combat Time: %.03f\n", totalCombatTime)
	local s6 = string.format("%% Spell Uptime: %.03f%%\n", percentUptime )
	local s7 = string.format("DPS: %.03f\n", spellDPS )
	local s8 = string.format("%% of Total DPS: %.03f%%\n", contributionDPS )

	logEntry = string.format("%s   %s   %s   %s   %s   %s   %s   %s\n", s1, s2, s3, s4, s5, s6, s7, s8  )
	return logEntry	
end
--******************************************************************************************
--										PARSE SPELL
--******************************************************************************************
local function parseSpell( spellDmg, stats )
	local timeStamp		= stats[TIMESTAMP]
	local spellName		= stats[SPELLNAME]
	local eventType		= stats[EVENT_TYPE]
	local spellDamage	= stats[DAMAGE]
	local isCrit 		= stats[CRITICAL]
	local logSuffix		= string.format("\n")
	
	spellDmg[DMG_SPELL_ID] = stats[SPELLID]
	if eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
		accumSpellTimer( spellDmg, timeStamp )
		accumulatedDmg = accumulatedDmg + spellDamage
		
		spellDmg[DMG_TIME] = timeStamp
		spellDmg[DMG_CASTS] = spellDmg[DMG_CASTS] + 1
		spellDmg[DMG_TOTAL] = spellDmg[DMG_TOTAL] + spellDamage

		if isCrit then
			spellDmg[DMG_CRIT] = spellDmg[DMG_CRIT] + spellDamage
			accumulatedCritDmg = accumulatedCritDmg + spellDamage
			logSuffix = string.format(", (%s), %d\n", L["CRIT"], spellDamage )
		else
			logSuffix = string.format(", %d\n", spellDamage)
		end
	end

	return logSuffix
end
function priest:reportEventSummaries()
	
	log:postEntry( reportTotal() )

	if shadowWordPain[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( shadowWordPain) )
	end
	if apparition[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( apparition) )
	end
	if shadowWordDeath[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( shadowWordDeath) )
	end
	if mindBlast[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( mindBlast ) )
	end
	if vampiricTouch[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( vampiricTouch ) )
	end
	if mindFlay[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( mindFlay ) )
	end
	if mindSear[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( mindSear ) )
	end
	if mindBomb[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( mindBomb) )
	end
	if voidEruption[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( voidEruption ) )
	end
	if shadowWord[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( shadowWordVoid ) )
	end
	if voidBolt[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( voidBolt) )
	end
	if darkAscension[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( darkAscension ) )
	end
	if voidTorrent[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( voidTorrent) )
	end
	if darkVoid[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( darkVoid ) )
	end
	if bender[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( bender ) )
	end
	if fiend[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( fiend ) )
	end
	if shadowCrash[DMG_TOTAL] > 0 then
		log:postEntry( reportSpell( shadowCrash) )
	end
	-- if shadowMend[DMG_TOTAL] > 0 then
	-- 	log:postEntry( reportSpell( shadowMend) )
	-- end



end
--******************************************************************************************
--										SHADOW WORD: VOID
--******************************************************************************************
local function parseSwVoid( stats )
	local dmgTable = shadowWordVoid
	local infoTable = shadowWordVoidInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										APPARITION
--******************************************************************************************
local function parseApparition( stats )
	local dmgTable = apparition
	local infoTable = apparitionInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										DARK VOID
--******************************************************************************************
local function parseDarkVoid(stats)
	local dmgTable = darkVoid
	local infoTable = darkVoidInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										VOID ERUPTION
--******************************************************************************************
local function parseVoidEruption( stats)
	local dmgTable = voidEruption
	local infoTable = voidEruptionInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										VOID BOLT
--******************************************************************************************
local function parseVoidBolt( stats )
	local dmgTable = voidBolt
	local infoTable = voidBoltInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										DARK ASCENSION
--******************************************************************************************
local function parseDarkAscention( stats )
	local dmgTable = darkAscension
	local infoTable = darkAscensionInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										SHADOW MEND
--******************************************************************************************
local function parseShadowMend( stats )
	local dmgTable = shadowMend
	local infoTable = shadowMendInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										SHADOW CRASH
--******************************************************************************************
local function parseShadowCrash( stats )
	local dmgTable = shadowCrash
	local infoTable = shadowCrashInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										MIND BOMB
--******************************************************************************************
local function parseMindBomb( stats )
	local dmgTable = mindBomb
	local infoTable = mindBombInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										SHADOW WORD: DEATH
--******************************************************************************************
local function parseSwDeath( stats )
	local dmgTable = shadowWordDeath
	local infoTable = shadowWordDeathInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		

end
--******************************************************************************************
--										SURRENDER TO MADNESS
--******************************************************************************************
local function surrender( stats )
	local dmgTable = surrender
	local infoTable = surrenderInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
end
--******************************************************************************************
--										VOID TORRENT
--******************************************************************************************
local function parseVoidTorrent( stats )
	local dmgTable = voidTorrent
	local infoTable = voidTorrentInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
end
--******************************************************************************************
--										MIND BENDER
--******************************************************************************************
local function parseMindBender( stats )
	local dmgTable = bender
	local infoTable = benderInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end
--******************************************************************************************
--										SHADOW FIEND
--******************************************************************************************
local function parseShadowFiend( stats )
	local dmgTable = fiend
	local infoTable = fiendInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end
end

--******************************************************************************************
--									    MIND FLAY
--******************************************************************************************
local function parseMindFlay( stats )
	local dmgTable = mindFlay
	local infoTable = mindFlayInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
	return parseSpell( dmgTable, stats )
end
--******************************************************************************************
--									    MIND SEAR
--******************************************************************************************
local function parseMindSear( stats )
	local dmgTable = mindSear
	local infoTable = mindSearInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
	return parseSpell( dmgTable, stats )
end
--******************************************************************************************
--										VAMPIRIC TOUCH
--******************************************************************************************
local function parseVTouch( stats )
	local dmgTable = vampiricTouch
	local infoTable = vampiricTouchInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end
	
	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
	return parseSpell( dmgTable, stats )
end
--******************************************************************************************
--										PARSE SHADOW WORD: PAIN
--******************************************************************************************
local function parseSwPain(stats)
	local dmgTable = shadowWordPain
	local infoTable = shadowWordPainInfo

	if infoTable[1] == nil then
		infoTable = { initSpellInfo( stats ) }
	end

	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
	return parseSpell( dmgTable, stats )
end
--******************************************************************************************
--										PARSE MIND BLAST
--******************************************************************************************
local function parseMindBlast( dmgTable, infoTable, stats )

	if infoTable[1] == 0 then
		infoTable = { initSpellInfo( stats ) }
	end
	
	-- If this is the first time through, the table will not
	-- have been initialized and the DMG_SPELL_ID value will be
	-- 0 (zero). 
	if dmgTable[DMG_SPELL_ID] ~= 0 then
		local result = validateSpellDmgTable( dmgTable )
		if result[1] == FAILURE then
			emf.postErrorMsg( result )
		end
	end		
	return parseSpell( dmgTable, stats )
end
--******************************************************************************************
--									    PARSE COMBAT EVENTS
--	Called from CombatLog.lua
--******************************************************************************************
function priest:parseCombatEvents( stats )
	local spellName = stats[SPELLNAME]
	local timeStamp = stats[TIMESTAMP]
	local eventType = stats[EVENT_TYPE]
	local logPrefix = string.format("%.02f, %s, %s", timeStamp, eventType, spellName )
	local logSuffix = string.format(" \n")

	if 	eventType ~= "SPELL_DAMAGE" and 
		eventType ~= "SPELL_PERIODIC_DAMAGE" and
		eventType ~= "SPELL_AURA_APPLIED" and
		eventType ~= "SWING_DAMAGE" and
		eventType ~= "SPELL_SUMMON" and
		eventType ~= "SPELL_ENERGIZE" and
		eventType ~= "SPELL_AURA_REMOVED" then			
			return nil
	end

	if validateSpellName( spellName ) == false then
		local result = errors:setErrorResult("ARG_INVALID", debugstack() )
		emf:postErrorMsg( result )
		return nil
	end

	-- see https://wow.gamepedia.com/API_UnitPowerType
	if eventType == "SPELL_ENERGIZE" then
		local powerType, powerName = UnitPowerType( "Player" )
		local primaryAmt = stats[15]
		logSuffix = string.format(", %s %d %s\n", L["GAINED"], primaryAmt, powerName )
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
	if spellName == "Shadow Word: Void" then
		logSuffix =  parseSwVoid( stats )
	end
	if spellName == "Mind Blast" then 
		logSuffix =  parseMindBlast(stats )
	end
	if spellName == "Shadowy Apparition" then
		logSuffix = parseApparition( stats )
	end
	if spellName == "Vampiric Touch" then
        logSuffix =  parseVTouch(stats)
	end
    if spellName == "Mind Flay" then
        logSuffix = parseMindFlay(stats)
	end
	if spellName == "Mind Sear" then
		logSuffix = parseMindSear(stats) 
	end
	if spellName == "Dark Void" then
		logSuffix = parseDarkVoid(stats)
	end
	if spellName == "Void Eruption" then
		logSuffix = parseVoidEruption( stats)
	end
	if spellName == "Void Bolt" then
		logSuffix = parseVoidBolt( stats )
	end

	return logPrefix..logSuffix
end

