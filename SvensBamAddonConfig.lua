local SvensBamAddon_ldb = LibStub("LibDataBroker-1.1")

local localAddon = SvensBamAddon

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDatabase = LibStub("AceDB-3.0")
local icon = LibStub("LibDBIcon-1.0")
local lib = LibStub("LibDropDownMenu");

local menuFrame = lib.Create_DropDownMenu("MyAddOn_DropDownMenu");
local menuList = {
    { text = "Crit List options", isNotRadio = true, notCheckable = true, hasArrow = true,
      menuList = {
          { text = "List crits", isNotRadio = true, notCheckable = true,
            func = function()
                localAddon:listCrits();
            end
          },

          { text = "Report crits", isNotRadio = true, notCheckable = true,
            func = function()
                localAddon:reportCrits();
            end
          },

          { text = "Clear crits", isNotRadio = true, notCheckable = true,
            func = function()
                localAddon:clearCritList();
            end
          },
      }
    },

    { text = "Open config", isNotRadio = true, notCheckable = true,
      func = function()
          InterfaceOptionsFrame_OpenToCategory(localAddon.mainOptionsFrame)
          InterfaceOptionsFrame_OpenToCategory(localAddon.mainOptionsFrame)
      end
    },
    { text = "Close menu", isNotRadio = true, notCheckable = true },
};
local MinimapIcon = SvensBamAddon_ldb:NewDataObject("SvensBamAddon_dataObject", {
    type = "data source",
    label = "SvensBamAddon_MinimapButton",
    text = "SvensBamAddon Minimap Icon",
    icon = "Interface\\AddOns\\SvensBamAddon\\textures\\Bam_Icon",
    OnClick = function(_, button)
        if button == "LeftButton" or button == "RightButton" then
            lib.EasyMenu(menuList, menuFrame, "LibDBIcon10_SvensBamAddon_dataObject", 0, 0, "MENU");
        end
    end,
})

local defaults = {
    profile = {
        outputDamageMessage = "BAM! SN SD!",
        outputHealMessage = "BAM! SN SD!",
        outputChannelList = {
            Say = false,
            Yell = false,
            Print = true,
            Guild = false,
            Raid = false,
            Emote = false,
            Party = false,
            Officer = false,
            Raid_Warning = false,
            Battleground = false,
            Whisper = false,
            Sound_damage = true,
            Sound_heal = true,
            Train_emote = true,
        },
        onlyOnNewMaxCrits = false,
        separateOffhandCrits = false,
        damageThreshold = 0,
        postLinkOfSpell = false,
        eventList = {
            spellDamage = { name = "Spell Damage", eventType = "SPELL_DAMAGE", boolean = true },
            ranged = { name = "Ranged", eventType = "RANGE_DAMAGE", boolean = true },
            melee = { name = "Melee Autohit", eventType = "SWING_DAMAGE", boolean = true },
            heal = { name = "Heal", eventType = "SPELL_HEAL", boolean = true },
        },
        whisperList = {},
        chatFrameName = COMMUNITIES_DEFAULT_CHANNEL_NAME,
        chatFrameIndex = 1,
        soundfileDamage = "Interface\\AddOns\\SvensBamAddon\\bam.ogg",
        soundfileHeal = "Interface\\AddOns\\SvensBamAddon\\bam.ogg",
        color = "|cff" .. "94" .. "CF" .. "00",
        minimap = { hide = false, },
        critList = {}

    }
}

local mainOptions = { -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
    name = "will be replaced",
    type = "group",
    args = {
        mainDescription = {
            type = "description",
            fontSize = "medium",
            name = "will be replaced"
        },
    }
}
local generalOptions = { -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
    name = "",
    type = "group",
    args = {
        outputMessageDamageOption = {
            type = "input",
            name = "will be replaced",
            desc = "Insert your damage message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!",
            get = function(_)
                return localAddon.db.profile.outputDamageMessage
            end,
            set = function(_, value)
                localAddon.db.profile.outputDamageMessage = value
            end
        },
        outputMessageHealOption = {
            type = "input",
            name = "will be replaced",
            desc = "Insert your heal message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!",
            get = function(_)
                return localAddon.db.profile.outputHealMessage
            end,
            set = function(_, value)
                localAddon.db.profile.outputHealMessage = value
            end
        },
        thresholdOption = {
            type = "input",
            name = "will be replaced",
            desc = "Damage or heal must be at least this high to trigger bam!\nSet 0 to trigger on everything.",
            get = function(_)
                return localAddon.db.profile.threshold
            end,
            set = function(_, value)
                localAddon.db.profile.threshold = value
            end
        },
        eventTypesToTriggerDescription = {
            type = "description",
            name = "will be replaced"
        },
        SpellDamageCheckbox = {
            type = "toggle",
            name = "Spell Damage",
            get = function(_)
                return localAddon.db.profile.eventList.spellDamage.boolean
            end,
            set = function(_, value)
                localAddon.db.profile.eventList.spellDamage.boolean = value
            end
        },
        healCheckbox = {
            type = "toggle",
            name = "Heal",
            get = function(_)
                return localAddon.db.profile.eventList.heal.boolean
            end,
            set = function(_, value)
                localAddon.db.profile.eventList.heal.boolean = value
            end
        },
        rangedCheckbox = {
            type = "toggle",
            name = "Ranged",
            get = function(_)
                return localAddon.db.profile.eventList.ranged.boolean
            end,
            set = function(_, value)
                localAddon.db.profile.eventList.ranged.boolean = value
            end
        },
        meleeCheckbox = {
            type = "toggle",
            name = "Melee Autohit",
            get = function(_)
                return localAddon.db.profile.eventList.melee.boolean
            end,
            set = function(_, value)
                localAddon.db.profile.eventList.melee.boolean = value
            end
        },
        triggerOptionsDescription = {
            type = "description",
            name = "will be replaced"
        },
        triggerOnCritRecordCheckbox = {
            type = "toggle",
            name = "Only trigger on new crit record",
            get = function(_)
                return localAddon.db.profile.onlyOnNewMaxCrits
            end,
            set = function(_, value)
                localAddon.db.profile.onlyOnNewMaxCrits = value
            end
        },
        showOffHandCritsSeparately = {
            type = "toggle",
            name = "Show off-hand crits separately",
            get = function(_)
                return localAddon.db.profile.showOffHandCritsSeparately
            end,
            set = function(_, value)
                localAddon.db.profile.showOffHandCritsSeparately = value
            end
        },
        otherOptionsDescription = {
            type = "description",
            name = "will be replaced"
        },
        miniMapButtonCheckbox = {
            type = "toggle",
            name = "Show Minimap Button",
            get = function(_)
                return not localAddon.db.profile.minimap.hide
            end,
            set = function(_, value)
                localAddon.db.profile.minimap.hide = not value
                if (value) then
                    icon:Show("SvensBamAddon_dataObject")
                else
                    icon:Hide("SvensBamAddon_dataObject")
                end
            end
        },
        postLinkOfSpellCheckbox = {
            type = "toggle",
            name = "Show off-hand crits separately",
            get = function(_)
                return localAddon.db.profile.postLinkOfSpell
            end,
            set = function(_, value)
                localAddon.db.profile.postLinkOfSpell = value
            end
        },
        fontColorDescription = {
            type = "description",
            name = "will be replaced"
        },
        redColorSlider = {
            type = "range",
            name = "Red",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.profile.color:sub(5, 6))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.profile.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.profile.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.profile.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.profile.color = "|cff" .. rgbValue .. rgb[2].value .. rgb[3].value
                localAddon:setPanelTexts()
            end
        },
        greenColorSlider = {
            type = "range",
            name = "Green",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.profile.color:sub(7, 8))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.profile.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.profile.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.profile.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.profile.color = "|cff" .. rgb[1].value .. rgbValue .. rgb[3].value
                localAddon:setPanelTexts()
            end
        },
        blueColorSlider = {
            type = "range",
            name = "Blue",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.profile.color:sub(9, 10))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.profile.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.profile.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.profile.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.profile.color = "|cff" .. rgb[1].value .. rgb[2].value .. rgbValue
                localAddon:setPanelTexts()
            end
        }
    },
}
local channelOptions = { -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
    name = "replacedByColorString",
    type = "group",
    args = {
        sayCheckbox = {
            type = "toggle",
            name = "Say",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Say
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Say = value
            end
        },
        yellCheckbox = {
            type = "toggle",
            name = "Yell",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Yell
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Yell = value
            end
        },
        printCheckbox = {
            type = "toggle",
            name = "Print",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Print
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Print = value
            end
        },
        printChannelInput = {
            type = "input",
            name = "",
            desc = "Define Channel Frame you want SvensBamAddon to print to",
            get = function(_)
                return localAddon.db.profile.chatFrameName
            end,
            set = function(_, value)
                localAddon.db.profile.chatFrameName = value
                localAddon:setIndexOfChatFrame(localAddon.db.profile.chatFrameName)
            end
        },
        guildCheckbox = {
            type = "toggle",
            name = "Guild",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Guild
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Guild = value
            end
        },
        raidCheckbox = {
            type = "toggle",
            name = "Raid",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Raid
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Raid = value
            end
        },
        emoteCheckbox = {
            type = "toggle",
            name = "Emote",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Emote
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Emote = value
            end
        },
        partyCheckbox = {
            type = "toggle",
            name = "Party",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Party
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Party = value
            end
        },
        officerCheckbox = {
            type = "toggle",
            name = "Officer",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Officer
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Officer = value
            end
        },
        raidWarningCheckbox = {
            type = "toggle",
            name = "Raid Warning",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Raid_Warning
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Raid_Warning = value
            end
        },
        battlegroundCheckbox = {
            type = "toggle",
            name = "Battleground",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Battleground
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Battleground = value
            end
        },
        whisperCheckbox = {
            type = "toggle",
            name = "Whisper",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Whisper
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Whisper = value
            end
        },
        whisperListInput = {
            type = "input",
            name = "",
            desc = "Separate names of people you want to whisper to with spaces.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.profile.whisperList) do
                    listAsString = listAsString .. " " .. v
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.profile.whisperList = {}
                for arg in string.gmatch(value, "%S+") do
                    table.insert(localAddon.db.profile.whisperList, arg)
                end
            end
        },

        soundDamageCheckbox = {
            type = "toggle",
            name = "Sound DMG",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Sound_damage
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Sound_damage = value
            end
        },
        soundDamageFileInput = {
            type = "input",
            name = "",
            desc = "Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths separated by spaces. Bam Addon will then play a random sound of that list.",
            get = function(_)
                return localAddon.db.profile.soundfileDamage
            end,
            set = function(_, value)
                localAddon.db.profile.soundfileDamage = value
            end
        },
        soundHealCheckbox = {
            type = "toggle",
            name = "Sound Heal",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Sound_heal
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Sound_heal = value
            end
        },
        soundHealFileInput = {
            type = "input",
            name = "",
            desc = "Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths separated by spaces. Bam Addon will then play a random sound of that list.",
            get = function(_)
                return localAddon.db.profile.soundfileHeal
            end,
            set = function(_, value)
                localAddon.db.profile.soundfileHeal = value
            end
        },
        trainEmoteCheckbox = {
            type = "toggle",
            name = "Do Train Emote",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Train_emote
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Train_emote = value
            end
        },


    }
}

function localAddon:loadAddon()
    self.db = AceDatabase:New("SvensBamAddonDB", defaults, "char")
    AceConfig:RegisterOptionsTable("SvensBamAddon_MainOptions", mainOptions)
    AceConfig:RegisterOptionsTable("SvensBamAddon_GeneralOptions", generalOptions)
    AceConfig:RegisterOptionsTable("SvensBamAddon_ChannelOptions", channelOptions)
    self.mainOptionsFrame = AceConfigDialog:AddToBlizOptions("SvensBamAddon_MainOptions", "Svens Bam Addon")   -- https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0
    AceConfigDialog:AddToBlizOptions("SvensBamAddon_GeneralOptions", "General options", "Svens Bam Addon")
    AceConfigDialog:AddToBlizOptions("SvensBamAddon_ChannelOptions", "Channel options", "Svens Bam Addon")

    self:setPanelTexts()

    icon:Register("SvensBamAddon_dataObject", MinimapIcon, self.db.profile.minimap)
    if (not self.db.profile.minimap.hide) then
        icon:Show("SvensBamAddon_dataObject")
    else
        icon:Hide("SvensBamAddon_dataObject")
    end

end

function localAddon:convertRGBDecimalToRGBHex(decimal)
    local result
    local numbers = "0123456789ABCDEF"
    result = numbers:sub(1 + (decimal / 16), 1 + (decimal / 16)) .. numbers:sub(1 + (decimal % 16), 1 + (decimal % 16))
    return result
end

function localAddon:setPanelTexts()
    mainOptions.name = self.db.profile.color .. "Choose sub menu to change options."
    mainOptions.args.mainDescription.name = self.db.profile.color .. "Command line options:\n\n"
            .. "/bam list: lists highest crits of each spell.\n"
            .. "/bam report: report highest crits of each spell to channel list.\n"
            .. "/bam clear: delete list of highest crits.\n/bam config: Opens this config page."

    generalOptions.args.outputMessageDamageOption.name = self.db.profile.color .. "Output Message Damage"
    generalOptions.args.outputMessageHealOption.name = self.db.profile.color .. "Output Message Heal"
    generalOptions.args.thresholdOption.name = self.db.profile.color .. "Least amount of damage/heal to trigger bam"
    generalOptions.args.eventTypesToTriggerDescription.name = self.db.profile.color .. "Event Types to Trigger"
    generalOptions.args.triggerOptionsDescription.name = self.db.profile.color .. "Trigger Options"
    generalOptions.args.otherOptionsDescription.name = self.db.profile.color .. "Other Options"
    generalOptions.args.fontColorDescription.name = self.db.profile.color .. "Change Color of Font"
    channelOptions.name = self.db.profile.color .. "Output Channel"
end

-- Taken and edited from BamModRevived on WoWInterface. Thanks to Sylen
-- We use this to get the index of our output channel
function localAddon:setIndexOfChatFrame(chatFrameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local chatWindowName = GetChatWindowInfo(i)
        if chatWindowName == chatFrameName then
            self.db.profile.chatFrameIndex = i
            return true
        end
    end
    return false
end