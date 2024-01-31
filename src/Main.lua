-- // Credits \\
-- TotalHorizons / @0horizon
-- MIT License

-- // Variables \\
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local DSS = game:GetService("DataStoreService")
local Database = DSS:GetDataStore("Database")
local Config = require(script.Configuration)

local SampleData = { ["Cash"] = 500, ["Bank"] = 1500 }
local ServerData = {}

-- // Configuration Checks \\
if (not script:FindFirstChild("Configuration")) then
	warn("[ERROR] The Configuration file is missing or misplaced.")
end

-- // Functions \\
local isBanned = function(Player: Player)
	if Config.GeoBlock then 
		local Region = LocalizationService:GetCountryRegionForPlayerAsync(Player)
		if table.find(Config.BannedCountries, Region) then
			Player:Kick("[GEOBLOCK] You've been restricted access to this experience.")
		end
	end
	
	if Config.GroupBans then 
		for _, v in pairs(Config.BannedGroups) do
			if Player:IsInGroup(v) then
				Player:Kick("[GROUPBANS] You've been restricted access to this experience.")
			end
		end
	end
  
end

local LoadData = function(Player: Player)
	local LoadedData = Database:GetAsync("DB_"..Player.UserId)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player
	
	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Parent = leaderstats
	
	local Bank = Instance.new("IntValue")
	Bank.Name = "Bank"
	Bank.Parent = leaderstats
	
	if (not LoadedData) then
		LoadedData = SampleData
	end
	
	ServerData[Player.UserId] = LoadedData
	
	for Key, Value in pairs(LoadedData) do
		Player.leaderstats:FindFirstChild(Key).Value = Value
	end
end

local SaveData = function(Player: Player)
	local LoadedData = ServerData[Player.UserId]
	local leaderstats = Player:WaitForChild("leaderstats")
	LoadedData["Cash"] = leaderstats["Cash"].Value
	LoadedData["Bank"] = leaderstats["Bank"].Value
	
	for Key, Value in pairs(leaderstats:GetChildren()) do
		LoadedData[Key] = leaderstats[Key].Value
	end
	
	Database:SetAsync("DB_"..Player.UserId, LoadedData)
	ServerData[Player.UserId] = nil
end

-- // Code \\
Players.PlayerAdded:Connect(function(player: Player)  
	LoadData(player)
	isBanned(player)
end)

Players.PlayerRemoving:Connect(SaveData)
