local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Promise = require(script.Parent.Parent.Promise)

local BASE_URLs = {
    Firestore = function(app)
        return ("https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/"):format(app.ProjectId)
    end,
    IdentityToolKit = function()
        return "https://identitytoolkit.googleapis.com/v1/accounts"
    end,
}

local Http = {}
local HTTP_METATABLE = {}
HTTP_METATABLE.__index = HTTP_METATABLE

function Http.new(app)
    local self = {}

    self.App = app

    return setmetatable(self, HTTP_METATABLE)
end

local function formatUrl(baseUrl, path, queries)
    local url = baseUrl.. path

    if queries then
        local queryStrings = {}

        for key, value in pairs(queries) do
            if type(key) == "number" then
                table.insert(queryStrings, value)
            else
                table.insert(queryStrings, ("%s=%s"):format(key, value))
            end
        end

        if #queryStrings > 0 then
            url = url.. "?".. table.concat(queryStrings, "&")
        end
    end

    return url
end

local function requestAsync(app, requestParams)
    requestParams.Headers = requestParams.Headers or {}

    if app._auth then
        requestParams.Headers.Authorization = "Bearer ".. app._auth.IdToken
    end

    local requestBody = requestParams.Body
    if requestBody and type(requestBody) == "table" then
        requestParams.Headers["content-type"] = "application/json"
        requestParams.Body = HttpService:JSONEncode(requestBody)
    end

    local response = HttpService:RequestAsync(requestParams)
    if response.StatusCode == 401 then
        app._auth = app._authentication:SignInWithEmailAndPassword(app.Email, app.Password):expect()
        requestParams.Headers.Authorization = "Bearer ".. app._auth.IdToken
        response = HttpService:RequestAsync(requestParams)
    end
    if response.Headers["content-type"]:find("application/json") then
        response.Body = HttpService:JSONDecode(response.Body)
    end

    return response
end

function HTTP_METATABLE:GET(serviceName, path, queries)
    return Promise.new(function(resolve, reject)
        local app = self.App

        local response = requestAsync(app, {
            Url = formatUrl(BASE_URLs[serviceName](app), path, queries),
            Method = "GET",
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

function HTTP_METATABLE:POST(serviceName, path, queries, body)
    return Promise.new(function(resolve, reject)
        local app = self.App

        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName](app), path, queries),
            Method = "POST",
            Body = body,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

function HTTP_METATABLE:DELETE(serviceName, path, queries, body)
    return Promise.new(function(resolve, reject)
        local app = self.App

        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName](app), path, queries),
            Method = "DELETE",
            Body = body,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

function HTTP_METATABLE:PATCH(serviceName, path, queries, body)
    return Promise.new(function(resolve, reject)
        local app = self.App

        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName](app), path, queries),
            Method = "PATCH",
            Body = body,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

return Http
