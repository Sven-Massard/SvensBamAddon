local buttonList = {}

outputChannelList = {}

function BAM_Config_OnLoad(self)
    
    SvensBamAddonConfig = {};
    SvensBamAddonConfig.panel = CreateFrame( "Frame", "SvensBamAddonConfig", UIParent );
    -- Register in the Interface Addon Options GUI
    -- Set the name for the Category for the Options Panel
    SvensBamAddonConfig.panel.name = "Svens Bam Addon";
    -- Add the panel to the Interface Options
    InterfaceOptions_AddCategory(SvensBamAddonConfig.panel);
    
    local ChannelMessage = CreateFrame("CheckButton", "SvensBamAddon_CheckButton", SvensBamAddonConfig.panel, "UICheckButtonTemplate")
    for i=1,12 do -- Checkboxes Channel
        createCheckButtonChannel(i, 1, i)
    end
end

--- Copied from RightClickModifier.lua and modified to needs



function createCheckButtonChannel(i, x, y)
	local list = 
	{
		"Say",
		"Yell",
		"Guild",
		"Raid",
        "Emote",
        "Party",
        "Officer",
        "Raid Warning",
        "Instanz chat",
        "Battleground",
        "Whisper",
        "Channel"
    }
	local checkButton = CreateFrame("CheckButton", "SvensBamAddon_CheckButton" .. i, SvensBamAddonConfig.panel, "UICheckButtonTemplate")
	buttonList[i] = checkButton
    
	checkButton:ClearAllPoints()
	checkButton:SetPoint("TOPLEFT", x * 32, y * -24)
	checkButton:SetSize(32, 32)
    
	_G[checkButton:GetName() .. "Text"]:SetText(list[i])
	_G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
	buttonList[i]:SetScript("OnClick", function()
    
		if buttonList[i]:GetChecked() then
            print("Adding "..list[i].." to channel list")
			table.insert(outputChannelList, list[i])
            
		else
			for j = 1, # outputChannelList do
                if(outputChannelList[j] == list[i]) then
                    print("Removing "..outputChannelList[j].." from channel list")
                    table.remove(outputChannelList, j)
		            
                end
            end
		end
	end)
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