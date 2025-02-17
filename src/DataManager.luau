local DataProfile = require(script.Parent.DataProfile)

local DataManager = {}
DataManager.__index = DataManager

export type DataManager<T> = {
	_profiles: { [Player]: DataProfile.DataProfile<T> },
	GetProfile: (player: Player) -> DataProfile.DataProfile<T>,
	OnPlayerDataReady: (player: Player, data: T) -> (),
	OnPlayerRemoving: (player: Player) -> (),
}

local function DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function ReconcileTable(target, template)
	for k, v in pairs(template) do
		if type(k) == "string" then -- Only string keys will be reconciled
			if target[k] == nil then
				if type(v) == "table" then
					target[k] = DeepCopyTable(v)
				else
					target[k] = v
				end
			elseif type(target[k]) == "table" and type(v) == "table" then
				ReconcileTable(target[k], v)
			end
		end
	end
end

function DataManager.new<T>(template: T, options: { validator: ((data: T) -> boolean)?, shouldReconcile: boolean? }?)
	local instance = setmetatable(
		{
			_profiles = {},
		} :: DataManager<T>,
		DataManager
	)

	function instance.GetProfile(self: DataManager<T>, player: Player)
		while not self._profiles[player] do
			task.wait()
		end

		return self._profiles[player]
	end

	function instance.OnPlayerDataReady(self: DataManager<T>, player: Player, data: T)
		if self._profiles[player] then
			warn("Player data already initialised, skipping... (This could be sign that you're not cleaning up!)")
			return
		end

		if options and options.shouldReconcile then
			ReconcileTable(data, template)
		end

		self._profiles[player] = DataProfile.new(data, options and options.validator or nil)
	end

	function instance.OnPlayerRemoving(self: DataManager<T>, player: Player)
		self._profiles[player] = nil
	end

	return instance
end

return DataManager
