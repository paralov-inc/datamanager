local HttpService = game:GetService("HttpService")

local Sift = require(script.Parent.Packages.Sift)

local DataProfile = {}
DataProfile.__index = DataProfile

export type DataProfile<T> = {
	_writableData: T,
	_readOnlyData: T,
	_callbacks: { [string]: (oldData: T) -> () },
	Read: (self: DataProfile<T>) -> T,
	Set: (self: DataProfile<T>, newData: T, options: { preventCallback: boolean? }) -> (),
	Watch: (self: DataProfile<T>, callback: (oldData: T) -> ()) -> () -> (),
}

function DataProfile.new<T>(writableData: T, validator: ((data: T) -> boolean)?)
	local instance = setmetatable(
		{
			_writableData = writableData,
			_readOnlyData = Sift.Dictionary.copyDeep(writableData),
			_callbacks = {},
		} :: DataProfile<T>,
		DataProfile
	)

	function instance.Read(self: DataProfile<T>): T
		return self._readOnlyData
	end

	function instance.Set(
		self: DataProfile<T>,
		newData: T,
		options: {
			preventCallback: boolean?,
		}?
	)
		-- Validate the new data
		if validator ~= nil and not validator(newData) then
			error("Invalid profile data")
		end

		-- Get a deep copy of the old data
		local oldData = Sift.Dictionary.copyDeep(self._writableData)

		-- Set the new data
		self._writableData = newData
		self._readOnlyData = Sift.Dictionary.copyDeep(newData)

		-- If the callback is not prevented, call it
		if not options or not options.preventCallback then
			for _, callback in self._callbacks do
				task.spawn(callback, oldData)
			end
		end
	end

	function instance.Watch(self: DataProfile<T>, callback: (oldData: T) -> ())
		local guid = HttpService:GenerateGUID(false)

		self._callbacks[guid] = callback

		return function()
			self._callbacks[guid] = nil
		end
	end

	return instance
end

return DataProfile
