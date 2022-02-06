local Promise = require(script.Parent.Parent.Parent.Packages.Promise)
local Parser = require(script.Parent.Parser)
local TableUtils = require(script.Parent.Parent.TableUtils)

--[=[
    @class DocumentReference
    Reference to a Firestore document.
]=]
local Document = {}
local DOCUMENT_METATABLE = {}
DOCUMENT_METATABLE.__index = DOCUMENT_METATABLE

--[=[
    @within DocumentReference
    @private
    Creates a `DocumentReference` object tied to a path.

    @param app FirebaseApp
    @param path string
    @return DocumentReference
]=]
function Document.new(app, path)
    local self = {}

    --[=[
        @within DocumentReference
        @prop App FirebaseApp
        The `FirebaseApp` object tied to this document.
    ]=]
    self.App = app
    --[=[
        @within DocumentReference
        @prop Cache { CreateTime: DateTime, UpdateTime: DateTime, Data: { [string]: any } }
        Data from the previous read operation.
    ]=]
    self.Cache = {}
    --[=[
        @within DocumentReference
        @prop LastWrite DateTime
        The last time the document was written to using this reference.
    ]=]
    self.LastWrite = nil
    --[=[
        @within DocumentReference
        @prop LastRead DateTime
        The last time the document was read from using this reference.
    ]=]
    self.LastRead = nil
    --[=[
        @within DocumentReference
        @prop Path string
        The path of this document.
    ]=]
    self.Path = path

    --[=[
        @within DocumentReference
        @prop DocumentId string
        The ID of this document.
    ]=]
    local pathParams = self.Path:split("/")
    self.DocumentId = pathParams[#pathParams]

    return setmetatable(self, DOCUMENT_METATABLE)
end

--[=[
    @within DocumentReference
    @private
    Creates a `DocumentReference` object tied to a document returned from the Firestore API.

    @param app FirebaseApp
    @param doc { name: string, fields = {[fieldName: string]: any }, updateTime = timestamp, createTime = timestamp }
    @return DocumentReference
]=]
function Document.fromDoc(app, doc)
    local self = {}

    self.App = app
    self.Cache = {}
    self.LastWrite = nil
    self.Path = doc.name
    self.Cache.Data = doc.fields
    self.LastRead = DateTime.now()

    local pathParams = self.Path:split("/")
    self.DocumentId = pathParams[#pathParams]

    return setmetatable(self, DOCUMENT_METATABLE)
end

--[=[
    @within DocumentReference
    Reads the document.

    @method Read
    @return Promise<{[fieldName: string]: any }>
]=]
function DOCUMENT_METATABLE:Read()
    return Promise.new(function(resolve)
        local status, doc = self.App._http:GET("Firestore", self.Path):await()

        if status and doc then
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
        else
            resolve(nil) -- Document does not exist
        end
    end)
end

--[=[
    @within DocumentReference
    Writes to the document. Returns full document currently on the Firestore server. The return is not very useful in
    this case as this method overwrites the data on the server.

    @method Write
    @param data {[fieldName: string]: any }
    @return Promise<{[fieldName: string]: any }>
]=]
function DOCUMENT_METATABLE:Write(data)
    return Promise.new(function(resolve)
        local doc = self.App._http:PATCH("Firestore", self.Path, nil, Parser.toFirestore(data)):expect()

        self.Cache.CreateTime = DateTime.fromIsoDate(doc.createTime)
        self.Cache.UpdateTime = DateTime.fromIsoDate(doc.updateTime)
        self.LastWrite = DateTime.now()

        resolve(doc.fields and Parser.toRbx(doc.fields))
    end)
end

--[=[
    @within DocumentReference
    Writes certain fields of data to the document. Returns the full document currently on the Firestore server.

    @method Update
    @param data {[fieldName: string]: any }
    @return Promise<{[fieldName: string]: any }>
]=]
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

--[=[
    @within DocumentReference
    Deletes the document.

    @method Delete
    @return Promise<void>
]=]
function DOCUMENT_METATABLE:Delete()
    return Promise.new(function(resolve)
        self.App._http:DELETE("Firestore", self.Path):expect()

        resolve()
    end)
end

return Document
