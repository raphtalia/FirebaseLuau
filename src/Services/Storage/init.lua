-- https://firebase.google.com/docs/reference/node/firebase.storage.Storage

local STORAGE_METATABLE = {}
function STORAGE_METATABLE:__index(i)
    if i == "App" then
        return rawget(self, "_app")
    else
        return STORAGE_METATABLE[i] or error(i.. " is not a valid member of Storage", 2)
    end
end
function STORAGE_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Storage or is unassignable", 2)
end

-- function STORAGE_METATABLE:ConnectEmulator()

-- end

-- function STORAGE_METATABLE:DisconnectEmulator()

-- end

return function(app)
    warn("Firebase Storage is not supported yet.")

    return setmetatable({
        _app = app,
    }, STORAGE_METATABLE)
end
