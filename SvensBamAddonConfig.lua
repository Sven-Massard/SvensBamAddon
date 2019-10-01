﻿
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
            "Battleground",
            "Whisper",
        }

    if(SBM_color == nil) then
		SBM_color = "|cff".."94".."CF".."00"
    end
	
	local rgb =
		{
			{color = "Red",   value = SBM_color:sub(5, 6)},
			{color = "Green", value= SBM_color:sub(7, 8)},
			{color = "Blue",  value= SBM_color:sub(9, 10)}
		}

    if(SBM_outputChannelList == nil) then
        SBM_outputChannelList = {}
    end
   
    if(SBM_whisperList == nil) then
        SBM_whisperList = {}
    end

    local defaultEventList = 
        {
            {name = "Spell Damage", eventType = "SPELL_DAMAGE", boolean = true},
            {name = "Ranged", eventType = "RANGE_DAMAGE",  boolean = false},
            {name = "Melee Autohit", eventType = "SWING_DAMAGE",  boolean = false},
            {name = "Heal", eventType = "SPELL_HEAL",  boolean = false},
        }

    --reset SBM_eventList in case defaultEventList was updated
    if(SBM_eventList == nil or not (# SBM_eventList == #defaultEventList)) then 
        SBM_eventList = defaultEventList
    end
      
    if(SBM_critList == nil) then
        SBM_critList = {}
    end
    
    if(SBM_outputMessage == nil) then
        SBM_outputMessage = "BAM! SN SD!"
    end
    
    --Good Guide https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/InterfaceOptionsFrame.lua
    --Options Main Menu
    SvensBamAddonConfig = {};
    SvensBamAddonConfig.panel = CreateFrame( "Frame", "SvensBamAddonConfig", UIParent );    
    SvensBamAddonConfig.panel.name = "Svens Bam Addon";
    SvensBamAddonConfig.panel.title = SvensBamAddonConfig.panel:CreateFontString("GeneralOptionsDescription", "OVERLAY");
    SvensBamAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensBamAddonConfig.panel.title:SetJustifyH("LEFT")

        
    --Channel Options SubMenu
    SvensBamAddonChannelOptions = {}
    SvensBamAddonChannelOptions.panel = CreateFrame( "Frame", "SvensBamAddonChannelOptions");
    SvensBamAddonChannelOptions.panel.name = "Channel options";
    SvensBamAddonChannelOptions.panel.parent = "Svens Bam Addon"
    SvensBamAddonChannelOptions.panel.okay = function()
        saveWhisperList()
        saveOutputList()
    end
    populateChannelSubmenu(channelButtonList, channelList)
	
    --General Options SubMenu NEEDS TO BE LAST BECAUSE SLIDERS CHANGE FONTSTRINGS OF ALL MENUS
    SvensBamAddonGeneralOptions = {}
    SvensBamAddonGeneralOptions.panel = CreateFrame( "Frame", "SvensBamAddonGeneralOptions");
    SvensBamAddonGeneralOptions.panel.name = "General options";
    SvensBamAddonGeneralOptions.panel.parent = "Svens Bam Addon"
    populateGeneralSubmenu(eventButtonList, SBM_eventList, rgb)
	
	--Set order of Menus here
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
	InterfaceOptions_AddCategory(SvensBamAddonGeneralOptions.panel);
	InterfaceOptions_AddCategory(SvensBamAddonChannelOptions.panel);
	
    print(SBM_color.."Svens Bam Addon loaded!")
end

function populateGeneralSubmenu(eventButtonList, SBM_eventList, rgb)
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("OutputMessageDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    
    createOutputMessageEditBox()
    
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("EventTypeDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -5 - 64);
    
    for i=1, # SBM_eventList do
        createEventTypeCheckBoxes(i, 1, i, eventButtonList, SBM_eventList)
    end
	
	SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("FontColorDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -5 - 64 -(# SBM_eventList)*32);
	
	for i=1, 3 do
		createColorSlider(i, SvensBamAddonGeneralOptions.panel, rgb)
	end
end

function createEventTypeCheckBoxes(i, x, y, eventButtonList, SBM_eventList)
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_EventTypeCheckButton" .. i, SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    eventButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y*-24 -64)
    checkButton:SetSize(32, 32)
    
    _G[checkButton:GetName() .. "Text"]:SetText(SBM_eventList[i].name)
    _G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
    for j = 1, # SBM_eventList do
        if(SBM_eventList[i].boolean) then            
            eventButtonList[i]:SetChecked(true)
        end
    end

    eventButtonList[i]:SetScript("OnClick", function()   
        if eventButtonList[i]:GetChecked() then
            SBM_eventList[i].boolean = true
        else
            SBM_eventList[i].boolean = false
        end
    end)

end

function createOutputMessageEditBox()
    outputMessageEditBox = createEditBox("OutputMessage", SvensBamAddonGeneralOptions.panel)
    outputMessageEditBox:SetPoint("TOPLEFT", 40, -24)
    outputMessageEditBox:Insert(SBM_outputMessage)
    outputMessageEditBox:SetCursorPosition(0)   
    outputMessageEditBox:SetScript( "OnEscapePressed", function(...)
        outputMessageEditBox:ClearFocus()
        outputMessageEditBox:SetText(SBM_outputMessage)
        end)
    outputMessageEditBox:SetScript( "OnEnterPressed", function(...)
        outputMessageEditBox:ClearFocus()
        saveOutputList()
    end)
    outputMessageEditBox:SetScript( "OnEnter", function(...)            
        GameTooltip:SetOwner(outputMessageEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText( "Insert your damage message here.\nSN will be replaced with spell name.\nSD with spell damage.\nDefault: BAM! SN SD!" )
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    outputMessageEditBox:SetScript( "OnLeave", function()
        GameTooltip:Hide()
    end)
end

function populateChannelSubmenu(channelButtonList, channelList)
    SvensBamAddonChannelOptions.panel.title = SvensBamAddonChannelOptions.panel:CreateFontString("OutputChannelDescription", "OVERLAY");
    SvensBamAddonChannelOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonChannelOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
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
    for j = 1, # SBM_outputChannelList do
        if(SBM_outputChannelList[j] == channelList[i]) then            
            channelButtonList[i]:SetChecked(true)
        end
    end
    
    channelButtonList[i]:SetScript("OnClick", function()   
        if channelButtonList[i]:GetChecked() then
            table.insert(SBM_outputChannelList, channelList[i])         
        else
            indexOfFoundValues = {}
            for j = 1, # SBM_outputChannelList do
                if(SBM_outputChannelList[j] == channelList[i]) then
                    table.insert(indexOfFoundValues, j)
                end
            end
            j = # indexOfFoundValues
            while (j>0) do   
                table.remove(SBM_outputChannelList, indexOfFoundValues[j])
                j = j-1;
            end
        end
    end)
    
    -- Create Edit Box for whispers
    if(channelList[i] == "Whisper") then
        whisperFrame = createEditBox("WhisperList", SvensBamAddonChannelOptions.panel)
        whisperFrame:SetPoint("TOP",50, -24*y)
        for _, v in pairs(SBM_whisperList) do
            whisperFrame:Insert(v.." ")
        end
        whisperFrame:SetCursorPosition(0)
        
        whisperFrame:SetScript( "OnEscapePressed", function(...)
            whisperFrame:ClearFocus()
            whisperFrame:SetText("")
            for _, v in pairs(SBM_whisperList) do
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
            SBM_outputChannelList = {}
    end)
end

function createColorSlider(i, panel, rgb)
	local slider = CreateFrame("Slider", "SBM_Slider"..i, panel, "OptionsSliderTemplate")
	slider:ClearAllPoints()
	slider:SetPoint("TOPLEFT", 32, -240-16*2*(i-1))
	slider:SetSize(256,16)
	slider:SetMinMaxValues(0, 255)
	slider:SetValueStep(1)
	_G[slider:GetName() .. "Low"]:SetText("|c00ffcc00Min:|r 0")
	_G[slider:GetName() .. "High"]:SetText("|c00ffcc00Max:|r 255")
	slider:SetScript("OnValueChanged", function(self, event, arg1)
		local value = floor(slider:GetValue())
		_G[slider:GetName() .. "Text"]:SetText("|c00ffcc00"..rgb[i].color.."|r "..value)
		_G[slider:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
		rgb[i].value = convertRGBDecimalToRGBHex(value)
		SBM_color = "|cff"..rgb[1].value..rgb[2].value..rgb[3].value
		setPanelTexts()
	end)
	slider:SetValue(tonumber("0x"..rgb[i].value))
	
end

function saveWhisperList()
    SBM_whisperList = {}
    for arg in string.gmatch(whisperFrame:GetText(), "%S+") do
        table.insert(SBM_whisperList, arg)
    end
end

function saveOutputList()
    SBM_outputMessage = outputMessageEditBox:GetText()
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

function convertRGBDecimalToRGBHex(decimal)
	local result
	local numbers = "0123456789ABCDEF"
	result = numbers:sub(1+(decimal/16), 1+(decimal/16))..numbers:sub(1+(decimal%16), 1+(decimal%16))
	return result
end

function setPanelTexts()
	GeneralOptionsDescription:SetText(SBM_color.."Choose sub menu to change options.\n\n\nCommand line options:\n\n"
            .."/bam list: lists highest crits of each spell.\n/bam clear: delete list of highest crits.\n/bam config: Opens this config page.")
	OutputMessageDescription:SetText(SBM_color.."Output Message")
	    EventTypeDescription:SetText(SBM_color.."Event Types to Trigger")
	SvensBamAddonGeneralOptions.panel.title:SetText(SBM_color.."Change color of Font")
	FontColorDescription:SetText(SBM_color.."Change color of Font")
	OutputChannelDescription:SetText(SBM_color.."Output Channel")
end