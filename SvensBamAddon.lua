SvensBamAddon = LibStub("AceAddon-3.0"):NewAddon("SvensBamAddon", "AceConsole-3.0", "AceEvent-3.0")

local localAddon = SvensBamAddon

function localAddon:OnEnable()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SBM_suppressWhisperMessage)
end

function localAddon:OnDisable()
    -- Called when the addon is disabled
end

function localAddon:OnInitialize()
    MinimapIcon = nil -- Needs to be initialized to be saved
    self:loadAddon() -- in SvensBamAddonConfig.lua
    self:RegisterChatCommand("bam", "SlashCommand")
end

function localAddon:COMBAT_LOG_EVENT_UNFILTERED()
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
        if (self.db.profile.separateOffhandCrits and isOffHand) then
            spellName = "Off-Hand Autohit"
        else
            spellName = "Autohit"
        end
    end

    if (critical ~= true) then
        do
            return
        end
    end
    if (spellId and self.db.profile.postLinkOfSpell) then
        spellLink = GetSpellLink(spellId)
    end

    if (amount ~= nil and amount < tonumber(self.db.profile.threshold) and tonumber(self.db.profile.threshold ~= 0)) then
        do
            return
        end
    end

    --for i = 1, #self.db.profile.eventList do
    for _, event in pairs(self.db.profile.eventList) do
        if (eventType == event.eventType and event.boolean) then

            newMaxCrit = self:addToCritList(spellName, amount);
            if (self.db.profile.onlyOnNewMaxCrits and not newMaxCrit) then
                do
                    return
                end
            end
            local output
            if (spellLink) then
                spellName = spellLink
            end
            if eventType == "SPELL_HEAL" then
                output = self.db.profile.outputHealMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
            else
                output = self.db.profile.outputDamageMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
            end
            for k, v in pairs(self.db.profile.outputChannelList) do
                if v == true then
                    if k == "Print" then
                        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. output)
                    elseif (k == "Say" or k == "Yell") then
                        local inInstance, _ = IsInInstance()
                        if (inInstance) then
                            SendChatMessage(output, v);
                        end
                    elseif (k == "Battleground") then
                        local _, instanceType = IsInInstance()
                        if (instanceType == "pvp") then
                            SendChatMessage(output, "INSTANCE_CHAT")
                        end
                    elseif (k == "Officer") then
                        if (CanEditOfficerNote()) then
                            SendChatMessage(output, v)
                        end
                    elseif (k == "Raid" or v == "Raid_Warning") then
                        if IsInRaid() then
                            SendChatMessage(output, v);
                        end
                    elseif (k == "Party") then
                        if IsInGroup() then
                            SendChatMessage(output, v);
                        end
                    elseif (k == "Whisper") then
                        for _, w in pairs(self.db.profile.whisperList) do
                            SendChatMessage(output, "WHISPER", "COMMON", w)
                        end
                    elseif (k == "Sound_damage" and eventType ~= "SPELL_HEAL") then
                        self:playRandomSoundFromList(self.db.profile.soundFilesDamage)
                    elseif (k == "Sound_heal" and eventType == "SPELL_HEAL") then
                        self:playRandomSoundFromList(self.db.profile.soundFilesHeal)
                    elseif (k == "Do Train Emote") then
                        DoEmote("train");
                    else
                        SendChatMessage(output, v);
                    end
                end
            end
        end
    end
end

function localAddon:playRandomSoundFromList(listOfFilesAsString)
    local soundFileList = {}
    for arg in string.gmatch(listOfFilesAsString, "[^\r\n]+") do
        table.insert(soundFileList, arg)
    end
    local randomIndex = random(1, #soundFileList)
    PlaySoundFile(soundFileList[randomIndex])
end

-- Function for event filter for CHAT_MSG_SYSTEM to suppress message of player on whisper list being offline when being whispered to
function SBM_suppressWhisperMessage(_, _, msg, _, ...)
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
    for _, w in pairs(localAddon.db.profile.whisperList) do
        if (w == name) then
            isNameInWhisperList = true
        end
    end
    return isNameInWhisperList

end

function localAddon:SlashCommand(msg)
    if (msg == "help" or msg == "") then
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "Possible parameters:")
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "list: lists highest crits of each spell")
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "report: report highest crits of each spell to channel list")
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "clear: delete list of highest crits")
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "config: Opens config page")
    elseif (msg == "list") then
        self:listCrits();
    elseif (msg == "report") then
        self:reportCrits();
    elseif (msg == "clear") then
        self:clearCritList();
    elseif (msg == "config") then
        -- For some reason, needs to be called twice to function correctly on first call
        InterfaceOptionsFrame_OpenToCategory(self.mainOptionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.mainOptionsFrame)
    elseif (msg == "test") then
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "Function not implemented")
    else
        _G["ChatFrame" .. self.db.profile.chatFrameIndex]:AddMessage(self.db.profile.color .. "Bam Error: Unknown command")
    end
end

