-- Utils.lua

local addonName, MTP = ...
MTP.Utils = {}
utils = MTP.Utils

local L = MTP.L
local P = errors

-- returns true if the current expansion is CLASSIC
function utils.isClassic()
    local isClassic = false
    local expansion = GetAddOnMetadata( Defaults[ADDON_C_NAME], Defaults[EXPANSION_C_FIELD] )	-- BLIZZ API ENTRY
    
    if expansion == nil then
        local result = error.setErrorResult(RETURN_C_NIL, debugstack() )
		errors:postResult( result )
        return isClassic
    end
  
	if utils.toUpper(expansion) == "CLASSIC" then
        isClassic = true
    end
    return isClassic
end

function utils.getCalendarDate()
	  
	local d = C_DateAndTime.GetCurrentCalendarTime()
	local dateStr = string.format("%02d:%02d, %s, %d %s %d", 
								d.hour, 
								d.minute, 
								CALENDAR_WEEKDAY_NAMES[d.weekday], 
								d.monthDay, 
								CALENDAR_FULLDATE_MONTH_NAMES[d.month], 
								d.year)
	return( dateStr)
end

-- num  the number to be rounded
-- places   the precision (e.g., 3 is 3 digits tot he right of the decimal place)
function utils.round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

---------------------------------------------------------------------------------------------
--                      For debugging purposes
---------------------------------------------------------------------------------------------
-- local DEBUG_C_ENABLED = errors.isDebugEnabled()

-- function utils.isFileLoaded()
-- 	return true
-- end
