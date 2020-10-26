local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua caching
local format,strjoin = string.format, string.join

--WoW API caching
local WrapTextInColorCode = WrapTextInColorCode
local InCombatLockdown = InCombatLockdown
local GetZonePVPInfo = GetZonePVPInfo
local IsInInstance = IsInInstance
--

local mapInfo = E.MapInfo


--credit LocationPlus by Benik and Blizz's ZoneText.lua
local function GetStatus()
	local pvpType = GetZonePVPInfo()
	local inInstance = IsInInstance()
	local r, g, b = 1, 1, 0

	if (pvpType == "sanctuary") then
		r, g, b = 0.41, 0.8, 0.94
	elseif(pvpType == "arena") then
		r, g, b = 1, 0.1, 0.1
	elseif(pvpType == "friendly") then
		r, g, b = 0.1, 1, 0.1
	elseif(pvpType == "hostile") then
		r, g, b = 1, 0.1, 0.1
	elseif(pvpType == "contested") then
		r, g, b = 1, 0.7, 0
	elseif(pvpType == "combat" ) then
		r, g, b = 1, 0.1, 0.1
	elseif inInstance then
		r, g, b = 1, 0.1, 0.1
	else 
		r, g, b = 1.0, 0.93, 0.76
	end

	return {r = r, g = g, b = b}
end




local function OnEvent(self, event, ...)
	if not mapInfo.mapID then
		self.text:SetText('N/A')
		return
	end

	local db = E.db.extradatatexts.datatexts.location

	local text

	if db.showSubZone then
		text = mapInfo.subZoneText
	end

	if db.showZone then
		text = text and (text .. ', ' .. mapInfo.zoneText) or mapInfo.zoneText 
	end

	if db.showContinent then
		text = text and (text .. ', ' .. mapInfo.continentName) or mapInfo.continentName
	end



	local color = db.customColor or P.extradatatexts.datatexts.customColor
	if db.color == 'CLASS' then
		local cc = E:ClassColor(E.myclass)
		color = {r = cc.r, g = cc.g, b = cc.b}
	elseif db.color == 'REACTION' then
		color = GetStatus()
	end

	local colorCode = 'ff'..E:RGBToHex(color.r, color.g, color.b, '')

	self.text:SetFormattedText(WrapTextInColorCode(text or 'N/A', colorCode))
end

--credit: ElvUI - Coordinates.lua datatext
local function OnClick()
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
	_G.ToggleFrame(_G.WorldMapFrame)
end

local function OnEnter(self)
	DT.tooltip:ClearLines()
	-- code goes here
	DT.tooltip:Show()
end

--[[
	ELVUI_FORCE_UPDATE is auto-included
]]
local events = {
	'LOADING_SCREEN_DISABLED',
	'ZONE_CHANGED_NEW_AREA',
	'ZONE_CHANGED_INDOORS',
	'ZONE_CHANGED'
}

DT:RegisterDatatext(L['Location'], 'ExtraDataTexts', events, OnEvent, nil, OnClick, OnEnter)
