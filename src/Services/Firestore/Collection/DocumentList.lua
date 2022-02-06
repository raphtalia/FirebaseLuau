local Promise = require(script.Parent.Parent.Parent.Parent.Packages.Promise)
local Document = require(script.Parent.Parent.Document)

--[=[
    @class DocumentList
    Reference to a page of documents from a Firestore collection.
]=]
local DocumentList = {}
local DOCUMENTLIST_METATABLE = {}
DOCUMENTLIST_METATABLE.__index = DOCUMENTLIST_METATABLE

--[=[
    @within DocumentList
    @private
    Creates a `DocumentList` object.

    @param app FirebaseApp
    @param path string
    @param pageSize number
    @param _pageToken string
    @return DocumentList
]=]
function DocumentList.new(app, path, pageSize, _pageToken)
    return Promise.new(function(resolve)
        local self = {}

        --[=[
            @within DocumentList
            @prop App FirebaseApp
            The `FirebaseApp` object tied to this list.
        ]=]
        self.App = app
        --[=[
            @within DocumentList
            @prop Path string
            The path of this list.
        ]=]
        self.Path = path
        --[=[
            @within DocumentList
            @prop PageSize number
            The intial page size of this list.
        ]=]
        self.PageSize = pageSize
        --[=[
            @within DocumentList
            @prop Docs DocumentReference[]
            References to the documents in this list.
        ]=]
        self.Docs = {}

        local response = self.App._http:GET("Firestore", self.Path, {
            pageSize = pageSize,
            pageToken = _pageToken,
        }):expect()

        for _,doc in ipairs(response.documents or {}) do
            table.insert(self.Docs, Document.new(self.App, doc))
        end

        --[=[
            @within DocumentList
            @prop NextPageToken string
            The token to use for the next page of results. This will be nil if there are no more results.
        ]=]
        self.NextPageToken = response.nextPageToken

        resolve(setmetatable(self, DOCUMENTLIST_METATABLE))
    end)
end

--[=[
    @within DocumentList
    Returns the next page of documents. Returns nothing if there are no more documents.

    @method GetNextPage
    @return DocumentList
]=]
function DOCUMENTLIST_METATABLE:GetNextPage()
    if self.NextPageToken then
        return DocumentList.new(self.App, self.Path, self.PageSize, self.NextPageToken)
    end
end

return DocumentList
