local E, L, V, P, G, _ = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local EDT = select(2, ...).EDT


--Cache global variables
--Lua functions

local format = string.format
--WoW API / Variables
local C_PvP_IsWarModeActive = C_PvP.IsWarModeActive
local C_PvP_IsWarModeDesired = C_PvP.IsWarModeDesired
local C_PvP_ToggleWarMode = C_PvP.ToggleWarMode
local C_PvP_CanToggleWarMode = C_PvP.CanToggleWarMode
local C_PvP_CanToggleWarModeInArea = C_PvP.CanToggleWarModeInArea
local C_PvP_GetWarModeRewardBonus = C_PvP.GetWarModeRewardBonus
local IsResting = IsResting
local UnitFactionGroup = UnitFactionGroup

local GameTooltip_AddColoredLine = GameTooltip_AddColoredLine
local GameTooltip_AddNormalLine = GameTooltip_AddNormalLine

local PVP_WAR_MODE_DESCRIPTION_FORMAT = PVP_WAR_MODE_DESCRIPTION_FORMAT
local PLAYER_FACTION_GROUP = PLAYER_FACTION_GROUP
local PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA = PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA
local PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA = PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA
local PVP_WAR_MODE_NOT_NOW_HORDE = PVP_WAR_MODE_NOT_NOW_HORDE
local PVP_WAR_MODE_NOT_NOW_ALLIANCE = PVP_WAR_MODE_NOT_NOW_ALLIANCE
local RED_FONT_COLOR = RED_FONT_COLOR

local function OnEnter(self)
    E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)

    DT:SetupTooltip(self)

    DT.tooltip:ClearLines()

    local warModeRewardBonus = C_PvP_GetWarModeRewardBonus()

    GameTooltip_AddNormalLine(DT.tooltip, PVP_WAR_MODE_DESCRIPTION_FORMAT:format(warModeRewardBonus), true)

    local canToggleWarmode = C_PvP_CanToggleWarMode(true)
    local canToggleWarmodeOFF = C_PvP_CanToggleWarMode(false)

    local warmodeErrorText
    if (not canToggleWarmode or not canToggleWarmodeOFF) then

        if(not C_PvP_CanToggleWarModeInArea()) then
            if(C_PvP_IsWarModeDesired()) then
                if(not canToggleWarmodeOFF and not IsResting()) then
                    warmodeErrorText = UnitFactionGroup('player') == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA or PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA;
                end
            else
                if(not canToggleWarmode) then
                    warmodeErrorText = UnitFactionGroup('player') == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
                end
            end
        end

        GameTooltip_AddColoredLine(DT.tooltip, warmodeErrorText, RED_FONT_COLOR, true)
    end

    DT.tooltip:Show()
end

local function OnClick(_, button)
    if button == 'LeftButton' then
        DT.tooltip:Hide()

        if C_PvP_CanToggleWarMode(not C_PvP_IsWarModeActive()) then
            C_PvP_ToggleWarMode()
        end
    end
end

local function OnEvent(self)
    local color
    local icon
    if C_PvP_IsWarModeDesired() then
        color = 'ff0000'
        icon = ' |TInterface\\Icons\\ui_warmode:16|t '
    else
        color = '00ff00'
        icon = ''
    end

    self.text:SetText(format('%s|cff%sWar Mode%s', icon, color, icon))
end

local events = {
    'WAR_MODE_STATUS_UPDATE',
    'PLAYER_FLAGS_CHANGED'
}

DT:RegisterDatatext('War Mode', EDT.DTCategory, events, OnEvent, nil, OnClick, OnEnter)