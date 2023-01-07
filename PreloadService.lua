--[[
PRELOADSERVICE Blue v3

Blue Release: 3a
The following is all essential to providing the core functions, and exploit protection.
I advise you do not modify any code, but I cant stop you.
IF YOU MODIFY CODE I WILL NOT OFFER SUPPORT
]]


------
local Config = require(script.Config)
script.Config.Parent = script.PreloadService
print("["..Config.Name.."] \n Starting up...")
local CurrentVers, ModuleNotRequire, ModuleNotRequire.Parent = Config.Version, script.PreloadService, game.ReplicatedStorage
local Remotes = Instance.new("Folder")
Remotes.Name, Remotes.Parent = "PSRemotes", game.ReplicatedStorage
local PluginsRemotes = Instance.new("Folder")
PluginsRemotes.Name, PluginsRemotes.Parent = "PS_PluginsRemotes", Remotes
local NewPlayerClient = Instance.new("RemoteEvent", Remotes)
NewPlayerClient.Name = "NewPlayerClient"
local GivenAdmin, MPS, PlrCount, SpecialEvent = Instance.new("RemoteEvent"), game:GetService("MarketplaceService"), 0, Instance.new("RemoteEvent")
SpecialEvent.Name, SpecialEvent.Parent = "ServerCompleted", Remotes
local e1 = Instance.new("RemoteFunction")  
e1.Parent, e1.Name = Remotes, "GetServerIndexRemote"
local e2 = Instance.new("RemoteFunction")
e2.Parent, e2.Name = game.ReplicatedStorage, "TPRemote"
local e3 = Instance.new("RemoteEvent")
e3.Parent, e3.Name = Remotes, "CheckForUpdates"
local DSS = game:GetService("DataStoreService")

print("Started!")

-- The following code remakes the admin code to make sure nobody can get into it. It's Server-Sided but it's still nice to have an extra layer.

local AdminsScript, AdminIDs, GroupIDs = script.Admins, require(AdminsScript).Admins, require(AdminsScript).Groups
local players, LoadedModules, InGameAdmins, CompletedTimes, ServerLifetime = game:GetService("Players"), {}, {}, {}, 0
local Settings, PS, Decimals = require(game.ReplicatedStorage.PreloadService.Config)["Settings"], require(game.ReplicatedStorage.PreloadService), GetSetting("ShortNumberDecimals")

local function GetSetting(Setting)
	local SettingModule = Config["Settings"]
	return SettingModule[Setting]
end

local function Format(Int)
	return string.format("%02i", Int)
end

local function Average(Table)
	local number = 0
	for _, value in pairs(Table) do
		number += value
	end
	return number / #Table
end

local function Ban(Player) end

local kick, KickRem = game:GetService("DataStoreService"):GetDataStore("KickData"), Instance.new("RemoteEvent", Remotes)
KickRem.Name = "KickPlr"

KickRem.OnServerEvent:Connect(function(player, plrkicked) 
	for i, v in ipairs(InGameAdmins) do
		if player.UserId == v.UserId then
			game:GetService("MessagingService"):PublishAsync("KickPlayer_PS", plrkicked)
		else
			if GetSetting("BanForExploits") then
				Ban(player)
			end
		end
	end
end)

local function IsWidgetActive(plr, Widget)
	local DataStore = DSS:GetDataStore("PreloadService_Widgets")
	if DataStore:GetAsync(plr.Name.."-"..Widget) then
		local Data = DataStore:GetAsync(plr.Name.."-"..Widget)
		local IsEnabled = Data[2]
	end
end

local function WriteWidgetData(plr, Widget) end

local function n(admin, bodytext, headingtext, image, dur, t)
	local Placeholder  = Instance.new("Frame")
	Placeholder.Parent, Placeholder.BackgroundTransparency, Placeholder.Size = admin.PlayerGui.PreloadServiceAdminPanel.Notifications, 1, UDim2.new(0.996,0,0.096,0)
	local notif = admin.PlayerGui.PreloadServiceAdminPanel.Notifications.Template:Clone()
	notif.Position, notif.Visible, notif.Size, notif.Parent, notif.Body.Text, notif.Header.Title.Text, notif.Header.ImageL.Image = UDim2.new(0.4,0,0.904,0), true, UDim2.new(0.996,0,0.096,0), admin.PlayerGui.PreloadServiceAdminPanel.NotificationsTest, bodytext, headingtext, image                 
	local NewSound  = Instance.new("Sound")
	NewSound.Parent = notif
	if not t then NewSound.SoundId = "rbxassetid://9770089602" NewSound:Play() else NewSound.SoundId = "rbxassetid://9770087788" NewSound:Play() end
	local TS = game:GetService("TweenService")
	local NotifTween = TS:Create(
		notif,
		TweenInfo.new(
			0.4,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In,
			0,
			false,
			0
		),
		{
			Position = UDim2.new(-0.02,0,0.904,0)
		}
	)
	NotifTween:Play()
	NotifTween.Completed:Wait()
	Placeholder:Destroy()
	notif.Parent = admin.PlayerGui.PreloadServiceAdminPanel.Notifications
	task.wait(dur)
	local Placeholder2  = Instance.new("Frame")
	Placeholder2.Parent, Placeholder2.BackgroundTransparency, Placeholder2.Size = admin.PlayerGui.PreloadServiceAdminPanel.Notifications, 1, UDim2.new(0.996,0,0.096,0)
	notif.Parent = admin.PlayerGui.PreloadServiceAdminPanel.NotificationsTest
	local NotifTween2 = TS:Create(
		notif,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In,
			0,
			false,
			0
		),
		{
			Position = UDim2.new(1.8,0,0.904,0)
		}
	)
	NotifTween2:Play()
	NotifTween2.Completed:Wait()
	notif:Destroy()
	Placeholder2:Destroy()
end

local function NewNotification(admin, bodytext, headingtext, image, dur, t)
	task.spawn(n, admin, bodytext, headingtext, image, dur, t)
end

local function VersionCheck(plr, MAKE_THIS_FALSE)
	task.wait(2)
	if not table.find(InGameAdmins,plr) then
		warn("ERROR: Unexpected call of CheckForUpdates")
		plr:Kick("\n [PreloadService]: \n Unexpected Error:\n \n Exploits or non admin tried to fire CheckForUpdates. \n Developers, if this is in your code, then please do not fire it, that will result in players being kicked unexpectedly.\n Please only fire it from the Admin Panel, the remote is only for server communication. \n \n Error code 0x83jd29, end of error")
		while task.wait(.5) do
			warn("ERROR: Unexpected call of CheckForUpdates")
		end
	end
	local VersModule, Frame = require(8788148542), plr.PlayerGui.PreloadServiceAdminPanel.Main.Menu.Main.BUpdate
	if VersModule.Version ~= CurrentVers then
		Frame.Parent.AInfo.vers.Text = CurrentVers.." by DarkPixlz, 2022".."(latest avail: "..VersModule.Version..", released "..VersModule.ReleaseDate.."."
		warn("[PreloadService]: Out of date! Please update your module by closing this server.")
		Frame.Value.Value = tostring(math.random(1,100000000))
		NewNotification(plr, "Your module is out of date. Please update your module by closing the servers, then replace it in Studio.", "Version check complete", "rbxassetid://9894144899", 10)
	else
		Frame.Parent.AInfo.vers.Text = CurrentVers.." by DarkPixlz, 2022. Released "..VersModule.ReleaseDate.."."
	end
end

local function New(plr)
	table.insert(InGameAdmins, plr)
	task.wait(1.5)
	local NewPanel = script.PreloadServiceAdminPanel:Clone()
	NewPanel.Parent = plr.PlayerGui
	VersionCheck(plr, true)
	if game:GetService("RunService"):IsStudio() then
		NewPanel.Main.Header.ErrorFrame.Visible = true
		NewNotification(plr,"Sorry, but PreloadService Admin does not work in Studio. Pages do not operate and display data.","Error!","rbxassetid://9894144899",15, true)
	else
		task.spawn(NewNotification,plr,"Please wait, loading PreloadServiceAdmin Panel","PreloadService Admin Panel v"..CurrentVers,"rbxassetid://9894144899", 8)
	end

	for i, asset in pairs(NewPanel:GetDescendants()) do
		local succ, err = pcall(function()
			game:GetService("ContentProvider"):PreloadAsync({asset})
		end)
		if not succ then
			warn(asset.Name.." could not load. Error: "..err)
			NewNotification(plr,"Could not load "..asset.Name..", continuing to load...", "Could not load item!","rbxassetid://9894144899", 5)
		end
	end
	local Frame = plr.PlayerGui.PreloadServiceAdminPanel.Main.Menu.Main.BUpdate
	Frame.Parent.AInfo.vers.Text = CurrentVers.." by DarkPixlz, 2022. Licensed under TBD."
	NewNotification(plr,"PreloadService Admin Panel v"..CurrentVers.." loaded! Press "..GetSetting("PrefixString").." to enter the panel.","Welcome!","rbxassetid://10012255725",15)
end

players.PlayerAdded:Connect(function(plr)
	NewPlayerClient:FireAllClients(PlrCount)
	if table.find(AdminIDs, plr.UserId) then
		New(plr)
	else
		for i, v in pairs(GroupIDs) do
			if plr:IsInGroup(v) then
				New(plr)
				return
			end
		end
	end
end)

local function GetTimeWithSeconds(Seconds)
	local Minutes = (Seconds - Seconds%60)/60;
	Seconds = Seconds - Minutes*60;

	local Hours = (Minutes - Minutes%60)/60;
	Minutes = Minutes - Hours*60;
	if GetSetting("DisplayHours") then
		return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
	else
		return Format(Minutes)..":"..Format(Seconds)
	end

end

function GetShortNumer(Number)
	return math.floor(((Number < 1 and Number) or math.floor(Number) / 10 ^ (math.log10(Number) - math.log10(Number) % 3)) * 10 ^ (Decimals or 3)) / 10 ^ (Decimals or 3)..(({"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"})[math.floor(math.log10(Number) / 3)] or "")
end

local CurrentlyExisting = 0

--Thanks to @334901766 for helping out a bit

local function MakeLargeHistoryHomeWidget(Admin,PFP,Username,InstanceName,InstanceType,Time)
	CurrentlyExisting = #Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.Widgets.LargeHistory.Content:GetChildren()
	if CurrentlyExisting >= 49 then
		for i = 1, (CurrentlyExisting - 49) do
			Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget:FindFirstChildWhichIsA("Frame"):Destroy()
		end
	end
	CurrentlyExisting = #Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget:GetChildren()

	local NewCard = Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.Template:Clone()
	NewCard.Parent, NewCard.Visible, NewCard.Name, NewCard.PlayerImage.Image, NewCard.Username.Text, NewCard.Time.Text, NewCard.ItemName.Text = Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget, true, CurrentlyExisting, PFP, "@"..Username, Time, InstanceName
end

local function MakeHistory(Admin,PFP,Username,InstanceName,InstanceType,Time)
	CurrentlyExisting = #Admin.PlayerGui.PreloadServiceAdminPanel.Main.History.MainFrame:GetChildren()
	if CurrentlyExisting >= GetSetting("MaxHistoryItems") then
		for i = 1, (CurrentlyExisting - GetSetting("MaxHistoryItems")) do
			Admin.PlayerGui.PreloadServiceAdminPanel.Main.History.MainFrame:FindFirstChildWhichIsA("Frame"):Destroy()
		end
	end
	CurrentlyExisting = #Admin.PlayerGui.PreloadServiceAdminPanel.Main.History.MainFrame:GetChildren()

	local NewCard = Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.Template:Clone()
	NewCard.Parent, NewCard.Visible, NewCard.Name, NewCard.PlayerImage.Image, NewCard.Username.Text, NewCard.Time.Text, NewCard.ItemName.Text = Admin.PlayerGui.PreloadServiceAdminPanel.Main.History.MainFrame, true, CurrentlyExisting, PFP, "@"..Username, Time, InstanceName
end

local function MakeModuleHistoryCard(Admin,PFP,Username,InstanceName,InstanceType,Time)
	CurrentlyExisting = #Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget:GetChildren()
	if CurrentlyExisting >= 50 then
		for i = 1, (CurrentlyExisting - 50) do
			Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget:FindFirstChildWhichIsA("Frame"):Destroy()
		end
	end
	CurrentlyExisting = #Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget:GetChildren()

	local NewCard = Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.Template:Clone()
	NewCard.Parent, NewCard.Visible, NewCard.Name, NewCard.PlayerImage.Image, NewCard.Username.Text, NewCard.Time.Text, NewCard.Type.Text = Admin.PlayerGui.PreloadServiceAdminPanel.Main.Home.HistoryWidget, true, CurrentlyExisting, PFP, "@"..Username, Time, InstanceName
end

players.PlayerRemoving:Connect(function(plr)
	if table.find(InGameAdmins, plr) then table.remove(InGameAdmins, table.find(InGameAdmins, plr)) end
end)

SpecialEvent.OnServerEvent:Connect(function(PlayerLoaded, Time, ItemClass, ItemName, ModOrRegular, item)
	table.insert(CompletedTimes,Time)
	ServerLifetime += 1
	for i, v in ipairs(InGameAdmins) do
		if IsWidgetActive("LargeHistory") then
			MakeLargeHistoryHomeWidget(
				v,
				players:GetUserThumbnailAsync(PlayerLoaded.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
				PlayerLoaded.Name,
				ItemName,
				ItemClass,
				GetTimeWithSeconds(Time)
			)
		end

		local Frame = v.PlayerGui.PreloadServiceAdminPanel.Main.History.MainFrame
		if not Frame then
			warn("[PreloadService ERROR]: Could not find Summary of the main panel! \n Roblox error tree is below, it could be because you renamed the panel, or multiple UI's names 'panel' exist.")
			NewNotification(v, "ERROR: Could not find history page! More info in console", "Error", "rbxassetid://9894144899", 15)
		end
		if ItemClass ~= "ModuleScript" then
			MakeHistory(
				v,
				players:GetUserThumbnailAsync(PlayerLoaded.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
				PlayerLoaded.Name,
				ItemName,
				ItemClass,
				GetTimeWithSeconds(Time)
			)
			local Home = Frame.Parent.Parent.Home
			Home.total.Text, Home.avg.Text, Home.server.Text = GetShortNumer(#CompletedTimes).." total assets loaded", GetTimeWithSeconds(Average(CompletedTimes)).." average loading time, or lower", GetShortNumer(ServerLifetime).." assets loaded in server lifetime"
		else
			table.insert(LoadedModules, item)
			local new = Frame.Parent.Template:Clone()
			new.Visible, new.Parent, new.ItemName.Text, new.Type.Text = true, Frame, "Loaded "..ItemName, ItemClass
			if math.floor(Time) ~= 0 then new.Time.Text = GetTimeWithSeconds(Time) else new.Time.Text = "🎉 Below 0" end
			new.Username.Text = PlayerLoaded.DisplayName.."(@"..PlayerLoaded.Name..")"
			task.wait(Settings.renderTime)
			new.PlayerImage.Image = players:GetUserThumbnailAsync(PlayerLoaded.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			-- History
			local new = Frame.Parent.Parent.Modules.MainFrame.Template:Clone()
			new.Visible, new.Parent, new.ItemName.Text, new.Type.Text, new.Time.Text, new.Time.Text, new.Username.Text, new.thumbnail.Image = true, Frame.Parent.Parent.Modules.MainFrame, "Loaded "..ItemName, ItemClass, GetTimeWithSeconds(Time), PlayerLoaded.DisplayName.."(@"..PlayerLoaded.Name..")", players:GetUserThumbnailAsync(PlayerLoaded.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			local Home, ModulesFrame = Frame.Parent.Parent.Home, Frame.Parent.Parent.Modules
			Home.total.Text = GetShortNumer(#CompletedTimes).." Total Assets Loaded"
			--	Home.server.Text = GetShortNumer(ServerLifetime).." assets loaded in server lifetime"
			--	print(Home.server.Text..", "..ServerLifetime)
			if math.floor(Average(CompletedTimes)) ~= 0 then Home.avg.Text = GetTimeWithSeconds(Average(CompletedTimes)).." Average Loading Time" else Home.avg.Text = "🎉 Average is 0 or lower!" end
			if #LoadedModules ~= 1 then Home.modules.Text = GetShortNumer(#LoadedModules).." loaded modules" else Home.modules.Text = "1 loaded module" end
		end
	end
end)

e3.OnServerEvent:Connect(function(plr)
	task.wait(2)
	if not table.find(InGameAdmins,plr) then
		warn("ERROR: Unexpected call of CheckForUpdates")
		plr:Kick("\n [PreloadService]: \n Unexpected Error:\n \n Exploits or non admin tried to fire CheckForUpdates. \n Developers, if this is in your code, then please do not fire it, that will result in players being kicked unexpectedly.\n Please only fire it from the Admin Panel, the remote is only for server communication. \n \n Error code 0x83jd29, end of error")
		if GetSetting("BanForExploits") then
			Ban(plr)
		end
		while task.wait(.5) do
			warn("ERROR: Unexpected call of CheckForUpdates")
		end
	end
	local VersModule = require(8788148542)
	VersModule.Parent = script
	local Frame = plr.PlayerGui.PreloadServiceAdminPanel.Main.Menu.Main.BUpdate
	Frame.Parent.AInfo.vers.Text = CurrentVers.." by DarkPixlz, 2022".."(latest avail: "..VersModule.Version..", released "..VersModule.ReleaseDate..")."
	Frame.Value.Value = tostring(math.random(1,100000000))
	Frame.Parent.CLogs.log.Text = VersModule.ReleaseNotes
	Frame.Parent.CLogs.title.Text = "Update Logs (v"..VersModule.Version..")"
	if VersModule.Version ~= CurrentVers then
		warn("[PreloadService]: Out of date! Please update your module by closing this server.")
		Frame.Value.Value = tostring(math.random(1,100000000))
		NewNotification(plr, "Your module is out of date. Please update your module by closing the servers, then replace it in Studio.", "Version check complete", "rbxassetid://9894144899", 25)
	else
		NewNotification(plr, "Your module is up to date! Current: "..CurrentVers, "Version check complete", "rbxassetid://9894144899", 25)
	end
end)
