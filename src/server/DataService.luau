local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataProfile = require(ServerScriptService.Server.Modules.DataProfile)
local Store = require(ServerScriptService.Server.Modules.Store)

local Profiles: { [Player]: Store.Profile } = {}
local DataProfiles: { [Player]: DataProfile.DataProfile } = {}

local DataService = {}

local function onPlayerAdded(player: Player)
	-- Start a profile session for this player's data:

	local data = Store:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if data ~= nil then
		data:AddUserId(player.UserId) -- GDPR compliance
		data:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		data.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Profiles[player] = data
			print(`Profile loaded for {player.DisplayName}!`)
		else
			-- The player has left before the profile session started
			data:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function DataService:GetProfile(player: Player)
	local profile = Profiles[player]

	-- Wait for the profile to be loaded:
	while profile == nil do
		profile = Profiles[player]
		task.wait()
	end

	local dataProfile = DataProfiles[player]

	if dataProfile == nil then
		dataProfile = DataProfile.new(player, profile)
		DataProfiles[player] = dataProfile
	end

	return dataProfile
end

function DataService:KnitStart()
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		local data = Profiles[player]
		if data ~= nil then
			data:EndSession()
		end
	end)
end

return DataService
