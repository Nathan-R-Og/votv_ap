auto_map = {
    ["Progressive Processing Level"] =      { hint = 0, run = function() Upgrade("processLvl") end },
    ["Progressive Processing Speed"] =      { hint = 0, run = function() Upgrade("processSpeed") end },
    ["Progressive Download Speed"] =        { hint = 0, run = function() Upgrade("downloadSpd") end },
    ["Progressive Cursor Drift"] =          { hint = 0, run = function() Upgrade("coordDrift") end },
    ["Progressive Cursor Speed"] =          { hint = 0, run = function() Upgrade("coordMovementSpeed") end },
    ["Progressive Ping Speed"] =            { hint = 0, run = function() Upgrade("coordPingSpeed") end },
    ["Progressive Ping Cooldown"] =         { hint = 0, run = function() Upgrade("coordCooldown") end },
    ["Progressive Coordinate Speed"] =      { hint = 0, run = function() Upgrade("coordRadarSpeed") end },
    ["Progressive Radar History"] =         { hint = 0, run = function() Upgrade("radarHist") end },
    ["Progressive Radar Speed"] =           { hint = 0, run = function() Upgrade("radar") end },
    ["Progressive Breaker Time"] =          { hint = 0, run = function() Upgrade("compTime") end },
    ["Progressive Detector Quality"] =      { hint = 0, run = function() Upgrade("detecQual") end },
    ["Progressive Detector Strength"] =     { hint = 0, run = function() Upgrade("scanner") end },
    ["Progressive Detector Frequency"] =    { hint = 0, run = function() Upgrade("scannerFr") end },
    -- Unused
    ["Progressive Filter Size"] =           { hint = 0, run = function() Upgrade("downloadFiltSize") end },
    ["Progressive Server Stability"] =      { hint = 0, run = function() Upgrade("serverStability") end },
    ["Progressive Transformer Stability"] = { hint = 0, run = function() Upgrade("transformer") end },

    ["Drunk Trap"] = {
        hint = 2,
        run = function()
            
        end
    },
}

complex_item_map = {
    ["Progressive Sleeping Bag"] = function()
        local i = 0
        for i=1,GetRecievedItems() do
            if GetAPItemNameFromId(item_list[i].item) == "Progressive Sleeping Bag" then
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
            AddHint(3, "You collected too many sleeping bags!")
        end
    end,
    ["Bunker Keycard"] = function()
        local GameMode = GetGameMode()
        local Pawn = GetPawn()
        if GameMode:IsValid() and Pawn:IsValid() then
            local out = {}
            GameMode:spawnPropThroughGamemode(
                FName("keycard"),
                { ["Translation"] = Pawn:K2_GetActorLocation(), ["Scale3D"] = { ["X"] = 1.0, ["Y"] = 1.0, ["Z"] = 1.0 } },
                1,
                out
            )
            out["actor "].Open = "ALPHA_HIDEOUT"
            Pawn:putObjectInventory2(out["actor "], false, {})
        end
    end,
    ["Kerfur-Omega Complete Manual"] = function()
        local Pawn = GetPawn()
        local blueprint = SpawnSomething("/Game/objects/prop_blueprint_kerfurOmega.prop_blueprint_kerfurOmega_C")
        if Pawn:IsValid() and blueprint:IsValid() then
            Pawn:putObjectInventory2(blueprint, false, {})
        end
    end,
}

item_map = {}
function FillItemMap()
    item_map = {}
    local datatable = StaticFindObject("/Game/main/datatables/list_props.list_props")
    if datatable:IsValid() then
        print("Filling item map with " .. #datatable .. " items")
        local total = 0
        datatable:ForEachRow(function(k, v)
            local name = v.displayName_8_FE83ADBF40AA162942FCE589F5806DD2:ToString()
            if name ~= "" then
                item_map[k] = name
                total = total + 1
            end
        end)
        print("Filtered down to " .. total .. " items")
    end
end
