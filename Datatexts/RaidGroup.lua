local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local IsInRaid = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitName = UnitName

local function OnEvent(self)
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
	'GROUP_ROSTER_UPDATE'
}

DT:RegisterDatatext('Raid Group', 'ExtraDataTexts', events, OnEvent)