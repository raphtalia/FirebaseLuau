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
    self.Email = appParams.Email
    self.Password = appParams.Password

    self._http = Http.new(self)
    self._authentication = Authentication.new(self)
    self.Firestore = Firestore.new(self)

    if self.Email and self.Password then
        self._auth = self._authentication:SignInWithEmailAndPassword(self.Email, self.Password):expect()
    end

    return setmetatable(self, FIREBASELUAU_METATABLE)
end

return FirebaseLuau
