-- https://firebase.google.com/docs/reference/node/firebase
-- https://firebase.google.com/docs/reference/node/firebase.app.App

local Authentication = require(script.Services.Authentication)
local Firestore = require(script.Services.Firestore)
local Functions = require(script.Services.Functions)
local Realtime = require(script.Services.Realtime)
local Storage = require(script.Services.Storage)

local FirebaseApp = {}
local FIREBASE_APP_METATABLE = {}
function FIREBASE_APP_METATABLE:__index(i)
    if i == "Options" then
        return rawget(self, "_options")
    else
        return FIREBASE_APP_METATABLE[i] or error(i.. " is not a valid member of FirebaseApp", 2)
    end
end
function FIREBASE_APP_METATABLE:__newindex(i)
    error(i.. " is not a valid member of FirebaseApp or is unassignable", 2)
end

function FirebaseApp.initializeApp(options)
    return setmetatable({
        -- Auth = nil,
        -- Firestore = nil,
        -- Functions = nil,
        -- Realtime = nil,
        -- Storage = nil,

        _options = {
            ApiKey = options.ApiKey,
            ProjectId = options.ProjectId,
            -- AppId = options.AppId,
            -- AuthDomain = options.AuthDomain or ("%s.firebaseapp.com"):format(options.ProjectId),
            -- DatabaseURL = options.DatabaseURL or ("https://%s.firebaseio.com"):format(options.ProjectId),
            -- StorageBucket = options.StorageBucket or ("%s.appspot.com"):format(options.ProjectId),
        },
    }, FIREBASE_APP_METATABLE)
end

function FIREBASE_APP_METATABLE:GetAuth()
    local auth = rawget(self, "Auth")
    if not auth then
        auth = Authentication(self)
        rawset(self, "Auth", auth)
    end

    return auth
end

function FIREBASE_APP_METATABLE:GetFirestore()
    local firestore = rawget(self, "Firestore")
    if not firestore then
        firestore = Firestore(self)
        rawset(self, "Firestore", firestore)
    end

    return firestore
end

function FIREBASE_APP_METATABLE:GetFunctions()
    local functions = rawget(self, "Functions")
    if not functions then
        functions = Functions(self)
        rawset(self, "Functions", functions)
    end

    return functions
end

function FIREBASE_APP_METATABLE:GetRealtime()
    local realtime = rawget(self, "Realtime")
    if not realtime then
        realtime = Realtime(self)
        rawset(self, "Realtime", realtime)
    end

    return realtime
end

function FIREBASE_APP_METATABLE:GetStorage()
    local storage = rawget(self, "Storage")
    if not storage then
        storage = Storage(self)
        rawset(self, "Storage", storage)
    end

    return storage
end

return FirebaseApp
