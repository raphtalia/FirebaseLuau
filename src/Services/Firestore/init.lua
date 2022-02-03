local Collection = require(script.Collection)
local Document = require(script.Document)

local Firestore = {}
local FIRESTORE_METATABLE = {}
FIRESTORE_METATABLE.__index = FIRESTORE_METATABLE

function Firestore.new(app)
    local self = {}

    self.App = app

    return setmetatable(self, FIRESTORE_METATABLE)
end

function FIRESTORE_METATABLE:GetCollection(path)
    return Collection.new(self.App, path)
end

function FIRESTORE_METATABLE:GetDoc(path)
    return Document.new(self.App, path)
end

return Firestore
