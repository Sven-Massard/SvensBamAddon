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
        local spellName = eventInfo[13];
        local value = eventInfo[15];
		local outputMessage = "BAM! "..spellName.." "..value.." Damage";
		PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
		SendChatMessage(outputMessage ,"YELL" );
        addToCritList(spellName, value);
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
        addToCritList("SpellName"..i, i);
        i = i+1;
        
    end
    
end

function list()
    if not (critList.value == nil) then
        print("Highest crits:");
        local it = critList
        print(it.spellName..": "..it.value)
        while not (it.nextNode == nil) do
            it = it.nextNode
            print(it.spellName..": "..it.value)
        end
    else
        print("Not crits recorded");
    end
end

function addToCritList(spellName, val)

    if(critList.spellName==nil and critList.value==nil) then
        critList.spellName = spellName
        critList.value = val
        critList.nextNode = nil
        
    else
        local it = critList
        if(it.spellName==spellName) then -- Maybe later refactor to avoid duplicate code
            if(it.value<val) then
                it.value=val
            end
            do return end
        end
        
        while not (it.nextNode == nil) do
            if(it.spellName==spellName) then
                if(it.value<val) then
                    it.value=val
                end
                do return end
            end
            it = it.nextNode
        end
        it.nextNode = newNode(spellName, val)
    end
    
end

function newNode(spellName, val)
    local newNode = {};
    newNode.spellName = spellName
    newNode.value = val
    newNode.nextNode = nil
    return newNode
end

function clear()
    critList = {};
    print("Critlist cleared");
end