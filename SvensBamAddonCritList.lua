function addToCritList(spellName, val)

    if(SBM_critList.spellName==nil and SBM_critList.value==nil) then
        SBM_critList = newNode(spellName, val)
        
    else
        local it = SBM_critList
        if(it.spellName==spellName) then -- Maybe later refactor to avoid duplicate code
            if(it.value<val) then
                it.value=val
            end
            do return end
        end
        
        while not (it.nextNode == nil) do
            it = it.nextNode
            if(it.spellName==spellName) then
                if(it.value<val) then
                    it.value=val
                end
                do return end
            end         
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
    SBM_critList = {};
    print(SBM_color.."Critlist cleared");
end


function listCrits()
    if not (SBM_critList.value == nil) then
        print(SBM_color.."Highest crits:");
        local it = SBM_critList
        print(SBM_color..it.spellName..": "..it.value)
        while not (it.nextNode == nil) do
            it = it.nextNode
            print(SBM_color..it.spellName..": "..it.value)
        end
    else
        print(SBM_color.."No crits recorded");
    end
end