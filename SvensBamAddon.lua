-- Variables

critList = {}
outputPrepend = "BAM! "
outputChannels = {"YELL"}

function BAM_OnLoad(self)
    print("Svens Bam Addon geladen");
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
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function eventHandler(self, event, ...)
	name, realm = UnitName("player");
	eventInfo = {CombatLogGetCurrentEventInfo()}
	if not (eventInfo[5] == name) then
		do return end
	end
    -- eventInfo[21] = crit
	if (eventInfo[2] == "SPELL_DAMAGE" and eventInfo[21] == true) then 
        local spellName = eventInfo[13];
        local value = eventInfo[15];
        local outputMessage = (outputPrepend..spellName.." "..value.." Damage")
		PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
        for _, v in pairs(outputChannels) do
		    SendChatMessage(outputMessage ,v );
        end
        addToCritList(spellName, value);
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
        print("channel listOfChannels: e.g. '/bam channel YELL GUILD SAY'. Channels with numbers not yet supported.")   
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
    elseif(cmd == "channel") then
        outputChannels = {}
        while(params[firstVariable]) do
                table.insert(outputChannels, params[firstVariable])
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
