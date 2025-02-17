local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileTemplate = require(ReplicatedStorage.Shared.ProfileTemplate)
local ProfileStore = require(ServerScriptService.Packages.ProfileStore)

local DATASTORE_KEY = "Profiles_0"

local Store = ProfileStore.New(DATASTORE_KEY, ProfileTemplate.template)

export type Profile = typeof(Store:StartSessionAsync())

return Store
