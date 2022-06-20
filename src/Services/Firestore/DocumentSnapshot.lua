-- https://firebase.google.com/docs/reference/node/firebase.firestore.DocumentSnapshot

local TableUtils = require(script.Parent.Parent.Parent.Util.TableUtils)

local DocumentSnapshot = {}
local DOCUMENT_SNAPSHOT_METATABLE = {}
function DOCUMENT_SNAPSHOT_METATABLE:__index(i)
    if i == "Exists" then
        return not not rawget(self, "Snapshot")
    elseif i == "Metadata" then
        return rawget(self, "_metadata")
    elseif i == "Ref" then
        return rawget(self, "_ref")
    elseif i == "Data" then
        return TableUtils.deepCopy(rawget(self, "_data"))
    else
        return DOCUMENT_SNAPSHOT_METATABLE[i] or error(i.. " is not a valid member of DocumentSnapshot", 2)
    end
end
function DOCUMENT_SNAPSHOT_METATABLE:__newindex(i)
    error(i.. " is not a valid member of DocumentSnapshot or is unassignable", 2)
end

function DocumentSnapshot.new(ref, metadata, data)
    metadata = metadata or {}

    return setmetatable({
        _metadata = table.freeze({
            FromCache = not not metadata.FromCache,
            Timestamp = DateTime.fromIsoDate(metadata.Timestamp or tick()),
        }),
        _ref = ref,
        _data = if data then table.freeze(TableUtils.deepCopy(data)) else nil,
    }, DOCUMENT_SNAPSHOT_METATABLE)
end

return DocumentSnapshot
