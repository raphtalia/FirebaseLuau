local Http = require(script.Http)
local Authentication = require(script.Services.Authentication)
local Firestore = require(script.Services.Firestore)

local FirebaseLuau = {}
local FIREBASELUAU_METATABLE = {}
FIREBASELUAU_METATABLE.__index = FIREBASELUAU_METATABLE

function FirebaseLuau.init(appParams)
    local self = {}

    self.ProjectId = appParams.ProjectId
    self.APIKey = appParams.APIKey

    self._http = Http.new(self)
    self._authentication = Authentication.new(self)
    self.Firestore = Firestore.new(self)

    local email = appParams.Email
    local password = appParams.Password

    if email and password then
        self._auth = self._authentication:SignInWithEmailAndPassword(email, password):expect()
    end

    return setmetatable(self, FIREBASELUAU_METATABLE)
end

return FirebaseLuau
