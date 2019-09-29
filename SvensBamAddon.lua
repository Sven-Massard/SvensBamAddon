-- Variables

critList = {}
outputPrepend = "BAM! "

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
        loadAddon()
    end
end

function combatLogEvent(self, event, ...)
	name, realm = UnitName("player");
    eventType,_ ,_ , eventSource = select(2, CombatLogGetCurrentEventInfo())
	if not (eventSource == name) then
		do return end
	end
    spellName, _, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(13, CombatLogGetCurrentEventInfo())
	if (eventType == "SPELL_DAMAGE" and critical == true) then 
        local outputMessage = (outputPrepend..spellName.." "..amount.." Damage")
		PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
        for _, v in pairs(outputChannelList) do
            if v == "Print" then
                print(outputMessage)
            elseif (v == "Whisper") then
                for _, w in pairs(_G["whisperList"]) do
                    SendChatMessage(outputMessage, "WHISPER", "COMMON", w)
                end
		    else
                SendChatMessage(outputMessage ,v );
            end
        end
        addToCritList(spellName, amount);
	end
end
 
function bam_cmd(params)
    cmd = params[1]
    local firstVariable=2
    if(cmd == "help" or cmd == "") then
        print("Possible parameters:")
        print("list: lists highest crits of each spell")
        print("clear: delete list of highest crits")
        print("output msg: sets beginning of message to msg. Default: 'BAM!'")
    elseif(cmd == "list") then
        list();
    elseif(cmd == "clear") then
        clear();   
    elseif(cmd == "output") then
        outputPrepend = ""
        while(params[firstVariable]) do 
            outputPrepend = outputPrepend..params[firstVariable].." "
            firstVariable = firstVariable + 1
        end
    elseif(cmd == "test") then
        addToCritList("Mindblast", 100);
        addToCritList("Smite", 105);
        addToCritList("Smite", 100);
        local list = {}
        table.insert(list, "a")
        table.insert(list, "b")
        table.insert(list, "d")
        for _, v in pairs(list) do
            print(v)
        end       
    else
        print("Bam Error: Unknown command")
    end   
end
