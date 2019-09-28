
function loadAddon()
    SvensBamAddonConfig = {};
    SvensBamAddonConfig.panel = CreateFrame( "Frame", "SvensBamAddonConfig", UIParent );
    local buttonList = {}
    local list = 
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
            "Channel"
        }
        
    if(outputChannelList == nil) then
        outputChannelList = {}
    end
   
    if(whisperList == nil) then
        whisperList = {}
    end

    -- Register in the Interface Addon Options GUI
    -- Set the name for the Category for the Options Panel
    SvensBamAddonConfig.panel.name = "Svens Bam Addon";
    -- Add the panel to the Interface Options
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
    SvensBamAddonConfig.panel.title = SvensBamAddonConfig.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonConfig.panel.title:SetText("Output Channel")
    
    for i=1, # list do -- Checkboxes Channel
        createCheckButtonChannel(i, 1, i, buttonList, list)
    end
   
end    
    
    --- Copied from RightClickModifier.lua and modified to needs
    
    function createCheckButtonChannel(i, x, y, buttonList, list)
        
        local checkButton = CreateFrame("CheckButton", "SvensBamAddon_CheckButton" .. i, SvensBamAddonConfig.panel, "UICheckButtonTemplate")
        buttonList[i] = checkButton
        
        checkButton:ClearAllPoints()
        checkButton:SetPoint("TOPLEFT", x * 32, y*-24)
        checkButton:SetSize(32, 32)
        
        _G[checkButton:GetName() .. "Text"]:SetText(list[i])
        _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
        
        if(list[i] == "Whisper") then
            local whisperFrame = createInputFrame(y)
            for _, v in pairs(_G["whisperList"]) do
                whisperFrame:Insert(v.." ")
            end
            whisperFrame:SetCursorPosition(0)
            whisperFrame:SetScript( "OnEscapePressed", function(...)
                whisperFrame:ClearFocus()
                saveWhisperList(whisperFrame)
            end)
            whisperFrame:SetScript( "OnEnterPressed", function(...)
                whisperFrame:ClearFocus()
                saveWhisperList(whisperFrame)
            end)
        end
        
        for j = 1, # outputChannelList do
            if(outputChannelList[j] == list[i]) then
                
                buttonList[i]:SetChecked(true)
            end
        end
        
        buttonList[i]:SetScript("OnClick", function()   
            if buttonList[i]:GetChecked() then
                table.insert(outputChannelList, list[i])         
            else
                indexOfFoundValues = {}
                for j = 1, # outputChannelList do
                    if(outputChannelList[j] == list[i]) then
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
        
    end
    
    function saveWhisperList(whisperFrame)
        whisperList = {}
        for arg in string.gmatch(whisperFrame:GetText(), "%S+") do
            table.insert(whisperList, arg)
        end
        _G["whisperList"] = whisperList
    end
    
    function createInputFrame(y)
        local eb = CreateFrame("EditBox", "WhisperList", SvensBamAddonConfig.panel, "InputBoxTemplate")
        eb:ClearAllPoints()
        eb:SetPoint("TOP",50, -24*y)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetHeight(32)
        eb:SetWidth(400)
        eb:SetFontObject("ChatFontNormal")
        return eb
    end
    
    function setupButtons(i)
        for i = 1, 4 do
            if i % 2 == 1 then
    
                    buttonList[i]:SetChecked(true)
                    buttonList[i + 1]:SetAlpha(1)
                    buttonList[i + 1]:Enable()
    
                    buttonList[i]:SetChecked(true)
            end
        end
    end