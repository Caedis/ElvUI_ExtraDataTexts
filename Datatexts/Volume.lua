local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local select = select
local format, join = string.format, string.join
local ceil = math.ceil
local strform = string.format
local tonumber = tonumber
local tostring = tostring

--WoW API / Variables
local setCV = SetCVar
local getCV = GetCVar
local IsShiftKeyDown = IsShiftKeyDown
local SOUND = SOUND
local ShowOptionsPanel = ShowOptionsPanel

local displayString = ''

local volumeCVars =
	{
		[1] = {Name = MASTER, CVs = { Volume = "Sound_MasterVolume", Enabled = "Sound_EnableAllSound" }, Enabled = nil},
		[2] = {Name = SOUND_VOLUME, CVs = { Volume = "Sound_SFXVolume", Enabled = "Sound_EnableSFX" }, Enabled = nil},
		[3] = {Name = AMBIENCE_VOLUME, CVs = { Volume = "Sound_AmbienceVolume", Enabled = "Sound_EnableAmbience" }, Enabled = nil},
		[4] = {Name = DIALOG_VOLUME, CVs = { Volume = "Sound_DialogVolume", Enabled = "Sound_EnableDialog" }, Enabled = nil},
		[5] = {Name = MUSIC_VOLUME, CVs = { Volume = "Sound_MusicVolume", Enabled = "Sound_EnableMusic" }, Enabled = nil}
	}


local activeVolumeIndex = 1
local activeVolume = volumeCVars[activeVolumeIndex]
local menu = {
	[1] = {text = "Volume Stream", isTitle = true, notCheckable = true}
}

local function GetStatusColor(vol, text)
	if not text then
		text = vol.Name
	end

	return strform('|cFF%s%s|r',(getCV(vol.CVs.Volume) == "0" or not vol.Enabled) and 'FF0000' or '00FF00', text)
end

local function OnEnter(self)
	E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)

	DT:SetupTooltip(self)
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine('Volume Streams')
	DT.tooltip:AddLine(' ')
	
	for _,vol in ipairs(volumeCVars) do
		DT.tooltip:AddDoubleLine(vol.Name, GetStatusColor(vol, strform("%.f", getCV(vol.CVs.Volume) * 100) .. "%"))
	end

	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine('|cffFFFFFFLeft Click:|r Select Volume Stream')
	DT.tooltip:AddLine('|cffFFFFFFRight Click:|r Toggle Volume Stream')
	DT.tooltip:AddLine('|cffFFFFFFShift + Left Click:|r Open System Audio Panel')

	DT.tooltip:Show()
end



local function OnEvent(self, event, ...)
	activeVolume = volumeCVars[activeVolumeIndex]

	if (event == "ELVUI_FORCE_UPDATE" ) then -- I hate you Azil <3

		self:EnableMouseWheel(true)

		self:SetScript("OnMouseWheel", function(tself, delta)
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
		
			setCV(activeVolume.CVs.Volume, vol)
			OnEvent(self, nil)
		end)
		
	end

	

	for i = 1, #volumeCVars do
		volumeCVars[i].Enabled = getCV(volumeCVars[i].CVs.Enabled) == "1"

		menu[i+1]={
			text = volumeCVars[i].Name,
			checked = i == activeVolumeIndex,
			func = function(slf)
				activeVolumeIndex = i; 
				OnEvent(self, nil);
			 end
		}
	end
	

	
	self.text:SetText(activeVolume.Name..": "..GetStatusColor(activeVolume, strform("%.f", getCV(activeVolume.CVs.Volume) * 100) .. "%"))
end



local function OnClick(self, button)

	if button == "LeftButton" then
		if IsShiftKeyDown() then
			ShowOptionsPanel(_G.VideoOptionsFrame, _G.GameMenuFrame, SOUND)
			return
		end

		menu[1].text = "Select Volume Stream"
		for i = 2, #menu do
			menu[i].checked = i - 1 == activeVolumeIndex
			menu[i].func = function(slf)
				activeVolumeIndex = i - 1; 
				OnEvent(self, nil);
			end
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menu, DT.EasyMenu, nil, nil, nil, 'MENU')
	elseif button == "RightButton" then
		menu[1].text = "Toggle Volume Stream"
		for i = 2, #menu do
			menu[i].checked = volumeCVars[i - 1].Enabled
			menu[i].func = function(slf)
					setCV(volumeCVars[i - 1].CVs.Enabled, (not volumeCVars[i - 1].Enabled) and "1" or "0");
					OnEvent(self, nil);
			end
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menu, DT.EasyMenu, nil, nil, nil, 'MENU')
	end
end


local function ValueColorUpdate()
	displayString = strjoin('', '|cffFFFFFF%s:|r ')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true


DT:RegisterDatatext('Volume', 'ExtraDataTexts', {'PLAYER_ENTERING_WORLD', "CVAR_UPDATE"}, OnEvent, nil, OnClick, OnEnter)