local HttpService = game:GetService("HttpService")

local Promise = require(script.Parent.Packages.Promise)

local BASE_URLs = {
    Firestore = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/",
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
            table.insert(queryStrings, ("%s=%s"):format(key, value))
        end

        if #queryStrings > 0 then
            url = url.. "?".. table.concat(queryStrings, "&")
        end
    end

    return url
end

local function requestAsync(app, requestParams)
    requestParams.Headers = requestParams.Headers or {}
    requestParams.Headers.Authorization = "Bearer ".. app.Token

    return HttpService:RequestAsync(requestParams)
end

function HTTP_METATABLE:GET(serviceName, projectId, path, queries)
    return Promise.new(function(resolve, reject)
        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName]:format(projectId), path, queries),
            Method = "GET",
        })

        if response.StatusCode == 200 then
            if response.Headers["content-type"]:find("application/json") then
                resolve(HttpService:JSONDecode(response.Body))
            else
                resolve(response.Body)
            end
        else
            reject(response.Body)
        end
    end)
end

function HTTP_METATABLE:POST(serviceName, projectId, path, queries, body)
    return Promise.new(function(resolve, reject)
        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName]:format(projectId), path, queries),
            Method = "POST",
            Body = body,
        })

        if response.StatusCode == 200 then
            if response.Headers["content-type"]:find("application/json") then
                resolve(HttpService:JSONDecode(response.Body))
            else
                resolve(response.Body)
            end
        else
            reject(response.Body)
        end
    end)
end

function HTTP_METATABLE:DELETE(serviceName, projectId, path, queries, body)
    return Promise.new(function(resolve, reject)
        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName]:format(projectId), path, queries),
            Method = "DELETE",
            Body = body,
        })

        if response.StatusCode == 200 then
            if response.Headers["content-type"]:find("application/json") then
                resolve(HttpService:JSONDecode(response.Body))
            else
                resolve(response.Body)
            end
        else
            reject(response.Body)
        end
    end)
end

function HTTP_METATABLE:PATCH(serviceName, projectId, path, queries, body)
    return Promise.new(function(resolve, reject)
        local response = requestAsync(self.App, {
            Url = formatUrl(BASE_URLs[serviceName]:format(projectId), path, queries),
            Method = "PATCH",
            Body = body,
        })

        if response.StatusCode == 200 then
            if response.Headers["content-type"]:find("application/json") then
                resolve(HttpService:JSONDecode(response.Body))
            else
                resolve(response.Body)
            end
        else
            reject(response.Body)
        end
    end)
end

return Http
