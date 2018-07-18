local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Majority of code is taken from the ArtifactBar module


--Cache global variables
--Lua functions
local _G = _G
local format = format

--WoW API / Variables
local HasArtifactEquipped = HasArtifactEquipped
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local C_ArtifactUIGetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local ARTIFACT_POWER = ARTIFACT_POWER


local shortNum = function(v)
	if v <= 999 then
		return format("%d", v)
	elseif v >= 1000000000 then
		return format("%.1fb", v/1000000000)
	elseif v >= 1000000 then
		return format("%.1fm", v/1000000)
	elseif v >= 1000 then
		return format("%.1fk", v/1000)
	end
end


function OnEvent(self, event, ...)
	
	local showArtifact = HasArtifactEquipped();
	
	if not showArtifact then
		self.text:SetText("Artifact Not Equipped")
	else
		
		local text = ''
		local itemID, altItemID, name, icon, xp, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo();
		local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, xp, artifactTier);
		
		if xpForNextPoint == 0 then
			xpForNextPoint = xp
		end
		
		self.text:SetText(format('|cffe6cc80AP|r: %s / %s (%.0f%%)', shortNum(xp), shortNum(xpForNextPoint), xp/xpForNextPoint * 100))
	end
end

function Click(self)

	if not ArtifactFrame or not ArtifactFrame:IsShown() then
		ShowUIPanel(SocketInventoryItem(16))
	elseif ArtifactFrame and ArtifactFrame:IsShown() then
		HideUIPanel(ArtifactFrame)
	end

end


function OnEnter(self)

	if not HasArtifactEquipped() then
		return
	end


	DT:SetupTooltip(self)
	
	DT.tooltip:ClearLines()
	DT.tooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	DT.tooltip:AddLine(ARTIFACT_POWER)
	DT.tooltip:AddLine(' ')

		local itemID, altItemID, name, icon, xp, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo();
		local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, xp, artifactTier);

	if xpForNextPoint == 0 then
			xpForNextPoint = xp
		end
	
	DT.tooltip:AddDoubleLine(L["XP:"], format(' %s / %s (%.0f%%)', shortNum(xp), shortNum(xpForNextPoint), xp/xpForNextPoint * 100), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %s (%d%% - %d '..L["Bars"]..')', shortNum(xpForNextPoint - xp), (xpForNextPoint - xp) / xpForNextPoint * 100, 20 * (xpForNextPoint - xp) / xpForNextPoint), 1, 1, 1)
	DT.tooltip:AddDoubleLine("Available Points:", format('%d', numPointsAvailableToSpend), 1, 1, 1)
	
	
	DT.tooltip:Show()
end








local events = {
"ARTIFACT_XP_UPDATE",
"UNIT_INVENTORY_CHANGED",
"PLAYER_ENTERING_WORLD",
}

DT:RegisterDatatext('Artifact Power', events, OnEvent, nil, Click, OnEnter)