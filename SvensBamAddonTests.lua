local localAddon = SvensBamAddon

local function assertEquals(expected, actual, msg)
    if expected ~= actual then
        error(("Assertion failed for " .. msg .. ": expected " .. tostring(expected) ..
                ", got " .. tostring(actual)))
    end
end

function localAddon:runApiTests()
    print("Running tests")

    print("Need to test crit once manually")

    assertEquals("|cff71d5ff|Hspell:15431:0|h[Holy Nova]|h|r", C_Spell.GetSpellLink(15431), "Spell link broken")

    assert(type(UnitGUID("player")) == "string" and #UnitGUID("player") > 0, "Player GUID invalid")

    SendChatMessage("Bam Test Say", "Say");
    SendChatMessage("Bam Test Whisper", "WHISPER", select(2, GetDefaultLanguage()), UnitName("player"))
    _G["ChatFrame1"]:AddMessage(self.db.char.color .. "Bam Test Print with Color")

    local bnetTag = nil -- Enter valid bnet tag here
    if (bnetTag) then
        local battleNetTagToId = localAddon:mapBattleNetTagToId(bnetTag)
        BNSendWhisper(battleNetTagToId[bnetTag], "Bam Test BNet Whisper")
    else
        print("Need to put valid BNet Id in test for Bnet whisper test. Search for ENTER_TAG_TO_TEST_HERE in code")
    end

    local inInstance, instanceType = IsInInstance()
    assert(type(inInstance) == "boolean", "IsInInstance returned a non-boolean")
    assert(type(instanceType) == "string", "Instance type is not a string")

    assert(type(C_GuildInfo.CanEditOfficerNote()) == "boolean", "CanEditOfficerNote type is not a boolean")
    assert(type(IsInRaid()) == "boolean", "IsInRaid type is not a boolean")
    assert(type(IsInGroup()) == "boolean", "IsInGroup type is not a boolean")

    PlaySoundFile("Interface\\AddOns\\SvensBamAddon\\bam.ogg")
    DoEmote("train")

    assert(ERR_CHAT_PLAYER_NOT_FOUND_S, "ERR_CHAT_PLAYER_NOT_FOUND_S no longer exists")

    assert(type(GetChatWindowInfo(1)) == "string", "GetChatWindowInfo type is not a string")

    assert(type(NUM_CHAT_WINDOWS) == "number", "NUM_CHAT_WINDOWS type is not a number")

    print("All tests successful")
end