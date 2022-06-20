local TableUtils = {}

function TableUtils.keys(tab)
    local keys = {}

    for key in pairs(tab) do
        table.insert(keys, key)
    end

    return keys
end

-- function TableUtils.values(tab)
--     local values = {}

--     for _,value in pairs(tab) do
--         table.insert(values, value)
--     end

--     return values
-- end

function TableUtils.isEmpty(tab)
    for _ in pairs(tab) do
        return false
    end

    return true
end

function TableUtils.map(tab, callback)
    local newTab = {}

    for key, value in ipairs(tab) do
        table.insert(newTab, callback(value, key, tab))
    end

    return newTab
end

function TableUtils.deepCopy(tab)
    local newTab = {}

    for key, value in pairs(tab) do
        newTab[key] = if type(value) == "table" then TableUtils.deepCopy(value) else value
    end

    return newTab
end

return TableUtils
