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
            Train_emote = false,
        },
        onlyOnNewMaxCrits = false,
        separateOffhandCrits = false,
        threshold = 0,
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
        soundFilesDamage = "Interface\\AddOns\\SvensBamAddon\\bam.ogg",
        soundFilesHeal = "Interface\\AddOns\\SvensBamAddon\\bam.ogg",
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
            order = 0,
            type = "toggle",
            name = "Say",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Say
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Say = value
            end
        },
        placeholderDescription1 = {
            order = 1,
            type = "description",
            name = ""
        },
        yellCheckbox = {
            order = 2,
            type = "toggle",
            name = "Yell",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Yell
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Yell = value
            end
        },
        placeholderDescription2 = {
            order = 3,
            type = "description",
            name = ""
        },
        printCheckbox = {
            order = 4,
            type = "toggle",
            name = "Print",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Print
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Print = value
            end
        },
        printChannelInput = {
            order = 6,
            type = "input",
            name = "",
            width = double,
            desc = "Define Channel Frame you want SvensBamAddon to print to",
            get = function(_)
                return localAddon.db.profile.chatFrameName
            end,
            set = function(_, value)
                local isValidName = localAddon:setIndexOfChatFrame(value)
                if (isValidName) then
                    localAddon.db.profile.chatFrameName = value
                else
                    _G["ChatFrame" .. localAddon.db.profile.chatFrameIndex]:AddMessage(localAddon.db.profile.color .. "Could not find channel name!")
                end
            end
        },
        placeholderDescription4 = {
            order = 7,
            type = "description",
            name = ""
        },
        guildCheckbox = {
            order = 8,
            type = "toggle",
            name = "Guild",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Guild
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Guild = value
            end
        },
        placeholderDescription5 = {
            order = 9,
            type = "description",
            name = ""
        },
        raidCheckbox = {
            order = 10,
            type = "toggle",
            name = "Raid",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Raid
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Raid = value
            end
        },
        placeholderDescription6 = {
            order = 11,
            type = "description",
            name = ""
        },
        emoteCheckbox = {
            order = 12,
            type = "toggle",
            name = "Emote",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Emote
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Emote = value
            end
        },
        placeholderDescription7 = {
            order = 13,
            type = "description",
            name = ""
        },
        partyCheckbox = {
            order = 14,
            type = "toggle",
            name = "Party",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Party
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Party = value
            end
        },
        placeholderDescription8 = {
            order = 15,
            type = "description",
            name = ""
        },
        officerCheckbox = {
            order = 16,
            type = "toggle",
            name = "Officer",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Officer
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Officer = value
            end
        },
        placeholderDescription9 = {
            order = 17,
            type = "description",
            name = ""
        },
        raidWarningCheckbox = {
            order = 18,
            type = "toggle",
            name = "Raid Warning",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Raid_Warning
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Raid_Warning = value
            end
        },
        placeholderDescription10 = {
            order = 19,
            type = "description",
            name = ""
        },
        battlegroundCheckbox = {
            order = 20,
            type = "toggle",
            name = "Battleground",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Battleground
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Battleground = value
            end
        },
        placeholderDescription11 = {
            order = 21,
            type = "description",
            name = ""
        },
        whisperCheckbox = {
            order = 22,
            type = "toggle",
            name = "Whisper",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Whisper
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Whisper = value
            end
        },
        whisperListInput = {
            order = 23,
            type = "input",
            name = "",
            width = "double",
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
        placeholderDescription12 = {
            order = 24,
            type = "description",
            name = ""
        },
        soundDamageCheckbox = {
            order = 25,
            type = "toggle",
            name = "Sound DMG",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Sound_damage
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Sound_damage = value
            end
        },
        soundDamageFileInput = {
            order = 26,
            type = "input",
            name = "",
            width = "double",
            multiline = true,
            desc = "Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths separated by spaces. Bam Addon will then play a random sound of that list.",
            get = function(_)
                return localAddon.db.profile.soundFilesDamage
            end,
            set = function(_, value)
                localAddon.db.profile.soundFilesDamage = value
            end
        },
        placeholderDescription13 = {
            order = 27,
            type = "description",
            name = ""
        },
        soundHealCheckbox = {
            order = 28,
            type = "toggle",
            name = "Sound Heal",
            descStyle = "",
            get = function(_)
                return localAddon.db.profile.outputChannelList.Sound_heal
            end,
            set = function(_, value)
                localAddon.db.profile.outputChannelList.Sound_heal = value
            end
        },
        soundHealFileInput = {
            order = 29,
            type = "input",
            width = "double",
            name = "",
            multiline = true,
            desc = "Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths separated by spaces. Bam Addon will then play a random sound of that list.",
            get = function(_)
                return localAddon.db.profile.soundFilesHeal
            end,
            set = function(_, value)
                localAddon.db.profile.soundFilesHeal = value
            end
        },
        placeholderDescription14 = {
            order = 30,
            type = "description",
            name = ""
        },
        trainEmoteCheckbox = {
            order = 31,
            type = "toggle",
            name = "Do Train Emote",
            descStyle = "",
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