SvensBamAddon = LibStub("AceAddon-3.0"):NewAddon("SvensBamAddon", "AceConsole-3.0", "AceEvent-3.0")

function SvensBamAddon:OnEnable()
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SvensBamAddon_suppressWhisperMessage)
end

function SvensBamAddon:OnDisable()
    -- Called when the addon is disabled
end

function SvensBamAddon:OnInitialize()
    self:RegisterChatCommand("bam", "SlashCommand")

end

function SvensBamAddon:ADDON_LOADED()
    SvensBamAddon_icon = nil -- Needs to be initialized to be saved
    SvensBamAddon:loadAddon() -- in SvensBamAddonConfig.lua
end

function SvensBamAddon:COMBAT_LOG_EVENT_UNFILTERED()
    local name, _ = UnitName("player");
    local eventType, _, _, eventSource, _, _, _, enemyName = select(2, CombatLogGetCurrentEventInfo())
    if not (eventSource == name) then
        do
            return
        end
    end

    local spellId, spellName, amount, critical, spellLink

    --Assign correct values to variables
    if (eventType == "SPELL_DAMAGE") then
        spellId, spellName, _, amount, _, _, _, _, _, critical, _, _ = select(12, CombatLogGetCurrentEventInfo())
    elseif (eventType == "SPELL_HEAL") then
        spellId, spellName, _, amount, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
    elseif (eventType == "RANGE_DAMAGE") then
        spellId, spellName, _, amount, _, _, _, _, _, critical, _, _ = select(12, CombatLogGetCurrentEventInfo())
    elseif (eventType == "SWING_DAMAGE") then
        amount, _, _, _, _, _, critical, _, _, isOffHand = select(12, CombatLogGetCurrentEventInfo())
        if (SvensBamAddon_separateOffhandCrits and isOffHand) then
            spellName = "Off-Hand Autohit"
        else
            spellName = "Autohit"
        end
    end

    if (spellId and SvensBamAddon_Settings.postLinkOfSpell) then
        spellLink = GetSpellLink(spellId)
    end

    if (amount ~= nil and amount < SvensBamAddon_threshold and SvensBamAddon_threshold ~= 0) then
        do
            return
        end
    end

    for i = 1, #SvensBamAddon_eventList do
        if (eventType == SvensBamAddon_eventList[i].eventType and SvensBamAddon_eventList[i].boolean and critical == true) then
            newMaxCrit = SvensBamAddon:addToCritList(spellName, amount);
            if (SvensBamAddon_onlyOnNewMaxCrits and not newMaxCrit) then
                do
                    return
                end
            end
            local output
            if (spellLink) then
                spellName = spellLink
            end

            if eventType == "SPELL_HEAL" then
                output = SvensBamAddon_outputHealMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
            else
                output = SvensBamAddon_outputDamageMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
            end
            for _, v in pairs(SvensBamAddon_outputChannelList) do
                if v == "Print" then
                    _G["ChatFrame" .. SvensBamAddon_Settings.chatFrameIndex]:AddMessage(SvensBamAddon_color .. output)
                elseif (v == "Say" or v == "Yell") then
                    local inInstance, _ = IsInInstance()
                    if (inInstance) then
                        SendChatMessage(output, v);
                    end
                elseif (v == "Battleground") then
                    local _, instanceType = IsInInstance()
                    if (instanceType == "pvp") then
                        SendChatMessage(output, "INSTANCE_CHAT")
                    end
                elseif (v == "Officer") then
                    if (CanEditOfficerNote()) then
                        SendChatMessage(output, v)
                    end
                elseif (v == "Raid" or v == "Raid_Warning") then
                    if IsInRaid() then
                        SendChatMessage(output, v);
                    end
                elseif (v == "Party") then
                    if IsInGroup() then
                        SendChatMessage(output, v);
                    end
                elseif (v == "Whisper") then
                    for _, w in pairs(SvensBamAddon_whisperList) do
                        SendChatMessage(output, "WHISPER", "COMMON", w)
                    end
                elseif (v == "Sound DMG") then
                    if (eventType ~= "SPELL_HEAL") then
                        SvensBamAddon:playRandomSoundFromList(SvensBamAddon_soundfileDamage)
                    end
                elseif (v == "Sound Heal") then
                    if (eventType == "SPELL_HEAL") then
                        SvensBamAddon:playRandomSoundFromList(SvensBamAddon_soundfileHeal)
                    end
                elseif (v == "Do Train Emote") then
                    DoEmote("train");
                else
                    SendChatMessage(output, v);
                end
            end
        end
    end
end

function SvensBamAddon:playRandomSoundFromList(listOfFilesAsString)
    SvensBamAddon_soundFileList = {}
    for arg in string.gmatch(listOfFilesAsString, "%S+") do
        table.insert(SvensBamAddon_soundFileList, arg)
    end
    local randomIndex = random(1, #SvensBamAddon_soundFileList)
    PlaySoundFile(SvensBamAddon_soundFileList[randomIndex])
end

-- Function for event filter for CHAT_MSG_SYSTEM to suppress message of player on whisper list being offline when being whispered to
function SvensBamAddon_suppressWhisperMessage(_, _, msg, _, ...)
    -- TODO Suppression only works for Portuguese, English, German and French because they have the same naming format.
    -- See https://www.townlong-yak.com/framexml/live/GlobalStrings.lua
    local textWithoutName = msg:gsub("%'%a+%'", ""):gsub("  ", " ")

    localizedPlayerNotFoundStringWithoutName = ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%'%%s%'", ""):gsub("  ", " ")

    if not (textWithoutName == localizedPlayerNotFoundStringWithoutName) then
        return false
    end

    local name = string.gmatch(msg, "%'%a+%'")

    -- gmatch returns iterator.
    for w in name do
        name = w
    end
    if not (name == nil) then
        name = name:gsub("'", "")
    else
        return false
    end

    local isNameInWhisperList = false
    for _, w in pairs(SvensBamAddon_whisperList) do
        if (w == name) then
            isNameInWhisperList = true
        end
    end
    return isNameInWhisperList

end

function SvensBamAddon:SlashCommand(msg)
    if (msg == "help" or msg == "") then
        print(SvensBamAddon_color .. "Possible parameters:")
        print(SvensBamAddon_color .. "list: lists highest crits of each spell")
        print(SvensBamAddon_color .. "report: report highest crits of each spell to channel list")
        print(SvensBamAddon_color .. "clear: delete list of highest crits")
        print(SvensBamAddon_color .. "config: Opens config page")
    elseif (msg == "list") then
        SvensBamAddon:listCrits();
    elseif (msg == "report") then
        SvensBamAddon:reportCrits();
    elseif (msg == "clear") then
        SvensBamAddon:clearCritList();
    elseif (msg == "config") then
        -- For some reason, needs to be called twice to function correctly on first call
        InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
        InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
    elseif (msg == "test") then
        print(SvensBamAddon_color .. "Function not implemented")
    else
        print(SvensBamAddon_color .. "Bam Error: Unknown command")
    end
end

