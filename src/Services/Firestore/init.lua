local Collection = require(script.Collection)
local Document = require(script.Document)

--[=[
    @class Firestore
    Object tied to a FirebaseApp's Firestore service.
]=]
local Firestore = {}
local FIRESTORE_METATABLE = {}
FIRESTORE_METATABLE.__index = FIRESTORE_METATABLE

--[=[
    @within Firestore
    @private
    Creates a `Firestore` object tied to the given FirebaseApp.

    @param app FirebaseApp
    @return Firestore
]=]
function Firestore.new(app)
    local self = {}

    self.App = app

    return setmetatable(self, FIRESTORE_METATABLE)
end

--[=[
    @within Firestore
    Returns a collection reference.

    @method GetCollection
    @param path string
    @return CollectionReference
]=]
function FIRESTORE_METATABLE:GetCollection(path)
    return Collection.new(self.App, path)
end

--[=[
    @within Firestore
    Returns a document reference.

    @method GetDoc
    @param path string
    @return DocumentReference
]=]
function FIRESTORE_METATABLE:GetDoc(path)
    return Document.new(self.App, path)
end

return Firestore
