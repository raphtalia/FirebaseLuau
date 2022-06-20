local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FirebaseLuau = require(ReplicatedStorage.Packages.FirebaseLuau)
local env = require(script.Parent[".env"])

local app = FirebaseLuau.initializeApp({
    ApiKey = env.API_KEY,
    ProjectId = env.PROJECT_ID,
})

app:GetAuth():SignInWithEmailAndPassword("tests@fbluau.com", "password"):expect()

local ref = app:GetFirestore():GetCollection("Players"):AddDoc({
    a = 1,
    b = 2,
    c = 3,
}):expect()

print(ref)
