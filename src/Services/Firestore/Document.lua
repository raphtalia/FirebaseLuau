local Promise = require(script.Parent.Parent.Parent.Packages.Promise)
local Parser = require(script.Parent.Parser)
local TableUtils = require(script.Parent.Parent.TableUtils)

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
        local doc = self.App._http:GET("Firestore", self.Path):expect()

        local parsedData
        if doc.fields then
            -- Empty documents do not have a fields property
            parsedData = Parser.toRbx(doc.fields)
            self.Cache.Data = parsedData
        end

        self.Cache.CreateTime = DateTime.fromIsoDate(doc.createTime)
        self.Cache.UpdateTime = DateTime.fromIsoDate(doc.updateTime)
        self.LastRead = DateTime.now()

        resolve(parsedData)
    end)
end

function DOCUMENT_METATABLE:Write(data)
    return Promise.new(function(resolve)
        local doc = self.App._http:PATCH("Firestore", self.Path, nil, Parser.toFirestore(data)):expect()

        self.Cache.CreateTime = DateTime.fromIsoDate(doc.createTime)
        self.Cache.UpdateTime = DateTime.fromIsoDate(doc.updateTime)
        self.LastWrite = DateTime.now()

        resolve(doc.fields and Parser.toRbx(doc.fields))
    end)
end

function DOCUMENT_METATABLE:Update(data)
    return Promise.new(function(resolve)
        local doc = self.App._http:PATCH("Firestore", self.Path, TableUtils.map(TableUtils.keys(data), function(value)
            return "updateMask.fieldPaths=".. value
        end), Parser.toFirestore(data)):expect()

        self.Cache.CreateTime = DateTime.fromIsoDate(doc.createTime)
        self.Cache.UpdateTime = DateTime.fromIsoDate(doc.updateTime)
        self.LastWrite = DateTime.now()

        resolve(doc.fields and Parser.toRbx(doc.fields))
    end)
end

function DOCUMENT_METATABLE:Delete()
    
end

return Document
