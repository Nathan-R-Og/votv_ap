print("[MyLuaMod] Mod loaded\n")

require("archipelago")
require("utils")
require("item_map")

local UEHelpers = require("UEHelpers")
local lastLocation = nil

--ap day items
local have_days = 0

--last achieved day
local latest_day = 0

-- function SpawnSomething()
--     --TODO: make this an argument probably
--     --local the = "/Game/objects/prop_food_potatoCooked.prop_food_potatoCooked_C"
--     local the = "/Game/objects/misc/radiotowerPoof.radiotowerPoof_C"
--     LoadAsset(the)

--     --Old method. not really good :)
--     --local FirstPlayerController = UEHelpers:GetPlayerController()
--     --local CM = FirstPlayerController.CheatManager
--     --CM:Summon(the)

--     --spawn class at player
--     local Class = StaticFindObject(the)
--     if Class:IsValid() then
--         print(Class:GetFullName())
--         local World = UEHelpers:GetWorld()
--         local FirstPlayerController = UEHelpers:GetPlayerController()
--         local Pawn = FirstPlayerController.Pawn
--         local Location = Pawn:K2_GetActorLocation()
--         local Rotation = Pawn:K2_GetActorRotation()
--         local SpawnedActor = World:SpawnActor(Class, Location, Rotation)
--         return SpawnedActor
--     end
--     return nil
-- end

-- function ReadPlayerLocation()
--     local FirstPlayerController = UEHelpers:GetPlayerController()
--     local Pawn = FirstPlayerController.Pawn
--     local Location = Pawn:K2_GetActorLocation()
--     print(string.format("[MyLuaMod] Player location: {X=%.3f, Y=%.3f, Z=%.3f}\n", Location.X, Location.Y, Location.Z))
--     if lastLocation then
--         print(string.format("[MyLuaMod] Player moved: {delta_X=%.3f, delta_Y=%.3f, delta_Z=%.3f}\n",
--             Location.X - lastLocation.X,
--             Location.Y - lastLocation.Y,
--             Location.Z - lastLocation.Z)
--         )
--     end
--     lastLocation = Location
--     return Location
-- end

-- function SendViaDrone()
--     local drone_class = StaticFindObject("/Game/objects/drone.drone_C")
--     local drone = FindObject(drone_class, UEHelpers:GetWorld(), "drone", true)
--     local laptop = FindFirstOf("ui_laptop_C")

--     local class = StaticFindObject('/Script/Engine.UserDefinedStruct')
--     --local outer = fucking_class2
--     local outer = StaticFindObject("/Game/main/structs/struct_storeOrder.struct_storeOrder")

--     if class:IsValid() and outer:IsValid() and drone:IsValid() and laptop:IsValid() then
--         local CreatedConsole = StaticConstructObject(class, outer, 0, 0, 0, nil, false, false, nil)
--         outer = StaticFindObject("/Game/main/structs/struct_store.struct_store")
--         local CreatedItem = StaticConstructObject(class, outer, 0, 0, 0, nil, false, false, nil)
--         if CreatedConsole:IsValid() and CreatedItem:IsValid() then
--             local the = "/Game/objects/prop_drive.prop_drive_C"
--             local Class = StaticFindObject(the)
--             --CreatedItem.price_11_BE3AF83E446D1C3BDEA63BA50CFE096C = 2
--             --CreatedItem.name_14_B3814BBE478D1FA0AB005BB6386C1541 = FName("drive")
--             --CreatedItem.object_18_519B13C4426D465A5A4A80A9FFFBB161 = Class
--             --CreatedItem.asProp_21_D3F8D96740005CA84664FBAD4E0F5F48 = FName("")
--             --CreatedItem.category_24_257ED6AB4855F44C55FFC98ECEA1F511 = 6
--             --CreatedItem.subcategory_35_BC2B1FF94CA9FC340ADDC78FFA014589 = FText("Electronics")
--             --CreatedItem.size_30_C3131BE84D89E0C389F1DB9557E08D74 = 1
--             --CreatedItem.achievementUnlock_38_883E827740DCBD0E996CF9B74B755175 = FName("")
--             --CreatedConsole.time_7_E02F9C514C9048F7B4AA4E82388D6DAE = 0.0
--             --CreatedConsole.items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927 = {CreatedItem}

--             ---@class Fstruct_store
--             local item_table = {
--                 ["price_11_BE3AF83E446D1C3BDEA63BA50CFE096C"] = 2,
--                 ["name_14_B3814BBE478D1FA0AB005BB6386C1541"] = FName("drive"),
--                 ["object_18_519B13C4426D465A5A4A80A9FFFBB161"] = Class,
--                 ["asProp_21_D3F8D96740005CA84664FBAD4E0F5F48"] = FName(""),
--                 ["category_24_257ED6AB4855F44C55FFC98ECEA1F511"] = 6,
--                 ["subcategory_35_BC2B1FF94CA9FC340ADDC78FFA014589"] = FText("Electronics"),
--                 ["size_30_C3131BE84D89E0C389F1DB9557E08D74"] = 1,
--                 ["achievementUnlock_38_883E827740DCBD0E996CF9B74B755175"] = FName(""),
--             }
--             --CreatedItem:Set(item_table)
--             ---@class Fstruct_storeOrder
--             local order_table = {
--                 ["time_7_E02F9C514C9048F7B4AA4E82388D6DAE"] = 0.0,
--                 ["items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927"] = {item_table},
--             }
--             --CreatedConsole:Set(order_table)
--             drone.sendShop({{laptop.storeSlots[1].Data}, 0.0})

--             --CreatedConsole:Set()
--             --if lmfaofunny ~= nil then
--             --    drone.sendShop(lmfaofunny)
--             --end

--             -- local order = laptop.storeSlots
--             -- order:ForEach(function(index, slot)
--             --     print(tostring(slot.Data))
--             -- end)

--             -- print("doohucieky")
--             -- print(CreatedItem:GetOuter():GetFullName())
--             -- print(CreatedItem:GetClass():GetFullName())
--             -- print(CreatedItem:GetFullName())

--             -- print(CreatedConsole:GetOuter():GetFullName())
--             -- print(CreatedConsole:GetClass():GetFullName())
--             -- print(CreatedConsole:GetFullName())

--             -- local my_int = CreatedItem:GetAddress()
--             -- local hex_uppercase = string.format("%X", my_int)
--             -- print(hex_uppercase) -- Output: ff
--             -- my_int = CreatedConsole:GetAddress()
--             -- hex_uppercase = string.format("%X", my_int)
--             -- print(hex_uppercase) -- Output: FF

--             --drone.sendShop(CreatedConsole)
--         end
--     end
-- end


-- function SendViaDroneReal()
--     local drone_class = StaticFindObject("/Game/objects/drone.drone_C")
--     local drone = FindObject(drone_class, UEHelpers:GetWorld(), "drone", true)

--     local laptop = FindFirstOf("ui_laptop_C")

--     if laptop:IsValid() and drone:IsValid() then
--         drone.sendShop({{[1]=laptop.storeSlots[1].Data}, 0.0})

--         local order = laptop.storeSlots
--         order:ForEach(function(index, slot)
--             print(tostring(slot.Data))
--         end)

--         print("bunge")
--     end
-- end

function MessWithSaveGame()
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())

    if GameMode:IsValid() then
        GameMode.Immortal = true
        -- You now have the USaveGame object
        local SaveGameObject = GameMode.saveSlot
        if SaveGameObject:IsValid() then
            SaveGameObject.Points = 2
            SaveGameObject.food = 100.0
            SaveGameObject.sleep = 100.0
            GameMode.AddPoints(0)
        else
            print("Failed to load save game")
        end
    else
        print("Failed to load save game")
    end
end

--MakePlayerLookAt({["X"] = 0.0,["Y"] = 0.0,["Z"] = 0.0})
function MakePlayerLookAt(look_here)
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    local Location = Pawn:K2_GetActorLocation()
    Pawn.makeLookAt(look_here,Location)
end

function MakePlayerDropItem()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.forceDrop()
end

function MakePlayerEatShit(dmg)
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.ateShit(dmg)
end

function MakePlayerEatPiss(heal)
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.heal(heal)
end

function MakePlayerPassOut()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.wakeup(true)
end

--??? only really makes you reset camera
function MakePlayerWakeUp()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.forceWakeup()
end

--the funnier alternative to deathlink
function MakePlayerInexplicablyDie()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.fallen(true)
end

function MakePlayerBurn(duration)
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.ignite(duration)
end

--trap? can be escaped by ragdolling
function MakePlayerStop()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.ladderOn()
end

--trap
function MakePlayerPause()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.simulateEsc()
end

function MakePlayerWalk()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.unrun()
end

function MakePlayerLoseInput()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.input_forward = false
    Pawn.input_back = false
    Pawn.input_right = false
    Pawn.input_left = false
    Pawn.input_run = false
    Pawn.input_alt = false
    Pawn.input_jump = false
    Pawn.input_crouch = false
end

--can be a trap or a buff :)
function MakePlayerChangeArm(length)
    length = length or 100 -- ~100 is the default
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.armLength = length
end

function MakePlayerChangeSensitivity(speed)
    speed = speed or 1 -- 1 is the default
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.mouseSens = speed
end

function MakePlayerStrong(boolean)
    boolean = boolean or false -- false is the default
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.hulkMode = boolean
end

function MakePlayerFlingItem()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.grabLen = 10000.0
    Pawn.grab_speed = 0.0001
end

function MakePlayerMirrorMouse()
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.isMirror = true
end

--??? makes it so you cant put up the item you are holding
function MakePlayerUnableToStash()
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
    if GameMode:IsValid() then
        GameMode.fuckYOuItem()
    end
end

--trap ; make player reset radio tower
function MakePlayerLoseRadioTower()
    local dnc = StaticFindObject("/Game/objects/radiotower.radiotower_C")
    local danc = FindObject(dnc, UEHelpers:GetWorld(), "radiotower", true)

    if danc:IsValid() then
        danc.breakdown()
        danc.breakdown()
        danc.breakdown()
    end
end

function MakePlayerLoseTransformers()
    local ActorInstances = FindAllOf("generator_C")
    if ActorInstances then
        for Index, ActorInstance in pairs(ActorInstances) do
            ActorInstance.IsBroken = true
        end
    end
end

function SwapToLevel(Levelname)
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    GameplayStatics:OpenLevel(UEHelpers:GetWorld(), FName(Levelname), false, "")
end

function AddEmail()
    local laptop = FindFirstOf("ui_laptop_C")
    if laptop:IsValid() then
        --0 == Dr_Bao
        --1 == Dr_Lea
        --2 == Auto
        --3 == Dr_Max
        --4 == Dr_Ken
        --5 == Dr_Ena
        --6 == Dr_Ula
        --7 == Dr_Ler
        --8 == user
        --9 == Dr_Noa
        --10 == enum_MAX
        --else == blank
        local the_email = {
            ["new_14_5FB7784E4E60A05C8BC13ABD93D6EFDF"] = true,
            ["pfp_2_286B75414BAC856FBED047B8BE9F0065"] = nil,
            ["username_18_778252D64AB06BB5D3FBC386EC59383F"] = 2,
            ["date_8_932438DD4158A22517E43E8DAD3BBC45"] = nil,
            ["topic_17_91E2F92C4DC4FF16CFAF539A3561F74B"] = FText("URGENT - TAKE ACTION NOW"),
            ["text_11_B74A8FDC40C1F46E42A9F382C0EFA6FF"] = FText("hi :P"),
        }
        laptop.addEmail(the_email)
    end
end

function AddHint(text, type)
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
    if GameMode:IsValid() then
        --0 == i
        --1 == warning
        --2 == x
        --3 == thought bubble
        --else == null
        --doesnt specify anywhere it takes itself as an arg? okay
        GameMode.addHint(GameMode, FText(text), type)
    end
end


function GiveItem(itemname)
    local FirstPlayerController = UEHelpers:GetPlayerController()
    local Pawn = FirstPlayerController.Pawn
    Pawn.addPropToPlayer(Pawn, FName(itemname))
end

function GetRecievedItems()
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
    local SaveGameObject = nil
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
    local SaveGameObject = nil
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

function OnItemRecieved(item_name)
    local invert = table_invert(item_map)
    local only_itemnames = extract_keys(invert)
    if array_contains(only_itemnames, item_name) then
        print("can give player "..item_name)
        GiveItem(invert[item_name])
    else
        print("cant give player "..item_name)
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
        local i = GetRecievedItems()
        if i < #item_list then
            local item = item_list[i+1]
            if item.index >= i then
                local APItemIdToName = table_invert(items)
                local ApItemName = APItemIdToName[item.item]
                print(ApItemName)
                AddHint(ApItemName .. " from " .. ap:get_player_alias(item.player), 0)
                OnItemRecieved(ApItemName)
                SetRecievedItems(item.index+1)

                local item_count = #item_list - (item.index+1)
                if item_count > 0 then
                    item = item_list[GetRecievedItems()+1]
                    local APItemIdToName = table_invert(items)
                    local ApItemName = APItemIdToName[item.item]
                    AddHint("You have " .. tostring(item_count) .. " unclaimed items left.\nNext item is " .. ApItemName, 0)
                end
            end
        end
    end)
end)

RegisterKeyBind(Key.F8, function()
    ExecuteInGameThread(function()
        ReadPlayerLocation()
    end)
end)

--Dump Order Contents
local existing_hooks = {}
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self, NewPawn)
    NotifyOnNewObject("/Game/main/mainPlayer.mainPlayer_C", function(self)
        SetRecievedItems(0)
        if not array_contains(existing_hooks, "makeAnOrder") then
            add_unique(existing_hooks, "makeAnOrder")
            RegisterHook("/Game/umg/ui_laptop.ui_laptop_C:makeAnOrder", function(self, NewItem, automatic)
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
        end

        if not array_contains(existing_hooks, "report_check") then
            add_unique(existing_hooks, "report_check")
            RegisterHook("/Game/objects/droneSellBox.droneSellBox_C:sell", function(self, Array, Info, itembox, Data, Points, responseEmail, checked)
                --0 == worst?
                --6 == best?
                local is_itembox = itembox[0]
                local email_response = responseEmail[0]
                print(tostring(email_response))
                AddHint("Email response " .. tostring(email_response), 0)
                if not is_itembox then
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
                end
            end)
        end
        -- if not array_contains(existing_hooks, "sendShop") then
        --     add_unique(existing_hooks, "sendShop")
        --     RegisterHook("/Game/objects/drone.drone_C:sendShop", function(self, order)
        --         local orderreal = order:get().items_3_C1FD2F664A7CE19ACFEB6DA0AF4F9927
        --         orderreal:ForEach(function(index, item)
        --             local item_s = item:get()
        --             local item_name = item_s.name_14_B3814BBE478D1FA0AB005BB6386C1541:ToString()
        --             local object = item_s.object_18_519B13C4426D465A5A4A80A9FFFBB161
        --             local object_name = object:GetFullName()
        --             print(tostring(item_s.price_11_BE3AF83E446D1C3BDEA63BA50CFE096C))
        --             print(item_name)
        --             print(object_name)
        --             print(item_s.asProp_21_D3F8D96740005CA84664FBAD4E0F5F48:ToString())
        --             print(tostring(item_s.category_24_257ED6AB4855F44C55FFC98ECEA1F511))
        --             print(item_s.subcategory_35_BC2B1FF94CA9FC340ADDC78FFA014589:ToString())
        --             print(tostring(item_s.size_30_C3131BE84D89E0C389F1DB9557E08D74))
        --             print(item_s.achievementUnlock_38_883E827740DCBD0E996CF9B74B755175:ToString())

        --             print(item_s:GetOuter():GetFullName())
        --             print(item_s:GetClass():GetFullName())
        --             print(item_s:GetFullName())
        --         end)
        --         local time = order:get().time_7_E02F9C514C9048F7B4AA4E82388D6DAE
        --         print(tostring(time))
        --     end)
        -- end

        --Day Looping
        if not array_contains(existing_hooks, "dnc") then
            add_unique(existing_hooks, "dnc")
            RegisterHook("/Game/objects/misc/daynightCycle.daynightCycle_C:ReceiveTick", function(self, DeltaSeconds)
                local GameplayStatics = UEHelpers:GetGameplayStatics()
                local GameMode = GameplayStatics:GetGameMode(UEHelpers:GetWorld())
                local SaveGameObject = nil

                if GameMode:IsValid() then
                    --GameMode.Immortal = true
                    -- You now have the USaveGame object
                    SaveGameObject = GameMode.saveSlot
                    if SaveGameObject:IsValid() then
                        --SaveGameObject.Points = 2
                        --GameMode.AddPoints(0)
                        --SaveGameObject.food = 100.0
                        --SaveGameObject.sleep = 100.0
                        --SaveGameObject.maxDay = 2
                        --SaveGameObject.Day = 100
                    end
                end

                local dnc = StaticFindObject("/Game/objects/misc/daynightCycle.daynightCycle_C")
                local danc = FindObject(dnc, UEHelpers:GetWorld(), "daynightCycle", true)

                if danc:IsValid() and SaveGameObject ~= nil then
                    --safe zone of time before next day
                    if danc.Day >= danc.MaxTime - 5 then
                        --check if has next day
                        if SaveGameObject.savedTime.Z + 1 > have_days then
                            AddHint('You do not have the next day! Looping..', 2)
                            danc.Day = 0
                        end
                    end

                    --do survived checks
                    if SaveGameObject.savedTime.Z > latest_day then
                        latest_day = SaveGameObject.savedTime.Z
                        SendLocation("Survived Day " .. tostring(latest_day))
                    end
                end

            end)
        end
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

    return false
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

    return false
end)

RegisterConsoleCommandHandler("connect", function(FullCommand, Parameters)
    -- debug
    if #Parameters < 2 then
        connectToAp("archipelago.gg:57875", "NathanR_VOTV", "")
        return false
    end
    local password = ""
    if #Parameters == 3 then
        password = Parameters[3]
    end
    connectToAp(Parameters[1], Parameters[2], password)
    return false
end)

RegisterConsoleCommandHandler("disconnect", function(FullCommand, Parameters)
    disconnect()

    return true
end)

