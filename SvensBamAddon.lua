local _,ns = ...
SBM = ns

function SBM:BAM_OnLoad(self)
    SlashCmdList["BAM"] = function(cmd)
        local params = {}
        local i = 1
        for arg in string.gmatch(cmd, "%S+") do
            params[i] = arg
            i = i + 1
        end
        SBM:bam_cmd(params)
    end
    SLASH_BAM1 = '/bam'
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function SBM:eventHandler(self, event, arg1)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        SBM:combatLogEvent(self, event, arg1)
    elseif event == "ADDON_LOADED" and arg1 == "SvensBamAddon" then
        SBM:loadAddon() -- in SvensBamAddonConfig.lua
    end
end

function SBM:combatLogEvent(self, event, ...)
	name, realm = UnitName("player");
    eventType,_ ,_ , eventSource,_,_,_,enemyName = select(2, CombatLogGetCurrentEventInfo())
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
    
    if (amount ~= nil and amount < SBM_threshold and SBM_threshold ~= 0) then
        do return end
    end
    for i=1, # SBM_eventList do
        if (eventType == SBM_eventList[i].eventType and SBM_eventList[i].boolean and critical == true) then
            newMaxCrit = SBM:addToCritList(spellName, amount);
            if(SBM_onlyOnNewMaxCrits and not newMaxCrit) then
                do return end
            end
            local output = SBM_outputMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
            for _, v in pairs(SBM_outputChannelList) do
                if v == "Print" then
                    print(SBM_color..output)
                elseif (v == "Whisper") then
                    for _, w in pairs(SBM_whisperList) do
                        SendChatMessage(output, "WHISPER", "COMMON", w)
                    end
				elseif (v == "Sound") then
					PlaySoundFile(SBM_soundfile)
				elseif (v == "Battleground") then
					inInstance, instanceType = IsInInstance()
					if(instanceType == "pvp") then
						SendChatMessage(output, "INSTANCE_CHAT" )
					end
                else
                    SendChatMessage(output ,v );
                end
            end
        end
    end
end
 
function SBM:bam_cmd(params)
    cmd = params[1]
    local firstVariable=2
    if(cmd == "help" or cmd == "") then
        print(SBM_color.."Possible parameters:")
        print(SBM_color.."list: lists highest crits of each spell")
        print(SBM_color.."clear: delete list of highest crits")
		print(SBM_color.."config: Opens config page")
    elseif(cmd == "list") then
        SBM:listCrits();
    elseif(cmd == "clear") then
        SBM:clearCritList();   
    elseif(cmd == "config") then
		-- For some reason, needs to be called twice to function correctly on first call
		InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
		InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
	elseif(cmd == "test") then
        for i = 1, # SBM_outputChannelList do
            print(SBM_color..SBM_outputChannelList[i])
        end
		PlaySoundFile(SBM_soundfile)
    else
        print("Bam Error: Unknown command")
    end   
end
