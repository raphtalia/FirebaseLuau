local Auth = {}
local AUTH_METATABLE = {}
AUTH_METATABLE.__index = AUTH_METATABLE

function Auth.new(_, authParams)
    local self = {}

    self.IdToken = authParams.IdToken
    self.Issued = tick()
    self.Expires = self.Issued + authParams.ExpiresIn

    return setmetatable(self, AUTH_METATABLE)
end

return Auth
