-- https://firebase.google.com/docs/reference/node/firebase.functions.Functions

local FUNCTIONS_METATABLE = {}
function FUNCTIONS_METATABLE:__index(i)
    if i == "App" then
        return rawget(self, "_app")
    else
        return FUNCTIONS_METATABLE[i] or error(i.. " is not a valid member of Functions", 2)
    end
end
function FUNCTIONS_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Functions or is unassignable", 2)
end

-- function FUNCTIONS_METATABLE:ConnectEmulator()

-- end

-- function FUNCTIONS_METATABLE:DisconnectEmulator()

-- end

return function(app)
    warn("Firebase Functions is not supported yet.")

    return setmetatable({
        _app = app,
    }, FUNCTIONS_METATABLE)
end
