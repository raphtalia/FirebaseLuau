local Http = require(script.Http)
local Authentication = require(script.Services.Authentication)
local Firestore = require(script.Services.Firestore)

--[=[
    @class Firebase
    Main Firebase library.
]=]
local FirebaseLuau = {}
--[=[
    @class FirebaseApp
    An object tied to a specific Firebase project and used to access Firebase services such as Firestore.
]=]
local FIREBASELUAU_METATABLE = {}
FIREBASELUAU_METATABLE.__index = FIREBASELUAU_METATABLE

--[=[
    @within Firebase
    Creates a `FirebaseApp` object with the given ProjectId, APIKey, Email and password.

    @param appParams { ProjectId: string, APIKey: string, Email: string, Password: string }
    @return FirebaseApp
]=]
function FirebaseLuau.init(appParams)
    local self = {}

    --[=[
        @within FirebaseApp
        @prop ProjectId string
        Project ID of the Firebase project.
    ]=]
    self.ProjectId = appParams.ProjectId
    --[=[
        @within FirebaseApp
        @prop APIKey string
        API key of the Firebase project.
    ]=]
    self.APIKey = appParams.APIKey
    --[=[
        @within FirebaseApp
        @prop Email string
        Email of the Firebase user.
    ]=]
    self.Email = appParams.Email
    --[=[
        @within FirebaseApp
        @prop Password string
        Password of the Firebase user.
    ]=]
    self.Password = appParams.Password

    --[=[
        @within FirebaseApp
        @private
        @prop _http Http
        Http object used to communicate with the Firebase API.
    ]=]
    self._http = Http.new(self)
    --[=[
        @within FirebaseApp
        @private
        @prop _authentication Authentication
        Authentication object used to authenticate with the Firebase API.
    ]=]
    self._authentication = Authentication.new(self)
    --[=[
        @within FirebaseApp
        @prop Firestore Firestore
        Firestore object used to access the Firestore API.
    ]=]
    self.Firestore = Firestore.new(self)

    if self.Email and self.Password then
        self._auth = self._authentication:SignInWithEmailAndPassword(self.Email, self.Password):expect()
    end

    return setmetatable(self, FIREBASELUAU_METATABLE)
end

return FirebaseLuau
