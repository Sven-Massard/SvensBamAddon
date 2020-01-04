local _,ns = ...
SBM = ns

-- Function for event filter for CHAT_MSG_SYSTEM to suppress message of player on whisper list being offline when being whispered to
function SBM_suppressWhisperMessage(self, event, msg, author, ...)

	local textWithoutName = msg:gsub("%'%a+%'", "")
	
	if not (textWithoutName == "No player named  is currently playing.") then
		return false
	end
	
	local name = string.gmatch(msg, "%'%a+%'")

	-- gmatch returns iterator.
	for w in name do
		name = w
	end
	if not (name == nil) then	
		name = name:gsub("'", "")
	else
		return false
	end
	
	local nameInWhisperList = false
	for _, w in pairs(SBM_whisperList) do
		if(w == name) then
			nameInWhisperList = true
		end
	end
	return nameInWhisperList	

end

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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SBM_suppressWhisperMessage)
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
			local output
			if eventType == "SPELL_HEAL" then
				output = SBM_outputHealMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
			else
				output = SBM_outputDamageMessage:gsub("(SN)", spellName):gsub("(SD)", amount):gsub("TN", enemyName)
			end
            for _, v in pairs(SBM_outputChannelList) do
                if v == "Print" then
                    print(SBM_color..output)
                elseif (v == "Whisper") then
                    for _, w in pairs(SBM_whisperList) do
						SendChatMessage(output, "WHISPER", "COMMON", w)
                    end
				elseif (v == "Sound DMG") then
					if (eventType ~= "SPELL_HEAL") then
						SBM:playRandomSoundFromList(SBM_soundfileDamage)
					end
				elseif (v == "Sound Heal") then
					if (eventType == "SPELL_HEAL") then
						SBM:playRandomSoundFromList(SBM_soundfileHeal)
					end
				elseif (v == "Battleground") then
					inInstance, instanceType = IsInInstance()
					if(instanceType == "pvp") then
						SendChatMessage(output, "INSTANCE_CHAT" )
					end
				elseif (v == "Officer") then
					if (CanEditOfficerNote()) then
						SendChatMessage(output ,v )
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
		print(SBM_color.."report: report highest crits of each spell to channel list")
        print(SBM_color.."clear: delete list of highest crits")
		print(SBM_color.."config: Opens config page")
    elseif(cmd == "list") then
        SBM:listCrits();
	elseif(cmd == "report") then
        SBM:reportCrits();	
    elseif(cmd == "clear") then
        SBM:clearCritList();   
    elseif(cmd == "config") then
		-- For some reason, needs to be called twice to function correctly on first call
		InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
		InterfaceOptionsFrame_OpenToCategory(SvensBamAddonConfig.panel)
	elseif(cmd == "test") then
		print("Function not implemented")
    else
        print("Bam Error: Unknown command")
    end   
end

function SBM:playRandomSoundFromList(listOfFilesAsString)
	SBM_soundFileList = {}
    for arg in string.gmatch(listOfFilesAsString, "%S+") do
        table.insert(SBM_soundFileList, arg)
    end
	local randomIndex = random(1, #SBM_soundFileList)
	PlaySoundFile(SBM_soundFileList[randomIndex])
end
