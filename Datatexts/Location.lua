local E, L, _, P = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')
local EDT = select(2, ...).EDT


--WoW API caching
local WrapTextInColorCode = WrapTextInColorCode
local InCombatLockdown = InCombatLockdown
local GetZonePVPInfo = GetZonePVPInfo
local IsInInstance = IsInInstance
--

local mapInfo = E.MapInfo

local colors = {
	["arena"] = {r = 1, g = 0.1, b = 0.1},
	["combat"] = {r = 1, g = 0.1, b = 0.1},
	["contested"] = {r = 1, g = 0.7, b = 0.10},
	["friendly"] = {r = 0.1, g = 1, b = 0.1},
	["hostile"] = {r = 1, g = 0.1, b = 0.1},
	["instance"] = {r = 1, g = 0.1, b =  0.1},
	["sanctuary"] = {r = 0.41, g = 0.8, b = 0.94},
}

local function GetStatus()
	local pvpType = GetZonePVPInfo()
	local inInstance = IsInInstance()

	return inInstance and colors["instance"] or colors[pvpType] or {r = 1, g = 1, b = 0}
end

local function OnEvent(self)
	if not mapInfo.mapID then
		self.text:SetText('N/A')
		return
	end

	local db = E.db.extradatatexts.datatexts.location

	local text

	if db.showContinent then
		text = mapInfo.continentName
	end

	if db.showZone then
		text = text and (text .. ': ' .. mapInfo.zoneText) or mapInfo.zoneText
	end

	if db.showSubZone then
		text = text and (text .. ': ' .. mapInfo.subZoneText) or mapInfo.subZoneText
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

local function OnEnter()
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

DT:RegisterDatatext(L['Location'], EDT.DTCategory, events, OnEvent, nil, OnClick, OnEnter)