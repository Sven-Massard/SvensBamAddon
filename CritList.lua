function addToCritList(spellName, val)

    if(critList.spellName==nil and critList.value==nil) then
        critList = newNode(spellName, val)
        
    else
        local it = critList
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
    critList = {};
    print("Critlist cleared");
end


function listCrits()
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