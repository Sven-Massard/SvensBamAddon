function BAM_OnLoad(self)
    SlashCmdList["BAM"] = function(cmd)
        local params = {}
        local i = 1
        for arg in string.gmatch(cmd, "%S+") do
            params[i] = arg
            i = i + 1
        end
        bam_cmd(params)
    end
    SLASH_BAM1 = '/bam'
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function eventHandler(self, event, arg1)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        combatLogEvent(self, event, arg1)
    elseif event == "ADDON_LOADED" and arg1 == "SvensBamAddon" then
        loadAddon() -- in SvensBamAddonConfig.lua
    end
end

function combatLogEvent(self, event, ...)
	name, realm = UnitName("player");
    eventType,_ ,_ , eventSource = select(2, CombatLogGetCurrentEventInfo())
	if not (eventSource == name) then
		do return end
	end
    --Assign correct values to variables
    if(eventType == "SPELL_DAMAGE") then
        spellName, _, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(13, CombatLogGetCurrentEventInfo())
    elseif(eventType == "SPELL_HEAL") then
        spellName, _, amount, overheal, school, critical = select(13, CombatLogGetCurrentEventInfo())
    elseif (eventType == "RANGE_DAMAGE") then
        spellName, _, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(13, CombatLogGetCurrentEventInfo())
    elseif (eventType == "SWING_DAMAGE") then
        spellName = "Autohit"
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
    end
    
    for i=1, # eventList do
        if (eventType == eventList[i].eventType and eventList[i].boolean and critical == true) then
            local output = outputMessage:gsub("(SN)", spellName):gsub("(SD)", amount)
            PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
            for _, v in pairs(outputChannelList) do
                if v == "Print" then
                    print(output)
                elseif (v == "Whisper") then
                    for _, w in pairs(whisperList) do
                        SendChatMessage(output, "WHISPER", "COMMON", w)
                    end
                else
                    SendChatMessage(output ,v );
                end
            end
            addToCritList(spellName, amount);
        end
    end
end
 
function bam_cmd(params)
    cmd = params[1]
    local firstVariable=2
    if(cmd == "help" or cmd == "") then
        print("Possible parameters:")
        print("list: lists highest crits of each spell")
        print("clear: delete list of highest crits")
		print("config: Opens config page")
    elseif(cmd == "list") then
        listCrits();
    elseif(cmd == "clear") then
        clear();   
    elseif(cmd == "config") then
		-- For some reason, needs to be called twice to function correctly on first call
		InterfaceOptionsFrame_OpenToCategory(SvensBamAddonGeneralOptions.panel)
		InterfaceOptionsFrame_OpenToCategory(SvensBamAddonGeneralOptions.panel)
	elseif(cmd == "test") then
        for i = 1, # outputChannelList do
            print(outputChannelList[i])
        end
    else
        print("Bam Error: Unknown command")
    end   
end
