local HttpService = game:GetService("HttpService")

local Parser = {}

local RBX_TO_FIRESTORE_TYPE_MAP = {
    string = "stringValue";
    number = "integerValue";
}

local FIRESTORE_TO_RBX_TYPE_MAP = {
    stringValue = "string";
    integerValue = "number";
    booleanValue = "boolean";
}

function Parser.toRbx(data)
    data = (type(data) == "table" and data or HttpService:JSONDecode(data))
    local function format(table)
        local newData = {}
        for k,v in pairs(table) do
            if v.integerValue then
                newData[k] = tonumber(v.integerValue)
            elseif v.stringValue then
                newData[k] = v.stringValue
            elseif v.booleanValue ~= nil then
                newData[k] = v.booleanValue
            elseif v.timestampValue then
                newData[k] = DateTime.fromIsoDate(v.timestampValue)
            elseif v.arrayValue then
                newData[k] = format(v.arrayValue.values)
            elseif v.mapValue then
                newData[k] = format(v.mapValue.fields)
            end
        end

        return newData
    end

    data = format(data)
    return data
end

function Parser.toFirestore(data)
    local function getTableType(table)
        if next(table) == nil then return "Empty" end
        local isArray = true
        local isDictionary = true
        for k, _ in next, table do
            if typeof(k) == "number" and k%1 == 0 and k > 0 then
                isDictionary = false
            else
                isArray = false
            end
        end
        if isArray then
            return "Array"
        elseif isDictionary then
            return "Dictionary"
        else
            return "Mixed"
        end
    end

    local function format(table, newData)
        newData = newData or {fields = {}}
        local fields = newData.fields or newData.values

        for k,v in pairs(table) do
            if type(v) == "number" then
                fields[k] = {integerValue = v}
            elseif type(v) == "string" then
                fields[k] = {stringValue = v}
            elseif type(v) == "boolean" then
                fields[k] = {booleanValue = v}
            elseif typeof(v) == "DateTime" then
                fields[k] = {timestampValue = v:ToIsoDate()}
            elseif type(v) == "table" then
                local typeTable = getTableType(v)
                if typeTable == "Array" or typeTable == "Empty" then
                    fields[k] = {arrayValue = format(v, {values = {}})}
                else
                    fields[k] = {mapValue = format(v)}
                end
            end
        end

        return newData
    end

    return format(data)
end

return Parser
