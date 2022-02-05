local Document = require(script.Parent.Document)
local DocumentList = require(script.DocumentList)

local Collection = {}
local COLLECTION_METATABLE = {}
COLLECTION_METATABLE.__index = COLLECTION_METATABLE

function Collection.new(app, path)
    local self = {}

    self.App = app
    self.Path = path

    return setmetatable(self, COLLECTION_METATABLE)
end

function COLLECTION_METATABLE:GetDoc(path)
    return Document.new(self.App, self.Path .. "/" .. path)
end

function COLLECTION_METATABLE:GetDocs(pageSize)
    return DocumentList.new(self.App, self.Path, pageSize)
end

function COLLECTION_METATABLE:Delete()
    
end

return Collection
