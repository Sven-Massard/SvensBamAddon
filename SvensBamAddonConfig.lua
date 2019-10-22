
function SBM:loadAddon()
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
			"Sound"
        }
    
    if(SBM_onlyOnNewMaxCrits == nil) then
        SBM_onlyOnNewMaxCrits = false
    end
    
    if(SBM_color == nil) then
		SBM_color = "|cff".."94".."CF".."00"
    end
    
    if(SBM_threshold == nil) then
        SBM_threshold = 0
    end
	
	if(SBM_soundfile == nil) then
		SBM_soundfile = "Interface\\AddOns\\SvensBamAddon\\bam.ogg"
	end
	
	local rgb =
		{
			{color = "Red",   value = SBM_color:sub(5, 6)},
			{color = "Green", value= SBM_color:sub(7, 8)},
			{color = "Blue",  value= SBM_color:sub(9, 10)}
		}

    if(SBM_outputChannelList == nil) then
        SBM_outputChannelList = {"Print", "Sound"}
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
        SBM:saveWhisperList()
		SBM:saveSoundfile()
    end
    SBM:populateChannelSubmenu(channelButtonList, channelList)
	
    --General Options SubMenu NEEDS TO BE LAST BECAUSE SLIDERS CHANGE FONTSTRINGS OF ALL MENUS
    SvensBamAddonGeneralOptions = {}
    SvensBamAddonGeneralOptions.panel = CreateFrame( "Frame", "SvensBamAddonGeneralOptions");
    SvensBamAddonGeneralOptions.panel.name = "General options";
    SvensBamAddonGeneralOptions.panel.parent = "Svens Bam Addon"
    SvensBamAddonGeneralOptions.panel.okay = function()
        SBM:saveOutputList()
        SBM:saveThreshold()
    end
    SBM:populateGeneralSubmenu(eventButtonList, SBM_eventList, rgb)
	
	--Set order of Menus here
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
	InterfaceOptions_AddCategory(SvensBamAddonGeneralOptions.panel);
	InterfaceOptions_AddCategory(SvensBamAddonChannelOptions.panel);
	
    print(SBM_color.."Svens Bam Addon loaded!")
end

function SBM:populateGeneralSubmenu(eventButtonList, SBM_eventList, rgb)

	local lineHeight = 16
	local boxHeight = 32
	local boxSpacing = 24 -- Even though a box is 32 high, it somehow takes only 24 of space
	local editBoxWidth = 400
	local categoriePadding = 16
	local baseYOffSet = 5
	
	local categorieNumber = 0 -- increase after each categorie
	local amountLinesWritten = 0 -- increase after each Font String
	local boxesPlaced = 0 -- increase after each edit box or check box placed
	
	-- Output Messages
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("OutputMessageDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing));
	amountLinesWritten = amountLinesWritten + 1
	
    SBM:createOutputDamageMessageEditBox(boxHeight, editBoxWidth, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing))
	boxesPlaced = boxesPlaced +1
	categorieNumber = categorieNumber + 1
	
	-- Damage Threshhold
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("ThresholdDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5,-(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing));
    amountLinesWritten = amountLinesWritten + 1
	
    SBM:createThresholdEditBox(-(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing))
	boxesPlaced = boxesPlaced +1
    categorieNumber = categorieNumber + 1
	
	-- Event Types to Trigger
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("EventTypeDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing));
    amountLinesWritten = amountLinesWritten + 1
	
    for i=1, # SBM_eventList do
        SBM:createEventTypeCheckBoxes(i, 1, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing), eventButtonList, SBM_eventList)
		boxesPlaced = boxesPlaced +1
    end
	categorieNumber = categorieNumber + 1
	
	-- Trigger Options
    SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("OnlyOnMaxCritsDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing));
    amountLinesWritten = amountLinesWritten + 1
	
	SBM:createTriggerOnlyOnCritRecordCheckBox(1, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing))
	boxesPlaced = boxesPlaced +1
	categorieNumber = categorieNumber + 1
	
	-- Color changer 
    yOffSet = 3
	SvensBamAddonGeneralOptions.panel.title = SvensBamAddonGeneralOptions.panel:CreateFontString("FontColorDescription", "OVERLAY");
    SvensBamAddonGeneralOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonGeneralOptions.panel.title:SetPoint("TOPLEFT", 5, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing));
	amountLinesWritten = amountLinesWritten + 1
	amountLinesWritten = amountLinesWritten + 1 --Another Time, because the Sliders have on line above
	print(-(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing))
	for i=1, 3 do
		SBM:createColorSlider(i, SvensBamAddonGeneralOptions.panel, rgb, -(baseYOffSet + categorieNumber*categoriePadding + amountLinesWritten*lineHeight + boxesPlaced*boxSpacing))
	end
	categorieNumber = categorieNumber + 1
	
    
end

function SBM:createEventTypeCheckBoxes(i, x, y, eventButtonList, SBM_eventList)
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_EventTypeCheckButton" .. i, SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    eventButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
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

function SBM:createOutputDamageMessageEditBox(height, width, y)
    outputMessageEditBox = SBM:createEditBox("OutputMessage", SvensBamAddonGeneralOptions.panel, height, width)
    outputMessageEditBox:SetPoint("TOPLEFT", 40, y)
    outputMessageEditBox:Insert(SBM_outputMessage)
    outputMessageEditBox:SetCursorPosition(0)   
    outputMessageEditBox:SetScript( "OnEscapePressed", function(...)
        outputMessageEditBox:ClearFocus()
        outputMessageEditBox:SetText(SBM_outputMessage)
        end)
    outputMessageEditBox:SetScript( "OnEnterPressed", function(...)
        outputMessageEditBox:ClearFocus()
        SBM:saveOutputList()
    end)
    outputMessageEditBox:SetScript( "OnEnter", function(...)            
        GameTooltip:SetOwner(outputMessageEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText( "Insert your damage message here.\nSN will be replaced with spell name,\nSD with spell damage,\nTN with enemy name.\nDefault: BAM! SN SD!" )
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    outputMessageEditBox:SetScript( "OnLeave", function()
        GameTooltip:Hide()
    end)
end

function SBM:createThresholdEditBox(y)
    thresholdEditBox = SBM:createEditBox("ThresholdEditBox", SvensBamAddonGeneralOptions.panel, 32, 400)
    thresholdEditBox:SetPoint("TOPLEFT", 40, y)
    thresholdEditBox:Insert(SBM_threshold)
    thresholdEditBox:SetCursorPosition(0)   
    thresholdEditBox:SetScript( "OnEscapePressed", function(...)
        thresholdEditBox:ClearFocus()
        thresholdEditBox:SetText(SBM_threshold)
        end)
    thresholdEditBox:SetScript( "OnEnterPressed", function(...)
        thresholdEditBox:ClearFocus()
        SBM:saveThreshold()
    end)
    thresholdEditBox:SetScript( "OnEnter", function(...)            
        GameTooltip:SetOwner(thresholdEditBox, "ANCHOR_BOTTOM");
        GameTooltip:SetText( "Damage or heal must be at least this high to trigger bam!\nSet 0 to trigger on everything." )
        GameTooltip:ClearAllPoints()
        GameTooltip:Show()
    end)
    thresholdEditBox:SetScript( "OnLeave", function()
        GameTooltip:Hide()
    end)
end

function SBM:createTriggerOnlyOnCritRecordCheckBox(x, y)
    local checkButton = CreateFrame("CheckButton", "OnlyOnMaxCritCheckBox", SvensBamAddonGeneralOptions.panel, "UICheckButtonTemplate")
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, y)
    checkButton:SetSize(32, 32)
    OnlyOnMaxCritCheckBoxText:SetText("Only trigger on new crit record")
    OnlyOnMaxCritCheckBoxText:SetFont(GameFontNormal:GetFont(), 14, "NONE")
    
    if(SBM_onlyOnNewMaxCrits) then            
        OnlyOnMaxCritCheckBox:SetChecked(true)
    end

    OnlyOnMaxCritCheckBox:SetScript("OnClick", function()   
        if OnlyOnMaxCritCheckBox:GetChecked() then
            SBM_onlyOnNewMaxCrits = true
        else
            SBM_onlyOnNewMaxCrits = false
        end
    end)
end

function SBM:populateChannelSubmenu(channelButtonList, channelList)
    SvensBamAddonChannelOptions.panel.title = SvensBamAddonChannelOptions.panel:CreateFontString("OutputChannelDescription", "OVERLAY");
    SvensBamAddonChannelOptions.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensBamAddonChannelOptions.panel.title:SetPoint("TOPLEFT", 5, -5);
    -- Checkboxes channels and Edit Box for whispers
    for i=1, # channelList do
        SBM:createCheckButtonChannel(i, 1, i, channelButtonList, channelList)
    end
    SBM:createResetChannelListButton(SvensBamAddonChannelOptions.panel, channelList, channelButtonList)
end

function SBM:createCheckButtonChannel(i, x, y, channelButtonList, channelList)
	local YOffset = y*-24
    local checkButton = CreateFrame("CheckButton", "SvensBamAddon_ChannelCheckButton" .. i, SvensBamAddonChannelOptions.panel, "UICheckButtonTemplate")
    channelButtonList[i] = checkButton
    checkButton:ClearAllPoints()
    checkButton:SetPoint("TOPLEFT", x * 32, YOffset)
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
        whisperFrame = SBM:createEditBox("WhisperList", SvensBamAddonChannelOptions.panel, 32, 400)
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
            SBM:saveWhisperList()
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
	
	-- Create Edit Box for Soundfile and reset button
    if(channelList[i] == "Sound") then
		local soundfileFrameXOffset = 50
		local soundfileFrameHeight = 32
		local soundfileFrameWidth = 400
        soundfileFrame = SBM:createEditBox("Soundfile", SvensBamAddonChannelOptions.panel, soundfileFrameHeight, soundfileFrameWidth)
        soundfileFrame:SetPoint("TOP",soundfileFrameXOffset, YOffset)
        
        soundfileFrame:Insert(SBM_soundfile)
        
        soundfileFrame:SetCursorPosition(0)
        
        soundfileFrame:SetScript( "OnEscapePressed", function(...)
            soundfileFrame:ClearFocus()
            soundfileFrame:SetText("")
            soundfileFrame:Insert(SBM_soundfile)
        end)
        soundfileFrame:SetScript( "OnEnterPressed", function(...)
            soundfileFrame:ClearFocus()
            SBM:saveSoundfile()
        end)
        soundfileFrame:SetScript( "OnEnter", function(...)            
            GameTooltip:SetOwner(soundfileFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText("Specify sound file path, beginning from your WoW _classic_ folder.\nIf you copy a sound file to your World of Warcraft folder,\nyou have to restart the client before that file works!")
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        soundfileFrame:SetScript( "OnLeave", function()
            GameTooltip:Hide()
        end)
		local resetSoundfileButtonWidth = 56
		SBM:createResetSoundfileButton(SvensBamAddonChannelOptions.panel, resetSoundfileButtonWidth, soundfileFrameWidth/2 + soundfileFrameXOffset + resetSoundfileButtonWidth/2, YOffset, soundfileFrameHeight)
    end
end

--SBM:createResetChannelListButton(SvensBamAddonChannelOptions.panel, channelList, channelButtonList)
function SBM:createResetSoundfileButton(parentFrame, resetSoundfileButtonWidth, x, y, soundfileFrameHeight)
	local resetSoundfileButtonHeight = 24
	resetChannelListButton = CreateFrame("Button", "ResetSoundfile", parentFrame, "UIPanelButtonTemplate");
    resetChannelListButton:ClearAllPoints()
    resetChannelListButton:SetPoint("TOP", x, y -(soundfileFrameHeight-resetSoundfileButtonHeight)/2)
    resetChannelListButton:SetSize(resetSoundfileButtonWidth, resetSoundfileButtonHeight)
    resetChannelListButton:SetText("Reset")
    resetChannelListButton:SetScript( "OnClick", function(...)
            SBM_soundfile = "Interface\\AddOns\\SvensBamAddon\\bam.ogg"
			soundfileFrame:SetText(SBM_soundfile)
    end)
end

function SBM:createResetChannelListButton(parentFrame, channelList, channelButtonList)
    resetChannelListButton = CreateFrame("Button", "ResetButtonChannels", parentFrame, "UIPanelButtonTemplate");
    resetChannelListButton:ClearAllPoints()
    resetChannelListButton:SetPoint("TOPLEFT", 32, ((# channelList) + 1)*-24 -8)
    resetChannelListButtonText = "Clear Channel List (May fix bugs after updating)"
    resetChannelListButton:SetSize(resetChannelListButtonText:len()*7, 32)
    resetChannelListButton:SetText(resetChannelListButtonText)
    resetChannelListButton:SetScript( "OnClick", function(...)
        for i = 1, # channelButtonList do
            channelButtonList[i]:SetChecked(false)
        end
            SBM_outputChannelList = {}
    end)
end

function SBM:createColorSlider(i, panel, rgb, yOffSet)
	local slider = CreateFrame("Slider", "SBM_Slider"..i, panel, "OptionsSliderTemplate")
	slider:ClearAllPoints()
	print( -16*2*(i-1)+yOffSet)
	slider:SetPoint("TOPLEFT", 32, -16*2*(i-1)+yOffSet)
	slider:SetSize(256,16)
	slider:SetMinMaxValues(0, 255)
	slider:SetValueStep(1)
	_G[slider:GetName() .. "Low"]:SetText("|c00ffcc00Min:|r 0")
	_G[slider:GetName() .. "High"]:SetText("|c00ffcc00Max:|r 255")
	slider:SetScript("OnValueChanged", function(self, event, arg1)
		local value = floor(slider:GetValue())
		_G[slider:GetName() .. "Text"]:SetText("|c00ffcc00"..rgb[i].color.."|r "..value)
		_G[slider:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
		rgb[i].value = SBM:convertRGBDecimalToRGBHex(value)
		SBM_color = "|cff"..rgb[1].value..rgb[2].value..rgb[3].value
		SBM:setPanelTexts()
	end)
	slider:SetValue(tonumber("0x"..rgb[i].value))
	
end

function SBM:saveWhisperList()
    SBM_whisperList = {}
    for arg in string.gmatch(whisperFrame:GetText(), "%S+") do
        table.insert(SBM_whisperList, arg)
    end
end

function SBM:saveSoundfile()
	SBM_soundfile = soundfileFrame:GetText()
end
	
function SBM:saveOutputList()
    SBM_outputMessage = outputMessageEditBox:GetText()
end

function SBM:saveThreshold()
    SBM_threshold = thresholdEditBox:GetNumber()
end
    
function SBM:createEditBox(name, parentFrame, height, width)
    local eb = CreateFrame("EditBox", name, parentFrame, "InputBoxTemplate")
    eb:ClearAllPoints()
    eb:SetAutoFocus(false)
    eb:SetHeight(height)
    eb:SetWidth(width)
    eb:SetFontObject("ChatFontNormal")
    return eb
end

function SBM:convertRGBDecimalToRGBHex(decimal)
	local result
	local numbers = "0123456789ABCDEF"
	result = numbers:sub(1+(decimal/16), 1+(decimal/16))..numbers:sub(1+(decimal%16), 1+(decimal%16))
	return result
end

function SBM:setPanelTexts()
	GeneralOptionsDescription:SetText(SBM_color.."Choose sub menu to change options.\n\n\nCommand line options:\n\n"
            .."/bam list: lists highest crits of each spell.\n/bam clear: delete list of highest crits.\n/bam config: Opens this config page.")
	OutputMessageDescription:SetText(SBM_color.."Output Message")
	    EventTypeDescription:SetText(SBM_color.."Event Types to Trigger")
	SvensBamAddonGeneralOptions.panel.title:SetText(SBM_color.."Change color of Font")
	FontColorDescription:SetText(SBM_color.."Change color of Font")
	OutputChannelDescription:SetText(SBM_color.."Output Channel")
    ThresholdDescription:SetText(SBM_color.."Least amount of damage/heal to trigger bam:")
    OnlyOnMaxCritsDescription:SetText(SBM_color.."Trigger options:")
end