local Http = require(script.Http)
local Firestore = require(script.Services.Firestore)

local FirebaseLuau = {}
local FIREBASELUAU_METATABLE = {}
FIREBASELUAU_METATABLE.__index = FIREBASELUAU_METATABLE

function FirebaseLuau.init(appParams)
    local self = {}

    self.ProjectId = appParams.ProjectId
    self.Token = appParams.Token

    self._http = Http.new(self)
    self.Firestore = Firestore.new(self)

    return setmetatable(self, FIREBASELUAU_METATABLE)
end

return FirebaseLuau
