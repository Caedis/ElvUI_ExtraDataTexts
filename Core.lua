local addonName, Engine = ...
local E, L, _, P = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDT = E:NewModule(addonName, 'AceEvent-3.0', 'AceConsole-3.0');
local DT = E:GetModule('DataTexts')
local EP = LibStub("LibElvUIPlugin-1.0");
local format, strjoin, strlower = string.format, strjoin, strlower
local GetAddOnMetadata = GetAddOnMetadata
local InCombatLockdown = InCombatLockdown
Engine.EDT = EDT

EDT.DTCategory = 'ExtraDataTexts'



local function BuildBaseDTOption(name)
	return {
		order = 1,
		name = L[name],
		type = 'group',
		inline = false,
		get = function(info) return E.db.extradatatexts.datatexts[strlower(name)][info[#info]] end,
		set = function(info, value) E.db.extradatatexts.datatexts[strlower(name)][info[#info]] = value DT:ForceUpdate_DataText(name) end,
		args = {}
	}
end

local function InsertOptions()

	local ACH = E.Libs.ACH
	local version = format('|cff1784d1v%s|r', GetAddOnMetadata(addonName, 'Version'))

	E.Options.args.extraDT = {
		name = '|cff1784d1Extra|r|cffffffffDataTexts|r',
		order = 6,
		type = 'group',
		childGroups = "tab",
		args = {
			title = {
				order = 1,
				name = format('|cff1784d1ElvUI|r_|cFFffffffExtraDataTexts|r [%s] by |cfffc7f03Caedis|r', version),
				type = 'header'
			},
			datatexts = {
				order = 2,
				name = L["DataText Customization"],
				type = 'group',
				childGroups = 'tree',
				args = {}
			}
		}
	}

	local opts = E.Options.args.extraDT.args.datatexts.args

	opts.location = BuildBaseDTOption('Location')

	opts.location.args = {
				showContinent = {
					order = 1,
					name = 'Show Continent',
					type = 'toggle'
				},
				showZone = {
					order = 2,
					name = 'Show Zone',
					type = 'toggle'
				},
				showSubZone = {
					order = 3,
					name = 'Show Sub Zone',
					type = 'toggle'
				},
				space1 = ACH:Spacer(5),
				color = {
					order = 6,
					name = 'Text Coloring',
					type = 'select',
					sortByValue = false,
					values = {
						['REACTION'] = 'Reaction',
						['CLASS'] = 'Class',
						['CUSTOM'] = 'Custom'
					}
				},
				customColor = {
					order = 7,
					name = 'Custom Color',
					type = 'color',
					get = function(info)
						local c = E.db.extradatatexts.datatexts.location[info[#info]]
						local d = P.extradatatexts.datatexts.location.customColor
						return c.r, c.g, c.b, 1, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local c = E.db.extradatatexts.datatexts.location[info[#info]]
						c.r, c.g, c.b = r, g, b
						DT:ForceUpdate_DataText('Location')
					end,
					disabled = function()
						return E.db.extradatatexts.datatexts.location.color ~= 'CUSTOM'
					end
				},
				space1 = ACH:Spacer(10),
				disableBlizzZoneText = {
					order = 11,
					name = 'Disable Blizzard Zone Text',
					type = 'toggle',
					set = function(_, value) E.db.extradatatexts.datatexts.location.disableBlizzZoneText = value E:StaticPopup_Show('CONFIG_RL') end
				}
	}



end

function EDT:HideZoneText()
	if E.db.extradatatexts.datatexts.location.disableBlizzZoneText then
		if InCombatLockdown() then 
			EDT:RegisterEvent('PLAYER_REGEN_ENABLED', EDT.HideZoneText)
		else
			EDT:UnregisterEvent('PLAYER_REGEN_ENABLED')
			_G.ZoneTextFrame:UnregisterAllEvents()
			_G.SubZoneTextFrame:UnregisterAllEvents()
		end
	end
end

function EDT:Initialize()

	EDT:HideZoneText()

	EDT:RegisterEvent('ADDON_LOADED', function(_, arg1)
		if arg1 == "ElvUI_OptionsUI" then
			InsertOptions()
			EDT:UnregisterEvent('ADDON_LOADED')
		end
	end)

	EP:RegisterPlugin(EDT:GetName())
end

E:RegisterModule(addonName)