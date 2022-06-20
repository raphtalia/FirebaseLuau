-- https://firebase.google.com/docs/reference/node/firebase.firestore.Firestore

local CollectionReference = require(script.CollectionReference)
local DocumentReference = require(script.DocumentReference)

local FIRESTORE_METATABLE = {}
function FIRESTORE_METATABLE:__index(i)
    if i == "App" then
        return rawget(self, "_app")
    else
        return FIRESTORE_METATABLE[i] or error(i.. " is not a valid member of Firestore", 2)
    end
end
function FIRESTORE_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Firestore or is unassignable", 2)
end

-- function FIRESTORE_METATABLE:ConnectEmulator()

-- end

-- function FIRESTORE_METATABLE:DisconnectEmulator()

-- end

function FIRESTORE_METATABLE:GetCollection(path)
    local cache = rawget(self, "CachedCollections")
    local collection = cache[path]

    if not collection then
        collection = CollectionReference.new(self, path)
        cache[path] = collection
    end

    return collection
end

-- function FIRESTORE_METATABLE:GetCollectionGroup()

-- end

function FIRESTORE_METATABLE:GetDoc(path)
    local cache = rawget(self, "CachedDocs")
    local doc = cache[path]

    if not doc then
        doc = DocumentReference.new(self, path)
        cache[path] = doc
    end

    return doc
end

-- function FIRESTORE_METATABLE:RunQuery()

-- end

return function(app)
    return setmetatable({
        CachedCollections = {},
        CachedDocs = {},
        _app = app,
    }, FIRESTORE_METATABLE)
end
