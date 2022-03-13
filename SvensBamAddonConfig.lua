local SvensBamAddon_ldb = LibStub("LibDataBroker-1.1")

function SvensBamAddon:loadAddon()

    local channelButtonList = {}
    local eventButtonList = {}
    local channelList = {
        "Say",
        "Yell",
        "Print",
        "Guild",
        "Raid",
        "Emote",
        "Party",
        "Officer",
        "Raid_Warning",
        "Battleground",
        "Whisper",
        "Sound DMG",
        "Sound Heal",
        "Do Train Emote"
    }

    if (SvensBamAddon_Settings == nil) then
        SvensBamAddon_Settings = {}
    end

    if (SvensBamAddon_onlyOnNewMaxCrits == nil) then
        SvensBamAddon_onlyOnNewMaxCrits = false
    end

    if (SvensBamAddon_separateOffhandCrits == nil) then
        SvensBamAddon_separateOffhandCrits = false
    end

    if (SvensBamAddon_MinimapSettings == nil) then
        SvensBamAddon_MinimapSettings = {
            hide = false,
        }
    end

    if (SvensBamAddon_color == nil) then
        SvensBamAddon_color = "|cff" .. "94" .. "CF" .. "00"
    end

    if (SvensBamAddon_threshold == nil) then
        SvensBamAddon_threshold = 0
    end

    if (SvensBamAddon_soundfileDamage == nil) then
        SvensBamAddon_soundfileDamage = "Interface\\AddOns\\SvensBamAddon\\bam.ogg"
    end

    if (SvensBamAddon_soundfileHeal == nil) then
        SvensBamAddon_soundfileHeal = "Interface\\AddOns\\SvensBamAddon\\bam.ogg"
    end

    local rgb = {
        { color = "Red", value = SvensBamAddon_color:sub(5, 6) },
        { color = "Green", value = SvensBamAddon_color:sub(7, 8) },
        { color = "Blue", value = SvensBamAddon_color:sub(9, 10) }
    }

    if (SvensBamAddon_whisperList == nil) then
        SvensBamAddon_whisperList = {}
    end

    if (SvensBamAddon_Settings.chatFrameName == nil) then
        SvensBamAddon_Settings.chatFrameName = COMMUNITIES_DEFAULT_CHANNEL_NAME
        SvensBamAddon:setIndexOfChatFrame(SvensBamAddon_Settings.chatFrameName)
    end

    if (SvensBamAddon_Settings.postLinkOfSpell == nil) then
        SvensBamAddon_Settings.postLinkOfSpell = false
    end

    local defaultEventList = {
        { name = "Spell Damage", eventType = "SPELL_DAMAGE", boolean = true },
        { name = "Ranged", eventType = "RANGE_DAMAGE", boolean = true },
        { name = "Melee Autohit", eventType = "SWING_DAMAGE", boolean = true },
        { name = "Heal", eventType = "SPELL_HEAL", boolean = true },
    }

    --reset SvensBamAddon_eventList in case defaultEventList was updated
    if (SvensBamAddon_eventList == nil or not (#SvensBamAddon_eventList == #defaultEventList)) then
        SvensBamAddon_eventList = defaultEventList
    end

    if (SvensBamAddon_critList == nil) then
        SvensBamAddon_critList = {}
    end

    if (SvensBamAddon_outputDamageMessage == nil) then
        SvensBamAddon_outputDamageMessage = "BAM! SN SD!"
        SvensBamAddon_outputChannelList = { "Print", "Sound DMG", "Sound Heal" } -- Reset to fix problems in new version
    end

    if (SvensBamAddon_outputHealMessage == nil) then
        SvensBamAddon_outputHealMessage = "BAM! SN SD!"
        SvensBamAddon_outputChannelList = { "Print", "Sound DMG", "Sound Heal" } -- Reset to fix problems in new version
    end

    if (SvensBamAddon_outputChannelList == nil) then
        SvensBamAddon_outputChannelList = { "Print", "Sound DMG", "Sound Heal" }
    end

    ----Good Guide https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/InterfaceOptionsFrame.lua
    ----Options Main Menu
    SvensBamAddonConfig = {};
    SvensBamAddonConfig.panel = CreateFrame("Frame", "SvensBamAddonConfig", UIParent);
    SvensBamAddonConfig.panel.name = "Svens Bam Addon";
    SvensBamAddonConfig.panel.title = SvensBamAddonConfig.panel:CreateFontString("GeneralOptionsDescription", "OVERLAY");
    SvensBamAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonConfig.panel.title:SetJustifyH("LEFT")


    --Channel Options SubMenu
    SvensBamAddonChannelOptions = {}
    SvensBamAddonChannelOptions.panel = CreateFrame("Frame", "SvensBamAddonChannelOptions");
    SvensBamAddonChannelOptions.panel.name = "Channel options";
    SvensBamAddonChannelOptions.panel.parent = "Svens Bam Addon"
    SvensBamAddon:populateChannelSubmenu(channelButtonList, channelList)

    --General Options SubMenu NEEDS TO BE LAST BECAUSE SLIDERS CHANGE FONTSTRINGS OF ALL MENUS
    SvensBamAddonGeneralOptions = {}
    SvensBamAddonGeneralOptions.panel = CreateFrame("Frame", "SvensBamAddonGeneralOptions");
    SvensBamAddonGeneralOptions.panel.name = "General options";
    SvensBamAddonGeneralOptions.panel.parent = "Svens Bam Addon"
    SvensBamAddon:populateGeneralSubmenu(eventButtonList, SvensBamAddon_eventList, rgb)

    --Set order of Menus here
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
    InterfaceOptions_AddCategory(SvensBamAddonGeneralOptions.panel);
    InterfaceOptions_AddCategory(SvensBamAddonChannelOptions.panel);

    --Leave these here else we get Null Pointer
    SvensBamAddonConfig.panel.okay = SvensBamAddon:saveAllStringInputs() --TODO seems not to work
    SvensBamAddonChannelOptions.panel.okay = SvensBamAddon:saveAllStringInputs() --TODO seems not to work
    SvensBamAddonGeneralOptions.panel.okay = SvensBamAddon:saveAllStringInputs() --TODO seems not to work

end

function SvensBamAddon:populateGeneralSubmenu(eventButtonList, SvensBamAddon_eventList, rgb)

    local lineHeight = 16
    local boxHeight = 32
    local boxSpacing = 24 -- Even though a box is 32 high, it somehow takes only 24 of space
    local editBoxWidth = 400
    local categoryPadding = 16
    local baseYOffSet = 5

    local categoryCounter = 0 -- increase after each category
    local amountLinesWritten = 0 -- increase after each Font String
    local boxesPlaced = 0 -- increase after each edit box or check box placed

    -- Output Messages
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("OutputDamageMessageDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1

    SvensBamAddon:createOutputDamageMessageEditBox(boxHeight, editBoxWidth, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1
    categoryCounter = categoryCounter + 1

    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("OutputHealMessageDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1

    SvensBamAddon:createOutputHealMessageEditBox(boxHeight, editBoxWidth, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1

    -- Damage Threshold
    categoryCounter = categoryCounter + 1
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("ThresholdDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1

    SvensBamAddon:createThresholdEditBox(-(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1

    -- Event Types to Trigger
    categoryCounter = categoryCounter + 1
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("EventTypeDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1

    for i = 1, #SvensBamAddon_eventList do
        SvensBamAddon:createEventTypeCheckBoxes(i, 1, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing), eventButtonList, SvensBamAddon_eventList)
        boxesPlaced = boxesPlaced + 1
    end

    -- Trigger Options
    categoryCounter = categoryCounter + 1
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("TriggerOptionsDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1

    SvensBamAddon:createTriggerOnlyOnCritRecordCheckBox(1, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1

    SvensBamAddon:createSeparateOffhandCritsCheckBox(1, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1

    -- Minimap Button
    categoryCounter = categoryCounter + 1
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("OtherOptionsDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1

    SvensBamAddon:createMinimapShowOptionCheckBox(1, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1

    SvensBamAddon:createPostLinkCheckBox(1, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    boxesPlaced = boxesPlaced + 1
    categoryCounter = categoryCounter + 1

    -- Color changer
    yOffSet = 3
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("FontColorDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing));
    amountLinesWritten = amountLinesWritten + 1
    amountLinesWritten = amountLinesWritten + 1 --Another Time, because the Sliders have on line above
    for i = 1, 3 do
        SvensBamAddon:createColorSlider(i, SvensBamAddonGeneralOptions.panel, rgb, -(baseYOffSet + categoryCounter * categoryPadding + amountLinesWritten * lineHeight + boxesPlaced * boxSpacing))
    end
    categoryCounter = categoryCounter + 1


end

function SvensBamAddon:createEventTypeCheckBoxes(i, x, y, eventButtonList, SvensBamAddon_eventList)
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_EventTypeCheckButton" .. i, SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    eventButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
    checkButton:SetSize(32, 32)

    _G[checkButton:GetName() .. "Text"]:SetText(SvensBamAddon_eventList[i].name)
    _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
    if (SvensBamAddon_eventList[i].boolean) then
        eventButtonList[i]:SetChecked(true)
    end

    eventButtonList[i]:SetScript("OnClick", function()
        if eventButtonList[i]:GetChecked() then
            SvensBamAddon_eventList[i].boolean = true
        else
            SvensBamAddon_eventList[i].boolean = false
        end
    end)

end

function SvensBamAddon:createOutputDamageMessageEditBox(height, width, y)
    outputDamageMessageEditBox = SvensBamAddon:createEditBox("OutputDamageMessage", SvensBamAddonGeneralOptions.panel, height, width)
    outputDamageMessageEditBox:SetPoint("TOPLEFT", 40, y)
    outputDamageMessageEditBox:Insert(SvensBamAddon_outputDamageMessage)
    outputDamageMessageEditBox:SetCursorPosition(0)
    outputDamageMessageEditBox:SetScript("OnEscapePressed", function(...)
        outputDamageMessageEditBox:ClearFocus()
        outputDamageMessageEditBox:SetText(SvensBamAddon_outputDamageMessage)
    end)
    outputDamageMessageEditBox:SetScript("OnEnterPressed", function(...)
        outputDamageMessageEditBox:ClearFocus()
        SvensBamAddon:saveDamageOutputList()
    end)
    outputDamageMessageEditBox:SetScript("OnEnter", function(...)
        GameTooltip:SetOwner(outputDamageMessageEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText("Insert your damage message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!")
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    outputDamageMessageEditBox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function SvensBamAddon:createOutputHealMessageEditBox(height, width, y)
    outputHealMessageEditBox = SvensBamAddon:createEditBox("OutputHealMessage", SvensBamAddonGeneralOptions.panel, height, width)
    outputHealMessageEditBox:SetPoint("TOPLEFT", 40, y)
    outputHealMessageEditBox:Insert(SvensBamAddon_outputHealMessage)
    outputHealMessageEditBox:SetCursorPosition(0)
    outputHealMessageEditBox:SetScript("OnEscapePressed", function(...)
        outputHealMessageEditBox:ClearFocus()
        outputHealMessageEditBox:SetText(SvensBamAddon_outputHealMessage)
    end)
    outputHealMessageEditBox:SetScript("OnEnterPressed", function(...)
        outputHealMessageEditBox:ClearFocus()
        SvensBamAddon:saveHealOutputList()
    end)
    outputHealMessageEditBox:SetScript("OnEnter", function(...)
        GameTooltip:SetOwner(outputHealMessageEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText("Insert your heal message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!")
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    outputHealMessageEditBox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function SvensBamAddon:createThresholdEditBox(y)
    thresholdEditBox = SvensBamAddon:createEditBox("ThresholdEditBox", SvensBamAddonGeneralOptions.panel, 32, 400)
    thresholdEditBox:SetPoint("TOPLEFT", 40, y)
    thresholdEditBox:Insert(SvensBamAddon_threshold)
    thresholdEditBox:SetCursorPosition(0)
    thresholdEditBox:SetScript("OnEscapePressed", function(...)
        thresholdEditBox:ClearFocus()
        thresholdEditBox:SetText(SvensBamAddon_threshold)
    end)
    thresholdEditBox:SetScript("OnEnterPressed", function(...)
        thresholdEditBox:ClearFocus()
        SvensBamAddon:saveThreshold()
    end)
    thresholdEditBox:SetScript("OnEnter", function(...)
        GameTooltip:SetOwner(thresholdEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText("Damage or heal must be at least this high to trigger bam!\nSet 0 to trigger on everything.")
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    thresholdEditBox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function SvensBamAddon:createTriggerOnlyOnCritRecordCheckBox(x, y)
    local checkButton = CreateFrame("CheckButton", "OnlyOnMaxCritCheckBox", SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
    checkButton:SetSize(32, 32)
    OnlyOnMaxCritCheckBoxText:SetText("Only trigger on new crit record")
    OnlyOnMaxCritCheckBoxText:SetFont(GameFontNormal:GetFont(), 14, "NONE")

    if (SvensBamAddon_onlyOnNewMaxCrits) then
        OnlyOnMaxCritCheckBox:SetChecked(true)
    end

    OnlyOnMaxCritCheckBox:SetScript("OnClick", function()
        if OnlyOnMaxCritCheckBox:GetChecked() then
            SvensBamAddon_onlyOnNewMaxCrits = true
        else
            SvensBamAddon_onlyOnNewMaxCrits = false
        end
    end)
end

function SvensBamAddon:createSeparateOffhandCritsCheckBox(x, y)
    local checkButton = CreateFrame("CheckButton", "SeparateOffhandCritsCheckBox", SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
    checkButton:SetSize(32, 32)
    SeparateOffhandCritsCheckBoxText:SetText("Show off-hand crits separately")
    SeparateOffhandCritsCheckBoxText:SetFont(GameFontNormal:GetFont(), 14, "NONE")

    if (SvensBamAddon_separateOffhandCrits) then
        SeparateOffhandCritsCheckBox:SetChecked(true)
    end

    SeparateOffhandCritsCheckBox:SetScript("OnClick", function()
        if SeparateOffhandCritsCheckBox:GetChecked() then
            SvensBamAddon_separateOffhandCrits = true
        else
            SvensBamAddon_separateOffhandCrits = false
        end
    end)
end

function SvensBamAddon:createPostLinkCheckBox(x, y)
    local checkButton = CreateFrame("CheckButton", "PostLinkCheckBox", SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
    checkButton:SetSize(32, 32)
    PostLinkCheckBoxText:SetText("Post links of spells")
    PostLinkCheckBoxText:SetFont(GameFontNormal:GetFont(), 14, "NONE")

    if (SvensBamAddon_Settings.postLinkOfSpell) then
        PostLinkCheckBox:SetChecked(true)
    end

    PostLinkCheckBox:SetScript("OnClick", function()
        if PostLinkCheckBox:GetChecked() then
            SvensBamAddon_Settings.postLinkOfSpell = true
        else
            SvensBamAddon_Settings.postLinkOfSpell = false
        end
    end)
end

function SvensBamAddon:createMinimapShowOptionCheckBox(x, y)
    local checkButton = CreateFrame("CheckButton", "MinimapShowOptionButtonCheckBox", SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
    checkButton:SetSize(32, 32)
    MinimapShowOptionButtonCheckBoxText:SetText("Show Minimap Button")
    MinimapShowOptionButtonCheckBoxText:SetFont(GameFontNormal:GetFont(), 14, "NONE")

    if (SvensBamAddon_MinimapSettings.hide == false) then
        MinimapShowOptionButtonCheckBox:SetChecked(true)
        SvensBamAddon:createMinimapButton()
    end

    MinimapShowOptionButtonCheckBox:SetScript("OnClick", function()
        if MinimapShowOptionButtonCheckBox:GetChecked() then
            SvensBamAddon_MinimapSettings.hide = false
            if (LibDBIcon10_SvensBamAddon_dataObject == nil) then
                SvensBamAddon:createMinimapButton()
            else
                LibDBIcon10_SvensBamAddon_dataObject:Show()
            end
        else
            LibDBIcon10_SvensBamAddon_dataObject:Hide()
            SvensBamAddon_MinimapSettings.hide = true
        end
    end)
end

function SvensBamAddon:populateChannelSubmenu(channelButtonList, channelList)
    SvensBamAddonChannelOptions.panel.title = SvensBamAddonChannelOptions.panel:CreateFontString("OutputChannelDescription", "OVERLAY");
    SvensBamAddonChannelOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonChannelOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    -- Checkboxes channels and Edit Box for whispers
    for i = 1, #channelList do
        SvensBamAddon:createCheckButtonChannel(i, 1, i, channelButtonList, channelList)
    end
    SvensBamAddon:createResetChannelListButton(SvensBamAddonChannelOptions.panel, channelList, channelButtonList)
end

function SvensBamAddon:createCheckButtonChannel(i, x, y, channelButtonList, channelList)

    local xOffset = x * 32
    local yOffset = y * -24
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_ChannelCheckButton" .. i, SvensBamAddonChannelOptions.panel, "UICheckButtonTemplate")
    channelButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", xOffset, yOffset)
    checkButton:SetSize(32, 32)

    _G[checkButton:GetName() .. "Text"]:SetText(channelList[i])
    _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
    for j = 1, #SvensBamAddon_outputChannelList do
        if (SvensBamAddon_outputChannelList[j] == channelList[i]) then
            checkButton:SetChecked(true)
        end
    end

    checkButton:SetScript("OnClick", function()
        if checkButton:GetChecked() then
            table.insert(SvensBamAddon_outputChannelList, channelList[i])
        else
            indexOfFoundValues = {}
            for j = 1, #SvensBamAddon_outputChannelList do
                if (SvensBamAddon_outputChannelList[j] == channelList[i]) then
                    table.insert(indexOfFoundValues, j)
                end
            end
            j = #indexOfFoundValues
            while (j > 0) do
                table.remove(SvensBamAddon_outputChannelList, indexOfFoundValues[j])
                j = j - 1;
            end
        end
    end)

    -- Create Edit Box for whispers
    if (channelList[i] == "Whisper") then
        whisperFrame = SvensBamAddon:createEditBox("WhisperList", SvensBamAddonChannelOptions.panel, 32, 400)
        whisperFrame:SetPoint("TOP", 50, yOffset)
        for _, v in pairs(SvensBamAddon_whisperList) do
            whisperFrame:Insert(v .. " ")
        end
        whisperFrame:SetCursorPosition(0)

        whisperFrame:SetScript("OnEscapePressed", function(...)
            whisperFrame:ClearFocus()
            whisperFrame:SetText("")
            for _, v in pairs(SvensBamAddon_whisperList) do
                whisperFrame:Insert(v .. " ")
            end
        end)
        whisperFrame:SetScript("OnEnterPressed", function(...)
            whisperFrame:ClearFocus()
            SvensBamAddon:saveWhisperList()
        end)
        whisperFrame:SetScript("OnEnter", function(...)
            GameTooltip:SetOwner(whisperFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText("Separate names of people you want to whisper to with spaces.")
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        whisperFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    -- Create Edit Box for Damage Soundfile and reset button
    if (channelList[i] == "Sound DMG") then
        local soundfileDamageFrameXOffset = 50
        local soundfileDamageFrameHeight = 32
        local soundfileDamageFrameWidth = 400
        soundfileDamageFrame = SvensBamAddon:createEditBox("SoundfileDamage", SvensBamAddonChannelOptions.panel, soundfileDamageFrameHeight, soundfileDamageFrameWidth)
        soundfileDamageFrame:SetPoint("TOP", soundfileDamageFrameXOffset, yOffset)

        soundfileDamageFrame:Insert(SvensBamAddon_soundfileDamage)

        soundfileDamageFrame:SetCursorPosition(0)

        soundfileDamageFrame:SetScript("OnEscapePressed", function(...)
            soundfileDamageFrame:ClearFocus()
            soundfileDamageFrame:SetText("")
            soundfileDamageFrame:Insert(SvensBamAddon_soundfileDamage)
        end)
        soundfileDamageFrame:SetScript("OnEnterPressed", function(...)
            soundfileDamageFrame:ClearFocus()
            SvensBamAddon:saveSoundfileDamage()
        end)
        soundfileDamageFrame:SetScript("OnEnter", function(...)
            GameTooltip:SetOwner(soundfileDamageFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText("Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths separated by spaces. Bam Addon will then play a random sound of that list.")
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        soundfileDamageFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local resetSoundfileButtonWidth = 56
        SvensBamAddon:createResetSoundfileDamageButton(SvensBamAddonChannelOptions.panel, resetSoundfileButtonWidth, soundfileDamageFrameWidth / 2 + soundfileDamageFrameXOffset + resetSoundfileButtonWidth / 2, yOffset, soundfileDamageFrameHeight)
    end

    -- Create Edit Box for Heal Soundfile and reset button
    if (channelList[i] == "Sound Heal") then
        local soundfileHealFrameXOffset = 50
        local soundfileHealFrameHeight = 32
        local soundfileHealFrameWidth = 400
        soundfileHealFrame = SvensBamAddon:createEditBox("SoundfileHeal", SvensBamAddonChannelOptions.panel, soundfileHealFrameHeight, soundfileHealFrameWidth)
        soundfileHealFrame:SetPoint("TOP", soundfileHealFrameXOffset, yOffset)

        soundfileHealFrame:Insert(SvensBamAddon_soundfileHeal)

        soundfileHealFrame:SetCursorPosition(0)

        soundfileHealFrame:SetScript("OnEscapePressed", function(...)
            soundfileHealFrame:ClearFocus()
            soundfileHealFrame:SetText("")
            soundfileHealFrame:Insert(SvensBamAddon_soundfileHeal)
        end)
        soundfileHealFrame:SetScript("OnEnterPressed", function(...)
            soundfileHealFrame:ClearFocus()
            SvensBamAddon:saveSoundfileHeal()
        end)
        soundfileHealFrame:SetScript("OnEnter", function(...)
            GameTooltip:SetOwner(soundfileHealFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText("Specify sound file path, beginning from your WoW _classic_ folder.\n"
                    .. "If you copy a sound file to your World of Warcraft folder, you have to restart the client before that file works!\n"
                    .. "You can enter multiple file paths separated by spaces. Bam Addon will then play a random sound of that list.")
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        soundfileHealFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        local resetSoundfileButtonWidth = 56
        SvensBamAddon:createResetSoundfileHealButton(SvensBamAddonChannelOptions.panel, resetSoundfileButtonWidth, soundfileHealFrameWidth / 2 + soundfileHealFrameXOffset + resetSoundfileButtonWidth / 2, yOffset, soundfileHealFrameHeight)
    end

    -- Create Edit Box for Print
    if (channelList[i] == "Print") then
        chatChannelFrame = SvensBamAddon:createEditBox("ChatFrame", SvensBamAddonChannelOptions.panel, 32, 400)
        chatChannelFrame:SetPoint("TOP", 50, -24 * y)
        chatChannelFrame:Insert(SvensBamAddon_Settings.chatFrameName)
        chatChannelFrame:SetCursorPosition(0)

        chatChannelFrame:SetScript("OnEscapePressed", function(...)
            chatChannelFrame:ClearFocus()
            chatChannelFrame:SetText("")
            chatChannelFrame:Insert(SvensBamAddon_Settings.chatFrameName)
        end)
        chatChannelFrame:SetScript("OnEnterPressed", function(...)
            chatChannelFrame:ClearFocus()
            SvensBamAddon:saveChatFrame()
        end)
        chatChannelFrame:SetScript("OnEnter", function(...)
            GameTooltip:SetOwner(chatChannelFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText("Define Channel Frame you want SvensBamAddon to print to")
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        chatChannelFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
end

function SvensBamAddon:createResetSoundfileDamageButton(parentFrame, resetSoundfileButtonWidth, x, y, soundfileDamageFrameHeight)
    local resetSoundfileButtonHeight = 24
    resetChannelListButton = CreateFrame("Button", "ResetSoundfileDamage", parentFrame, "UIPanelButtonTemplate");
    resetChannelListButton:ClearAllPoints()
    resetChannelListButton:SetPoint("TOP", x, y - (soundfileDamageFrameHeight - resetSoundfileButtonHeight) / 2)
    resetChannelListButton:SetSize(resetSoundfileButtonWidth, resetSoundfileButtonHeight)
    resetChannelListButton:SetText("Reset")
    resetChannelListButton:SetScript("OnClick", function(...)
        SvensBamAddon_soundfileDamage = "Interface\\AddOns\\SvensBamAddon\\bam.ogg"
        soundfileDamageFrame:SetText(SvensBamAddon_soundfileDamage)
    end)
end

function SvensBamAddon:createResetSoundfileHealButton(parentFrame, resetSoundfileButtonWidth, x, y, soundfileDamageFrameHeight)
    local resetSoundfileButtonHeight = 24
    resetChannelListButton = CreateFrame("Button", "ResetSoundfileHeal", parentFrame, "UIPanelButtonTemplate");
    resetChannelListButton:ClearAllPoints()
    resetChannelListButton:SetPoint("TOP", x, y - (soundfileDamageFrameHeight - resetSoundfileButtonHeight) / 2)
    resetChannelListButton:SetSize(resetSoundfileButtonWidth, resetSoundfileButtonHeight)
    resetChannelListButton:SetText("Reset")
    resetChannelListButton:SetScript("OnClick", function(...)
        SvensBamAddon_soundfileHeal = "Interface\\AddOns\\SvensBamAddon\\bam.ogg"
        soundfileHealFrame:SetText(SvensBamAddon_soundfileHeal)
    end)
end

function SvensBamAddon:createResetChannelListButton(parentFrame, channelList, channelButtonList)
    resetChannelListButton = CreateFrame("Button", "ResetButtonChannels", parentFrame, "UIPanelButtonTemplate");
    resetChannelListButton:ClearAllPoints()
    resetChannelListButton:SetPoint("TOPLEFT", 32, ((#channelList) + 1) * -24 - 8)
    resetChannelListButtonText = "Clear Channel List (May fix bugs after updating)"
    resetChannelListButton:SetSize(resetChannelListButtonText:len() * 7, 32)
    resetChannelListButton:SetText(resetChannelListButtonText)
    resetChannelListButton:SetScript("OnClick", function(...)
        for i = 1, #channelButtonList do
            channelButtonList[i]:SetChecked(false)
        end
        SvensBamAddon_outputChannelList = {}
    end)
end

function SvensBamAddon:createColorSlider(i, panel, rgb, yOffSet)
    local slider = CreateFrame("Slider", "SvensBamAddon_Slider" .. i, panel, "OptionsSliderTemplate")
    slider:ClearAllPoints()
    slider:SetPoint("TOPLEFT", 32, -16 * 2 * (i - 1) + yOffSet)
    slider:SetSize(256, 16)
    slider:SetMinMaxValues(0, 255)
    slider:SetValueStep(1)
    _G[slider:GetName() .. "Low"]:SetText("|c00ffcc00Min:|r 0")
    _G[slider:GetName() .. "High"]:SetText("|c00ffcc00Max:|r 255")
    slider:SetScript("OnValueChanged", function()
        local value = floor(slider:GetValue())
        _G[slider:GetName() .. "Text"]:SetText("|c00ffcc00" .. rgb[i].color .. "|r " .. value)
        _G[slider:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
        rgb[i].value = SvensBamAddon:convertRGBDecimalToRGBHex(value)
        SvensBamAddon_color = "|cff" .. rgb[1].value .. rgb[2].value .. rgb[3].value
        SvensBamAddon:setPanelTexts()
    end)
    slider:SetValue(tonumber("0x" .. rgb[i].value))

end

function SvensBamAddon:saveWhisperList()
    SvensBamAddon_whisperList = {}
    for arg in string.gmatch(whisperFrame:GetText(), "%S+") do
        table.insert(SvensBamAddon_whisperList, arg)
    end
end

function SvensBamAddon:saveSoundfileDamage()
    SvensBamAddon_soundfileDamage = soundfileDamageFrame:GetText()
end

function SvensBamAddon:saveSoundfileHeal()
    SvensBamAddon_soundfileHeal = soundfileHealFrame:GetText()
end

function SvensBamAddon:saveDamageOutputList()
    SvensBamAddon_outputDamageMessage = outputDamageMessageEditBox:GetText()
end

function SvensBamAddon:saveHealOutputList()
    SvensBamAddon_outputHealMessage = outputHealMessageEditBox:GetText()
end

function SvensBamAddon:saveThreshold()
    SvensBamAddon_threshold = thresholdEditBox:GetNumber()
end

function SvensBamAddon:saveChatFrame()
    local channelToSave = chatChannelFrame:GetText()
    local channelFound = SvensBamAddon:setIndexOfChatFrame(channelToSave)
    if (channelFound == true) then
        SvensBamAddon_Settings.chatFrameName = channelToSave
    else
        print(SvensBamAddon_color .. "Cannot save channel " .. channelToSave .. ". Channel not found!")
    end
end

function SvensBamAddon:saveAllStringInputs()
    SvensBamAddon:saveDamageOutputList()
    SvensBamAddon:saveHealOutputList()
    SvensBamAddon:saveSoundfileDamage()
    SvensBamAddon:saveSoundfileHeal()
    SvensBamAddon:saveThreshold()
    SvensBamAddon:saveWhisperList()
    SvensBamAddon:saveChatFrame()
end

function SvensBamAddon:createEditBox(name, parentFrame, height, width)
    local eb = CreateFrame("EditBox", name, parentFrame, "InputBoxTemplate")
    eb:ClearAllPoints()
    eb:SetAutoFocus(false)
    eb:SetHeight(height)
    eb:SetWidth(width)
    eb:SetFontObject("ChatFontNormal")
    return eb
end

function SvensBamAddon:convertRGBDecimalToRGBHex(decimal)
    local result
    local numbers = "0123456789ABCDEF"
    result = numbers:sub(1 + (decimal / 16), 1 + (decimal / 16)) .. numbers:sub(1 + (decimal % 16), 1 + (decimal % 16))
    return result
end

function SvensBamAddon:createMinimapButton()

    --Dropdown Menu
    local lib = LibStub("LibDropDownMenu");
    local menuFrame = lib.Create_DropDownMenu("MyAddOn_DropDownMenu");
    -- instead of template UIDropDownMenuTemplate
    local menuList = {
        { text = "Crit List options", isNotRadio = true, notCheckable = true, hasArrow = true,
          menuList = {
              { text = "List crits", isNotRadio = true, notCheckable = true,
                func = function()
                    SvensBamAddon:listCrits();
                end
              },

              { text = "Report crits", isNotRadio = true, notCheckable = true,
                func = function()
                    SvensBamAddon:reportCrits();
                end
              },

              { text = "Clear crits", isNotRadio = true, notCheckable = true,
                func = function()
                    SvensBamAddon:clearCritList();
                end
              },
          }
        },

        { text = "Open config", isNotRadio = true, notCheckable = true,
          func = function()
              InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
              InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
          end
        },
        { text = "Close menu", isNotRadio = true, notCheckable = true },
    };

    --Minimap Icon
    SvensBamAddon_icon = SvensBamAddon_ldb:NewDataObject("SvensBamAddon_dataObject", {
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
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register("SvensBamAddon_dataObject", SvensBamAddon_icon, SvensBamAddon_MinimapSettings)
end

function SvensBamAddon:setPanelTexts()
    GeneralOptionsDescription:SetText(SvensBamAddon_color .. "Choose sub menu to change options.\n\n\nCommand line options:\n\n"
            .. "/bam list: lists highest crits of each spell.\n"
            .. "/bam report: report highest crits of each spell to channel list.\n"
            .. "/bam clear: delete list of highest crits.\n/bam config: Opens this config page.")
    OutputDamageMessageDescription:SetText(SvensBamAddon_color .. "Output Message Damage")
    OutputHealMessageDescription:SetText(SvensBamAddon_color .. "Output Message Heal")
    EventTypeDescription:SetText(SvensBamAddon_color .. "Event Types to Trigger")
    SvensBamAddonGeneralOptions.panel.title:SetText(SvensBamAddon_color .. "Change color of Font")
    FontColorDescription:SetText(SvensBamAddon_color .. "Change color of Font")
    OutputChannelDescription:SetText(SvensBamAddon_color .. "Output Channel")
    ThresholdDescription:SetText(SvensBamAddon_color .. "Least amount of damage/heal to trigger bam:")
    TriggerOptionsDescription:SetText(SvensBamAddon_color .. "Trigger options:")
    OtherOptionsDescription:SetText(SvensBamAddon_color .. "Other options:")
end

-- Taken and edited from BamModRevived on WoWInterface. Thanks to Sylen
-- We use this to get the index of our output channel
function SvensBamAddon:setIndexOfChatFrame(chatFrameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local chatWindowName = GetChatWindowInfo(i)
        if chatWindowName == chatFrameName then
            SvensBamAddon_Settings.chatFrameIndex = i
            return true
        end
    end
    return false
end