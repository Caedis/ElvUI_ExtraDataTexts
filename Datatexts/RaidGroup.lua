local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local function OnEvent(self, event, unit)
	if not IsInRaid() then self.text:SetText('Raid Group: N/A') return end
	for i = 1, GetNumGroupMembers() do
		local name, _, subgroup = GetRaidRosterInfo(i)
		if name == UnitName('player') then
			self.text:SetFormattedText('Raid Group: %d', subgroup)
			return
		end
	end
end

local events = {
	'PLAYER_ENTERING_WORLD',
	'ELVUI_FORCE_UPDATE',
	'GROUP_ROSTER_UPDATE'
}

DT:RegisterDatatext('Raid Group', 'ExtraDataTexts', events, OnEvent)