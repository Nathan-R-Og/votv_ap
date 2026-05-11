print("[MyLuaMod] Mod loaded\n")

UEHelpers = require("UEHelpers")

require("utils")
require("game_utils")
require("archipelago")
require("item_map")

--ap day items
local have_days = 0

--last achieved day
local latest_day = 0

--currently active task
local task_active = false

--active fuse count
local fuses = {}
local fuse_debt = {}

-- TODO: Store that somewhere in the save slot
local sold_garbage_bags = 0

looking_at_location = -1

local last_item_failed = false

DELETE_LOCATION_ITEMS = true

function GetRecievedItems()
    local GameMode = GetGameMode()
    if GameMode:IsValid() then
        --GameMode.Immortal = true
        -- You now have the USaveGame object
        local SaveGameObject = GameMode.saveSlot
        if SaveGameObject:IsValid() then
            print("SAVE I IS " .. tostring(SaveGameObject.I))
            return SaveGameObject.I
        end
    end
    return 0
end

function SetRecievedItems(val)
    local GameMode = GetGameMode()
    if GameMode:IsValid() then
        --GameMode.Immortal = true
        -- You now have the USaveGame object
        local SaveGameObject = GameMode.saveSlot
        if SaveGameObject:IsValid() then
            print("SAVE I IS " .. tostring(SaveGameObject.I))
            SaveGameObject.I = val
            print("SAVE I IS NOW " .. tostring(SaveGameObject.I))
            return true
        end
    end
    return false
end

-- TODO: Find better name
function CheckAutoItem(i)
    if i < #item_list then
        local next_item = item_list[i+1]
        local item_name = GetAPItemNameFromId(next_item.item)
        if item_name == "Day" then
            AddHint("You got a new day!", HintType.Thought)
            have_days = have_days + 1
            return CheckAutoItem(i+1)
        end
        local auto_item = auto_map[item_name]
        if auto_item ~= nil then
            AddHint(item_name .. " from " .. ap:get_player_alias(next_item.player), auto_item.hint)
            auto_item.run()
            return CheckAutoItem(i+1)
        end
    end
    SetRecievedItems(i)
    SendItemsHint()
end

function SendItemsHint()
    local item_count = #item_list - GetRecievedItems()
    if item_count > 0 then
        local item = item_list[GetRecievedItems()+1]
        local item_name = GetAPItemNameFromId(item.item)
        AddHint("You have " .. tostring(item_count) .. " unclaimed item(s).\nNext item is " .. item_name .. "\nPress F9 to claim.", HintType.Warning)
    else
        AddHint("You have recieved all items. Yay!", HintType.Thought)
    end
end

function GetNextItem()
    local i = GetRecievedItems()
    if i < #item_list then
        local item = item_list[i+1]
        if item.index >= i then
            local item_name = GetAPItemNameFromId(item.item)
            AddHint(item_name .. " from " .. ap:get_player_alias(item.player), HintType.Info)
            local complex_item = complex_item_map[item_name]
            if complex_item then
                complex_item()
            else
                local internal_name = inverse_item_map[string.lower(item_name)]
                if internal_name ~= nil then
                    GiveItem(internal_name)
                elseif last_item_failed then
                    AddHint("Item skipped", HintType.Warning)
                    last_item_failed = false
                else
                    AddHint("Item unsupported. :)\nYou may stop your run here and report this to the maintainers,\nor press F9 again to skip this item\nIt will be lost forever if you do so", HintType.Error)
                    last_item_failed = true
                    return
                end
            end
            CheckAutoItem(i+1)
        end
    end
end

RegisterKeyBind(Key.F9, function()
    ExecuteInGameThread(function()
        GetNextItem()
    end)
end)

function OnTouchProp(prop)
    local key = prop:get().Key:ToString()
    -- Prevent items given by AP from triggering checks
    if string.startswith(key, "APItem") then return end
    local name = prop:get().Name:ToString()
    local location = locationKeys[key] or locationKeys[name]
    if location and SendLocation(location) and DELETE_LOCATION_ITEMS and not preserve_items[name] then
        prop:get():K2_DestroyActor()
    end
end

function CheckDailyTask()
    local SaveGameObject = GetSaveSlot()
    if SaveGameObject ~= nil then
        local new_active = SaveGameObject.taskNew.active_15_4D2EB6A44AAAE79770E875BDC11E595B
        if task_active and not new_active then
            SendNextLocation("Daily Task Done")
        end
        print("DAILY TASK ACTIVE IS NOW " .. tostring(new_active))
        task_active = new_active
    end
end

function CheckFuseHealth(index, obj)
    if not obj:IsValid() then return 0 end
    local base = fuses[index] or {}
    fuses[index] = {}
    obj.fuses:ForEach(function(i, e) fuses[index][i] = e:get() end)

    old_health = 0
    old_broken = 0
    new_health = 0
    new_broken = 0
    for _, fuse in pairs(base) do
        if fuse == 1 then old_health = old_health + 1 elseif fuse == 2 then old_broken = old_broken + 1 end
    end
    for _, fuse in pairs(fuses[index]) do
        if fuse == 1 then new_health = new_health + 1 elseif fuse == 2 then new_broken = new_broken + 1 end
    end

    local broken_increase = new_broken - old_broken
    local increase = new_health - old_health + (broken_increase > 0 and broken_increase or 0)
    print(obj:GetFName():ToString() .. " health: " .. new_health .. " (" .. increase .. ")")
    fuse_debt[index] = fuse_debt[index] and fuse_debt[index] + increase or increase
    if fuse_debt[index] > 0 then
        increase = fuse_debt[index]
        fuse_debt[index] = 0
        return increase
    else
        return 0
    end
end

function ReachGoal()
    if ap == nil then return end
    ap:StatusUpdate(ap.ClientStatus.GOAL)
    AddHint("You have reached your goal, congratulations!", HintType.Info)
    completed = true
end

function RegisterAllHooks()
    RegisterUniqueHook("/Game/objects/prop.prop_C:playerTryToGrab", function(self, player, collected)
        OnTouchProp(self)
    end)
    RegisterUniqueHook("/Game/objects/prop.prop_C:playerTryToHold", function(self, player, collected)
        OnTouchProp(self)
    end)
    RegisterUniqueHook("/Game/objects/prop.prop_C:playerTryToCollect", function(self, player, collected)
        OnTouchProp(self)
    end)
    RegisterUniqueHook("/Game/objects/prop.prop_C:player_use", function(self, player, collected)
        OnTouchProp(self)
    end)
    RegisterUniqueHook("/Game/objects/prop.prop_C:GetName", function(self, DisplayName, propname)
        local key = self:get().Key:ToString()
        local location = locationKeys[key]
        if location ~= nil then
            print("Found clientside location: " .. location)
            local id = GetAPLocationIDfromName(location)
            print("Serverside id: " .. tostring(id))
            if id ~= nil and id >= 0 then
                local missing = array_contains(MissingLocations, id)
                local scout = ScoutedLocations[id]
                if scout ~= nil then
                    DisplayName:set(FText("[AP] " .. scout.item .. " for " .. scout.player))
                elseif missing then
                    DisplayName:set(FText("[AP] Scouting..."))
                    ScoutLocationByName(location)
                    looking_at_location = id
                end
            end
        end
    end)

    RegisterUniqueHook("/Game/objects/drone.drone_C:triggerFly", function(self, console)
        print("Drone has begun flight")
        local SaveSlot = GetSaveSlot()
        if SaveSlot ~= nil then
            local container_index = self:get().container.propInventory.Index
            local container_data = SaveSlot.GObjStack[container_index + 1].obj_11_89CC26B14C79E8F107FE6E9010A5AFC9
            container_data:ForEach(function(_, item)
                local classname = item:get().class_3_5267A5ED44C89294283B8CBBEC685F8A:GetFName():ToString()
                if classname == "prop_box_C" then
                    item:get().signals_45_CE5AB8DE4026B6660BF9A28FA6690AD5:ForEach(function(_, signal)
                        if #signal:get().name_15_4DC53B564EDE34E0A8A16A92BD26B4AD:ToString() > 0 then
                            local level = signal:get().level_8_986E7CB3437BFD9FC9F6DF824C794EA8
                            if options.BackwardsSignalLevels == 1 then
                                for i=0,level do
                                    SendNextLocation("Sell Level " .. i .. " Signal")
                                end
                            else
                                SendNextLocation("Sell Level " .. level .. " Signal")
                            end
                        end
                    end)
                end

                if classname == "prop_garbageBag_C" then
                    sold_garbage_bags = sold_garbage_bags + 1
                end
            end)

            while sold_garbage_bags >= 24 do
                SendNextLocation("Sell 24 Full Trash Bags")
                sold_garbage_bags = sold_garbage_bags - 24
            end
        end
    end)
    RegisterUniqueHook("/Game/objects/droneSellLocation.droneSellLocation_C:sell", function(self, Points, responseEmail, checked, soldAmountSig, sellList)
        print("Sold: " .. sellList:get():ToString())
        CheckDailyTask()
    end)

    RegisterUniqueHook("/Game/objects/serverBox.serverBox_C:fix", function(self)
        SendNextLocation("Repair Server")
    end)
    RegisterUniqueHook("/Game/objects/misc/coordRadarDish.coordRadarDish_C:updFuses", function(self)
        for i=1,CheckFuseHealth(self:get().ID, self:get()) do
            SendNextLocation("Replace Fuse")
        end
    end)
    RegisterUniqueHook("/Game/objects/radiotower.radiotower_C:updFuses", function(self)
        for i=1,CheckFuseHealth(3, self:get()) do
            SendNextLocation("Replace Fuse")
        end
    end)

    local generatorCycles = {}
    RegisterUniqueHook("/Game/objects/generator.generator_C:player_use", function(self)
        local index = self:get().Index
        local cycle = self:get().cycle
        if generatorCycles[index] ~= nil and generatorCycles[index] < 90 and cycle == 100 then
            SendNextLocation("Repair Transformer")
        end
        generatorCycles[index] = cycle
    end)

    RegisterUniqueHook("/Game/objects/misc/kitchen.kitchen_C:fix", function(self, clean, Player, sponge, Hit)
        SendLocation("Repair the Oven")
    end)
    RegisterUniqueHook("/Game/objects/prop_shower.prop_shower_C:cleanSponge", function(self, clean, Player, sponge, Hit)
        if self:get().clean >= 1.0 then SendLocation("Clean the Shower") end
    end)
    RegisterUniqueHook("/Game/objects/toilet.toilet_C:cleanSponge", function(self, clean, Player, sponge, Hit)
        if self:get().clean >= 1.0 then SendLocation("Clean the Toilet") end
    end)
    RegisterUniqueHook("/Game/objects/sink.sink_C:cleanSponge", function(self, clean, Player, sponge, Hit)
        if self:get().clean >= 1.0 then SendLocation("Clean the Sink") end
    end)

    for _, variety in ipairs({"shri", "mush", "pepp", "pine"}) do
        RegisterUniqueHook("/Game/objects/prop_cfood_pizzad_" .. variety .. ".prop_cfood_pizzad_" .. variety .. "_C:cooked", function(self)
            SendLocation("Bake a Pizza")
        end)
    end
    RegisterUniqueHook("/Game/objects/prop_cfood_breadmold.prop_cfood_breadmold_C:cooked", function(self)
        SendLocation("Bake Bread")
    end)
    RegisterUniqueHook("/Game/objects/prop_cookingFood_cookietray.prop_cookingFood_cookietray_C:cooked", function(self)
        SendLocation("Bake Cookies")
    end)

    RegisterUniqueHook("/Game/objects/drone.drone_C:sendShop", function(self, order)
        local orderreal = order:get().items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927
        local filtered_order = {}
        orderreal:ForEach(function(index, item)
            local item_name = item:get().name_14_B3814BBE478D1FA0AB005BB6386C1541:ToString()
            if item_name == nil then
                return
            end
            if SendLocation("Purchase ".. item_map[item_name]) then
                return
            end
            table.insert(filtered_order, item:get())
        end)
        orderreal:Empty()
        for index, item in ipairs(filtered_order) do
            orderreal[index] = item
        end
    end)

    RegisterUniqueHook("/Game/umg/interfaces/ui_laptop.ui_laptop_C:makeAnOrder", function(self, NewItem, automatic)
        local SaveGameObject = GetSaveSlot()
        if SaveGameObject and #SaveGameObject.orders > 0 then
            local last_order = SaveGameObject.orders[#SaveGameObject.orders]
            local order_items = last_order.items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927
            local filtered_order = {}
            order_items:ForEach(function(index, item)
                local item_name = item:get().name_14_B3814BBE478D1FA0AB005BB6386C1541:ToString()
                if item_name == nil then return end
                if SendLocation("Purchase " .. item_map[item_name]) then return end
                table.insert(filtered_order, item:get())
            end)
            print("Order has size " .. #order_items .. ", filtering down to " .. #filtered_order)
            order_items:Empty()
            for index, item in ipairs(filtered_order) do
                order_items[index] = item
            end
        end
    end)

    -- Day Looping
    RegisterUniqueHook("/Game/objects/misc/daynightCycle.daynightCycle_C:ReceiveTick", function(self, DeltaSeconds)
        if ap == nil then return end
        local SaveGameObject = GetSaveSlot()
        local danc = GetDNC()
        if danc:IsValid() and SaveGameObject ~= nil then
            --safe zone of time before next day
            if danc.Day >= danc.MaxTime - 5 and options.DayAsItems == 1 then
                --check if has next day
                if SaveGameObject.savedTime.Z + 1 > have_days then
                    AddHint('You do not have the next day! Looping..', HintType.Warning)
                    danc.Day = 0
                end
            end

            --do survived checks
            while SaveGameObject.savedTime.Z > latest_day do
                latest_day = latest_day + 1
                SendLocation("Survive Day " .. tostring(latest_day))
                if options.Objective == 6 and options.SurviveDay <= latest_day and not completed then
                    ReachGoal()
                end
            end
        end
    end)

    for cls, goal in pairs(createdGoals) do
        print("Setting up goal check for " .. cls)
        NotifyUniqueOnNewObject(cls, function(self)
            if ap == nil or completed then return end
            if goal == options.Objective then
                ReachGoal()
            end
        end)
    end
    RegisterUniqueHook("/Game/objects/warpbox.warpbox_C:player_use", function(self)
        if ap == nil or completed then return end
        if options.Objective ~= 5 then return end
        for index=1,9 do
            local has_tile = self:get().tiles[index]
            if not has_tile then return end
        end
        ReachGoal()
        self:get():Open(true)
        self:get().Out:Open(true)
    end)

    CheckDailyTask()
    local static_radio = StaticFindObject("/Game/objects/radiotower.radiotower_C")
    local radiotower = FindObject(static_radio, GetWorld(), "radiotower", true)
    CheckFuseHealth(3, radiotower)
    local coordRadars = FindAllOf("coordRadarDish_C")
    for _, radar in ipairs(coordRadars or {}) do
        CheckFuseHealth(radar.ID, radar)
    end
    FillItemMap()

    AddHint("Remember to connect to Archipelago!", HintType.Thought)
end

RegisterKeyBind(Key.F8, function()
    ExecuteInGameThread(function()
        RegisterAllHooks()
    end)
end)

RegisterKeyBind(Key.F7, function()
    ExecuteInGameThread(function()
        AddHint("Debug shortcut", HintType.Warning)
        print(inverse_item_map["shrimp pack"])
        print(inverse_item_map["shrimps pack"])
    end)
end)

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self, NewPawn)
    NotifyUniqueOnNewObject("/Game/main/mainPlayer.mainPlayer_C", function(self)
        SetRecievedItems(0)
        disconnect()
    end)

    RegisterUniqueHook("/Game/main/mainGamemode.mainGamemode_C:Load Primitives", function(self, in_canLoad, in_isSubData, in_loadingSubLevel)
        RegisterAllHooks()
    end)
end)

RegisterConsoleCommandHandler("daymax", function(FullCommand, Parameters)
    -- If we have no parameters then just let someone else handle this command
    if #Parameters < 1 then
        return false
    end

    local danc = GetDNC()
    if danc:IsValid() then
        danc.MaxTime = tonumber(Parameters[1])
    end

    return true
end)

RegisterConsoleCommandHandler("host_timescale", function(FullCommand, Parameters)
    -- If we have no parameters then just let someone else handle this command
    if #Parameters < 1 then
        return false
    end

    local dnc = StaticFindObject("/Game/objects/misc/daynightCycle.daynightCycle_C")
    local danc = FindObject(dnc, GetWorld(), "daynightCycle", true)

    if danc:IsValid() then
        danc.TimeScale = tonumber(Parameters[1])
    end

    return true
end)

RegisterConsoleCommandHandler("connect", function(FullCommand, Parameters)
    -- debug
    if #Parameters < 2 then
        connectToAp("archipelago.gg:57875", "NathanR_VOTV", "")
        return true
    end
    local password = ""
    if #Parameters == 3 then
        password = Parameters[3]
    end
    connectToAp(Parameters[1], Parameters[2], password)
    return true
end)

RegisterConsoleCommandHandler("disconnect", function(FullCommand, Parameters)
    disconnect()
    return true
end)
