local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')
local EDT = select(2, ...).EDT


--Cache global variables
local _G = _G
--Lua functions
local format = string.format
local pairs = pairs
local IsShiftKeyDown = IsShiftKeyDown
local tinsert, twipe = tinsert, wipe
--WoW API / Variables
local ToggleCharacter = ToggleCharacter
local C_EquipmentSet_GetEquipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs
local C_EquipmentSet_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local C_EquipmentSet_UseEquipmentSet = C_EquipmentSet.UseEquipmentSet


local db = {}
local activeSetIndex
local setMenu = {}

local hexColor = ''

local function OnEnter(self)
	E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)

	DT:SetupTooltip(self)
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine('Equipment Sets')

	DT.tooltip:AddLine(' ')

	for _,set in pairs(db) do
		DT.tooltip:AddLine(format('|T%s:14:14:0:0:64:64:4:60:4:60|t |cFF%s%s|r', set.IconFileID, set.IsEquipped and '00ff00' or 'ff0000', set.Name))
	end

	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine('|cffFFFFFFLeft Click:|r Change Equipment Set')
	DT.tooltip:AddLine('|cffFFFFFFShift + Left Click:|r Open Equipment Manager')

	DT.tooltip:Show()
end

local function OnClick(self, button)
	if button == 'LeftButton' then
		if IsShiftKeyDown() then
			ToggleCharacter('PaperDollFrame')

			if PaperDollSidebarTab3 then -- just in case something happens to this tab
				PaperDollSidebarTab3:Click()
			end

			return
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(setMenu, DT.EasyMenu, nil, nil, nil, 'MENU')

	end

end


local function OnEvent(self)
	twipe(db)
	twipe(setMenu)
	tinsert(setMenu, { text = 'Equipment Sets', isTitle = true, notCheckable = true })


	local sets = C_EquipmentSet_GetEquipmentSetIDs()

	activeSetIndex = -1
	for i,setID in pairs(sets) do
		local name, iconFileID, _, isEquipped = C_EquipmentSet_GetEquipmentSetInfo(setID)

		tinsert(setMenu,
			{
				text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', iconFileID, name),
				checked = isEquipped,
				func = function() C_EquipmentSet_UseEquipmentSet(setID) end
			}
		)

		tinsert(db,
			{
				SetID = setID,
				Name = name,
				IconFileID = iconFileID,
				IsEquipped = isEquipped
			}
		)

		if isEquipped then
			activeSetIndex = i
		end
	end

	if activeSetIndex == -1 then
		self.text:SetText('No Set Equipped')
	else
		local set = db[activeSetIndex]
		self.text:SetText(format('Set: %s%s|r |T%s:16:16:0:0:64:64:4:60:4:60|t', hexColor, set.Name, set.IconFileID))
	end

end



local function ValueColorUpdate(hex)
	hexColor = hex
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

local events = {
	'EQUIPMENT_SETS_CHANGED',
	'PLAYER_EQUIPMENT_CHANGED',
	'EQUIPMENT_SWAP_FINISHED'
}


DT:RegisterDatatext('Equipment Sets', EDT.DTCategory, events, OnEvent, nil, OnClick, OnEnter, nil, nil, nil, ValueColorUpdate)