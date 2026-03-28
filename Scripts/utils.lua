function array_contains(arr, val)
    for index, value in ipairs(arr) do
        if value == val then
            return true -- Value found
        end
    end
    return false -- Value not found
end

function add_unique(arr, val)
    if not array_contains(arr, val) then
        table.insert(arr, val)
    end
end

function table_invert(t)
    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
end

function extract_keys(original_table)
    local keys_only_table = {}
    for k, v in pairs(original_table) do -- Iterate over all key-value pairs
        table.insert(keys_only_table, k) -- Insert the key 'k' into the new table as a value
    end
    return keys_only_table
end