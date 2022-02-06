# FirebaseLuau

Promise based library for accessing Firebase services from within Roblox. Currently this project only has support for
Firestore.

## Setup

Authentication is done through Firebase's Authentication service using a normal email/password provider. This
**is not** your actual email or password. Once an account is created update your rules to allow this account read/write
permissions on any services you need.

A simple example of a rule is allowing only the UID of the account to read and write.

```cel
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == "kaTY7zQKbkZsjvlkv2Hu6KQhRf02";
    }
  }
}
```

## Example

```lua
local Firebase = require("FirebaseLuau")
local firebase = Firebase.init({
    ProjectId = "PROJECT_ID",
    APIKey = "WEB_API_KEY",
    Email = "EMAIL",
    Password = "PASSWORD"
})

local usersCollection = firebase.Firestore:GetCollection("users")
local userDoc = usersCollection:GetDoc("72938051") -- OR firebase.Firestore:GetDoc("users/72938051")

userDoc:Write({
    gold = 100,
}):await()

print(userDoc:Read():expect())
```
