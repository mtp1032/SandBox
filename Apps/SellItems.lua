--------------------------------------------------------------------------------------
-- SellItems.lua
-- AUTHOR: Michael Peterson
-- Version 0.1
--	Sell all items in all bags according to their quaility - Grey, White, Green, etc.
-- ORIGINAL DATE: 14 June, 2019
--------------------------------------------------------------------------------------
local ADDON_C_NAME, MTP = ...
MTP.SellItems = {}
sell = MTP.SellItemss

local L = MTP.L
local E = errors

--------------------------------------------------------------------------------------
--						QUALITY (RARITY ) values
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

		for i = 1, totalSlots do
			local itemLink = GetContainerItemLink(bagSlot, i )	-- BLIZZ
			if itemLink ~= nil then
				if itemLink then
					_, _, quality, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemLink)
					_, itemCount = GetContainerItemInfo( bagSlot, i )
					if quality == itemQuality and itemSellPrice ~= 0 then
						sumTotal = sumTotal + (itemSellPrice * itemCount)
						mf:postMsg("Sold: ".. itemLink .. " for " .. GetCoinTextureString(itemSellPrice * itemCount))
						UseContainerItem(bagSlot, i )
					end
				end
			end

		end
	end

	print( sumTotal )
end

local ButtonSellItems = CreateFrame( "Button" , "SellItemsBtn" , MerchantFrame, "UIPanelButtonTemplate" )
ButtonSellItems:SetText("Sell Items")
ButtonSellItems:SetWidth(90)
ButtonSellItems:SetHeight(21)
ButtonSellItems:SetPoint("TopRight", -180, -30 )
ButtonSellItems:RegisterForClicks("AnyUp")		
ButtonSellItems:SetScript("Onclick", sellItems )
