local localAddon = SvensBamAddon

function localAddon:addToCritList(spellName, val, target)
    local critList = self.db.char.critList
    local spellTable = { spellName = spellName, amount = val, target = target }

    local foundSpell = false;
    for i, v in ipairs(critList) do
        if v.spellName == spellName then
            foundSpell = true
            if (v.amount < val) then
                table.remove(critList, i)
                table.insert(critList, spellTable)
                return true
            end
        end
    end

    if (foundSpell == false) then
        table.insert(critList, spellTable)
        return true
    end
    return false
end

function localAddon:clearCritList()
    local critList = self.db.char.critList
    for i, _ in ipairs(critList) do
        critList[i] = nil
    end
    _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Crit list cleared");
end

function localAddon:listCrits()
    local critList = self.db.char.critList
    if #critList == 0 then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "No crits recorded")
    else
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Highest crits:");
        for _, v in ipairs(critList) do
            local target = v.target
            if target == nil then
                target = "unknown"
            end
            _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. v.spellName .. " " .. v.amount .. " to " .. target)
        end
    end
end

function localAddon:reportCrits()
    local critList = self.db.char.critList
    if (#critList == 0) then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "No crits recorded");
    else
        for k, v in pairs(self.db.char.outputChannelList) do
            if (k == "Print" and v == true) then
                _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Highest crits:");
                for _, c in ipairs(critList) do
                    local target = c.target
                    if target == nil then
                        target = "unknown"
                    end
                    _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. c.spellName .. " " .. c.amount .. " to " .. target)
                end
            elseif (k == "Officer" and v == true) then
                if (CanEditOfficerNote()) then
                    self:ReportToChannel(k)
                end
            elseif (k == "Battleground" and v == true) then
                inInstance, instanceType = IsInInstance()
                if (instanceType == "pvp") then
                    self:ReportToChannel("INSTANCE_CHAT")
                end
            elseif (k == "Party" and v == true) then
                if IsInGroup() then
                    self:ReportToChannel(k);
                end
            elseif ((k == "Raid" or k == "Raid_Warning") and v == true) then
                if IsInRaid() then
                    self:ReportToChannel(k);
                end
            elseif (k == "Whisper" and v == true) then
                for _, w in pairs(self.db.char.whisperList) do
                    SendChatMessage("Highest crits:", "WHISPER", "COMMON", w)
                    for _, c in ipairs(critList) do
                        local target = c.target
                        if target == nil then
                            target = "unknown"
                        end
                        SendChatMessage(c.spellName .. " " .. c.amount .. " to " .. target, "WHISPER", "COMMON", w)
                    end
                end
            elseif (k == "battleNetWhisper" and v == true) then
                for _, w in pairs(self.db.char.battleNetWhisperBattleNetTagToId) do
                    BNSendWhisper(w, "Highest crits:")
                    for _, c in ipairs(critList) do
                        local target = c.target
                        if target == nil then
                            target = "unknown"
                        end
                        BNSendWhisper(w, c.spellName .. " " .. c.amount .. " to " .. target)
                    end
                end
            elseif (k == "Sound_damage" or k == "Sound_heal" or k == "Train_emote") then
                -- do nothing
            elseif (v == true) then
                self:ReportToChannel(k);
            end
        end
    end
end

function localAddon:ReportToChannel(channelName)
    local critList = self.db.char.critList
    SendChatMessage("Highest crits:", channelName)
    for _, v in ipairs(critList) do
        local target = v.target
        if target == nil then
            target = "unknown"
        end
        SendChatMessage(v.spellName .. " " .. v.amount .. " to " .. target, channelName)

    end

end