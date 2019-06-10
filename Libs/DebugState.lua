-- DebugState.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 15 December, 2018

local _, MTP = ...
MTP.DebugState = {}
debugState = MTP.DebugState

local dbgSandBox = "SandBox.lua loaded"
local dbgErrors = "Errors.lua loaded"
local dbgWrappers = "Wrappers.lua loaded"
local dbgErrorMsg = "ErrorMsgFrame.lua loaded"
local dbgUtils = "Utils.lua loaded"
local dbgScrollingMsg = "ScrollingMsgFrame.lua loaded"
local dbgEquipSet = "EquipSet.lua loaded"
local dbgArmorItems = "ArmorItems.lua loaded"
local dbgPlayer = "Player.lua loaded"
local dbgEvent = "EventHandler.lua loaded"

local function postLoadedFiles()
    local logStr = nil

    if sbx.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgSandBox )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgSandBox )
        display.postMessage( logStr )
    end
    
    if errors.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgErrors )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgErrors )
        display.postMessage( logStr )
    end

    if wpr.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgWrappers )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgWrappers )
        display.postMessage( logStr )
    end


    if emf.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgErrorMsg )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgErrorMsg )
        display.postMessage( logStr )
    end

    if utils.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgUtils )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgUtils )
        display.postMessage( logStr )
    end

    if display.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgScrollingMsg )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgScrollingMsg )
        display.postMessage( logStr )
    end

    if eqs.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgEquipSet )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgEquipSet )
        display.postMessage( logStr )
    end

    if items.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgArmorItems )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgArmorItems )
        display.postMessage( logStr )
    end

    if player.isFileLoaded() == true then
        logStr = string.format("[LOG] %s",  dbgPlayer )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s failed to load",  dbgPlayer )
        display.postMessage( logStr )
    end

    local eventFileLoaded = false
    eventFileLoaded = event.isFileLoaded()
    if eventFileLoaded == true then
        logStr = string.format("[LOG] %s",  dbgEvent )
        display.postMessage( logStr )
    else
        logStr = string.format("[LOG] %s FAILED TO LOAD",  dbgEvent)
        display.postMessage( logStr )
    end

end

postLoadedFiles()
