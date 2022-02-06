local Document = require(script.Parent.Document)
local DocumentList = require(script.DocumentList)

--[=[
    @class CollectionReference
    Reference to a Firestore collection.
]=]
local Collection = {}
local COLLECTION_METATABLE = {}
COLLECTION_METATABLE.__index = COLLECTION_METATABLE

--[=[
    @within CollectionReference
    @private
    Creates a `CollectionReference` object tied to a path.

    @param app FirebaseApp
    @param path string
    @return CollectionReference
]=]
function Collection.new(app, path)
    local self = {}

    --[=[
        @within CollectionReference
        @prop App FirebaseApp
        The `FirebaseApp` object tied to this collection.
    ]=]
    self.App = app
    --[=[
        @within CollectionReference
        @prop Path string
        The path of this collection.
    ]=]
    self.Path = path

    return setmetatable(self, COLLECTION_METATABLE)
end

--[=[
    @within CollectionReference
    Returns a document reference.

    @method GetDoc
    @param path string
    @return DocumentReference
]=]
function COLLECTION_METATABLE:GetDoc(path)
    return Document.new(self.App, self.Path .. "/" .. path)
end

--[=[
    @within CollectionReference
    Returns a `DocumentList` used to iterate over documents in the collection.

    @method GetDocs
    @param pageSize number
    @return Promise<DocumentList>
]=]
function COLLECTION_METATABLE:GetDocs(pageSize)
    return DocumentList.new(self.App, self.Path, pageSize)
end

--[=[
    @within CollectionReference
    Returns a document reference.

    @method Delete
    @return Promise<void>
]=]
function COLLECTION_METATABLE:Delete()
    
end

return Collection
