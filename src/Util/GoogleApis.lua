local HttpService = game:GetService("HttpService")

local Promise = require(script.Parent.Parent.Parent.Promise)

local BASE_URLs = {
    Firestore = function(app)
        return ("https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents"):format(app.Options.ProjectId)
    end,
    IdentityToolKit = function()
        return "https://identitytoolkit.googleapis.com/v1/accounts"
    end,
    SecureToken = function()
        return "https://securetoken.googleapis.com/v1"
    end,
}

local GoogleApis = {}

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

local function requestAsync(requestParams)
    requestParams.Headers = requestParams.Headers or {}

    local requestBody = requestParams.Body
    if requestBody and type(requestBody) == "table" then
        requestParams.Headers["content-type"] = "application/json"
        requestParams.Body = HttpService:JSONEncode(requestBody)
    end

    print(requestParams)
    local response = HttpService:RequestAsync(requestParams)
    if response.Headers["content-type"]:find("application/json") then
        response.Body = HttpService:JSONDecode(response.Body)
    end

    return response
end

function GoogleApis.get(options)
    return Promise.new(function(resolve, reject)
        local response = requestAsync({
            Url = formatUrl(BASE_URLs[options.Service](options.App), options.Path, options.Params),
            Method = "GET",
            Headers = options.Headers,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

function GoogleApis.post(options)
    return Promise.new(function(resolve, reject)
        local response = requestAsync({
            Url = formatUrl(BASE_URLs[options.Service](options.App), options.Path, options.Params),
            Method = "POST",
            Headers = options.Headers,
            Body = options.Body,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

function GoogleApis.delete(options)
    return Promise.new(function(resolve, reject)
        local response = requestAsync({
            Url = formatUrl(BASE_URLs[options.Service](options.App), options.Path, options.Params),
            Method = "DELETE",
            Headers = options.Headers,
            Body = options.Body,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

function GoogleApis.patch(options)
    return Promise.new(function(resolve, reject)
        local response = requestAsync({
            Url = formatUrl(BASE_URLs[options.Service](options.App), options.Path, options.Params),
            Method = "PATCH",
            Headers = options.Headers,
            Body = options.Body,
        })

        if response.StatusCode == 200 then
            resolve(response.Body)
        else
            reject(response.Body)
        end
    end)
end

return GoogleApis
