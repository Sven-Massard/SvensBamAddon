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
    local eventType, _, _, eventSource, _, _, _, targetName = select(2, CombatLogGetCurrentEventInfo())
    if not (eventSource == name .. "-" .. GetRealmName() or eventSource == name) then
        do
            return
        end
    end

    local spellId, spellName, amount, critical, spellLink

    --TODO Add dot and hot ticks
    --Assign correct values to variables
    if (eventType == "SPELL_DAMAGE") then
        spellId, spellName, _, amount, _, _, _, _, _, critical, _, _ = select(12, CombatLogGetCurrentEventInfo())
    elseif (eventType == "SPELL_HEAL") then
        spellId, spellName, _, amount, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
    elseif (eventType == "RANGE_DAMAGE") then
        spellId, spellName, _, amount, _, _, _, _, _, critical, _, _ = select(12, CombatLogGetCurrentEventInfo())
    elseif (eventType == "SWING_DAMAGE") then
        amount, _, _, _, _, _, critical, _, _, isOffHand = select(12, CombatLogGetCurrentEventInfo())
        if (self.db.char.separateOffhandCrits and isOffHand) then
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

    for _, w in pairs(self.db.char.spellIgnoreList) do
        if (w == spellName) then
            do
                return
            end
        end
    end

    if (spellId and self.db.char.postLinkOfSpell) then
        spellLink = GetSpellLink(spellId)
    end

    if (amount ~= nil and tonumber(amount) < self.db.char.threshold and self.db.char.threshold ~= 0) then
        do
            return
        end
    end
    --for i = 1, #self.db.char.eventList do
    for _, event in pairs(self.db.char.eventList) do
        if (eventType == event.eventType and event.boolean) then
            newMaxCrit = self:addToCritList(spellName, amount, targetName);
            if (self.db.char.onlyOnNewMaxCrits and not newMaxCrit) then
                do
                    return
                end
            end
            local output
            if (spellLink) then
                spellName = spellLink
            end
            if eventType == "SPELL_HEAL" then
                output = self.db.char.outputHealMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", targetName)
            else
                output = self.db.char.outputDamageMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", targetName)
            end
            for k, v in pairs(self.db.char.outputChannelList) do
                if v == true then
                    if k == "Print" then
                        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. output)
                    elseif (k == "Say" or k == "Yell") then
                        local inInstance, _ = IsInInstance()
                        if (inInstance) then
                            SendChatMessage(output, k);
                        end
                    elseif (k == "Battleground") then
                        local _, instanceType = IsInInstance()
                        if (instanceType == "pvp") then
                            SendChatMessage(output, "INSTANCE_CHAT")
                        end
                    elseif (k == "Officer") then
                        if (CanEditOfficerNote()) then
                            SendChatMessage(output, k)
                        end
                    elseif (k == "Raid" or v == "Raid_Warning") then
                        if IsInRaid() then
                            SendChatMessage(output, k);
                        end
                    elseif (k == "Party") then
                        if IsInGroup() then
                            SendChatMessage(output, k);
                        end
                    elseif (k == "Whisper") then
                        for _, w in pairs(self.db.char.whisperList) do
                            SendChatMessage(output, "WHISPER", "COMMON", w)
                        end
                    elseif (k == "battleNetWhisper") then
                        for _, w in pairs(self.db.char.battleNetWhisperBattleNetTagToId) do
                            BNSendWhisper(w, output)
                        end
                    elseif (k == "battleNetWhisper") then
                        for _, w in pairs(self.db.char.whisperList) do
                            SendChatMessage(output, "WHISPER", "COMMON", w)
                        end
                    elseif (k == "Sound_damage") then
                        if (eventType ~= "SPELL_HEAL") then
                            self:playRandomSoundFromList(self.db.char.soundFilesDamage)
                        end
                    elseif (k == "Sound_heal") then
                        if (eventType == "SPELL_HEAL") then
                            self:playRandomSoundFromList(self.db.char.soundFilesHeal)
                        end
                    elseif (k == "Train_emote") then
                        DoEmote("train");
                    else
                        SendChatMessage(output, k);
                    end
                end
            end
        end
    end
end

function localAddon:playRandomSoundFromList(tableWithSoundFileNames)
    local randomIndex = random(1, #tableWithSoundFileNames)
    PlaySoundFile(tableWithSoundFileNames[randomIndex])
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
    for _, w in pairs(localAddon.db.char.whisperList) do
        if (w == name) then
            isNameInWhisperList = true
        end
    end
    return isNameInWhisperList

end

function localAddon:SlashCommand(msg)
    if (msg == "help" or msg == "") then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Possible parameters:")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "list: lists highest crits of each spell")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "report: report highest crits of each spell to channel list")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "clear: delete list of highest crits")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "config: Opens config page")
    elseif (msg == "list") then
        self:listCrits();
    elseif (msg == "report") then
        self:reportCrits();
    elseif (msg == "clear") then
        self:clearCritList();
    elseif (msg == "config") then
        -- For some reason, needs to be called twice to function correctly on first call
        InterfaceOptionsFrame_OpenToCategory(self.mainOptionsFrame)
    elseif (msg == "test") then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Function not implemented")
    else
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Bam Error: Unknown command")
    end
end

