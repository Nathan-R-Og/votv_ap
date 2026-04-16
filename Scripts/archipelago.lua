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

-- Goal = nil
local item_list = {}

function SendItemsHint()
    local item_count = #item_list - GetRecievedItems()
    if item_count > 0 then
        local item = item_list[GetRecievedItems()+1]
        local ApItemName = GetAPItemNameFromId(item.item)
        AddHint("You have " .. tostring(item_count) .. " unclaimed item(s).\nNext item is " .. ApItemName .. "\nPress F9 to claim.", 1)
    else
        AddHint("You have recieved all items. Yay!", 3)
    end
end

function GetNextItem()
    local i = GetRecievedItems()
    if i < #item_list then
        local item = item_list[i+1]
        if item.index >= i then
            local ApItemName = GetAPItemNameFromId(item.item)
            print(ApItemName)
            AddHint(ApItemName .. " from " .. ap:get_player_alias(item.player), 0)
            OnItemReceived(ApItemName)
            SetRecievedItems(item.index+1)
            SendItemsHint()
        end
    end
end

function connect(server, slot, password)
    function on_socket_connected()
        AddHint("Socket connected", 0)
    end

    function on_socket_error(msg)
        AddHint("Socket error: " .. msg, 2)
    end

    function on_socket_disconnected()
        AddHint("Socket disconnected", 2)
    end

    function on_room_info()
        AddHint("Room info", 0)
        ap:ConnectSlot(slot, password, items_handling, {"Lua-APClientPP"}, client_version)
    end

    function on_slot_connected(slot_data)
        AddHint("Slot connected", 0)
        ap:ConnectUpdate(nil, {"Lua-APClientPP"})
        -- Goal = slot_data["Goal"]
    end

    function on_slot_refused(reasons)
        AddHint("Slot refused: " .. table.concat(reasons, ", "), 2)
    end

    function on_items_received(received_items)
        print("Items received: " .. #received_items)
        for _, item in ipairs(received_items) do table.insert(item_list, item) end
        print("Total items received: " .. #item_list)
        SendItemsHint()
    end

    function on_location_info(items)
        print("Locations scouted:")
        for _, item in ipairs(items) do
            if ScoutedLocations[item.location]==nil then
                print("placing item "..ap:get_item_name(item.item,ap:get_player_game(item.player)).." in location"..item.location)
                print("apnamelength "..#APNameToChestID)
                local APLocationName = APLocationIdToName[item.location]
                if APLocationName == nil then
                    print("we sajdklajskl")
                end
                ScoutedLocations[chestID] = {["ItemName"] = ap:get_item_name(item.item,ap:get_player_game(item.player)), ["PlayerName"] = ap:get_player_alias(item.player)}
            end
        end
    end

    function on_location_checked(locations)
        print("calling location checked")
        print("Locations checked:" .. table.concat(locations, ", "))
        print("Checked locations: " .. table.concat(ap.checked_locations, ", "))
        for _, LocationID in ipairs(locations) do
            CheckedLocations[LocationID] = true
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

    LoopAsync(500, function()
        if ap == nil then return true end
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
    return ap:get_location_name(locationName, nil)
end

function GetAPItemIdFromName(itemName)
    if (ap == nil) then return nil end
    return ap:get_item_id(itemName)
end

function GetAPItemNameFromId(itemId)
    if (ap == nil) then return nil end
    return ap:get_item_name(itemId, nil)
end

function GetAPLocationsToCheck()
    return ap.CheckedLocations
end

function GetAPMissingLocations()
    return ap.missing_locations
end

function ScoutLocations(ScoutLocations)
    if #ScoutLocations > 0 then
        ap:LocationScouts(ScoutLocations, 0)
    end
end

function FillScoutedLocations()

end

function SendLocation(location_name)
    local id = GetAPLocationIDfromName(location_name)
    print("Trying to send " .. location_name .. "(" .. id .. ")")
    if id ~= nil then
        add_unique(LocationsToCheck, id)
    end
end
