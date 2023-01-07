--[[
PreloadService V3

SETTINGS
]]

local module = require(game.ReplicatedStorage:WaitForChild("PreloadService"):WaitForChild("Config"))
local SettingsRemoteFolder = Instance.new("Folder", game.ReplicatedStorage.PSRemotes)
local DSS = game:GetService("DataStoreService")
local Key = "_PRELOADSERVICE_DATASTORE_SETTINGS_V1"
local DS = DSS:GetDataStore(Key)
local Active = false

local function Save(Property, Value)
	if not Active then
		warn("[PreloadService]: Cannot change "..Property..". This is usually because you tried changing it from outside the settings panel and it tried to save, please try again later.")
		return
	end
	task.wait(2)
	module[Property] = Value
	DS:SetAsync(Key,module)
	
end
