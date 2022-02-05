local TableUtils = {}

function TableUtils.keys(tab)
    local keys = {}

    for key in pairs(tab) do
        table.insert(keys, key)
    end

    return keys
end

function TableUtils.values(tab)
    local values = {}

    for _,value in pairs(tab) do
        table.insert(values, value)
    end

    return values
end

function TableUtils.isArray(tab)
    for key in pairs(tab) do
        if typeof(key) ~= "number" then
            return false
        end
    end

    return true
end

function TableUtils.isEmpty(tab)
    for _ in pairs(tab) do
        return false
    end

    return true
end

function TableUtils.map(tab, callback)
    local newArray = {}

    for key, value in ipairs(tab) do
        table.insert(newArray, callback(value, key, tab))
    end

    return newArray
end

return TableUtils
