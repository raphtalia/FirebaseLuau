local GoogleApis = require(script.Parent.Parent.Parent.Util.GoogleApis)

local SecureToken = {}
local SECURE_TOKEN_METATABLE = {}
function SECURE_TOKEN_METATABLE:__index(i)
    if i == "UserId" then
        return rawget(self, "_userId")
    elseif i == "IdToken" then
        return rawget(self, "_idToken")
    elseif i == "RefreshToken" then
        return rawget(self, "_refreshToken")
    elseif i == "IssuedAt" then
        return rawget(self, "_issuedAt")
    elseif i == "ExpiresIn" then
        return rawget(self, "_expiresIn")
    else
        return SECURE_TOKEN_METATABLE[i] or error(i.. " is not a valid member of SecureToken", 2)
    end
end
function SECURE_TOKEN_METATABLE:__newindex(i)
    error(i.. " is not a valid member of SecureToken or is unassignable", 2)
end

function SecureToken.new(rawSecureToken)
    return setmetatable({
        _userId = rawSecureToken.UserId,
        _idToken = rawSecureToken.IdToken,
        _refreshToken = rawSecureToken.RefreshToken,
        _issuedAt = rawSecureToken.IssuedAt,
        _expiresIn = tonumber(rawSecureToken.ExpiresIn),
    }, SECURE_TOKEN_METATABLE)
end

function SECURE_TOKEN_METATABLE:Refresh(app)
    -- https://cloud.google.com/identity-platform/docs/use-rest-api#section-refresh-token
    local status, response = GoogleApis.post({
        App = app,
        Service = "SecureToken",
        Params = {
            key = app.Options.ApiKey,
        },
        Body = {
            grant_type = "refresh_token",
            refresh_token = self.RefreshToken,
        }
    }):await()

    if status then
        return SecureToken.new({
            UserId = response.user_id,
            IdToken = response.id_token,
            RefreshToken = response.refresh_token,
            IssuedAt = tick(),
            ExpiresIn = response.expires_in,
        })
    else
        error(response, 2)
    end
end

function SECURE_TOKEN_METATABLE:IsExpired()
    return tick() - self.IssuedAt > self.ExpiresIn
end

return SecureToken
