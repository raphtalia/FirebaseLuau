-- https://firebase.google.com/docs/reference/node/firebase.auth.Auth

local Promise = require(script.Parent.Parent.Parent.Promise)
local User = require(script.User)

local AUTHENTICATION_METATABLE = {}
function AUTHENTICATION_METATABLE:__index(i)
    if i == "App" then
        return rawget(self, "_app")
    elseif i == "CurrentUser" then
        return rawget(self, "_currentUser")
    else
        return AUTHENTICATION_METATABLE[i] or error(i.. " is not a valid member of Authentication", 2)
    end
end
function AUTHENTICATION_METATABLE:__newindex(i, v)
    if i == "CurrentUser" then
        rawset(self, "_currentUser", v)
    else
        error(i.. " is not a valid member of Authentication or is unassignable", 2)
    end
end

-- function AUTHENTICATION_METATABLE:ConnectEmulator()

-- end

-- function AUTHENTICATION_METATABLE:DisconnectEmulator()

-- end

function AUTHENTICATION_METATABLE:CreateUserWithEmailAndPassword(email, password)
    return Promise.new(function(resolve)
        local user = User.new(self, {
            Email = email,
            Password = password,
        })

        self.CurrentUser = user
        resolve(user)
    end)
end

function AUTHENTICATION_METATABLE:SignInWithEmailAndPassword(email, password)
    return Promise.new(function(resolve)
        local user = User.signIn(self, email, password)

        self.CurrentUser = user
        resolve(user)
    end)
end

return function(app)
    return setmetatable({
        _app = app,
    }, AUTHENTICATION_METATABLE)
end
