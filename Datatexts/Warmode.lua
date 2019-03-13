local E, L, V, P, G, _ = unpack(ElvUI)
local DT = E:GetModule("DataTexts")

--Cache global variables
--Lua functions
local floor = floor
local format = string.format
--WoW API / Variables
local C_PvP_IsWarModeActive = C_PvP.IsWarModeActive
local C_PvP_IsWarModeDesired = C_PvP.IsWarModeDesired
local C_PvP_IsWarModeFeatureEnabled = C_PvP.IsWarModeFeatureEnabled
local C_PvP_ToggleWarMode = C_PvP.ToggleWarMode
local C_PvP_CanToggleWarMode = C_PvP.CanToggleWarMode

local InCombatLockdown = InCombatLockdown

local function OnEnter(self)
    E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)

    DT:SetupTooltip(self)

    DT.tooltip:ClearLines()

    DT.tooltip:AddLine("|cffFFFFFFLeft Click:|r Toggle War Mode")

    DT.tooltip:Show()
end

--azeriteItemsList
function OnClick(self, button)
    if button == "LeftButton" then
        DT.tooltip:Hide()

        if C_PvP_CanToggleWarMode() then
            C_PvP_ToggleWarMode()
        end
    end
end

local function OnEvent(self, event, unit)
    local color
    local icon
    if C_PvP_IsWarModeDesired() then
        color = "ff0000"
        icon = " |TInterface\\Icons\\ui_warmode:16|t "
    else
        color = "00ff00"
        icon = ""
    end

    self.text:SetText(format("%s|cff%sWar Mode%s", icon, color, icon))
end

local events = {
    "PLAYER_ENTERING_WORLD",
    "WAR_MODE_STATUS_UPDATE",
    "PLAYER_FLAGS_CHANGED"
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
DT:RegisterDatatext("War Mode", events, OnEvent, nil, OnClick, OnEnter)
