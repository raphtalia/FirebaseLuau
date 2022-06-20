-- https://firebase.google.com/docs/reference/node/firebase.User

local Promise = require(script.Parent.Parent.Parent.Parent.Promise)
local SecureToken = require(script.Parent.SecureToken)
local GoogleApis = require(script.Parent.Parent.Parent.Util.GoogleApis)

local User = {}
local USER_METATABLE = {}
function USER_METATABLE:__index(i)
    if i == "Auth" then
        return rawget(self, "_auth")
    elseif i == "DisplayName" then
        return rawget(self, "_displayName")
    elseif i == "Email" then
        return rawget(self, "_email")
    elseif i == "UserId" then
        return rawget(self, "_userId")
    elseif i == "Token" then
        return rawget(self, "_token")
    else
        return USER_METATABLE[i] or error(i.. " is not a valid member of User", 2)
    end
end
function USER_METATABLE:__newindex(i)
    error(i.. " is not a valid member of User or is unassignable", 2)
end

function User.new(auth, userParams)
    -- https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/signUp
    local status, response = GoogleApis.post({
        App = auth.App,
        Service = "IdentityToolKit",
        Path = ":signUp",
        Params = {
            key = auth.App.Options.ApiKey,
        },
        Body = {
            email = userParams.Email,
            password = userParams.Password,
            displayName = userParams.displayName,
        }
    }):await()

    if status then
        return setmetatable({
            _auth = auth,
            _email = response.email,
            _displayName = response.displayName,
            _userId = response.localId,
            _token = SecureToken.new({
                UserId = response.localId,
                IdToken = response.idToken,
                RefreshToken = response.refreshToken,
                IssuedAt = tick(),
                ExpiresIn = response.expiresIn,
            }),
        }, USER_METATABLE)
    else
        error(response, 2)
    end
end

function User.signIn(auth, email, password)
    -- https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/signInWithPassword
    local status, response = GoogleApis.post({
        App = auth.App,
        Service = "IdentityToolKit",
        Path = ":signInWithPassword",
        Params = {
            key = auth.App.Options.ApiKey,
        },
        Body = {
            email = email,
            password = password,
            returnSecureToken = true,
        }
    }):await()

    if status then
        return setmetatable({
            _auth = auth,
            _email = response.email,
            _displayName = response.displayName,
            _userId = response.localId,
            _token = SecureToken.new({
                UserId = response.localId,
                IdToken = response.idToken,
                RefreshToken = response.refreshToken,
                IssuedAt = tick(),
                ExpiresIn = response.expiresIn,
            }),
        }, USER_METATABLE)
    else
        error(response, 2)
    end
end

function USER_METATABLE:Reload()
    return Promise.new(function(resolve)
        local token = self.Token:Refresh()
        rawset(self, "_token", token)
        resolve(token)
    end)
end

function USER_METATABLE:Delete()
    -- https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/delete
    return Promise.new(function(resolve, reject)
        local status, response = GoogleApis.post({
            App = self.Auth.App,
            Service = "IdentityToolKit",
            Path = ":delete",
            Params = {
                key = self.Auth.App.Options.ApiKey,
            },
            Body = {
                idToken = self.Token.IdToken,
            }
        }):await()

        if status then
            resolve()
        else
            reject(response)
        end
    end)
end

function USER_METATABLE:Update(options)
    -- https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/update
    return Promise.new(function(resolve, reject)
        local status, response = GoogleApis.post({
            App = self.Auth.App,
            Service = "IdentityToolKit",
            Path = ":update",
            Params = {
                key = self.Auth.App.Options.ApiKey,
            },
            Body = {
                idToken = self.Token.IdToken,
                displayName = options.DisplayName,
                email = options.Email,
                password = options.Password,
                disableUser = options.DisableUser,
            }
        }):await()

        if status then
            rawset(self, "_token", SecureToken.new({
                UserId = response.localId,
                IdToken = response.idToken,
                RefreshToken = response.refreshToken,
                IssuedAt = tick(),
                ExpiresIn = response.expiresIn,
            }))
            resolve(self)
        else
            reject(response)
        end
    end)
end

return User
