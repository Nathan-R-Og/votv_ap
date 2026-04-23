local GameplayStatics = nil
function GetGameplayStatics()
    if GameplayStatics == nil or not GameplayStatics:IsValid() then GameplayStatics = UEHelpers:GetGameplayStatics() end
    return GameplayStatics
end

local World = nil
function GetWorld()
    if World == nil or not World:IsValid() then World = UEHelpers:GetWorld() end
    return World
end

local GameMode = nil
function GetGameMode()
    if GameMode == nil or not GameMode:IsValid() then GameMode = GetGameplayStatics():GetGameMode(GetWorld()) end
    return GameMode
end

function GetSaveSlot()
    local GameMode = GetGameMode()
    if GameMode:IsValid() then
        local slot = GameMode.saveSlot
        if slot:IsValid() then
            return slot
        else
            return nil
        end
    else
        return nil
    end
end

local Pawn = nil
function GetPawn()
    if Pawn == nil or not Pawn:IsValid() then
        local FirstPlayerController = UEHelpers:GetPlayerController()
        Pawn = FirstPlayerController.Pawn
    end
    return Pawn
end

local DNC = nil
function GetDNC()
    if DNC == nil or not DNC:IsValid() then
        local dnc = StaticFindObject("/Game/objects/misc/daynightCycle.daynightCycle_C")
        DNC = FindObject(dnc, GetWorld(), "daynightCycle", true)
    end
    return DNC
end

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
--         local World = GetWorld()
--         local FirstPlayerController = UEHelpers:GetPlayerController()
--         local Pawn = FirstPlayerController.Pawn
--         local Location = Pawn:K2_GetActorLocation()
--         local Rotation = Pawn:K2_GetActorRotation()
--         local SpawnedActor = World:SpawnActor(Class, Location, Rotation)
--         return SpawnedActor
--     end
--     return nil
-- end

-- function SendViaDrone()
--     local drone_class = StaticFindObject("/Game/objects/drone.drone_C")
--     local drone = FindObject(drone_class, GetWorld(), "drone", true)
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
--     local drone = FindObject(drone_class, GetWorld(), "drone", true)

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

--MakePlayerLookAt({["X"] = 0.0,["Y"] = 0.0,["Z"] = 0.0})
function MakePlayerLookAt(look_here)
    local Pawn = GetPawn()
    local Location = Pawn:K2_GetActorLocation()
    Pawn.makeLookAt(look_here,Location)
end

function MakePlayerDropItem()
    local Pawn = GetPawn()
    Pawn.forceDrop()
end

function MakePlayerEatShit(dmg)
    local Pawn = GetPawn()
    Pawn.ateShit(dmg)
end

function MakePlayerEatPiss(heal)
    local Pawn = GetPawn()
    Pawn.heal(heal)
end

function MakePlayerPassOut()
    local Pawn = GetPawn()
    Pawn.wakeup(true)
end

--??? only really makes you reset camera
function MakePlayerWakeUp()
    local Pawn = GetPawn()
    Pawn.forceWakeup()
end

--the funnier alternative to deathlink
function MakePlayerInexplicablyDie()
    local Pawn = GetPawn()
    Pawn.fallen(true)
end

function MakePlayerBurn(duration)
    local Pawn = GetPawn()
    Pawn.ignite(duration)
end

--trap? can be escaped by ragdolling
function MakePlayerStop()
    local Pawn = GetPawn()
    Pawn.ladderOn()
end

--trap
function MakePlayerPause()
    local Pawn = GetPawn()
    Pawn.simulateEsc()
end

function MakePlayerWalk()
    local Pawn = GetPawn()
    Pawn.unrun()
end

function MakePlayerLoseInput()
    local Pawn = GetPawn()
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
    local Pawn = GetPawn()
    Pawn.armLength = length
end

function MakePlayerChangeSensitivity(speed)
    speed = speed or 1 -- 1 is the default
    local Pawn = GetPawn()
    Pawn.mouseSens = speed
end

function MakePlayerStrong(boolean)
    boolean = boolean or false -- false is the default
    local Pawn = GetPawn()
    Pawn.hulkMode = boolean
end

function MakePlayerFlingItem()
    local Pawn = GetPawn()
    Pawn.grabLen = 10000.0
    Pawn.grab_speed = 0.0001
end

function MakePlayerMirrorMouse()
    local Pawn = GetPawn()
    Pawn.isMirror = true
end

--??? makes it so you cant put up the item you are holding
function MakePlayerUnableToStash()
    local GameMode = GetGameMode()
    if GameMode:IsValid() then
        GameMode.fuckYOuItem()
    end
end

--trap ; make player reset radio tower
function MakePlayerLoseRadioTower()
    local dnc = StaticFindObject("/Game/objects/radiotower.radiotower_C")
    local danc = FindObject(dnc, GetWorld(), "radiotower", true)

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
    GetGameplayStatics():OpenLevel(GetWorld(), FName(Levelname), false, "")
end

function AddEmail(title, text)
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
            ["topic_17_91E2F92C4DC4FF16CFAF539A3561F74B"] = FText(title),
            ["text_11_B74A8FDC40C1F46E42A9F382C0EFA6FF"] = FText(text),
        }
        laptop.addEmail(the_email)
    end
end

function AddHint(text, type)
    local GameMode = GetGameMode()
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
    local Pawn = GetPawn()
    Pawn.addPropToPlayer(Pawn, FName(itemname))
end

function ShowAchievementPopup(type, name, progressTarget, target)
    local GameMode = GetGameMode()
    if GameMode:IsValid() then
        local data = {
            ["name_4_0534A17545E554F4B68649B89423EB76"] = FName(name),
            ["image_20_0E252F6A4A1A655ECB0689A250A2EB57"] = nil,
            ["displayName_5_B400DAF547199398CDA692B5B2D6A599"] = FText(name),
            ["progressTarget_11_43B369D14FAD25B027282CAFFC2C3879"] = progressTarget,
            ["progress_8_16978C8F431AF43A377F3BA52100DF7A"] = target,
            ["desc_14_416AEAFF42C88E5C34C4DA9EC2040435"] = FText("This is a test achievement"),
            ["award_17_BF5ED5C148773720D6813BB3F829CC90"] = 0
        }
        --0 == achievement
        --1 == advancement
        GameMode:addAchievementPopup(data, type)
    end
end

local upgradeFullNames = {
    ["downloadSpd"] = {"upg_downloadSpd_3_BA98109842B6F6B10305FAAF5A3BBBF4", "upgrade_downloadSPeed"},
    ["processLvl"] = {"upg_processLvl_14_FA6136B44E749353CEF771AB0493F1A8", "upgrade_computerLvl"},
    ["processSpeed"] = {"upg_processSpeed_99_71FB42F64E4B845C653191A399690DB0", "upgrade_computerSPeed"},
    ["coordDrift"] = {"upg_coordDrift_95_A557469147F2A7F09452AFBD87AE4D20", "upgrade_sensorDrift"},
    ["coordPingSpeed"] = {"upg_coordPingSpeed_98_1F24EADD4D27B653A932A48987669FCB", "upgrade_pingSpeed"},
    ["coordMovementSpeed"] = {"upg_coordMovementSpeed_97_16B378034FDC97CB0628CBABB7674074", "upgrade_sensorSpeed"},
    ["coordRadarSpeed"] = {"upg_coordRadarSpeed_96_FBB3C8E541C23756B2F8A294D600F145", "upgrade_radarSpeed"},
    ["coordCooldown"] = {"upg_coordCooldown_77_DFB1A6684A3BDDFEF94C6689D37CD2E8", "upgrade_cooldown"},
    ["radarHist"] = {"upg_radarHist_93_3D85E50D4EA72B5864C6E0815C87CEB7", "upgrade_radarHist"},
    ["radar"] = {"upg_radar_speed_94_F1113DC149FA8DC9995F8EBAF2C7A452", "upgrade_radarSpd"},
    ["compTime"] = {"upg_compTime_69_7728FF794AD678EC9B481B840C119A20", "upgrade_breakerSpeed"},
    ["detecQual"] = {"upg_detecQual_54_0111E1654106C524D03278820389DDB3", "upgrade_deteQ"},
    ["scanner"] = {"upg_scanner_25_672849B8449E51A274C37DA92AD8B544", "upgrade_sensor"},
    ["scannerFr"] = {"upg_scannerFr_28_D57F12F148F3BE477D20A4A1494A8D62", "upgrade_sensor_fr"},
    -- Unused
    ["downloadFiltSize"] = {"upg_downloadFiltSize_100_4219D6DB44F558ABA055C7B749BDBCAD", nil},
    ["serverStability"] = {"upg_serverStability_13_4A619D224CE31D9B70EF93977E4491CB", nil},
    ["transformer"] = {"upg_transofrmer_66_A09469B64370DD7DC7F940B0FF8B2C13", nil},
}
function Upgrade(name)
    local fullNames = upgradeFullNames[name]
    if not fullNames then return false end

    local GameMode = GetGameMode()
    if not GameMode:IsValid() then return false end

    local SaveGameObject = GameMode.saveSlot
    if not SaveGameObject:IsValid() then return false end

    local current = SaveGameObject.upgrades[fullNames[1]]
    SaveGameObject.upgrades[fullNames[1]] = current + 1

    local laptop = FindFirstOf("ui_laptop_C")
    if laptop:IsValid() and fullNames[2] then
        laptop[fullNames[2]]:upd()
    end

    return true
end