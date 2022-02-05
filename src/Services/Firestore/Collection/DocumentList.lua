local Promise = require(script.Parent.Parent.Parent.Parent.Packages.Promise)
local Document = require(script.Parent.Parent.Document)

local DocumentList = {}
local DOCUMENTLIST_METATABLE = {}
DOCUMENTLIST_METATABLE.__index = DOCUMENTLIST_METATABLE

function DocumentList.new(app, path, pageSize, _pageToken)
    return Promise.new(function(resolve)
        local self = {}

        self.App = app
        self.Path = path
        self.PageSize = pageSize
        self.Docs = {}

        local pathParams = path:split("/")
        self.DocumentId = pathParams[#pathParams]

        local response = self.App._http:GET("Firestore", self.Path, {
            pageSize = pageSize,
            pageToken = _pageToken,
        }):expect()

        for _,doc in ipairs(response.documents or {}) do
            table.insert(self.Docs, Document.new(self.App, doc))
        end

        self.NextPageToken = response.nextPageToken

        resolve(setmetatable(self, DOCUMENTLIST_METATABLE))
    end)
end

function DOCUMENTLIST_METATABLE:GetNextPage()
    if self.NextPageToken then
        return DocumentList.new(self.App, self.Path, self.PageSize, self.NextPageToken)
    end
end

return DocumentList
