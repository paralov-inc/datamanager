local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Packages.DataService.DataManager)
local ProfileTemplate = require(ReplicatedStorage.Shared.ProfileTemplate)
local Store = require(ServerScriptService.Server.Store)

local Profiles: { [Player]: Store.Profile } = {}
local ProfileDataManager = DataManager.new(ProfileTemplate.template, {
	validator = ProfileTemplate.schema,
	shouldReconcile = true,
})

local PlayerDataManagementService = {}

local function onPlayerAdded(player: Player)
	-- Start a profile session for this player's data:

	local profile = Store:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance

		profile.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Profiles[player] = profile
			ProfileDataManager:OnPlayerDataReady(player, profile.Data)
			print(`Profile loaded for {player.DisplayName}!`)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function PlayerDataManagementService.Start()
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	Players.PlayerAdded:Connect(function(player)
		onPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:EndSession()
		end
	end)
end

function PlayerDataManagementService.GetProfileDataManager()
	return ProfileDataManager
end

return PlayerDataManagementService
