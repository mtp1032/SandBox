--------------------------------------------------------------------------------------
-- SellItems.lua
-- Sells all items in all bags according to their quaility - Grey, White, Green, etc.
-- AUTHOR: Michael Peterson
-- V 0.1 -- Sells only Grey and White items as specified in SlashCmds.lua
-- ORIGINAL DATE: 14 June, 2019
--------------------------------------------------------------------------------------
local ADDON_C_NAME, MTP = ...
MTP.SellItems = {}
sell = MTP.SellItemss

local L = MTP.L
local E = errors
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
