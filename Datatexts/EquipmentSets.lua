local E, L, V, P, G, _ = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

--Cache global variables
local _G = _G
--Lua functions
local floor = floor
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

local function RefreshCache()
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

end


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

    DT.tooltip:AddLine('|cffFFFFFFLeft Click:|r Equipment Set Dropdown')
    DT.tooltip:AddLine('|cffFFFFFFShift + Left Click:|r Open Equipment Manager')

    DT.tooltip:Show()
end

function OnClick(self, button)
    if button == "LeftButton" then
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

local function OnEvent(self, event, ...)
    if event == 'PLAYER_ENTERING_WORLD' then
        self:UnregisterEvent(event)
    end
    
    RefreshCache()
    
    if activeSetIndex == -1 then
        self.text:SetText('No Set Equipped')
    else
        local set = db[activeSetIndex]
        self.text:SetText(format('Set: %s |T%s:16:16:0:0:64:64:4:60:4:60|t', set.Name, set.IconFileID))
    end

end


local function ValueColorUpdate()
	displayString = strjoin('', '|cffFFFFFF%s:|r ')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

local events = {
    'PLAYER_ENTERING_WORLD',
    'ELVUI_FORCE_UPDATE',
    'EQUIPMENT_SETS_CHANGED',
    'PLAYER_EQUIPMENT_CHANGED',
    'EQUIPMENT_SWAP_FINISHED'
}


DT:RegisterDatatext('Equipment Sets', 'ExtraDataTexts', events, OnEvent, nil, OnClick, OnEnter)
