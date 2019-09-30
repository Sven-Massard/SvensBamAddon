
function loadAddon()
    local whisperFrame
    local outputMessageEditBox
    local channelButtonList = {}
    local eventButtonList = {}
    local channelList = 
        {
            "Say",
            "Yell",
            "Print",
            "Guild",
            "Raid",
            "Emote",
            "Party",
            "Officer",
            "Raid_Warning",
            "Instanz chat",
            "Battleground",
            "Whisper",
        }
        
    if(outputChannelList == nil) then
        outputChannelList = {}
    end
   
    if(whisperList == nil) then
        whisperList = {}
    end

    defaultEventList = 
        {
            {name = "Spell Damage", eventType = "SPELL_DAMAGE", boolean = true},
            {name = "Ranged", eventType = "RANGE_DAMAGE",  boolean = false},
            {name = "Melee Autohit", eventType = "SWING_DAMAGE",  boolean = false},
            {name = "Heal", eventType = "SPELL_HEAL",  boolean = false},
        }

    --reset eventList in case defaultEventList was updated
    if(eventList == nil or not (# eventList == #defaultEventList)) then 
        eventList = defaultEventList
    end
      
    if(critList == nil) then
        critList = {}
    end
    
    if(outputMessage == nil) then
        outputMessage = "BAM! SN SD"
    end
    
    --Good Guide https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/InterfaceOptionsFrame.lua
    --Options Main Menu
    SvensBamAddonConfig = {};
    SvensBamAddonConfig.panel = CreateFrame( "Frame", "SvensBamAddonConfig", UIParent );    
    SvensBamAddonConfig.panel.name = "Svens Bam Addon";
    SvensBamAddonConfig.panel.title = SvensBamAddonConfig.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonConfig.panel.title:SetText("|cff00ff00Choose sub menu to change options")
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
    
    --General Options SubMenu
    SvensBamAddonGeneralOptions = {}
    SvensBamAddonGeneralOptions.panel = CreateFrame( "Frame", "SvensBamAddonGeneralOptions");
    SvensBamAddonGeneralOptions.panel.name = "General options";
    SvensBamAddonGeneralOptions.panel.parent = "Svens Bam Addon"
    InterfaceOptions_AddCategory(SvensBamAddonGeneralOptions.panel);
    populateGeneralSubmenu(eventButtonList, eventList)
    
    --Channel Options SubMenu
    SvensBamAddonChannelOptions = {}
    SvensBamAddonChannelOptions.panel = CreateFrame( "Frame", "SvensBamAddonChannelOptions");
    SvensBamAddonChannelOptions.panel.name = "Channel options";
    SvensBamAddonChannelOptions.panel.parent = "Svens Bam Addon"
    SvensBamAddonChannelOptions.panel.okay = function()
        saveWhisperList()
        saveOutputList()
    end
    InterfaceOptions_AddCategory(SvensBamAddonChannelOptions.panel);
    populateChannelSubmenu(channelButtonList, channelList)
    
    print("|cff00ff00Svens Bam Addon loaded!")
end

function populateGeneralSubmenu(eventButtonList, eventList)
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonGeneralOptions.panel.title:SetText("|cff00ff00Output Message")
    
    createOutputMessageEditBox()
    
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -5 - 64);
    SvensBamAddonGeneralOptions.panel.title:SetText("|cff00ff00Event Types to Trigger")
    
    for i=1, # eventList do
        createEventTypeCheckBoxes(i, 1, i, eventButtonList, eventList)
    end
end

function createEventTypeCheckBoxes(i, x, y, eventButtonList, eventList)
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_EventTypeCheckButton" .. i, SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    eventButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y*-24 -64)
    checkButton:SetSize(32, 32)
    
    _G[checkButton:GetName() .. "Text"]:SetText(eventList[i].name)
    _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
    for j = 1, # eventList do
        if(eventList[i].boolean) then            
            eventButtonList[i]:SetChecked(true)
        end
    end

    eventButtonList[i]:SetScript("OnClick", function()   
        if eventButtonList[i]:GetChecked() then
            eventList[i].boolean = true
        else
            eventList[i].boolean = false
        end
    end)

end

function createOutputMessageEditBox()
    outputMessageEditBox = createEditBox("OutputMessage", SvensBamAddonGeneralOptions.panel)
    outputMessageEditBox:SetPoint("TOPLEFT", 40, -24)
    outputMessageEditBox:Insert(outputMessage)
    outputMessageEditBox:SetCursorPosition(0)   
    outputMessageEditBox:SetScript( "OnEscapePressed", function(...)
        outputMessageEditBox:ClearFocus()
        outputMessageEditBox:SetText(outputMessage)
        end)
    outputMessageEditBox:SetScript( "OnEnterPressed", function(...)
        outputMessageEditBox:ClearFocus()
        saveOutputList()
    end)
    outputMessageEditBox:SetScript( "OnEnter", function(...)            
        GameTooltip:SetOwner(outputMessageEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText( "Insert your damage message here.\nSN will be replaced with spell name.\nSD with spell damage.\nDefault: BAM! SN SD" )
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    outputMessageEditBox:SetScript( "OnLeave", function()
        GameTooltip:Hide()
    end)
end

function populateChannelSubmenu(channelButtonList, channelList)
    SvensBamAddonChannelOptions.panel.title = SvensBamAddonChannelOptions.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonChannelOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonChannelOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonChannelOptions.panel.title:SetText("|cff00ff00Output Channel")
    -- Checkboxes channels and Edit Box for whispers
    for i=1, # channelList do
        createCheckButtonChannel(i, 1, i, channelButtonList, channelList)
    end
    createResetChannelListButton(SvensBamAddonChannelOptions.panel, channelList, channelButtonList)
end

function createCheckButtonChannel(i, x, y, channelButtonList, channelList)
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_ChannelCheckButton" .. i, SvensBamAddonChannelOptions.panel, "UICheckButtonTemplate")
    channelButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y*-24)
    checkButton:SetSize(32, 32)
    
    _G[checkButton:GetName() .. "Text"]:SetText(channelList[i])
    _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
    for j = 1, # outputChannelList do
        if(outputChannelList[j] == channelList[i]) then            
            channelButtonList[i]:SetChecked(true)
        end
    end
    
    channelButtonList[i]:SetScript("OnClick", function()   
        if channelButtonList[i]:GetChecked() then
            table.insert(outputChannelList, channelList[i])         
        else
            indexOfFoundValues = {}
            for j = 1, # outputChannelList do
                if(outputChannelList[j] == channelList[i]) then
                    table.insert(indexOfFoundValues, j)
                end
            end
            j = # indexOfFoundValues
            while (j>0) do   
                table.remove(outputChannelList, indexOfFoundValues[j])
                j = j-1;
            end
        end
    end)
    
    -- Create Edit Box for whispers
    if(channelList[i] == "Whisper") then
        whisperFrame = createEditBox("WhisperList", SvensBamAddonChannelOptions.panel)
        whisperFrame:SetPoint("TOP",50, -24*y)
        for _, v in pairs(whisperList) do
            whisperFrame:Insert(v.." ")
        end
        whisperFrame:SetCursorPosition(0)
        
        whisperFrame:SetScript( "OnEscapePressed", function(...)
            whisperFrame:ClearFocus()
            whisperFrame:SetText("")
            for _, v in pairs(whisperList) do
                whisperFrame:Insert(v.." ")
            end
        end)
        whisperFrame:SetScript( "OnEnterPressed", function(...)
            whisperFrame:ClearFocus()
            saveWhisperList()
        end)
        whisperFrame:SetScript( "OnEnter", function(...)            
            GameTooltip:SetOwner(whisperFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText( "Separate names of people you want to whisper to with spaces." )
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        whisperFrame:SetScript( "OnLeave", function()
            GameTooltip:Hide()
        end)
    end
end

function createResetChannelListButton(parentFrame, channelList, channelButtonList)
    resetChannelListButton = CreateFrame("Button", "ResetButtonChannels", parentFrame, "UIPanelButtonTemplate");
    resetChannelListButton:ClearAllPoints()
    resetChannelListButton:SetPoint("TOPLEFT", 32, ((# channelList) + 1)*-24 -8)
    resetChannelListButtonText = "Reset Channel List (May fix bugs after updating)"
    resetChannelListButton:SetSize(resetChannelListButtonText:len()*7, 32)
    resetChannelListButton:SetText(resetChannelListButtonText)
    resetChannelListButton:SetScript( "OnClick", function(...)
        for i = 1, # channelButtonList do
            channelButtonList[i]:SetChecked(false)
        end
            outputChannelList = {}
    end)
end

function saveWhisperList()
    whisperList = {}
    for arg in string.gmatch(whisperFrame:GetText(), "%S+") do
        table.insert(whisperList, arg)
    end
end

function saveOutputList()
    outputMessage = outputMessageEditBox:GetText()
end
    
function createEditBox(name, parentFrame)
    local eb = CreateFrame("EditBox", name, parentFrame, "InputBoxTemplate")
    eb:ClearAllPoints()
    eb:SetAutoFocus(false) -- dont automatically focus
    eb:SetHeight(32)
    eb:SetWidth(400)
    eb:SetFontObject("ChatFontNormal")
    return eb
end