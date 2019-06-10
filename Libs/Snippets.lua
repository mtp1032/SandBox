-- Localizing stuff

local L = DBM:GetModLocalization("MyFirstBossMod")
L:SetGeneralLocalization{    
    name = "Hello, World with DBM" 
}

L:SetOptionLocalization{
    WarnHelloWorld = "Show Hello, World announce",
    SpecWarnHelloWorld = "Show Hello, World special warning",
    TimerHelloWorld = "Show Hello, World timer",
 }
 
 L:SetTimerLocalization{
    TimerHelloWorld = "Hello, World", 
 }

 
tbl1 = {“alpha”, “beta”, “gamma”} 
tbl2 = {“delta”, “epsilon”, “zeta”}
tbl3 = {} 

mt = {} 
setmetatable(tbl1, mt) 
setmetatable(tbl2, mt) 
setmetatable(tbl3, mt)



tbl4 = {[“Night elf”] = “Nachtelf”} 
setmetatable(tbl4, mt) 

enUS_defaults = { [“Human”] = “Human”, 
[“Night elf”] = “Night elf”, } 

mt.___index = enUS_defaults


local guid = UnitGUID("target");
local B = tonumber(guid:sub(5,5), 16);
local maskedB = B % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0xf
local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"};
print("Your target is a " .. (knownTypes[maskedB] or " unknown entity!"));


local bagMap = { 
    [0x100] = 1, 
    [0x200] = 2, 
    [0x400] = 3, 
    [0x800] = 4, 
} 
    
local function translateItemLocation(itemLocation) 
    if bit.band(itemLocation, ITEM_INVENTORY_BAGS) > 0 then 
        local bag = bagMap[bit.band(itemLocation, MASK_BAG)] 
        local slot = bit.band(itemLocation, MASK_SLOT) 
        return bag, slot 
    elseif bit.band(itemLocation, ITEM_INVENTORY_BACKPACK) > 0 then
        local slot = bit.band(itemLocation, MASK_SLOT)
        return 0, slot 
    end
end

-- Also, if you have a legitimate global variable but performance is an 
-- issue, create a local copy. For example, if your addon needs to 
-- use string.find several times per frame, add the following line 
-- to the beginning (you can name it anything you want, perhaps strfind): 

local string_find = string.find 


-- Notice that this doesn't call string.find (as shown by the lack of 
-- parentheses), but merely copies the function reference to the new 
-- local variable. By using string_find throughout the file, you will 
-- save two table lookups on each call (_G → string → find). These 
-- savings can add up quite quickly for addons that do a lot of data 
-- processing each frame.

-- error() function
if (type(name) == “string”) then
    print(“Hello ” .. name)    
elseif (type(name) == “nil”) then      
    print(“Hello friend”)    
else      
    error(“Invalid name was entered”)    
end

-- produces the following error message:
-- stdin:7: Invalid name was entered 
-- stack traceback: [C]: 
-- in function ‘error’ 
-- stdin:7: in function ‘greeting’ 
-- stdin:1: in main chunk 
-- [C]: ?

