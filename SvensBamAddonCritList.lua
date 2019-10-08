function SBM:addToCritList(spellName, val)
    -- list was empty until now
    if(SBM_critList.spellName==nil and SBM_critList.value==nil) then
        SBM_critList = SBM:newNode(spellName, val)
        return true
        
    else
        local it = SBM_critList
        --compare with first value
        if(it.spellName==spellName) then -- Maybe later refactor to avoid duplicate code
            if(it.value<val) then
                it.value=val
                return true
            end
            do return end
        end
        
        --compare with subsequent values
        while not (it.nextNode == nil) do
            it = it.nextNode
            if(it.spellName==spellName) then
                if(it.value<val) then
                    it.value=val
                    return true
                end
                do return end
            end         
        end
        
        --add spell if not found till now
        it.nextNode = newNode(spellName, val)
        return true
    end
    
end

function SBM:newNode(spellName, val)
    local newNode = {};
    newNode.spellName = spellName
    newNode.value = val
    newNode.nextNode = nil
    return newNode
end

function SBM:clearCritList()
    SBM_critList = {};
    print(SBM_color.."Critlist cleared");
end


function SBM:listCrits()
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