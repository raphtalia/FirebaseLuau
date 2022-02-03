local Collection = {}
local COLLECTION_METATABLE = {}
COLLECTION_METATABLE.__index = COLLECTION_METATABLE

function Collection.new(app, path)
    local self = {}

    self.App = app
    self.Path = path

    return setmetatable(self, COLLECTION_METATABLE)
end

function COLLECTION_METATABLE:GetDoc()
    
end

function COLLECTION_METATABLE:GetDocs()
    
end

function COLLECTION_METATABLE:Delete()
    
end

return Collection
