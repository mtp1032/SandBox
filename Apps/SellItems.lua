--------------------------------------------------------------------------------------
-- SellItems.lua
-- Sells all items in all bags according to their quaility - Grey, White, Green, etc.
-- 		See SellJunk video - https://www.youtube.com/watch?v=dwg8SmxnA9Y
-- For info on how to setup the options panel see the following addons:
-- Azeroth Autopilot, Bagnon, Details, GatherMate 2, CHACHING, HandyNotes, Mogit, Norganna 
-- 		Slide Bar, SexyMap, and Titan Panel
-- Azeroth Autopilot - loads an external options menu
-- Bagnon - loads an external options menu
-- Gathermate 2 - Interface closely models what I want SellItems to display
-- Titan Panel - Not an options screen. Just an information display panel.
-- CHACHING - like Gathermate 2
-- AUTHOR: Michael Peterson
-- V 0.1 -- Sells only Grey and White items as specified in SlashCmds.lua
-- ORIGINAL DATE: 14 June, 2019
--------------------------------------------------------------------------------------
local ADDON_C_NAME, MTP = ...
MTP.SellItems = {}
sellItems = MTP.SellItems

local L = MTP.L
local E = errors

local sellingEnabled = false
local sellGrey = false
local sellWhite = false

local function enableChaChing()
	sellingEnabled = true
	print("Cha-Ching is Enabled = true")
end
local function disableChaChing()
	sellingEnabled = false
end


local function sellAllGreyItems()
	sellGrey = true
end
local function sellNoGreyItems()
	sellGrey = false
end
local function sellAllWhiteItems()
	sellWhite = true
end
local function sellNoWhiteItems()
	sellWhite = false
end

local CHACHING = {
	DefaultSettings = {
		Active = true
	};
	Version = "0.01", -- Version number (text format)
	VersionNumber = 44800, -- Numeric version number for checking out-of-date clients
	DataCode = "4",
	isEnabled = false,
	sellAllGreyItems = false,
	sellAllWhiteItems = false
};

local function CHACHING_SetDefaults()
	CHACHING.Settings.Active = CHACHING.DefaultSettings.Active;
	-- CHACHING_SaveSettings();
end

local function CHACHING_RenderOptions()
	CHACHING.UIRendered = true;

	local ConfigurationPanel = CreateFrame("FRAME","CHACHING_MainFrame");
	ConfigurationPanel.name = "CHACHING";
	InterfaceOptions_AddCategory(ConfigurationPanel);	-- Register the Configuration panel with LibUIDropDownMenu

	-- Print a header at the top of the panel
	local IntroMessageHeader = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormalLarge");
	IntroMessageHeader:SetPoint("TOPLEFT", 10, -10);
	IntroMessageHeader:SetText("Cha-Ching Version "..CHACHING.Version );

	-- Create three check buttons, one to enable the addon, one to sell grey iterms, and one to sell white items
	local EnabledButton = CreateFrame("CheckButton", "CHACHING_EnabledButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	EnabledButton:SetPoint("TOPLEFT", 10, -40)
	EnabledButton.tooltip = "Check box to enable Cha-Ching, uncheck box to disable all selling"
	getglobal(EnabledButton:GetName().."Text"):SetText("Enable Cha-Ching?");
	EnabledButton:SetScript("OnClick",
		function()
			local isChecked = EnabledButton:GetChecked()
			if isChecked then
				enableChaChing()
			else
				disableChaChing()
			end
		end )

	local GreyQualityButton = CreateFrame("CheckButton", "CHACHING_GreyQualityButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	GreyQualityButton:SetPoint("TOPLEFT", 10, -95)
	GreyQualityButton.tooltip = "Check to sell all grey items in your inventory."
	getglobal(GreyQualityButton:GetName().."Text"):SetText("Sell All Grey Items!");
	GreyQualityButton:SetScript("OnClick",
	function()
		local isChecked = GreyQualityButton:GetChecked()
		if isChecked then
			sellAllGreyItems()
		else
			sellNoGreyItems()
		end
	end )

	local WhiteQualityButton = CreateFrame("CheckButton", "CHACHING_WhiteQualityButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	WhiteQualityButton:SetPoint("TOPLEFT", 200, -95)
	WhiteQualityButton.tooltip = "Check to sell all white items in your inventory. But be careful! Many potions, flasks, reagents, food, etc., are white)"
	getglobal(WhiteQualityButton:GetName().."Text"):SetText("Sell All White Items?");
	WhiteQualityButton:SetScript("OnClick",
	function()
		local isChecked = WhiteQualityButton:GetChecked()
		if isChecked then
			print("White quality button was unchecked and is now checked.")
			sellAllWhiteItems()
		else
			print("White quality button was checked and is now unchecked.")
			sellNoWhiteItems()
		end
	end )

end

CHACHING_RenderOptions()


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
