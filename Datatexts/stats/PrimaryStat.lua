local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local displayNumberString = ''
local lastPanel;
local join = string.join
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local UnitStat = UnitStat

-- 1 - Strength
-- 2 - Agility
-- 3 - Stamina
-- 4 - Intellect
-- 5 - Spirit

local statString
local specIndex
local specName

local statNameTable = {
   "Strength",
   "Agility",
   "Stamina",
   "Intellect",
   "Spirit"
}




local function OnEvent(self, event, ...)
	if (statString == nil or event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_ENTERING_WORLD') then
		 specIndex = GetSpecialization()
		 statString = select(6, GetSpecializationInfo(specIndex))
		 statName = statNameTable[statString]
	end
	

	 local primStat = UnitStat("player",statString)
	
	 self.text:SetFormattedText(displayNumberString, L[statName..': '], primStat)
	
	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = string.join("", "%s", hex, "%.f|r")
	
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
local events = {
	"UNIT_STATS",
	"UNIT_AURA",
	--"FORGE_MASTER_ITEM_CHANGE",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_TALENT_UPDATE",
	"PLAYER_ENTERING_WORLD" -- for the initial setup
}

DT:RegisterDatatext('Primary Stat', events, OnEvent)

