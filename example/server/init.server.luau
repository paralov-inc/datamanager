local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataManagementService = require(ServerScriptService.Server.PlayerDataManagementService)

PlayerDataManagementService:Start()

local function onPlayerAdded(player: Player)
	local profile = PlayerDataManagementService:GetProfileDataManager():GetProfile(player)

	print("original", profile:Read())

	profile:Watch(function(newData, oldData)
		if oldData.Currency.Dollar == newData.Currency.Dollar then
			return
		end

		print("watched", newData, oldData)
	end)

	local data = profile:Read()
	data.Currency.Dollar += 100
	profile:Set(data)

	print(profile:Read())

	data = profile:Read()
	data.Currency.Cents = -10
	profile:Set(data)
end

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
