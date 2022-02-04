local Promise = require(script.Parent.Parent.Packages.Promise)
local Auth = require(script.Auth)

local Authentication = {}
local AUTHENTICATION_METATABLE = {}
AUTHENTICATION_METATABLE.__index = AUTHENTICATION_METATABLE

function Authentication.new(app)
    local self = {}

    self.App = app

    return setmetatable(self, AUTHENTICATION_METATABLE)
end

function AUTHENTICATION_METATABLE:SignInWithEmailAndPassword(email, password)
    return Promise.new(function(resolve)
        local app = self.App

        local response = app._http:POST("IdentityToolKit", ":signInWithPassword", {
            key = app.APIKey,
        }, {
            email = email,
            password = password,
            returnSecureToken = true,
        }):expect()

        resolve(Auth.new(
            app,
            {
                IdToken = response.idToken,
                ExpiresIn = response.expiresIn,
            }
        ))
    end)
end

return Authentication
