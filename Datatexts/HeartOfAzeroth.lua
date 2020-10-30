local E, L, V, P, G, _ =  unpack(ElvUI);
local DT = E:GetModule('DataTexts')
local EDT = select(2, ...).EDT


--Cache global variables
--Lua functions
local floor = floor
local format = string.format
--WoW API / Variables
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem
local C_Item_DoesItemExist = C_Item.DoesItemExist
local OpenAzeriteEmpoweredItemUIFromItemLocation = OpenAzeriteEmpoweredItemUIFromItemLocation

local InCombatLockdown = InCombatLockdown
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local GetItemIcon = GetItemIcon
local Item = Item
local ItemLocation = ItemLocation
local ARTIFACT_POWER = ARTIFACT_POWER
local AZERITE_POWER_TOOLTIP_BODY = AZERITE_POWER_TOOLTIP_BODY
local AZERITE_POWER_TOOLTIP_TITLE = AZERITE_POWER_TOOLTIP_TITLE

local menuFrame = CreateFrame("Frame", "AzeriteItemsDatatextClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local azeriteItemsList = {
    { text = 'Select Azerite Item', isTitle = true, notCheckable = true },
	{ slot = 'HeadSlot', textTemplate = 'Helm: %s', notCheckable = true },
	{ slot = 'ShoulderSlot', textTemplate = 'Shoulders: %s', notCheckable = true },
	{ slot = 'ChestSlot', textTemplate = 'Chest: %s', notCheckable = true }
}


local shortNum = function(v)
	if v <= 999 then
		return format("%d", v)
	elseif v >= 1000000000 then
		return format("%.1fb", v/1000000000)
	elseif v >= 1000000 then
		return format("%.1fm", v/1000000)
	elseif v >= 1000 then
		return format("%.1fk", v/1000)
	end
end

local function OnEnter(self)

    E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
    
    DT:SetupTooltip(self)
	
    DT.tooltip:ClearLines()
    --DT.tooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

    local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem();
    
    if not azeriteItemLocation then
        return
    end

	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation);
	local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
	local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
	local xpToNextLevel = totalLevelXP - xp

	local azeriteItemName = azeriteItem:GetItemName()
	--[[ From Blizz Code
	GameTooltip:SetText(AZERITE_POWER_TOOLTIP_TITLE:format(currentLevel, xpToNextLevel), HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_BODY:format(azeriteItemName));
    ]]
    
    
	DT.tooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItemName.." ("..currentLevel..")", nil,  nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddDoubleLine(L["AP:"], format(' %d / %d (%d%%)', xp, totalLevelXP, xp / totalLevelXP  * 100), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', xpToNextLevel, xpToNextLevel / totalLevelXP * 100, 10 * xpToNextLevel / totalLevelXP), 1, 1, 1)
    DT.tooltip:AddLine(' ')
    DT.tooltip:AddLine("|cffFFFFFFLeft Click:|r Show Azerite UI")
    --DT.tooltip:AddLine("|cffFFFFFFRight Click:|r Change Azerite Item") --todo
	DT.tooltip:Show()
end

--azeriteItemsList
local function OnClick(self, button)

    if button == "LeftButton" then
		DT.tooltip:Hide()

        local i = 2;
        for index = 1, 3 do
            local item = azeriteItemsList[index + 1]
            local itemLocation = ItemLocation:CreateFromEquipmentSlot(GetInventorySlotInfo(item.slot));
            item.notCheckable = true;
            if C_Item_DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocation) then
                local itemID = GetInventoryItemID("PLAYER", GetInventorySlotInfo(item.slot))
                local itemName = GetItemInfo(itemID)
                local itemIcon = GetItemIcon(itemID)

                item.text = format(item.textTemplate, itemName)
                item.icon = itemIcon
                item.func = function() OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation) end
                item.disabled = false
            else
                item.text = format(item.textTemplate, 'None Equipped')
                item.icon = nil
                item.func = nil
                item.disabled = true
            end
        end

        _G.EasyMenu(azeriteItemsList, menuFrame, "cursor", -15, -7, "MENU", 2);
    end

end

local function OnEvent(self, event, unit)
	
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem(); 
	
    if (not azeriteItemLocation) then 
        self.text:SetText('Azerite Item Not Found')
		return; 
	end
	
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation); 
	
	local xp, totalXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation);
	local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation); 

	self.text:SetText(format('|cffe6cc80AP|r: %s/%s (%.0f%%)', shortNum(xp), shortNum(totalXP), xp/totalXP * 100))
end


local events = {
    "PLAYER_ENTERING_WORLD",
    "AZERITE_ITEM_EXPERIENCE_CHANGED"
}
--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Azerite', EDT.DTCategory, events, OnEvent, nil, OnClick, OnEnter)

