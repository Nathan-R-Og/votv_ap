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
local game_name = "Manual_Voices of the Void_Le Codex"
local items_handling = 7  -- full remote
local client_version = {0, 6, 7}  -- optional, defaults to lib version
local message_format = AP.RenderFormat.TEXT
---@type APClient
ap = nil
local LocationsToCheck = {}
local CheckedLocations = {}
local LocationsToScout = {}
local ScoutedLocations = {}

-- Goal = nil
item_list = {}

function connect(server, slot, password)
    function on_socket_connected()
        AddHint("Socket connected", 0)
    end

    function on_socket_error(msg)
        AddHint("Socket error: " .. msg, 2)
    end

    function on_socket_disconnected()
        AddHint("Socket disconnected", 2)
        item_list = {}
    end

    function on_room_info()
        AddHint("Room info", 0)
        ap:ConnectSlot(slot, password, items_handling, {"Lua-APClientPP"}, client_version)
    end

    function on_slot_connected(slot_data)
        AddHint("Slot connected", 0)
        ap:ConnectUpdate(nil, {"Lua-APClientPP"})
        print("Locations checked: " .. table.concat(ap.checked_locations, ", "))
        print("Goal: " .. slot_data["goal"])
    end

    function on_slot_refused(reasons)
        AddHint("Slot refused: " .. table.concat(reasons, ", "), 2)
    end

    function on_items_received(received_items)
        print("Items received: " .. #received_items)
        for _, item in ipairs(received_items) do table.insert(item_list, item) end
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
                    ScoutedLocations[location] = { ["item"] = item, ["player"] = player }
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
        AddHint(msg, 3)
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
    AddHint("Connecting to " .. server .. " ...", 1)
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
            -- AddHint("Polling!", 0)
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
    ap = nil
    collectgarbage("collect")
    AddHint("Successfully Disconnected.\nHave a good day!", 1)
end

function IsLocationChecked(locationID)
    return CheckedLocations[locationID] ~= nil
end

function GetAPLocationIDfromName(locationName)
    if (ap == nil) then return nil end
    return ap:get_location_id(locationName)
end

function GetAPNamefromLocationID(locationID)
    if (ap == nil) then return nil end
    return ap:get_location_name(locationID, nil)
end

function GetAPItemIdFromName(itemName)
    if (ap == nil) then return nil end
    return ap:get_item_id(itemName)
end

function GetAPItemNameFromId(itemId)
    if (ap == nil) then return nil end
    return ap:get_item_name(itemId, nil)
end

function ScoutLocation(location_name)
    if LocationsToScout[location_name] == nil then
        ap:LocationScouts({ location_name }, 0)
    end
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
        if id == nil then return false end
        current = current + 1
    until not array_contains(LocationChecks, id)
    return SendLocationId(id)
end

function SendLocationId(id)
    if id == nil or array_contains(LocationsToCheck, id) then return false end
    print("Trying to send " .. location_name .. "(" .. tostring(id) .. ")")
    add_unique(LocationsToCheck, id)
    local scoutInfo = ScoutedLocations[id]
    if scoutInfo then
        ShowAchievementPopup(1, scoutInfo.item .. " for " .. scoutInfo.player, 1, 1)
    else
        ScoutLocation(id)
    end
    return true
end
