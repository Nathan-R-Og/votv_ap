local AP_NOTEBOOK = nil
function GetAPNotebook()
    if AP_NOTEBOOK == nil or not AP_NOTEBOOK:IsValid() then
        AP_NOTEBOOK = FindAPNotebook()
        if AP_NOTEBOOK then return AP_NOTEBOOK end

        if not ap then return nil end
        print("Creating new AP notebook")

        local out = {}
        GetGameMode():spawnPropThroughGamemode(
            FName("clipboard"),
            -- On the black cube underneath Alpha Base
            { ["Translation"] = { X = -415, Y = -1560, Z = -3346 }, ["Scale3D"] = { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 } },
            1,
            out
        )
        AP_NOTEBOOK = out["actor "]
        AP_NOTEBOOK.Key = FName("__AP_NOTEBOOK__")
        AP_NOTEBOOK.Text[1] = FString(server .. "," .. slot .. "," .. password)
        AP_NOTEBOOK:upd()
    end
    return AP_NOTEBOOK
end

function FindAPNotebook()
    local notebooks = FindAllOf("prop_notebook_C") or {}
    for _, notebook in ipairs(notebooks) do
        if notebook.Key:ToString() == "__AP_NOTEBOOK__" then
            print("Found AP notebook")
            return notebook
        end
    end
    return nil
end

function GetRecievedItems()
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Getting received items")
        local receivedItems = tonumber(APNotebook.Text[2]:ToString()) or 0
        -- print("SAVE RECEIVED ITEMS IS " .. receivedItems)
        return receivedItems
    end
    return 0
end

function SetRecievedItems(val)
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Setting received items")
        APNotebook.Text[2] = FString(tostring(val))
        APNotebook:upd()
        print("SAVE RECEIVED ITEMS IS NOW " .. APNotebook.Text[2]:ToString())
        return true
    end
    return false
end

function GetSoldGarbageBags()
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Getting trash bags")
        local amount = tonumber(APNotebook.Text[3]:ToString()) or 0
        -- print("SAVE SOLD TRASH BAGS IS " .. tostring(amount))
        return amount
    end
    return 0
end

function SetSoldGarbageBags(val)
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Setting trash bags")
        APNotebook.Text[3] = FString(tostring(val))
        APNotebook:upd()
        print("SAVE SOLD TRASH BAGS IS NOW " .. APNotebook.Text[3]:ToString())
        return true
    end
    return false
end

function GetCheckedLocationNames()
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Getting location names")
        local codes = {}
        for name in string.gmatch(APNotebook.Text[4]:ToString() or "", "[^,]+") do
            table.insert(codes, name)
        end
        -- print("SAVE KEYNAME INDEX IS " .. #codes)
        return codes
    end
    return 0
end

function AddCheckedLocationName(val)
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Setting location names")
        local names = APNotebook.Text[4]:ToString()
        APNotebook.Text[4] = FString(#names > 0 and names .. "," .. val or val)
        APNotebook:upd()
        print("SAVE KEYNAME INDEX IS NOW " .. APNotebook.Text[4]:ToString())
        return true
    end
    return false
end

function WasSkipClaimed(val)
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Checking auto claimed items")
        for name in string.gmatch(APNotebook.Text[5]:ToString() or "", "[^,]+") do
            if name == val then
                return true
            end
        end
        return false
    end
    return false
end

function AddSkipClaimedItem(val)
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Setting auto claimed items")
        local names = APNotebook.Text[5]:ToString()
        APNotebook.Text[5] = FString(#names > 0 and names .. "," .. val or val)
        APNotebook:upd()
        print("SAVE AUTO CLAIMED IS NOW " .. APNotebook.Text[5]:ToString())
        return true
    end
    return false
end

function ShiftSkipClaimed()
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Shifting auto claimed items")
        local codes = {}
        for name in string.gmatch(APNotebook.Text[5]:ToString() or "", "[^,]+") do
            table.insert(codes, name)
        end
        table.remove(codes, 1)
        APNotebook.Text[5] = FString(table.concat(codes, ","))
        APNotebook:upd()
        print("SAVE AUTO CLAIMED IS NOW " .. APNotebook.Text[5]:ToString())
        return true
    end
    return false
end

function GetPendingFuseBlowouts()
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Getting pending blowouts")
        local amount = tonumber(APNotebook.Text[6]:ToString()) or 0
        -- print("SAVE PENDING BLOWOUTS IS " .. tostring(amount))
        return amount
    end
    return 1
end

function SetPendingFuseBlowouts(val)
    local APNotebook = GetAPNotebook()
    if APNotebook and APNotebook:IsValid() then
        -- print("Setting pending blowouts")
        APNotebook.Text[6] = FString(tostring(val))
        APNotebook:upd()
        print("SAVE PENDING BLOWOUTS IS NOW " .. APNotebook.Text[6]:ToString())
        return true
    end
    return false
end
