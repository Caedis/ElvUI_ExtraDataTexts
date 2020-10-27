local E = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local format = string.format
local tonumber = tonumber
local ipairs = ipairs

--WoW API / Variables
local setCV = SetCVar
local getCV = GetCVar
local IsShiftKeyDown = IsShiftKeyDown
local SOUND = SOUND
local ShowOptionsPanel = ShowOptionsPanel

local Sound_GameSystem_GetOutputDriverNameByIndex = Sound_GameSystem_GetOutputDriverNameByIndex
local Sound_GameSystem_GetNumOutputDrivers = Sound_GameSystem_GetNumOutputDrivers
local Sound_GameSystem_RestartSoundSystem = Sound_GameSystem_RestartSoundSystem


local volumeCVars =
	{
		[1] = {Name = MASTER, CVs = { Volume = 'Sound_MasterVolume', Enabled = 'Sound_EnableAllSound' }, Enabled = nil},
		[2] = {Name = SOUND_VOLUME, CVs = { Volume = 'Sound_SFXVolume', Enabled = 'Sound_EnableSFX' }, Enabled = nil},
		[3] = {Name = AMBIENCE_VOLUME, CVs = { Volume = 'Sound_AmbienceVolume', Enabled = 'Sound_EnableAmbience' }, Enabled = nil},
		[4] = {Name = DIALOG_VOLUME, CVs = { Volume = 'Sound_DialogVolume', Enabled = 'Sound_EnableDialog' }, Enabled = nil},
		[5] = {Name = MUSIC_VOLUME, CVs = { Volume = 'Sound_MusicVolume', Enabled = 'Sound_EnableMusic' }, Enabled = nil}
	}


local activeVolumeIndex = 1
local activeVolume = volumeCVars[activeVolumeIndex]
local menu = {
	[1] = {text = 'Select Volume Stream', isTitle = true, notCheckable = true},
	[7] = {text = 'Output Audio Device', isTitle = true, notCheckable = true}
}
local toggleMenu = {
	[1] = {text = 'Toggle Volume Stream', isTitle = true, notCheckable = true},
	[7] = {text = 'Output Audio Device', isTitle = true, notCheckable = true}
}

local function GetStatusColor(vol, text)
	if not text then
		text = vol.Name
	end

	return format('|cFF%s%s|r',(getCV(vol.CVs.Volume) == '0' or not vol.Enabled) and 'FF0000' or '00FF00', text)
end

local function OnEnter(self)
	E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)

	DT:SetupTooltip(self)
	DT.tooltip:ClearLines()

	local audioDev = Sound_GameSystem_GetOutputDriverNameByIndex(getCV('Sound_OutputDriverIndex'))
	--DT.tooltip:AddLine(format('|cffFFFFFFActive Output Audio Device|r: %s', audioDev))
	DT.tooltip:AddLine('|cffFFFFFFActive Output Audio Device|r')
	DT.tooltip:AddLine(audioDev)
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine('|cffFFFFFFVolume Streams|r')
	for _,vol in ipairs(volumeCVars) do
		DT.tooltip:AddDoubleLine(vol.Name, GetStatusColor(vol, format('%.f', getCV(vol.CVs.Volume) * 100) .. '%'))
	end

	DT.tooltip:AddLine(' ')


	DT.tooltip:AddLine('|cffFFFFFFLeft Click:|r Select Volume Stream')
	DT.tooltip:AddLine('|cffFFFFFFRight Click:|r Toggle Volume Stream')
	DT.tooltip:AddLine('|cffFFFFFFBoth:|r Select Output Audio Device')
	DT.tooltip:AddLine('|cffFFFFFFShift + Left Click:|r Open System Audio Panel')

	DT.tooltip:Show()
end



local function OnEvent(self, event, ...)
	activeVolume = volumeCVars[activeVolumeIndex]

	if (event == 'ELVUI_FORCE_UPDATE' ) then -- I hate you Azil <3

		self:EnableMouseWheel(true)

		self:SetScript('OnMouseWheel', function(_, delta)
			local vol = getCV(activeVolume.CVs.Volume);
			local volScale = 100;

			if (IsShiftKeyDown()) then
				volScale = 10;
			end

			vol = vol + (delta / volScale)

			if (vol >= 1) then
				vol = 1
			elseif (vol <= 0) then
				vol = 0
			end

			setCV(activeVolume.CVs.Volume, vol, 'EDT_VOLUME_CHANGED')
		end)

		OnEvent(self, 'CVAR_UPDATE', 'EDT_VOLUME_TEXT_CHANGE')
		OnEvent(self, 'CVAR_UPDATE', 'EDT_VOLUME_STREAM_TOGGLE')
		OnEvent(self, 'CVAR_UPDATE', 'EDT_OUTPUT_SOUND_DEVICE_CHANGED')
		OnEvent(self, 'CVAR_UPDATE', 'EDT_VOLUME_CHANGED', getCV(activeVolume.CVs.Volume))
	end


	if event == 'CVAR_UPDATE' then
		local cvar_name, value = ...

		if cvar_name == 'EDT_VOLUME_CHANGED' then
			self.text:SetText(activeVolume.Name..': '..GetStatusColor(activeVolume, format('%.f', value * 100) .. '%'))
		elseif cvar_name == 'EDT_VOLUME_TEXT_CHANGE' then
			for i = 1, #volumeCVars do
				menu[i+1]={
					text = volumeCVars[i].Name,
					checked = i == activeVolumeIndex,
					func = function()
						activeVolumeIndex = i;
						OnEvent(self, 'CVAR_UPDATE', 'EDT_VOLUME_TEXT_CHANGE');
						OnEvent(self, 'CVAR_UPDATE', 'EDT_VOLUME_CHANGED', getCV(volumeCVars[i].CVs.Volume));
					 end
				}
			end
		elseif cvar_name == 'EDT_VOLUME_STREAM_TOGGLE' then
			for i = 1, #volumeCVars do
				volumeCVars[i].Enabled = getCV(volumeCVars[i].CVs.Enabled) == '1'
				toggleMenu[i + 1] = {
					text = volumeCVars[i].Name,
					checked = getCV(volumeCVars[i].CVs.Enabled) == '1',
					func = function()
						setCV(
							volumeCVars[i].CVs.Enabled,
							(not volumeCVars[i].Enabled) and '1' or '0',
							'EDT_VOLUME_STREAM_TOGGLE')
						OnEvent(self, 'CVAR_UPDATE', 'EDT_VOLUME_CHANGED', getCV(activeVolume.CVs.Volume));
					end
				}
			end

		elseif cvar_name == 'EDT_OUTPUT_SOUND_DEVICE_CHANGED' then
			local numDevices = Sound_GameSystem_GetNumOutputDrivers()
			local activeIndex = tonumber(getCV('Sound_OutputDriverIndex'))

			for i = 0, numDevices -1 do
				local item = {
					text = Sound_GameSystem_GetOutputDriverNameByIndex(i),
					checked = i == activeIndex,
					func = function() setCV('Sound_OutputDriverIndex', i, 'EDT_OUTPUT_SOUND_DEVICE_CHANGED'); Sound_GameSystem_RestartSoundSystem(); end
				}
				menu[7 + i + 1] = item
				toggleMenu[7 + i + 1] = item
			end
		end
	end
end



local function OnClick(self, button)

	if button == 'LeftButton' then
		if IsShiftKeyDown() then
			ShowOptionsPanel(_G.VideoOptionsFrame, _G.GameMenuFrame, SOUND)
			return
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menu, DT.EasyMenu, nil, nil, nil, 'MENU')
	elseif button == 'RightButton' then
		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(toggleMenu, DT.EasyMenu, nil, nil, nil, 'MENU')
	end
end

local events = {
	'CVAR_UPDATE'
}

DT:RegisterDatatext('Volume', 'ExtraDataTexts', events, OnEvent, nil, OnClick, OnEnter)