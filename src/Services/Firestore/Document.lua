local Promise = require(script.Parent.Parent.Parent.Packages.Promise)

local Document = {}
local DOCUMENT_METATABLE = {}
DOCUMENT_METATABLE.__index = DOCUMENT_METATABLE

function Document.new(app, path)
    local self = {}

    self.App = app
    self.Path = path

    local pathParams = path:split("/")
    self.DocumentId = pathParams[#pathParams]

    self.Cache = {}
    self.LastRead = nil
    self.LastWrite = nil

    return setmetatable(self, DOCUMENT_METATABLE)
end

function DOCUMENT_METATABLE:Read()
    return Promise.new(function(resolve)
        local doc = self.App._http:GET("Firestore", self.App.ProjectId, self.Path):expect()

        -- TODO: Parse data into Lua table
        self.Cache.Data = doc.fields
        self.Cache.CreateTime = DateTime.fromIsoDate(doc.createTime)
        self.Cache.UpdateTime = DateTime.fromIsoDate(doc.updateTime)
        self.LastRead = DateTime.now()

        resolve(doc.fields)
    end)
end

function DOCUMENT_METATABLE:Write()
    
end

function DOCUMENT_METATABLE:Update()
    
end

function DOCUMENT_METATABLE:Delete()
    
end

return Document
