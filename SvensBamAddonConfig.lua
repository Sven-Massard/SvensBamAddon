
function loadAddon()
    local whisperFrame
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
        }
        
    if(outputChannelList == nil) then
        outputChannelList = {}
    end
   
    if(whisperList == nil) then
        whisperList = {}
    end
    
    --Good Guide https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/InterfaceOptionsFrame.lua
    --Options Main Menu
    SvensBamAddonConfig = {};
    SvensBamAddonConfig.panel = CreateFrame( "Frame", "SvensBamAddonConfig", UIParent );    
    SvensBamAddonConfig.panel.name = "Svens Bam Addon";
    SvensBamAddonConfig.panel.title = SvensBamAddonConfig.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonConfig.panel.title:SetText("|cff00ff00 Choose sub menu to change options")
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
    
    --General Options SubMenu
    SvensBamAddonGeneralOptions = {}
    SvensBamAddonGeneralOptions.panel = CreateFrame( "Frame", "SvensBamAddonGeneralOptions");
    SvensBamAddonGeneralOptions.panel.name = "General options";
    SvensBamAddonGeneralOptions.panel.parent = "Svens Bam Addon"
    InterfaceOptions_AddCategory(SvensBamAddonGeneralOptions.panel);
    populateGeneralSubmenu()
    
    --Channel Options SubMenu
    SvensBamAddonChannelOptions = {}
    SvensBamAddonChannelOptions.panel = CreateFrame( "Frame", "SvensBamAddonChannelOptions");
    SvensBamAddonChannelOptions.panel.name = "Channel options";
    SvensBamAddonChannelOptions.panel.parent = "Svens Bam Addon"
    SvensBamAddonChannelOptions.panel.okay = function()
        saveWhisperList()
    end
    InterfaceOptions_AddCategory(SvensBamAddonChannelOptions.panel);
    populateChannelSubmenu(buttonList, list)
end

function populateChannelSubmenu(buttonList, list)
    SvensBamAddonChannelOptions.panel.title = SvensBamAddonChannelOptions.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonChannelOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonChannelOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonChannelOptions.panel.title:SetText("|cff00ff00 Output Channel")
    -- Checkboxes Channel and Whisperlist
    for i=1, # list do
        createCheckButtonChannel(i, 1, i, buttonList, list)
    end   
end

function populateGeneralSubmenu()
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString(nil, "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonGeneralOptions.panel.title:SetText("|cff00ff00 Message Prepend")
--    createEditBox(name, parentFrame)
end
    
function createCheckButtonChannel(i, x, y, buttonList, list)
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_CheckButton" .. i, SvensBamAddonChannelOptions.panel, "UICheckButtonTemplate")
    buttonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y*-24)
    checkButton:SetSize(32, 32)
    
    _G[checkButton:GetName() .. "Text"]:SetText(list[i])
    _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
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
    
    -- Create Edit Box for whispers
    if(list[i] == "Whisper") then
        whisperFrame = createEditBox("WhisperList", SvensBamAddonChannelOptions.panel)
        whisperFrame:SetPoint("TOP",50, -24*y)
        for _, v in pairs(_G["whisperList"]) do
            whisperFrame:Insert(v.." ")
        end
        whisperFrame:SetCursorPosition(0)
        
        whisperFrame:SetScript( "OnEscapePressed", function(...)
            whisperFrame:SetText("")
            for _, v in pairs(_G["whisperList"]) do
                whisperFrame:Insert(v.." ")
            end
        end)
        whisperFrame:SetScript( "OnEnterPressed", function(...)
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

function saveWhisperList()
    whisperFrame:ClearFocus()
    whisperList = {}
    for arg in string.gmatch(whisperFrame:GetText(), "%S+") do
        table.insert(whisperList, arg)
    end
    _G["whisperList"] = whisperList
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