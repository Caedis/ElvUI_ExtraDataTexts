----------------------------------------------------------------------------------
-- This file is a blank datatext example template, this file will not be loaded.
----------------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local function Update(self, t)

end

local function OnEvent(self, event, ...)

end

local function Click()

end

local function OnEnter(self)
	DT.tooltip:ClearLines()
	-- code goes here
	DT.tooltip:Show()
end

local function ValueColorUpdate()
	displayString = strjoin('', '|cffFFFFFF%s:|r ')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true


--[[
	ELVUI_FORCE_UPDATE is auto-included
]]
local events = {
	'EVENT1',
	'EVENT2'
}

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc, localizedName)

	name - name of the datatext (required)
	category - name of the category the datatext belongs to.
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
	localizedName - localized name of the datetext
	objectEvent - register events on an object, using E.RegisterEventForObject instead of panel.RegisterEvent
	colorUpdate - function that fires when called from the config when you change the dt options.
]]

DT:RegisterDatatext('DTName', 'Category', events, OnEvent, Update, Click, OnEnter, nil, nil, nil, ValueColorUpdate)
