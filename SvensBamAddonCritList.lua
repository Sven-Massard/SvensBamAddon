local localAddon = SvensBamAddon

function localAddon:addToCritList(spellName, val)
    -- list was empty until now
    if (self.db.profile.critList.spellName == nil and self.db.profile.critList.value == nil) then

        self.db.profile.critList = self:newNode(spellName, val)
        return true

    else
        local it = self.db.profile.critList
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
    self.db.profile.critList = {};
    print(self.db.profile.color .. "Critlist cleared"); -- TODO replace all prints
end

function localAddon:listCrits()
    if not (self.db.profile.critList.value == nil) then
        print(self.db.profile.color .. "Highest crits:");
        local it = self.db.profile.critList
        print(self.db.profile.color .. it.spellName .. ": " .. it.value)
        while not (it.nextNode == nil) do
            it = it.nextNode
            print(self.db.profile.color .. it.spellName .. ": " .. it.value)
        end
    else
        print(self.db.profile.color .. "No crits recorded");
    end
end

function localAddon:reportCrits()
    if not (self.db.profile.critList.value == nil) then
        for _, v in pairs(self.db.profile.outputChannelList) do
            if v == "Print" then
                print(self.db.profile.color .. "Highest crits:");
                local it = self.db.profile.critList
                print(self.db.profile.color .. it.spellName .. ": " .. it.value)
                while not (it.nextNode == nil) do
                    it = it.nextNode
                    print(self.db.profile.color .. it.spellName .. ": " .. it.value)
                end
            elseif (v == "Officer") then
                if (CanEditOfficerNote()) then
                    self:ReportToChannel(v)
                end
            elseif (v == "Battleground") then
                inInstance, instanceType = IsInInstance()
                if (instanceType == "pvp") then
                    self:ReportToChannel("INSTANCE_CHAT")
                end
            elseif (v == "Party") then
                if IsInGroup() then
                    self:ReportToChannel(v);
                end
            elseif (v == "Raid" or v == "Raid_Warning") then
                if IsInRaid() then
                    self:ReportToChannel(v);
                end
            elseif (v == "Whisper") then
                for _, w in pairs(self.db.profile.whisperList) do
                    SendChatMessage("Highest crits:", "WHISPER", "COMMON", w)
                    local it = self.db.profile.critList
                    SendChatMessage(it.spellName .. ": " .. it.value, "WHISPER", "COMMON", w)
                    while not (it.nextNode == nil) do
                        it = it.nextNode
                        SendChatMessage(it.spellName .. ": " .. it.value, "WHISPER", "COMMON", w)
                    end
                end
            elseif (v == "Sound DMG" or v == "Sound Heal" or v == "Do Train Emote") then
                -- do nothing
            else
                self:ReportToChannel(v);
            end
        end
    else
        print(self.db.profile.color .. "No crits recorded");
    end
end

function localAddon:ReportToChannel(channelName)
    SendChatMessage("Highest crits:", channelName)
    local it = self.db.profile.critList
    SendChatMessage(it.spellName .. ": " .. it.value, channelName)
    while not (it.nextNode == nil) do
        it = it.nextNode
        SendChatMessage(it.spellName .. ": " .. it.value, channelName)
    end
end