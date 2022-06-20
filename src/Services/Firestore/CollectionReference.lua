-- https://firebase.google.com/docs/reference/node/firebase.firestore.CollectionReference

local Promise = require(script.Parent.Parent.Parent.Parent.Promise)

local CollectionReference = {
    Cache = {},
}
local COLLECTION_REFERENCE_METATABLE = {}
function COLLECTION_REFERENCE_METATABLE:__index(i)
    if i == "Firestore" then
        return rawget(self, "_firestore")
    elseif i == "Id" then
        return select(-1, unpack(self.Path:split("/")))
    elseif i == "Parent" then
        local path = self.Path:split("/")
        table.remove(path)
        return self.Firestore:GetDoc(table.concat(path, "/"))
    elseif i == "Path" then
        return rawget(self, "_path")
    else
        return COLLECTION_REFERENCE_METATABLE[i] or error(i.. " is not a valid member of CollectionReference", 2)
    end
end
function COLLECTION_REFERENCE_METATABLE:__newindex(i)
    error(i.. " is not a valid member of CollectionReference or is unassignable", 2)
end

function CollectionReference.get(firestore, path)
    return setmetatable({
        _firestore = firestore,
        _path = path,
    }, COLLECTION_REFERENCE_METATABLE)
end

-- function COLLECTION_REFERENCE_METATABLE:GetCollectionGroup()

-- end

function COLLECTION_REFERENCE_METATABLE:AddDoc(data)
    return Promise.new(function(resolve)
        local doc = self.Firestore:GetDoc(self.Path)
        doc:Set(data):expect()
        resolve(doc)
    end)
end

function COLLECTION_REFERENCE_METATABLE:GetDoc(path)
    return self.Firestore:GetDoc(self.Path.. "/" .. path)
end

-- function COLLECTION_REFERENCE_METATABLE:RunQuery()

-- end

return CollectionReference
