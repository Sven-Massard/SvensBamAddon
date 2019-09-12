
function BAM_OnLoad(self)
    print("Svens Bam Addon geladen");
    SlashCmdList["BAM"] = bam_listHighestCrits
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
		outputMessage = "BAM! "..eventInfo[13].." "..eventInfo[15].." Damage";
		PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
		SendChatMessage(outputMessage ,"YELL" );
		
	end
end
 
function bam_listHighestCrits(cmd)
    if(cmd == "help") then
        print("Possible commands:");
        print("listCrits -- lists highest crits of each spell");
    end
    if(cmd == "listCrits") then
        
    end
end

frame:SetScript("OnEvent", eventHandler);