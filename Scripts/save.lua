local Save = {
    ap_notebook = nil,
    received_items = 0,
    sold_garbage_bags = 0,
    checked_location_names = {},
    skip_claimed = {},
    pending_fuse_blowouts = 0,
    daily_tasks_done = 0,
    sold_signals = {0, 0, 0, 0},
    servers_repaired = 0,
    transformers_repaired = 0,
    fuses_replaced = 0
}

function Save:GetAPNotebook()
    if self.ap_notebook == nil then
        self.ap_notebook = self:FindAPNotebook()
        if self.ap_notebook then return self.ap_notebook end
        print("Creating new AP notebook")

        local out = {}
        GetGameMode():spawnPropThroughGamemode(
            FName("clipboard"),
            -- On the black cube underneath Alpha Base
            { ["Translation"] = { X = -415, Y = -1560, Z = -3346 }, ["Scale3D"] = { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 } },
            1,
            out
        )
        self.ap_notebook = out["actor "]
        self.ap_notebook.Key = FName("__AP_NOTEBOOK__")
        self:SaveDataToNotebook()
        self.ap_notebook:upd()
    elseif not self.ap_notebook:IsValid() then
        return nil  -- We had a notebook but we lost it: wait for it
    end
    return self.ap_notebook
end

function Save:FindAPNotebook()
    local notebooks = FindAllOf("prop_notebook_C") or {}
    for _, notebook in ipairs(notebooks) do
        if notebook.Key:ToString() == "__AP_NOTEBOOK__" then
            print("Found AP notebook")
            return notebook
        end
    end
    return nil
end

function Save:LoadNotebookData()
    local ap_notebook = self:FindAPNotebook()
    if ap_notebook and ap_notebook:IsValid() then
        local tokens = {}
        local text = ap_notebook.Text[1]:ToString() or ""
        for token in string.gmatch(text, "[^,]*") do
            table.insert(tokens, token)
        end
        if #tokens >= 3 and #tokens[1] > 0 and #tokens[2] > 0 then
            ConnectToAP(tokens[1], tokens[2], tokens[3])
        else
            AddHint("An AP save was detected but the connection info seems to be invalid. Please reconnect manually", HintType.Warning)
        end

        received_items = tonumber(ap_notebook.Text[2]:ToString()) or 0
        sold_garbage_bags = tonumber(ap_notebook.Text[3]:ToString()) or 0
        checked_location_names = {}
        for name in string.gmatch(ap_notebook.Text[4]:ToString() or "", "[^,]+") do
            table.insert(checked_location_names, name)
        end
        skip_claimed = {}
        for name in string.gmatch(ap_notebook.Text[5]:ToString() or "", "[^,]+") do
            table.insert(skip_claimed, name)
        end
        pending_fuse_blowouts = tonumber(ap_notebook.Text[6]:ToString()) or 0
        daily_tasks_done = tonumber(ap_notebook.Text[7]:ToString()) or 0
        sold_signals = {}
        for val in string.gmatch(ap_notebook.Text[8]:ToString() or "", "[^,]+") do
            table.insert(sold_signals, tonumber(val))
        end
        servers_repaired = tonumber(ap_notebook.Text[9]:ToString()) or 0
        transformers_repaired = tonumber(ap_notebook.Text[10]:ToString()) or 0
        fuses_replaced = tonumber(ap_notebook.Text[11]:ToString()) or 0
    end
end

function Save:SaveDataToNotebook()
    local ap_notebook = self:GetAPNotebook()
    if ap_notebook and ap_notebook:IsValid() then
        ap_notebook.Text[1] = FString(server .. "," .. slot .. "," .. password)
        ap_notebook.Text[2] = FString(tostring(received_items))
        ap_notebook.Text[3] = FString(tostring(sold_garbage_bags))
        ap_notebook.Text[4] = FString(table.concat(checked_location_names, ","))
        ap_notebook.Text[5] = FString(table.concat(skip_claimed, ","))
        ap_notebook.Text[6] = FString(tostring(pending_fuse_blowouts))
        ap_notebook.Text[7] = FString(tostring(daily_tasks_done))
        ap_notebook.Text[8] = FString(table.concat(sold_signals, ","))
        ap_notebook.Text[9] = FString(tostring(servers_repaired))
        ap_notebook.Text[10] = FString(tostring(transformers_repaired))
        ap_notebook.Text[11] = FString(tostring(fuses_replaced))
        ap_notebook:upd()
    else
        AddHint("AP save failed. Retrying", HintType.Warning)
        ExecuteWithDelay(function() self:SaveDataToNotebook() end, 1000)
    end
end

function Save:GetRecievedItems()
    return received_items
end

function Save:SetRecievedItems(val)
    received_items = val
    print("SAVE RECEIVED ITEMS IS NOW " .. tostring(received_items))
    self:SaveDataToNotebook()
    return true
end

function Save:GetSoldGarbageBags()
    return sold_garbage_bags
end

function Save:SetSoldGarbageBags(val)
    sold_garbage_bags = val
    print("SAVE SOLD TRASH BAGS IS NOW " .. tostring(sold_garbage_bags))
    self:SaveDataToNotebook()
    return true
end

function Save:GetCheckedLocationNames()
    return checked_location_names
end

function Save:AddCheckedLocationName(val)
    table.insert(checked_location_names, val)
    print("SAVE CHECKED LOCATIONS IS NOW " .. table.concat(checked_location_names, ","))
    self:SaveDataToNotebook()
    return true
end

function Save:WasSkipClaimed(val)
    return array_contains(skip_claimed, val)
end

function Save:AddSkipClaimedItem(val)
    table.insert(skip_claimed, val)
    print("SAVE AUTO CLAIMED IS NOW " .. table.concat(skip_claimed, ","))
    self:SaveDataToNotebook()
    return true
end

function Save:ShiftSkipClaimed()
    table.remove(skip_claimed, 1)
    print("SAVE AUTO CLAIMED IS NOW " .. table.concat(skip_claimed, ","))
    self:SaveDataToNotebook()
    return true
end

function Save:GetPendingFuseBlowouts()
    return pending_fuse_blowouts
end

function Save:SetPendingFuseBlowouts(val)
    pending_fuse_blowouts = val
    print("SAVE PENDING BLOWOUTS IS NOW " .. tostring(pending_fuse_blowouts))
    self:SaveDataToNotebook()
    return true
end

function Save:GetDailyTasksDone()
    return daily_tasks_done
end

function Save:SetDailyTasksDone(val)
    daily_tasks_done = val
    print("SAVE DAILY TASKS DONE IS NOW " .. tostring(daily_tasks_done))
    self:SaveDataToNotebook()
    return true
end

function Save:GetSoldSignals(level)
    return sold_signals[level + 1]
end

function Save:SetSoldSignals(level, val)
    sold_signals[level + 1] = val
    print("SAVE SOLD SIGNALS DONE IS NOW " .. table.concat(sold_signals, ","))
    self:SaveDataToNotebook()
    return true
end

function Save:GetAllSoldSignals()
    return sold_signals
end

function Save:SetAllSoldSignals(val)
    sold_signals = val
    print("SAVE SOLD SIGNALS DONE IS NOW " .. table.concat(sold_signals, ","))
    self:SaveDataToNotebook()
    return true
end

function Save:GetServersRepaired()
    return servers_repaired
end

function Save:SetServersRepaired(val)
    servers_repaired = val
    print("SAVE SERVERS REPAIRED DONE IS NOW " .. tostring(servers_repaired))
    self:SaveDataToNotebook()
    return true
end

function Save:GetTransformersRepaired()
    return transformers_repaired
end

function Save:SetTransformersRepaired(val)
    transformers_repaired = val
    print("SAVE TRANSFORMERS REPAIRED DONE IS NOW " .. tostring(transformers_repaired))
    self:SaveDataToNotebook()
    return true
end

function Save:GetFusesReplaced()
    return fuses_replaced
end

function Save:SetFusesReplaced(val)
    fuses_replaced = val
    print("SAVE FUSES REPLACED DONE IS NOW " .. tostring(fuses_replaced))
    self:SaveDataToNotebook()
    return true
end

return Save
