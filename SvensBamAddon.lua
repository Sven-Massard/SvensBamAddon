local frame = CreateFrame("FRAME", "FooAddonFrame");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

function eventHandler(self, event, ...)
	name, realm = UnitName("player");
	eventInfo = {CombatLogGetCurrentEventInfo()}
	if not (eventInfo[5] == name) then
		do return end
	end
	if (eventInfo[2] == "SPELL_DAMAGE" and eventInfo[21] == true) then
		outputMessage = "BAM! "..eventInfo[13].." "..eventInfo[15].." Damage";
		PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
		SendChatMessage(outputMessage ,"YELL" );
		
	end
end
 


frame:SetScript("OnEvent", eventHandler);