-- Variables

local critList = {};
local i = 1
function BAM_OnLoad(self)
    print("Svens Bam Addon geladen");
    SlashCmdList["BAM"] = bam_cmd
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
        spellName = eventInfo[13];
		outputMessage = "BAM! "..spellName.." "..eventInfo[15].." Damage";
		PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
		SendChatMessage(outputMessage ,"YELL" );
        addElementToCritList(spellName);
	end
end
 
function bam_cmd(cmd)
    if(cmd == "help" or cmd == "") then
        print("Possible parameters:");
        print("listCrits -- lists highest crits of each spell");
    
    elseif(cmd == "list") then
        list();
        
    elseif(cmd == "clear") then
        clear();
        
    elseif(cmd == "test") then
        addToCritList(i);
        print("Added "..i)
        i = i+1;
        
    end
    
end

function list()
    if not (critList.value == nil) then
        print("Highest crits:");
        local it = critList
        print(it.value)
        while not (it.nextNode == nil) do
            it = it.nextNode
            print(it.value)
        end
    else
        print("Not crits recorded");
    end
end

function addToCritList(val)

    if(critList.value == nil) then
        critList.value = val
        critList.nextNode = nil
        
    else
        local it = critList
        while not (it.nextNode == nil) do
            it = it.nextNode
        end
        it.nextNode = newNode(val)
        
    end
    
end

function newNode(val)
    local newNode = {};
    newNode.value = val
    newNode.nextNode = nil
    return newNode
end

function clear() --TODO
    critList = {};
    print("Critlist cleared");
end