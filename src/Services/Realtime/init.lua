local REALTIME_METATABLE = {}
function REALTIME_METATABLE:__index(i)
    if i == "App" then
        return rawget(self, "_app")
    else
        return REALTIME_METATABLE[i] or error(i.. " is not a valid member of Realtime", 2)
    end
end
function REALTIME_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Realtime or is unassignable", 2)
end

-- function REALTIME_METATABLE:ConnectEmulator()

-- end

-- function REALTIME_METATABLE:DisconnectEmulator()

-- end

return function(app)
    warn("Firebase Realtime is not supported yet.")

    return setmetatable({
        _app = app,
    }, REALTIME_METATABLE)
end
