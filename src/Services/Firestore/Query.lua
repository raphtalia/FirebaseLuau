-- https://firebase.google.com/docs/reference/node/firebase.firestore.Query

local Query = {}
local QUERY_METATABLE = {}
function QUERY_METATABLE:__index(i)
    if i == "Firestore" then
        return rawget(self, "_firestore")
    else
        return QUERY_METATABLE[i] or error(i.. " is not a valid member of Query", 2)
    end
end
function QUERY_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Query or is unassignable", 2)
end

function Query.new(firestore)
    return setmetatable({
        _firestore = firestore,
    }, QUERY_METATABLE)
end

function QUERY_METATABLE:Get()

end

function QUERY_METATABLE:EndAt()

end

function QUERY_METATABLE:EndBefore()

end

function QUERY_METATABLE:Limit()

end

function QUERY_METATABLE:LimitToLast()

end

function QUERY_METATABLE:OrderBy()

end

function QUERY_METATABLE:StartAfter()

end

function QUERY_METATABLE:StartAt()

end

function QUERY_METATABLE:Where()

end

return Query
