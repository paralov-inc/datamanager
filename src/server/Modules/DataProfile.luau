local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Sift = require(ReplicatedStorage.Packages.Sift)

local ProfileTemplate = require(ReplicatedStorage.Shared.ProfileTemplate)
local Store = require(ServerScriptService.Server.Modules.Store)

local DataProfile = {}
DataProfile.__index = DataProfile

type self = {
	_player: Player,
	_profile: Store.Profile,
	_callbacks: { [string]: (newData: Store.ProfileTemplate, oldData: Store.ProfileTemplate) -> () },
}

export type DataProfile = typeof(setmetatable({} :: self, DataProfile))

function DataProfile.new(player: Player, profile: Store.Profile): DataProfile
	return setmetatable({
		_player = player,
		_profile = profile,
		_callbacks = {},
	}, DataProfile)
end

--[=[
	Reads the profile data. (returns a deep copy, safe to modify)

	@return ProfileTemplate -- Returns the profile data
]=]
function DataProfile.Read(self: DataProfile): Store.ProfileTemplate
	return Sift.Dictionary.copyDeep(self._profile.Data)
end

--[=[
	Sets the profile data. 

	@param newData ProfileTemplate -- The new profile data
]=]
function DataProfile.Set(
	self: DataProfile,
	newData: Store.ProfileTemplate,
	options: {
		preventCallback: boolean?,
		ignoreValidation: boolean?,
	}?
)
	if not options or not options.ignoreValidation then
		-- Validate the new data
		if not ProfileTemplate.schema(newData) then
			error("Invalid profile data")
		end
	end

	-- Get a deep copy of the old data
	local oldData = Sift.Dictionary.copyDeep(self._profile.Data)

	-- Set the new data
	self._profile.Data = newData

	-- If the callback is not prevented, call it
	if not options or not options.preventCallback then
		local callbackNewData = Sift.Dictionary.copyDeep(newData)

		for _, callback in self._callbacks do
			task.spawn(callback, callbackNewData, oldData)
		end
	end
end

--[=[
	Sets a callback to be called when the profile data changes. 

	DO NOT under any circumstances call the `Set` function from within the callback. This will cause a stack overflow.

	@param callback (newData: ProfileTemplate, oldData: ProfileTemplate) -> () -- The callback to call when the data changes 
	`newData` and `oldData` are deep copies, so they are safe to modify - but you probably shouldn't.
	@return () -- Returns a function to remove the callback
]=]
function DataProfile.Watch(
	self: DataProfile,
	callback: (newData: Store.ProfileTemplate, oldData: Store.ProfileTemplate) -> ()
)
	local guid = HttpService:GenerateGUID(false)

	self._callbacks[guid] = callback

	return function()
		self._callbacks[guid] = nil
	end
end

return DataProfile
