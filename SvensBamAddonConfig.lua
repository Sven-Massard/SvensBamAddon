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
          if (localAddon.isAboveClassic) then
              Settings.OpenToCategory(localAddon.mainOptionsCategoryID)
          else
              InterfaceOptionsFrame_OpenToCategory(localAddon.mainOptionsFrame)
          end
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
    char = {
        outputDamageMessage = "BAM! SN SD to TN!",
        outputHealMessage = "BAM! SN SD to TN!",
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
            battleNetWhisper = false,
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
        pet = {
            eventList = {
                spellDamage = { name = "Spell Damage", eventType = "SPELL_DAMAGE", boolean = true },
                ranged = { name = "Ranged", eventType = "RANGE_DAMAGE", boolean = true },
                melee = { name = "Melee Autohit", eventType = "SWING_DAMAGE", boolean = true },
                heal = { name = "Heal", eventType = "SPELL_HEAL", boolean = true },
            },
        };
        whisperList = {},
        battleNetWhisperBattleNetTagToId = {},
        chatFrameName = COMMUNITIES_DEFAULT_CHANNEL_NAME,
        chatFrameIndex = 1,
        soundFilesDamage = { "Interface\\AddOns\\SvensBamAddon\\bam.ogg" },
        soundFilesHeal = { "Interface\\AddOns\\SvensBamAddon\\bam.ogg" },
        color = "|cff" .. "94" .. "CF" .. "00",
        minimap = { hide = false, },
        critList = {},
        spellIgnoreList = {},
        isMigratedToVersion10 = false
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
        chatFrameNameInput = {
            order = 1,
            type = "input",
            name = "to be replaced",
            width = "full",
            desc = "Define Channel Frame you want SvensBamAddon to print to",
            get = function(_)
                return localAddon.db.char.chatFrameName
            end,
            set = function(_, value)
                local isValidName = localAddon:setIndexOfChatFrame(value)
                if (isValidName) then
                    localAddon.db.char.chatFrameName = value
                else
                    _G["ChatFrame" .. localAddon.db.char.chatFrameIndex]:AddMessage(localAddon.db.char.color .. "Could not find channel name!")
                end
            end
        },

        placeholderDescriptionOutputMessage = {
            order = 2,
            type = "description",
            name = ""
        },

        outputMessageDamageOption = {
            order = 3,
            type = "input",
            width = "full",
            name = "will be replaced",
            desc = "Insert your damage message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!",
            get = function(_)
                return localAddon.db.char.outputDamageMessage
            end,
            set = function(_, value)
                localAddon.db.char.outputDamageMessage = value
            end
        },
        placeholderDescription1 = {
            order = 4,
            type = "description",
            name = ""
        },
        outputMessageHealOption = {
            order = 5,
            type = "input",
            width = "full",
            name = "will be replaced",
            desc = "Insert your heal message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!",
            get = function(_)
                return localAddon.db.char.outputHealMessage
            end,
            set = function(_, value)
                localAddon.db.char.outputHealMessage = value
            end
        },
        placeholderDescription2 = {
            order = 6,
            type = "description",
            name = ""
        },
        thresholdOption = {
            order = 10,
            type = "input",
            width = "full",
            name = "will be replaced",

            desc = "Damage or heal must be at least this high to trigger bam!\nSet 0 to trigger on everything.",
            get = function(_)
                return tostring(localAddon.db.char.threshold)
            end,
            set = function(_, value)
                localAddon.db.char.threshold = tonumber(value)
            end
        },
        placeholderDescription3 = {
            order = 11,
            type = "description",
            name = ""
        },

        critOptions = {
            type = "group",
            name = "To be Replaced",
            inline = true, -- Makes the options appear as part of the parent group
            order = 29, -- Adjust order to fit your needs
            args = {
                SpellDamageCheckbox = {
                    order = 1,
                    width = "double",
                    type = "toggle",
                    name = "Spell Damage",
                    get = function(_)
                        return localAddon.db.char.eventList.spellDamage.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.eventList.spellDamage.boolean = value
                    end
                },
                placeholderDescription5 = {
                    order = 2,
                    type = "description",
                    name = ""
                },
                healCheckbox = {
                    order = 3,
                    type = "toggle",
                    name = "Heal",
                    get = function(_)
                        return localAddon.db.char.eventList.heal.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.eventList.heal.boolean = value
                    end
                },
                placeholderDescription6 = {
                    order = 4,
                    type = "description",
                    name = ""
                },
                rangedCheckbox = {
                    order = 5,
                    type = "toggle",
                    name = "Ranged",
                    get = function(_)
                        return localAddon.db.char.eventList.ranged.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.eventList.ranged.boolean = value
                    end
                },
                placeholderDescription7 = {
                    order = 6,
                    type = "description",
                    name = ""
                },
                meleeCheckbox = {
                    order = 7,
                    type = "toggle",
                    name = "Melee Autohit",
                    get = function(_)
                        return localAddon.db.char.eventList.melee.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.eventList.melee.boolean = value
                    end
                },
            }
        },
        petCritOptions = {
            type = "group",
            name = "To be Replaced",
            inline = true, -- Makes the options appear as part of the parent group
            order = 30, -- Adjust order to fit your needs
            args = {
                spellDamage = {
                    order = 1,
                    type = "toggle",
                    name = "Pet Spell Damage",
                    get = function(_)
                        return localAddon.db.char.pet.eventList.spellDamage.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.pet.eventList.spellDamage.boolean = value
                    end,
                },
                newLineDescription1 = {
                    order = 2,
                    type = "description",
                    name = ""
                },
                ranged = {
                    order = 3,
                    type = "toggle",
                    name = "Pet Ranged",
                    get = function(_)
                        return localAddon.db.char.pet.eventList.ranged.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.pet.eventList.ranged.boolean = value
                    end,
                },
                newLineDescription2 = {
                    order = 4,
                    type = "description",
                    name = ""
                },
                melee = {
                    order = 5,
                    type = "toggle",
                    name = "Pet Melee Autohit",
                    get = function(_)
                        return localAddon.db.char.pet.eventList.melee.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.pet.eventList.melee.boolean = value
                    end,
                },
                newLineDescription3 = {
                    order = 6,
                    type = "description",
                    name = ""
                },
                heal = {
                    order = 7,
                    type = "toggle",
                    name = "Pet Heal",
                    get = function(_)
                        return localAddon.db.char.pet.eventList.heal.boolean
                    end,
                    set = function(_, value)
                        localAddon.db.char.pet.eventList.heal.boolean = value
                    end,
                },
            },
        },
        placeholderDescription21 = {
            order = 34,
            type = "description",
            name = ""
        },
        triggerOptionsDescription = {
            order = 35,
            type = "description",
            name = "will be replaced"
        },
        placeholderDescription9 = {
            order = 36,
            type = "description",
            name = ""
        },
        triggerOnCritRecordCheckbox = {
            order = 40,
            type = "toggle",
            width = "double",
            name = "Only trigger on new crit record",
            get = function(_)
                return localAddon.db.char.onlyOnNewMaxCrits
            end,
            set = function(_, value)
                localAddon.db.char.onlyOnNewMaxCrits = value
            end
        },
        placeholderDescription10 = {
            order = 41,
            type = "description",
            name = ""
        },
        separateOffhandCrits = {
            order = 42,
            type = "toggle",
            width = "double",
            name = "Show off-hand crits separately",
            get = function(_)
                return localAddon.db.char.separateOffhandCrits
            end,
            set = function(_, value)
                localAddon.db.char.separateOffhandCrits = value
            end
        },
        placeholderDescription11 = {
            order = 43,
            type = "description",
            name = ""
        },
        otherOptionsDescription = {
            order = 50,
            type = "description",
            name = "will be replaced"
        },
        placeholderDescription12 = {
            order = 51,
            type = "description",
            name = ""
        },
        miniMapButtonCheckbox = {
            order = 52,
            type = "toggle",
            name = "Show Minimap Button",
            desc = "Note that button collector addons manage minimap visibility.\nSo this checkbox might not do anything.",
            get = function(_)
                return not localAddon.db.char.minimap.hide
            end,
            set = function(_, value)
                localAddon.db.char.minimap.hide = not value
                if (value) then
                    icon:Show("SvensBamAddon_dataObject")
                else
                    icon:Hide("SvensBamAddon_dataObject")
                end
            end
        },
        placeholderDescription13 = {
            order = 53,
            type = "description",
            name = ""
        },
        postLinkOfSpellCheckbox = {
            order = 54,
            type = "toggle",
            name = "Post links of spells",
            get = function(_)
                return localAddon.db.char.postLinkOfSpell
            end,
            set = function(_, value)
                localAddon.db.char.postLinkOfSpell = value
            end
        },
        placeholderDescription55 = {
            order = 55,
            type = "description",
            name = ""
        },
        spellIgnoreListInput = {
            order = 60,
            type = "input",
            name = "to be replaced",
            multiline = true,
            width = "double",
            desc = "Put each spell you want to ignore on a new line.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.char.spellIgnoreList) do
                    listAsString = listAsString .. v .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.char.spellIgnoreList = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    -- Extract spell name from link, or use the arg directly if it's not a link
                    local spellName = string.match(arg, "%[(.-)%]") or arg
                    table.insert(localAddon.db.char.spellIgnoreList, spellName)
                end
            end
        },

        placeholderDescription69 = {
            order = 69,
            type = "description",
            name = ""
        },
        fontColorDescription = {
            order = 70,
            type = "description",
            name = "will be replaced"
        },
        placeholderDescription71 = {
            order = 71,
            type = "description",
            name = ""
        },
        redColorSlider = {
            order = 72,
            type = "range",
            width = "double",
            name = "Red",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.char.color:sub(5, 6))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.char.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.char.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.char.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.char.color = "|cff" .. rgbValue .. rgb[2].value .. rgb[3].value
                localAddon:setPanelTexts()
            end
        },
        placeholderDescription73 = {
            order = 73,
            type = "description",
            name = ""
        },
        greenColorSlider = {
            order = 74,
            type = "range",
            width = "double",
            name = "Green",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.char.color:sub(7, 8))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.char.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.char.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.char.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.char.color = "|cff" .. rgb[1].value .. rgbValue .. rgb[3].value
                localAddon:setPanelTexts()
            end
        },
        placeholderDescription75 = {
            order = 75,
            type = "description",
            name = ""
        },
        blueColorSlider = {
            order = 76,
            type = "range",
            width = "double",
            name = "Blue",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.char.color:sub(9, 10))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.char.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.char.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.char.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.char.color = "|cff" .. rgb[1].value .. rgb[2].value .. rgbValue
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
            desc = "Only works in instances",
            get = function(_)
                return localAddon.db.char.outputChannelList.Say
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Say = value
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
            desc = "Only works in instances",
            get = function(_)
                return localAddon.db.char.outputChannelList.Yell
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Yell = value
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
                return localAddon.db.char.outputChannelList.Print
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Print = value
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
                return localAddon.db.char.outputChannelList.Guild
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Guild = value
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
                return localAddon.db.char.outputChannelList.Raid
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Raid = value
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
                return localAddon.db.char.outputChannelList.Emote
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Emote = value
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
                return localAddon.db.char.outputChannelList.Party
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Party = value
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
                return localAddon.db.char.outputChannelList.Officer
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Officer = value
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
                return localAddon.db.char.outputChannelList.Raid_Warning
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Raid_Warning = value
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
                return localAddon.db.char.outputChannelList.Battleground
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Battleground = value
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
                return localAddon.db.char.outputChannelList.Whisper
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Whisper = value
            end
        },
        whisperListInput = {
            order = 23,
            type = "input",
            name = "Set Friends to Whisper to",
            multiline = true,
            width = "double",
            desc = "Put each name you want to whisper to on a new line.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.char.whisperList) do
                    listAsString = listAsString .. v .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.char.whisperList = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    table.insert(localAddon.db.char.whisperList, arg)
                end
            end
        },
        placeholderDescription12 = {
            order = 24,
            type = "description",
            name = ""
        },
        battleNetwhisperCheckbox = {
            order = 25,
            type = "toggle",
            name = "Whisper Bnet Name",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.battleNetWhisper
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.battleNetWhisper = value
            end
        },
        battleNetWhisperListInput = {
            order = 26,
            type = "input",
            name = "Set Battle.net Friends to Whisper to",
            multiline = true,
            width = "double",
            desc = "Put each battle net tag of people in your friend list on a new line.\nFor example xyz#3453",
            get = function(_)
                local listAsString = ""
                for k, _ in pairs(localAddon.db.char.battleNetWhisperBattleNetTagToId) do
                    listAsString = listAsString .. k .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                local bnetWhisperList = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    bnetWhisperList[arg] = true
                end

                local numBNetTotal, _, _, _ = BNGetNumFriends()
                localAddon.db.char.battleNetWhisperBattleNetTagToId = {}
                for i = 1, numBNetTotal do
                    if (not self.isAboveClassic) then
                        bnetIDAccount, _, battleTag, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = BNGetFriendInfo(i)
                    else
                        local acc = C_BattleNet.GetFriendAccountInfo(i)
                        bnetIDAccount = acc.bnetAccountID
                        battleTag = acc.battleTag
                    end
                    --local accountName = battleTag:gsub("(.*)#.*$", "%1")
                    if (bnetWhisperList[battleTag] == true) then
                        localAddon.db.char.battleNetWhisperBattleNetTagToId[battleTag] = bnetIDAccount;
                    end
                end

                for k, _ in pairs(bnetWhisperList) do
                    if (localAddon.db.char.battleNetWhisperBattleNetTagToId[k] == nil) then
                        _G["ChatFrame" .. localAddon.db.char.chatFrameIndex]:AddMessage(localAddon.db.char.color .. "Bnet account name " .. k .. " not found.")
                    end
                end
            end
        },
        placeholderDescription12 = {
            order = 27,
            type = "description",
            name = ""
        },
        soundDamageCheckbox = {
            order = 28,
            type = "toggle",
            name = "Sound DMG",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Sound_damage
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Sound_damage = value
            end
        },
        soundDamageFileInput = {
            order = 29,
            type = "input",
            name = "Sound file for damage to play",
            width = "double",
            multiline = true,
            desc = "Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths. Put each file on a new line. Bam Addon will then play a random sound of that list.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.char.soundFilesDamage) do
                    listAsString = listAsString .. v .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.char.soundFilesDamage = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    table.insert(localAddon.db.char.soundFilesDamage, arg)
                end
            end
        },
        placeholderDescription13 = {
            order = 30,
            type = "description",
            name = ""
        },
        soundHealCheckbox = {
            order = 31,
            type = "toggle",
            name = "Sound Heal",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Sound_heal
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Sound_heal = value
            end
        },
        soundHealFileInput = {
            order = 32,
            type = "input",
            width = "double",
            name = "Sound file for heal to play",
            multiline = true,
            desc = "Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths. Put each file on a new line. Bam Addon will then play a random sound of that list.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.char.soundFilesHeal) do
                    listAsString = listAsString .. v .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.char.soundFilesHeal = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    table.insert(localAddon.db.char.soundFilesHeal, arg)
                end
            end
        },
        placeholderDescription14 = {
            order = 33,
            type = "description",
            name = ""
        },
        trainEmoteCheckbox = {
            order = 34,
            type = "toggle",
            name = "Do Train Emote",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Train_emote
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Train_emote = value
            end
        },
    }
}

function localAddon:loadAddon()
    self.isAboveClassic = select(4, GetBuildInfo()) > 82000

    self.db = AceDatabase:New("SvensBamAddonDB", defaults)
    self:fixPetNotTable()

    AceConfig:RegisterOptionsTable("SvensBamAddon_MainOptions", mainOptions)
    AceConfig:RegisterOptionsTable("SvensBamAddon_GeneralOptions", generalOptions)
    AceConfig:RegisterOptionsTable("SvensBamAddon_ChannelOptions", channelOptions)
    self.mainOptionsFrame, self.mainOptionsCategoryID = AceConfigDialog:AddToBlizOptions("SvensBamAddon_MainOptions", "Svens Bam Addon")
    AceConfigDialog:AddToBlizOptions("SvensBamAddon_GeneralOptions", "General options", "Svens Bam Addon")
    AceConfigDialog:AddToBlizOptions("SvensBamAddon_ChannelOptions", "Channel options", "Svens Bam Addon")

    self:setPanelTexts()

    self:realignBattleNetTagToId()

    icon:Register("SvensBamAddon_dataObject", MinimapIcon, self.db.char.minimap)
    if (not self.db.char.minimap.hide) then
        icon:Show("SvensBamAddon_dataObject")
    else
        icon:Hide("SvensBamAddon_dataObject")
    end

    if (not self.db.char.isMigratedToVersion10) then
        self:migrateToVersion10()
    end
end

function localAddon:convertRGBDecimalToRGBHex(decimal)
    local result
    local numbers = "0123456789ABCDEF"
    result = numbers:sub(1 + (decimal / 16), 1 + (decimal / 16)) .. numbers:sub(1 + (decimal % 16), 1 + (decimal % 16))
    return result
end

function localAddon:setPanelTexts()
    mainOptions.name = self.db.char.color .. "Choose sub menu to change options."
    mainOptions.args.mainDescription.name = self.db.char.color .. "Command line options:\n\n"
            .. "/bam list: lists highest crits of each spell.\n"
            .. "/bam report: report highest crits of each spell to channel list.\n"
            .. "/bam clear: delete list of highest crits.\n/bam config: Opens this config page."

    generalOptions.args.chatFrameNameInput.name = self.db.char.color .. "Chat Frame to Print to"
    generalOptions.args.outputMessageDamageOption.name = self.db.char.color .. "Output Message Damage"
    generalOptions.args.outputMessageHealOption.name = self.db.char.color .. "Output Message Heal"
    generalOptions.args.thresholdOption.name = self.db.char.color .. "Least amount of damage/heal to trigger bam"
    generalOptions.args.critOptions.name = self.db.char.color .. "Event Types to Trigger"
    generalOptions.args.petCritOptions.name = self.db.char.color .. "Pet Event Types to Trigger"
    generalOptions.args.triggerOptionsDescription.name = self.db.char.color .. "Trigger Options"
    generalOptions.args.otherOptionsDescription.name = self.db.char.color .. "Other Options"
    generalOptions.args.spellIgnoreListInput.name = self.db.char.color .. "Spells to ignore"
    generalOptions.args.fontColorDescription.name = self.db.char.color .. "Change Color of Font"
    channelOptions.name = self.db.char.color .. "Output Channel"
end

-- Taken and edited from BamModRevived on WoWInterface. Thanks to Sylen
-- We use this to get the index of our output channel
function localAddon:setIndexOfChatFrame(chatFrameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local chatWindowName = GetChatWindowInfo(i)
        if chatWindowName == chatFrameName then
            self.db.char.chatFrameIndex = i
            return true
        end
    end
    return false
end

function localAddon:realignBattleNetTagToId()
    local numBNetTotal, _, _, _ = BNGetNumFriends()

    for i = 1, numBNetTotal do
        local bnetIDAccount, battleTag
        if (not self.isAboveClassic) then
            bnetIDAccount, _, battleTag, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = BNGetFriendInfo(i)
        else
            local acc = C_BattleNet.GetFriendAccountInfo(i)
            bnetIDAccount = acc.bnetAccountID
            battleTag = acc.battleTag
        end
        --local accountName = battleTag:gsub("(.*)#.*$", "%1")
        if (localAddon.db.char.battleNetWhisperBattleNetTagToId[battleTag] ~= nil) then
            localAddon.db.char.battleNetWhisperBattleNetTagToId[battleTag] = bnetIDAccount;
        end

    end
end

function localAddon:migrateToVersion10()
    self:Print("Migrating database for Svens Bam Addon. You should see this message only once.")

    -- migrate simple variables
    if (SBM_outputDamageMessage ~= nil) then
        self.db.char.outputDamageMessage = SBM_outputDamageMessage
    end
    if (SBM_outputHealMessage ~= nil) then
        self.db.char.outputHealMessage = SBM_outputHealMessage
    end
    if (SBM_whisperList ~= nil) then
        self.db.char.whisperList = SBM_whisperList
    end
    if (SBM_color ~= nil) then
        self.db.char.color = SBM_color
    end
    if (SBM_threshold ~= nil) then
        self.db.char.threshold = SBM_threshold
    end
    if (SBM_onlyOnNewMaxCrits ~= nil) then
        self.db.char.onlyOnNewMaxCrits = SBM_onlyOnNewMaxCrits
    end
    if (SBM_separateOffhandCrits ~= nil) then
        self.db.char.separateOffhandCrits = SBM_separateOffhandCrits
    end
    if (SBM_MinimapSettings ~= nil and SBM_MinimapSettings.hide ~= nil) then
        self.db.char.minimap.hide = SBM_MinimapSettings.hide
    end

    self:Print("Successfully migrated simple settings")

    -- SBM_Settings
    if (SBM_Settings ~= nil) then
        if (SBM_Settings.chatFrameName ~= nil) then
            self.db.char.chatFrameName = SBM_Settings.chatFrameName
        end
        if (SBM_Settings.chatFrameIndex ~= nil) then
            self.db.char.chatFrameIndex = SBM_Settings.chatFrameIndex
        end
        if (SBM_Settings.postLinkOfSpell ~= nil) then
            self.db.char.postLinkOfSpell = SBM_Settings.postLinkOfSpell
        end
    end

    self:Print("Successfully migrated SBM settings")

    -- migrate SBM_soundfileDamage
    if (SBM_soundfileDamage ~= nil) then
        self.db.char.soundFilesDamage = {}
        for arg in string.gmatch(SBM_soundfileDamage, "%S+") do
            table.insert(self.db.char.soundFilesDamage, arg)
        end
    end

    -- migrate SBM_soundfileHeal
    if (SBM_soundfileHeal ~= nil) then
        self.db.char.soundFilesHeal = {}
        for arg in string.gmatch(SBM_soundfileHeal, "%S+") do
            table.insert(self.db.char.soundFilesHeal, arg)
        end
    end

    self:Print("Successfully migrated sound files")

    -- migrate eventList
    local oldEventList = SBM_eventList
    if (oldEventList ~= nil) then
        local newEventList = self.db.char.eventList
        for _, v in ipairs(oldEventList) do
            if (v.name == "Spell Damage") then
                newEventList.spellDamage.boolean = v.boolean
            end
            if (v.name == "Ranged") then
                newEventList.ranged.boolean = v.boolean
            end
            if (v.name == "Melee Autohit") then
                newEventList.melee.boolean = v.boolean
            end
            if (v.name == "Heal") then
                newEventList.heal.boolean = v.boolean
            end
        end
    end

    self:Print("Successfully migrated event list")

    --migrate critList
    local it = SBM_critList
    if (it ~= nil) then
        local newCritList = self.db.char.critList

        while (it ~= nil)
        do
            local spellTable = { spellName = it.spellName, amount = it.value }
            table.insert(newCritList, spellTable)
            it = it.nextNode
        end
    end

    self:Print("Successfully migrated crit list")

    --migrate outputChannelList
    local oldChannelList = SBM_outputChannelList
    if (oldChannelList ~= nil) then
        local newChannelList = self.db.char.outputChannelList
        if (oldChannelList["Say"] ~= nil) then
            newChannelList.Say = true;
        end
        if (oldChannelList["Yell"] ~= nil) then
            newChannelList.Yell = true;
        end
        if (oldChannelList["Print"] ~= nil) then
            newChannelList.Print = true;
        end
        if (oldChannelList["Guild"] ~= nil) then
            newChannelList.Guild = true;
        end
        if (oldChannelList["Raid"] ~= nil) then
            newChannelList.Raid = true;
        end
        if (oldChannelList["Emote"] ~= nil) then
            newChannelList.Emote = true;
        end
        if (oldChannelList["Party"] ~= nil) then
            newChannelList.Party = true;
        end
        if (oldChannelList["Officer"] ~= nil) then
            newChannelList.Officer = true;
        end
        if (oldChannelList["Raid_Warning"] ~= nil) then
            newChannelList.Raid_Warning = true;
        end
        if (oldChannelList["Battleground"] ~= nil) then
            newChannelList.Battleground = true;
        end
        if (oldChannelList["Whisper"] ~= nil) then
            newChannelList.Whisper = true;
        end
        if (oldChannelList["Sound DMG"] ~= nil) then
            newChannelList.Sound_damage = true;
        end
        if (oldChannelList["Sound Heal"] ~= nil) then
            newChannelList.Sound_heal = true;
        end
        if (oldChannelList["Do Train Emote"] ~= nil) then
            newChannelList.Train_emote = true;
        end
    end

    self:Print("Successfully migrated output channel list")

    self.db.char.isMigratedToVersion10 = true
    self:Print("Finished migrating database for Svens Bam Addon. You should see this message only once.")

end

-- In some point in alpha version, db.char.pet was a boolean and thus when loading the addon, we got an error.
function localAddon:fixPetNotTable()
    if type(localAddon.db.char.pet) ~= "table" then
        localAddon.db.char.pet = defaults.char.pet
    end
end