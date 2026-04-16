print("[MyLuaMod] Mod loaded\n")

UEHelpers = require("UEHelpers")

require("archipelago")
require("utils")
require("game_utils")
require("item_map")

--ap day items
local have_days = 0

--last achieved day
local latest_day = 0

function GetRecievedItems()
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
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
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
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

function OnItemReceived(item_name)
    local invert = table_invert(item_map)
    local internal_name = invert[item_name]
    if internal_name ~= nil then
        print("can give player " .. item_name)
        GiveItem(internal_name)
    else
        print("cant give player " .. item_name)
        if item_name == "Day" then
            have_days = have_days + 1
            AddHint("You got a new day!", 1)
        else
            AddHint("Item unsupported. :)", 2)
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
    local location = locationKeys[key]
    if (location) then
        prop:get():K2_DestroyActor()
        ShowAchievementPopup(1, location, 1, 1)
        SendLocation(location)
    end
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

    RegisterUniqueHook("/Game/objects/droneSellLocation.droneSellLocation_C:sell", function(self, Points, responseEmail, checked, soldAmountSig, sellList)
        --0 == worst?
        --6 == best?
        local email_response = responseEmail[0]
        print(tostring(email_response))
        AddHint("Email response " .. tostring(email_response), 0)
        if email_response == 6 then
            local GameplayStatics = UEHelpers:GetGameplayStatics()
            local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
            local SaveGameObject = nil

            if GameMode:IsValid() then
                SaveGameObject = GameMode.saveSlot
                if SaveGameObject:IsValid() then
                    SendLocation("Day " .. tostring(SaveGameObject.savedTime.Z) .. " Report")
                end
            end
        end
    end)

    RegisterUniqueHook("/Game/objects/drone.drone_C:sendShop", function(self, order)
        local orderreal = order:get().items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927
        orderreal:ForEach(function(index, item)
            local item_s = item:get()
            local item_name = item_s.name_14_B3814BBE478D1FA0AB005BB6386C1541:ToString()
            local object = item_s.object_18_519B13C4426D465A5A4A80A9FFFBB161
            local object_name = object:GetFullName()
            print(tostring(item_s.price_11_BE3AF83E446D1C3BDEA63BA50CFE096C))
            print(item_name)
            print(object_name)
            print(item_s.asProp_21_D3F8D96740005CA84664FBAD4E0F5F48:ToString())
            print(tostring(item_s.category_24_257ED6AB4855F44C55FFC98ECEA1F511))
            print(item_s.subcategory_35_BC2B1FF94CA9FC340ADDC78FFA014589:ToString())
            print(tostring(item_s.size_30_C3131BE84D89E0C389F1DB9557E08D74))
            print(item_s.achievementUnlock_38_883E827740DCBD0E996CF9B74B755175:ToString())

            print(item_s:GetOuter():GetFullName())
            print(item_s:GetClass():GetFullName())
            print(item_s:GetFullName())
        end)
        local time = order:get().time_7_E02F9C514C9048F7B4AA4E82388D6DAE
        print(tostring(time))
    end)

    RegisterUniqueHook("/Game/umg/interfaces/ui_laptop.ui_laptop_C:makeAnOrder", function(self, NewItem, automatic)
        local order = NewItem:get().items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927
        order:ForEach(function(index, item)
            local item_s = item:get()
            local item_name = item_s.name_14_B3814BBE478D1FA0AB005BB6386C1541:ToString()
            if item_name == nil then
                return nil
            end
            print(item_name)
            print("DO SEND " .. item_map[item_name])
            SendLocation("Purchase ".. item_map[item_name])
            local object = item_s.object_18_519B13C4426D465A5A4A80A9FFFBB161
            local object_name = object:GetFullName()
            -- print(tostring(item_s.price_11_BE3AF83E446D1C3BDEA63BA50CFE096C))
            --print(item_s.asProp_21_D3F8D96740005CA84664FBAD4E0F5F48:ToString())
            -- print(tostring(item_s.category_24_257ED6AB4855F44C55FFC98ECEA1F511))
            -- print(item_s.subcategory_35_BC2B1FF94CA9FC340ADDC78FFA014589:ToString())
            -- print(tostring(item_s.size_30_C3131BE84D89E0C389F1DB9557E08D74))
            -- print(item_s.achievementUnlock_38_883E827740DCBD0E996CF9B74B755175:ToString())

            -- print(item_s:GetOuter():GetFullName())
            -- print(item_s:GetClass():GetFullName())
            -- print(item_s:GetFullName())
        end)
    end)

    --Day Looping
    -- RegisterUniqueHook("/Game/objects/misc/daynightCycle.daynightCycle_C:ReceiveTick", function(self, DeltaSeconds)
    --     local GameplayStatics = UEHelpers:GetGameplayStatics()
    --     local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
    --     local SaveGameObject = nil

    --     if GameMode:IsValid() then
    --         --GameMode.Immortal = true
    --         -- You now have the USaveGame object
    --         SaveGameObject = GameMode.saveSlot
    --         if SaveGameObject:IsValid() then
    --             --SaveGameObject.Points = 2
    --             --GameMode.AddPoints(0)
    --             --SaveGameObject.food = 100.0
    --             --SaveGameObject.sleep = 100.0
    --             --SaveGameObject.maxDay = 2
    --             --SaveGameObject.Day = 100
    --         end
    --     end

    --     local dnc = StaticFindObject("/Game/objects/misc/daynightCycle.daynightCycle_C")
    --     local danc = FindObject(dnc, UEHelpers:GetWorld(), "daynightCycle", true)

    --     if danc:IsValid() and SaveGameObject ~= nil then
    --         --safe zone of time before next day
    --         if danc.Day >= danc.MaxTime - 5 then
    --             --check if has next day
    --             if SaveGameObject.savedTime.Z + 1 > have_days then
    --                 AddHint('You do not have the next day! Looping..', 2)
    --                 danc.Day = 0
    --             end
    --         end

    --         --do survived checks
    --         if SaveGameObject.savedTime.Z > latest_day then
    --             latest_day = SaveGameObject.savedTime.Z
    --             SendLocation("Survived Day " .. tostring(latest_day))
    --         end
    --     end
    -- end)
end

RegisterKeyBind(Key.F8, function()
    ExecuteInGameThread(function()
        RegisterAllHooks()
    end)
end)

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self, NewPawn)
    NotifyOnNewObject("/Game/main/mainPlayer.mainPlayer_C", function(self)
        SetRecievedItems(0)
        RegisterAllHooks()
    end)
end)

RegisterConsoleCommandHandler("daymax", function(FullCommand, Parameters)
    -- If we have no parameters then just let someone else handle this command
    if #Parameters < 1 then
        return false
    end

    local dnc = StaticFindObject("/Game/objects/misc/daynightCycle.daynightCycle_C")
    local danc = FindObject(dnc, UEHelpers:GetWorld(), "daynightCycle", true)

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
    local danc = FindObject(dnc, UEHelpers:GetWorld(), "daynightCycle", true)

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
