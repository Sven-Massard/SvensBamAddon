function SvensBamAddon:addToCritList(spellName, val)
    -- list was empty until now
    if (SvensBamAddon_critList.spellName == nil and SvensBamAddon_critList.value == nil) then
        SvensBamAddon_critList = SvensBamAddon:newNode(spellName, val)
        return true

    else
        local it = SvensBamAddon_critList
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
        it.nextNode = SvensBamAddon:newNode(spellName, val)
        return true
    end

end

function SvensBamAddon:newNode(spellName, val)
    local newNode = {};
    newNode.spellName = spellName
    newNode.value = val
    newNode.nextNode = nil
    return newNode
end

function SvensBamAddon:clearCritList()
    SvensBamAddon_critList = {};
    print(SvensBamAddon_color .. "Critlist cleared");
end

function SvensBamAddon:listCrits()
    if not (SvensBamAddon_critList.value == nil) then
        print(SvensBamAddon_color .. "Highest crits:");
        local it = SvensBamAddon_critList
        print(SvensBamAddon_color .. it.spellName .. ": " .. it.value)
        while not (it.nextNode == nil) do
            it = it.nextNode
            print(SvensBamAddon_color .. it.spellName .. ": " .. it.value)
        end
    else
        print(SvensBamAddon_color .. "No crits recorded");
    end
end

function SvensBamAddon:reportCrits()
    if not (SvensBamAddon_critList.value == nil) then
        for _, v in pairs(SvensBamAddon_outputChannelList) do
            if v == "Print" then
                print(SvensBamAddon_color .. "Highest crits:");
                local it = SvensBamAddon_critList
                print(SvensBamAddon_color .. it.spellName .. ": " .. it.value)
                while not (it.nextNode == nil) do
                    it = it.nextNode
                    print(SvensBamAddon_color .. it.spellName .. ": " .. it.value)
                end
            elseif (v == "Officer") then
                if (CanEditOfficerNote()) then
                    SvensBamAddon:ReportToChannel(v)
                end
            elseif (v == "Battleground") then
                inInstance, instanceType = IsInInstance()
                if (instanceType == "pvp") then
                    SvensBamAddon:ReportToChannel("INSTANCE_CHAT")
                end
            elseif (v == "Party") then
                if IsInGroup() then
                    SvensBamAddon:ReportToChannel(v);
                end
            elseif (v == "Raid" or v == "Raid_Warning") then
                if IsInRaid() then
                    SvensBamAddon:ReportToChannel(v);
                end
            elseif (v == "Whisper") then
                for _, w in pairs(SvensBamAddon_whisperList) do
                    SendChatMessage("Highest crits:", "WHISPER", "COMMON", w)
                    local it = SvensBamAddon_critList
                    SendChatMessage(it.spellName .. ": " .. it.value, "WHISPER", "COMMON", w)
                    while not (it.nextNode == nil) do
                        it = it.nextNode
                        SendChatMessage(it.spellName .. ": " .. it.value, "WHISPER", "COMMON", w)
                    end
                end
            elseif (v == "Sound DMG" or v == "Sound Heal" or v == "Do Train Emote") then
                -- do nothing
            else
                SvensBamAddon:ReportToChannel(v);
            end
        end
    else
        print(SvensBamAddon_color .. "No crits recorded");
    end
end

function SvensBamAddon:ReportToChannel(channelName)
    SendChatMessage("Highest crits:", channelName)
    local it = SvensBamAddon_critList
    SendChatMessage(it.spellName .. ": " .. it.value, channelName)
    while not (it.nextNode == nil) do
        it = it.nextNode
        SendChatMessage(it.spellName .. ": " .. it.value, channelName)
    end
end