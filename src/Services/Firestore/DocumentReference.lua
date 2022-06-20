-- https://firebase.google.com/docs/reference/node/firebase.firestore.DocumentReference

local Promise = require(script.Parent.Parent.Parent.Parent.Promise)
local GoogleApis = require(script.Parent.Parent.Parent.Util.GoogleApis)
local TableUtils = require(script.Parent.Parent.Parent.Util.TableUtils)
local DocumentSnapshot = require(script.Parent.DocumentSnapshot)
local Parser = require(script.Parent.Parser)

local function makeSnapshot(ref, data)
    local snapshot

    if data then
        snapshot = DocumentSnapshot.new(
            ref,
            nil,
            if data.fields then Parser.toRbx(data.fields) else {}
        )
    else
        snapshot = DocumentSnapshot.new(ref)
    end

    return snapshot
end

local DocumentReference = {
    Cache = {},
}
local DOCUMENT_REFERENCE_METATABLE = {}
function DOCUMENT_REFERENCE_METATABLE:__index(i)
    if i == "Firestore" then
        return rawget(self, "_firestore")
    elseif i == "Id" then
        local path = self.Path:split("/")
        if #path % 2 == 0 then
            return select(-1, unpack(path))
        end
        -- Otherwise this doc has no ID yet
    elseif i == "Parent" then
        local path = self.Path:split("/")
        table.remove(path)
        return self.Firestore:GetCollection(table.concat(path, "/"))
    elseif i == "Path" then
        return rawget(self, "_path")
    elseif i == "LastSnapshot" then
        return rawget(self, "_lastSnapshot")
    elseif i == "LastRead" then
        local lastSnapshot = self.LastSnapshot
        if lastSnapshot then
            return lastSnapshot.Metadata.Timestamp
        end
        -- Otherwise was never read
    elseif i == "LastWrite" then
        return rawget(self, "_lastWrite")
    else
        return DOCUMENT_REFERENCE_METATABLE[i] or error(i.. " is not a valid member of DocumentReference", 2)
    end
end
function DOCUMENT_REFERENCE_METATABLE:__newindex(i)
    error(i.. " is not a valid member of DocumentReference or is unassignable", 2)
end

function DocumentReference.get(firestore, path)
    return setmetatable({
        _firestore = firestore,
        _path = path,
        -- _lastWrite = nil,
    }, DOCUMENT_REFERENCE_METATABLE)
end

function DOCUMENT_REFERENCE_METATABLE:GetCollection(path)
    return self.Firestore:GetCollection(path)
end

-- function DOCUMENT_REFERENCE_METATABLE:GetCollectionGroup()

-- end

function DOCUMENT_REFERENCE_METATABLE:Delete()
    return Promise.new(function(resolve, reject)
        local status, response = GoogleApis.delete({
            App = self.Firestore.App,
            Service = "Firestore",
            Path = "/".. self.Path,
            Headers = {
                Authorization = "Bearer ".. self.Firestore.App:GetAuth().CurrentUser.Token.IdToken,
            },
        }):await()

        if status then
            resolve()
        else
            reject(response)
        end
    end)
end

function DOCUMENT_REFERENCE_METATABLE:Get()
    return Promise.new(function(resolve, reject)
        local status, response = GoogleApis.get({
            App = self.Firestore.App,
            Service = "Firestore",
            Path = "/".. self.Path,
            Headers = {
                Authorization = "Bearer ".. self.Firestore.App:GetAuth().CurrentUser.Token.IdToken,
            },
        }):await()

        if status then
            local snapshot = makeSnapshot(self, response)
            rawset(self, "_lastSnapshot", snapshot)
            resolve(snapshot)
        else
            reject(response)
        end
    end)
end

function DOCUMENT_REFERENCE_METATABLE:Set(data)
    return Promise.new(function(resolve, reject)
        local status, response

        if self.Id then
            status, response = GoogleApis.patch({
                App = self.Firestore.App,
                Service = "Firestore",
                Path = "/".. self.Path,
                Headers = {
                    Authorization = "Bearer ".. self.Firestore.App:GetAuth().CurrentUser.Token.IdToken,
                },
                Body = Parser.toFirestore(data),
            }):await()
        else
            status, response = GoogleApis.post({
                App = self.Firestore.App,
                Service = "Firestore",
                Headers = {
                    Authorization = "Bearer ".. self.Firestore.App:GetAuth().CurrentUser.Token.IdToken,
                },
                Body = Parser.toFirestore(data),
            })
        end

        if status then
            local snapshot = makeSnapshot(self, response)
            rawset(self, "_lastSnapshot", snapshot)
            rawset(self, "_lastWrite", DateTime.now())
            if not self.Id then
                rawset(self, "_path", table.concat(response.name:split("/"), "/", 6))
            end
            resolve(snapshot)
        else
            reject(response)
        end
    end)
end

function DOCUMENT_REFERENCE_METATABLE:Update(data)
    return Promise.new(function(resolve, reject)
        local status, response = GoogleApis.patch({
            App = self.Firestore.App,
            Service = "Firestore",
            Path = "/".. self.Path,
            Params = TableUtils.map(TableUtils.keys(data), function(value)
                return "updateMask.fieldPaths=".. value
            end),
            Headers = {
                Authorization = "Bearer ".. self.Firestore.App:GetAuth().CurrentUser.Token.IdToken,
            },
            Body = Parser.toFirestore(data),
        }):await()

        if status then
            local snapshot = makeSnapshot(self, response)
            rawset(self, "_lastSnapshot", snapshot)
            rawset(self, "_lastWrite", DateTime.now())
            resolve(snapshot)
        else
            reject(response)
        end
    end)
end

-- function DOCUMENT_REFERENCE_METATABLE:RunQuery()

-- end

return DocumentReference
