---@diagnostic disable: lowercase-global
---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field


--require "ItemManager"
--require "StaticObjectGetters"
--require "DatabaseInfo"
--require "ArchipelagoLists"

local AP = require("lua-apclientpp")

require("item_map")
require("locations")
require("utils")

-- global to this mod
local game_name = "Voices of the Void"
local items_handling = AP.Permission  -- full remote
local client_version = {0, 6, 7}  -- optional, defaults to lib version
local message_format = AP.RenderFormat.TEXT
---@type APClient
ap = nil
local LocationsToCheck = {}
local CheckedLocations = {}
local LocationsToScout = {}
ScoutedLocations = {}

options = nil
completed = false
locked_recipes = {}
item_list = {}

function connect(server, slot, password)
    function on_socket_connected()
        AddHint("Socket connected", HintType.Info)
    end

    function on_socket_error(msg)
        AddHint("Socket error: " .. msg, HintType.Error)
    end

    function on_socket_disconnected()
        AddHint("Socket disconnected", HintType.Error)
        item_list = {}
    end

    function on_room_info()
        AddHint("Room info", HintType.Info)
        ap:ConnectSlot(slot, password, items_handling, {"Lua-APClientPP"}, client_version)
    end

    function on_slot_connected(slot_data)
        AddHint("Slot connected", HintType.Info)
        ap:ConnectUpdate(nil, {"Lua-APClientPP"})
        print("Locations checked: " .. table.concat(ap.checked_locations, ", "))
        options = slot_data.options

        if options.UpgradesAsItems >= 1 then
            local laptop = FindFirstOf("ui_laptop_C")
            if laptop == nil then
                AddHint("Couldn't disable upgrade controls!", HintType.Error)
            else
                local upgrades = {"downloadSpd", "processLvl", "processSpeed", "coordDrift", "coordPingSpeed", "coordMovementSpeed", "coordCooldown", "detecQual"}
                if options.UpgradesAsItems == 2 then
                    upgrades = table.pack(table.unpack(upgrades), "coordRadarSpeed", "radarHist", "radar", "compTime", "scanner", "scannerFr")
                end
                print("Disabling controls of " .. table.concat(upgrades, ", "))
                for _, name in ipairs(upgrades) do
                    local compName = upgradeFullNames[name][2]
                    laptop[compName].button_upgDown:SetVisibility(ESlateVisibility.Hidden)
                    laptop[compName].button_upgUp:SetVisibility(ESlateVisibility.Hidden)
                end
            end
        end

        if options.ShopItems then
            local storeDatatable = StaticFindObject("/Game/main/datatables/list_store.list_store")
            local propDatatable = StaticFindObject("/Game/main/datatables/list_prop.list_prop")
            if storeDatatable:IsValid() and propDatatable:IsValid() then
                local propAsItems = {}
                propDatatable:ForEach(function(name, data)
                    for _, dname in ipairs(slot_data.ItemNames) do
                        if string.lower(data.displayName_8_FE83ADBF40AA162942FCE589F5806DD2) == string.lower(dname) then
                            table.insert(propAsItems, name)
                        end
                    end
                end)
                storeDatatable:ForEach(function(name, data)
                    if array_contains(propAsItems, data.name_14_B3814BBE478D1FA0AB005BB6386C1541) then
                        print("Removing " .. name .. " from shop")
                        storeDatatable:RemoveRow(name)
                    end
                end)
            end
        end

        if options.ScrapRecipesAsItems then
            local datatable = StaticFindObject("/Game/main/datatables/list_crafting.list_crafting")
            local fNameToItemName = {
                ["scrap_Plastic"] = "Plastic Scrap Recipe",
                ["scrap_Metal"] = "Metal Scrap Recipe",
                ["scrap_elec"] = "Electronic Scrap Recipe",
                ["scrap_glass"] = "Glass Scrap Recipe",
                ["scrap_rubber"] = "Rubber Scrap Recipe",
                ["scrap_paper"] = "Paper Scrap Recipe",
                ["scrap_Wood"] = "Wood Scrap Recipe",
                ["scrap_rubble"] = "Rubble Recipe",
            }
            if datatable:IsValid() then
                datatable:ForEach(function(name, data)
                    local fname = data.result_6_893C01EE4438C4AAF7E917954BB7F448
                    local item = fNameToItemName[fname]
                    if fname then
                        datatable:RemoveRow(name)
                        if locked_recipes[item] == nil then locked_recipes[item] = {} end
                        table.insert(locked_recipes[item], {name, data})
                    end
                end)
            else
                AddHint("Failed to lock recipes", HintType.Error)
            end
        end

        local SaveGameObject = GetSaveSlot()
        if SaveGameObject ~= nil then
            if options.FunnySetting and not SaveGameObject.localGameRules.funnySetting_29_3DBB4B5041357E51DA0DFBAD9368E881 then
                AddHint("The AP includes funny items, but the setting is not enabled!", HintType.Error)
            end
        end
    end

    function on_slot_refused(reasons)
        AddHint("Slot refused: " .. table.concat(reasons, ", "), HintType.Error)
    end

    function on_items_received(received_items)
        print("Items received: " .. #received_items)
        local datatable = StaticFindObject("/Game/main/datatables/list_crafting.list_crafting")
        for _, item in ipairs(received_items) do
            table.insert(item_list, item)

            local recipes = locked_recipes[item]
            if recipes ~= nil then
                if datatable:IsValid() then
                    print("Unlocking " .. item)
                    for _, recipe in ipairs(recipes) do
                        datatable:AddRow(table.unpack(recipe))
                    end
                else
                    AddHint("Failed to unlock " .. item, HintType.Error)
                end
            end
        end
        print("Total items received: " .. #item_list)
        CheckAutoItem(GetRecievedItems())
    end

    function on_location_info(infos)
        print("Locations scouted:")
        for _, info in ipairs(infos) do
            if ScoutedLocations[info.location] == nil then
                local item = ap:get_item_name(info.item, ap:get_player_game(info.player))
                local location = GetAPNamefromLocationID(info.location)
                print("scouted item " .. item .. " in location " .. location)
                if location == nil then
                    print("we sajdklajskl")
                else
                    local player = ap:get_player_alias(info.player)
                    ScoutedLocations[info.location] = { ["item"] = item, ["player"] = player }
                    if array_contains(LocationsToCheck, info.location) then
                        ShowAchievementPopup(1, item .. " for " .. player, 1, 1)
                    end
                end
            end
        end
    end

    function on_location_checked(locations)
        print("Locations checked:" .. table.concat(locations, ", "))
        print("Checked locations: " .. table.concat(ap.checked_locations, ", "))
        for _, LocationID in ipairs(locations) do
            CheckedLocations[LocationID] = true
            table.insert(LocationsToCheck, LocationID)
        end
    end

    function on_data_package_changed(data_package)
        print("Data package changed:")
        print(table.concat(data_package, ", "))
    end

    function on_print(msg)
        AddHint(msg, HintType.Thought)
    end

    function on_print_json(msg, extra)
        print(ap:render_json(msg, message_format))
        for key, value in pairs(extra) do
            -- print("  " .. key .. ": " .. tostring(value))
        end
    end

    function on_bounced(bounce)
        print("Bounced:")
        print(bounce)
    end

    function on_retrieved(map, keys, extra)
        print("Retrieved:")
        -- since lua tables won't contain nil values, we can use keys array
        for _, key in ipairs(keys) do
            print("  " .. key .. ": " .. tostring(map[key]))
        end
        -- extra will include extra fields from Get
        print("Extra:")
        for key, value in pairs(extra) do
            print("  " .. key .. ": " .. tostring(value))
        end
        -- both keys and extra are optional
    end

    function on_set_reply(message)
        print("Set Reply:")
        for key, value in pairs(message) do
            print("  " .. key .. ": " .. tostring(value))
            if key == "value" and type(value) == "table" then
                for subkey, subvalue in pairs(value) do
                    print("    " .. subkey .. ": " .. tostring(subvalue))
                end
            end
        end
    end

    local uuid = ""
    ap = AP(uuid, game_name, server)
    AddHint("Connecting to " .. server .. " ...", HintType.Warning)
    ap:set_socket_connected_handler(on_socket_connected)
    ap:set_socket_error_handler(on_socket_error)
    ap:set_socket_disconnected_handler(on_socket_disconnected)
    ap:set_room_info_handler(on_room_info)
    ap:set_slot_connected_handler(on_slot_connected)
    ap:set_slot_refused_handler(on_slot_refused)
    ap:set_items_received_handler(on_items_received)
    ap:set_location_info_handler(on_location_info)
    ap:set_location_checked_handler(on_location_checked)
    ap:set_data_package_changed_handler(on_data_package_changed)
    ap:set_print_handler(on_print)
    ap:set_print_json_handler(on_print_json)
    ap:set_bounced_handler(on_bounced)
    ap:set_retrieved_handler(on_retrieved)
    ap:set_set_reply_handler(on_set_reply)
end

function connectToAp(host, slot, password)
    ExecuteAsync(function()
        connect(host, slot, "")
    end)

    LoopAsync(200, function()
        if ap == nil then return false end
        xpcall(function()
            ap:poll()
            -- AddHint("Polling!", HintType.Info)
            if #LocationsToCheck > 0 and #LocationsToCheck > #CheckedLocations then
                local only_new_ones = {}
                local i = #CheckedLocations
                while i < #LocationsToCheck do
                    table.insert(only_new_ones, LocationsToCheck[i+1])
                    i = i + 1
                end
                ap:LocationChecks(only_new_ones)
                for _, APID in ipairs(LocationsToCheck) do
                    CheckedLocations[APID] = true
                end
            end
        end, function()
            ap:disconnect()
        end)
        return false
    end)
end

function disconnect()
    CheckedLocations = {}
    item_list = {}
    ap = nil
    collectgarbage("collect")
    AddHint("Successfully Disconnected.\nHave a good day!", HintType.Warning)
end

function IsLocationChecked(locationID)
    return CheckedLocations[locationID] ~= nil
end

function GetAPLocationIDfromName(locationName)
    if ap == nil then return nil end
    return ap:get_location_id(locationName)
end

function GetAPNamefromLocationID(locationID)
    if ap == nil then return nil end
    return ap:get_location_name(locationID, nil)
end

function GetAPItemIdFromName(itemName)
    if ap == nil then return nil end
    return ap:get_item_id(itemName)
end

function GetAPItemNameFromId(itemId)
    if ap == nil then return nil end
    return ap:get_item_name(itemId, nil)
end

function ScoutLocationByName(location_name)
    if ap == nil then return end
    local id = GetAPLocationIDfromName(location_name)
    ScoutLocation(id)
end

function ScoutLocation(id)
    if ap == nil then return end
    if id == nil or id < 0 then return end
    if LocationsToScout[id] ~= nil or not array_contains(ap.missing_locations, id) then return end
    print("Scouting location " .. tostring(id))
    ap:LocationScouts({ id }, 0)
    LocationsToScout[id] = true
end

function SendLocation(location_name)
    print("Looking for " .. location_name)
    local id = GetAPLocationIDfromName(location_name)
    return SendLocationId(id)
end

function SendNextLocation(radical)
    print("Looking for next " .. radical)
    local id
    local current = 1
    repeat
        id = GetAPLocationIDfromName(radical .. " " .. current)
        if id == nil or id < 0 then return false end
        current = current + 1
    until not array_contains(LocationsToCheck, id)
    return SendLocationId(id)
end

function SendLocationId(id)
    if id == nil or id < 0 then return false end
    if array_contains(LocationsToCheck, id) or not array_contains(ap.missing_locations, id) then return false end
    print("Trying to send location " .. tostring(id))
    add_unique(LocationsToCheck, id)
    local scoutInfo = ScoutedLocations[id]
    if scoutInfo ~= nil then
        ShowAchievementPopup(1, scoutInfo.item .. " for " .. scoutInfo.player, 1, 1)
    else
        ScoutLocation(id)
    end
    return true
end
