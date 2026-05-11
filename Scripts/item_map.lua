auto_map = {
    ["Progressive Processing Level"] =      { hint = HintType.Info, run = function() Upgrade("processLvl") end },
    ["Progressive Processing Speed"] =      { hint = HintType.Info, run = function() Upgrade("processSpeed") end },
    ["Progressive Download Speed"] =        { hint = HintType.Info, run = function() Upgrade("downloadSpd") end },
    ["Progressive Cursor Drift"] =          { hint = HintType.Info, run = function() Upgrade("coordDrift") end },
    ["Progressive Cursor Speed"] =          { hint = HintType.Info, run = function() Upgrade("coordMovementSpeed") end },
    ["Progressive Ping Speed"] =            { hint = HintType.Info, run = function() Upgrade("coordPingSpeed") end },
    ["Progressive Ping Cooldown"] =         { hint = HintType.Info, run = function() Upgrade("coordCooldown") end },
    ["Progressive Coordinate Speed"] =      { hint = HintType.Info, run = function() Upgrade("coordRadarSpeed") end },
    ["Progressive Radar History"] =         { hint = HintType.Info, run = function() Upgrade("radarHist") end },
    ["Progressive Radar Speed"] =           { hint = HintType.Info, run = function() Upgrade("radar") end },
    ["Progressive Breaker Time"] =          { hint = HintType.Info, run = function() Upgrade("compTime") end },
    ["Progressive Detector Quality"] =      { hint = HintType.Info, run = function() Upgrade("detecQual") end },
    ["Progressive Detector Strength"] =     { hint = HintType.Info, run = function() Upgrade("scanner") end },
    ["Progressive Detector Frequency"] =    { hint = HintType.Info, run = function() Upgrade("scannerFr") end },
    -- Unused
    ["Progressive Filter Size"] =           { hint = HintType.Info, run = function() Upgrade("downloadFiltSize") end },
    ["Progressive Server Stability"] =      { hint = HintType.Info, run = function() Upgrade("serverStability") end },
    ["Progressive Transformer Stability"] = { hint = HintType.Info, run = function() Upgrade("transformer") end },

    -- Handled by the received items to properly process the initial items received packet
    -- TODO: See if we could move it here, and then just replay it when you receive the initial packet?
    ["Plastic Scrap Recipe"] =              { hint = HintType.Thought, run = function() UnlockRecipe("Plastic Scrap Recipe") end, replay = true },
    ["Metal Scrap Recipe"] =                { hint = HintType.Thought, run = function() UnlockRecipe("Metal Scrap Recipe") end, replay = true },
    ["Electronic Scrap Recipe"] =           { hint = HintType.Thought, run = function() UnlockRecipe("Electronic Scrap Recipe") end, replay = true },
    ["Glass Scrap Recipe"] =                { hint = HintType.Thought, run = function() UnlockRecipe("Glass Scrap Recipe") end, replay = true },
    ["Rubber Scrap Recipe"] =               { hint = HintType.Thought, run = function() UnlockRecipe("Rubber Scrap Recipe") end, replay = true },
    ["Paper Scrap Recipe"] =                { hint = HintType.Thought, run = function() UnlockRecipe("Paper Scrap Recipe") end, replay = true },
    ["Wood Scrap Recipe"] =                 { hint = HintType.Thought, run = function() UnlockRecipe("Wood Scrap Recipe") end, replay = true },
    ["Rubble Recipe"] =                     { hint = HintType.Thought, run = function() UnlockRecipe("Rubble Recipe") end, replay = true },

    ["Day"] =                               { hint = HintType.Thought, run = function() have_days = have_days + 1 end, replay = true },

    ["Lifecrystal Signal"] = {
        hint = HintType.Thought,
        run = function()
            local SaveGameObject = GetSaveSlot()
            if SaveGameObject ~= nil then
                SaveGameObject.forceObjects[#SaveGameObject.forceObjects + 1] = FName("lifecrystal")
            end
        end
    },
    ["Bonus Points"] = {
        hint = HintType.Info,
        run = function()
            local Gamemode = GetGameMode()
            if Gamemode ~= nil then
                Gamemode:AddPoints(options.BonusPointsAmount)
            end
        end
    },

    ["Drunk Trap"] = {
        hint = HintType.Error,
        run = function()
            
        end
    },
}

complex_item_map = {
    ["Progressive Sleeping Bag"] = function()
        local i = 0
        for j=1,GetRecievedItems() do
            if GetAPItemNameFromId(item_list[j].item) == "Progressive Sleeping Bag" then
                i = i + 1
            end
        end

        if i == 0 then
            GiveItem("sleepingbag")
        elseif i == 1 then
            GiveItem("sleepingbag_br")
        elseif i == 2 then
            GiveItem("sleepingbag_st")
        else
            AddHint("You collected too many sleeping bags!", HintType.Error)
        end
    end,
    ["Progressive Camera"] = function()
        local i = 0
        for j=1,GetRecievedItems() do
            if GetAPItemNameFromId(item_list[j].item) == "Progressive Camera" then
                i = i + 1
            end
        end

        if i <= 2 then
            GiveItem("cam_h_" .. i)
        else
            AddHint("You collected too many cameras!", HintType.Error)
        end
    end,
    ["Bunker Keycard"] = function()
        GiveItem("keycard", function(item) item.Open = "ALPHA_HIDEOUT" end)
    end,
    ["Kerfur-Omega Complete Manual"] = function()
        local Pawn = GetPawn()
        local blueprint = SpawnSomething("/Game/objects/prop_blueprint_kerfurOmega.prop_blueprint_kerfurOmega_C")
        if Pawn:IsValid() and blueprint:IsValid() then
            Pawn:putObjectInventory2(blueprint, false, {})
        end
    end,
    ["Scuba Gear"] = function()
        GiveItem("scuba")
        GiveItem("scuba_t")
    end,
    ["Kerfur"] = function()
        SpawnSomething("/Game/objects/p_kerfus.p_kerfus_C")
    end,
    ["Blue Kerfur"] = function()
        SpawnSomething("/Game/objects/p_kerfus.p_kerfus_C")
    end,
    ["Red Kerfur"] = function()
        SpawnSomething("/Game/objects/p_kerfus_r.p_kerfus_r_C")
    end,
    ["Pink Kerfur"] = function()
        SpawnSomething("/Game/objects/p_kerfus_p.p_kerfus_p_C")
    end,
    ["Skull"] = function()
        -- The skull in the prop data is not a valid skull for the ritual
        local Pawn = GetPawn()
        local blueprint = SpawnSomething("/Game/objects/prop_sskull.prop_sskull_C")
        if Pawn:IsValid() and blueprint:IsValid() then
            Pawn:putObjectInventory2(blueprint, false, {})
        end
    end
}

item_map = {}
inverse_item_map = {}
function FillItemMap()
    item_map = {}
    inverse_item_map = {}
    local datatable = StaticFindObject("/Game/main/datatables/list_props.list_props")
    if datatable:IsValid() then
        print("Filling item map with " .. #datatable .. " items")
        local total = 0
        datatable:ForEachRow(function(k, v)
            local name = v.displayName_8_FE83ADBF40AA162942FCE589F5806DD2:ToString()

            -- Special cases
            if k == "axe" then name = "Axe" end
            if k == "Blueprint_1" then name = "Radioactive Capsule Blueprint" end
            if k == "animalhead_0" then name = "Deer Skull" end

            if name ~= "" then
                item_map[k] = name
                if inverse_item_map[string.lower(name)] == nil then
                    inverse_item_map[string.lower(name)] = k
                end
                total = total + 1
            end
        end)
        -- To make both Shrimps Pack and Shrimp Pack valid
        inverse_item_map["shrimp pack"] = "shrimp"
        total = total + 1
        for k,name in pairs(locationKeys) do
            if not inverse_item_map[string.lower(name)] then
                inverse_item_map[string.lower(name)] = k
                total = total + 1
            end
        end
        print("Filtered down to " .. total .. " items")
    end
end
