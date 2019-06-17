--------------------------------------------------------------------------------------
-- SellItems.lua
-- Sells all items in all bags according to their quaility - Grey, White, Green, etc.
-- 		See SellJunk video - https://www.youtube.com/watch?v=dwg8SmxnA9Y
-- For info on how to setup the options panel see the following addons:
-- Azeroth Autopilot, Bagnon, Details, GatherMate 2, GTFO, HandyNotes, Mogit, Norganna 
-- 		Slide Bar, SexyMap, and Titan Panel
-- Azeroth Autopilot - loads an external options menu
-- Bagnon - loads an external options menu
-- Gathermate 2 - Interface closely models what I want SellItems to display
-- Titan Panel - Not an options screen. Just an information display panel.
-- GTFO - like Gathermate 2
-- AUTHOR: Michael Peterson
-- V 0.1 -- Sells only Grey and White items as specified in SlashCmds.lua
-- ORIGINAL DATE: 14 June, 2019
--------------------------------------------------------------------------------------
local ADDON_C_NAME, MTP = ...
MTP.SellItems = {}
sellItems = MTP.SellItems

local L = MTP.L
local E = errors

ChaChing = {};
ChaChing.panel = CreateFrame( "Frame", "ChaChingPanel", UIParent );  -- Registers in the Interface Addon Options GUI
ChaChing.panel.name = "ChaChing";  -- Sets the name for the parent Category in the Options Panel
 InterfaceOptions_AddCategory(ChaChing.panel); -- Add the panel to the Interface Options
 
 -- Make a child panel to specify what quality/rarity of items to sell (e.g, grey, white, etc.,)
 ChaChing.childpanel = CreateFrame( "Frame", "ChaChingChild", ChaChing.panel);
 ChaChing.childpanel.name = "Item Filters";
 ChaChing.childpanel.parent = ChaChing.panel.name;
 InterfaceOptions_AddCategory(ChaChing.childpanel);

 -- Make a second child panel to specify what specific items the addon is NOT TO SELL
 ChaChing.childpanel = CreateFrame( "Frame", "ChaChingChild", ChaChing.panel);
 ChaChing.childpanel.name = "Item Black list";
 ChaChing.childpanel.parent = ChaChing.panel.name;
 InterfaceOptions_AddCategory(ChaChing.childpanel);

 -- Create an info panel to be displayed when the parent ChChing panel is displayed.
 -- Now, create the bodies of the two child panels


--------------------------------------------------------------------------------------
--						QUALITY (i.e., RARITY) values
--						Presently defined in SlotClass.lua
--------------------------------------------------------------------------------------
-- QUALITY_GREY = 0
-- QUALITY_COMMON = 1
-- QUALITY_UNCOMMON = 2
-- QUALITY__RARE = 3
-- QUALITY__EPIC = 4
-- QUALITY_LEGENDARY = 5
-- QUALITY_ARTIFACT = 6
-- QUALITY_HEIRLOOM = 7

local QUALITY_NOT_SPECIFIED = -1
local itemQuality = QUALITY_NOT_SPECIFIED

function setItemQuality( quality )
	itemQuality = quality
end

local IS_DEBUG_ENABLED = 0
function enableDebug()
	IS_DEBUG_ENABLED = 1
end
function disableDebug()
	IS_DEBUG_ENABLED = 0
end
local function sellItems()
	local result = SUCCESSFUL_RESULT
	local sumTotal = 0

	if itemQuality == QUALITY_NOT_SPECIFIED then
		itemQuality = QUALITY_GREY
	end

	for bagSlot = 0, 4 do
		local totalSlots = GetContainerNumSlots( bagSlot )   -- BLIZZ
		local emptySlots = GetContainerNumFreeSlots( bagSlot )	-- BLIZZ
		if emptySlots == totalSlots then
			return 0
		end

		local itemsSold = 0
		for i = 1, totalSlots do
			local itemLink = GetContainerItemLink(bagSlot, i )	-- BLIZZ
			if itemLink ~= nil then
				if itemLink then
					itemInfo = {GetItemInfo(itemLink)}
					quality = itemInfo[3]
					itemSellPrice = itemInfo[11]
					--_, _, quality, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemLink)
					_, itemCount = GetContainerItemInfo( bagSlot, i )
					if quality == itemQuality and itemSellPrice ~= 0 then
						sumTotal = sumTotal + (itemSellPrice * itemCount)
						UseContainerItem(bagSlot, i )
						itemsSold = itemsSold + 1
						-- mf:postMsg("Sold: ".. itemLink .. " for " .. GetCoinTextureString(itemSellPrice * itemCount))
					end
				end
			end
		end
		local msg = string.format("No items were sold.\n")
		if sumTotal == 0 then
			DEFAULT_CHAT_FRAME:AddMessage(msg)
		else
			local word = "Items"
			if itemsSold == 1 then 
				word = "Item"
			end
			msg = string.format("%d %s sold for %s\n", itemsSold, word, GetCoinTextureString(sumTotal ))
			DEFAULT_CHAT_FRAME:AddMessage( msg )
		end
	end
end

local ButtonSellItems = CreateFrame( "Button" , "SellItemsBtn" , MerchantFrame, "UIPanelButtonTemplate" )
ButtonSellItems:SetText("Sell Items")
ButtonSellItems:SetWidth(90)
ButtonSellItems:SetHeight(21)
ButtonSellItems:SetPoint("TopRight", -180, -30 )
ButtonSellItems:RegisterForClicks("AnyUp")		
ButtonSellItems:SetScript("Onclick", sellItems )
