local localAddon = SvensBamAddon

function localAddon:addToCritList(spellName, val)
    -- list was empty until now
    if (self.db.char.critList.spellName == nil and self.db.char.critList.value == nil) then

        self.db.char.critList = self:newNode(spellName, val)
        return true

    else
        local it = self.db.char.critList
        --compare with first value
        if (it.spellName == spellName) then
            -- Maybe later refactor to avoid duplicate code
            if (it.value < val) then
                it.value = val
                return true
            end
            do
                return
            end
        end

        --compare with subsequent values
        while not (it.nextNode == nil) do
            it = it.nextNode
            if (it.spellName == spellName) then
                if (it.value < val) then
                    it.value = val
                    return true
                end
                do
                    return
                end
            end
        end

        --add spell if not found till now
        it.nextNode = self:newNode(spellName, val)
        return true
    end

end

function localAddon:newNode(spellName, val)
    local newNode = {};
    newNode.spellName = spellName
    newNode.value = val
    newNode.nextNode = nil
    return newNode
end

function localAddon:clearCritList()
    self.db.char.critList = {};
    _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Crit list cleared");
end

function localAddon:listCrits()
    if not (self.db.char.critList.value == nil) then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Highest crits:");
        local it = self.db.char.critList
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. it.spellName .. ": " .. it.value)
        while not (it.nextNode == nil) do
            it = it.nextNode
            _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. it.spellName .. ": " .. it.value)
        end
    else
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "No crits recorded");
    end
end

function localAddon:reportCrits()
    if not (self.db.char.critList.value == nil) then
        for k, v in pairs(self.db.char.outputChannelList) do
            if (k == "Print" and v == true) then
                _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Highest crits:");
                local it = self.db.char.critList
                _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. it.spellName .. ": " .. it.value)
                while not (it.nextNode == nil) do
                    it = it.nextNode
                    _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. it.spellName .. ": " .. it.value)
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
                    local it = self.db.char.critList
                    SendChatMessage(it.spellName .. ": " .. it.value, "WHISPER", "COMMON", w)
                    while not (it.nextNode == nil) do
                        it = it.nextNode
                        SendChatMessage(it.spellName .. ": " .. it.value, "WHISPER", "COMMON", w)
                    end
                end
            elseif (k == "Sound_damage" or k == "Sound_heal" or k == "Train_emote") then
                -- do nothing
            elseif (v == true) then
                self:ReportToChannel(k);
            end
        end
    else
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "No crits recorded");
    end
end

function localAddon:ReportToChannel(channelName)
    SendChatMessage("Highest crits:", channelName)
    local it = self.db.char.critList
    SendChatMessage(it.spellName .. ": " .. it.value, channelName)
    while not (it.nextNode == nil) do
        it = it.nextNode
        SendChatMessage(it.spellName .. ": " .. it.value, channelName)
    end
end