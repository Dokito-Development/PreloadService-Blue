-- PreloadService, DarkPixlz 2022-2023, v3. Do not claim as your own!
local Loader = {}
Loader.Completed = Instance.new("RemoteEvent")
repeat task.wait() until Loader.Completed
local Settings = require(script.Config)["Settings"]
function Print(msg)
	if Settings.PrintData == true then
		print("[PreloadService]: "..msg)
	end
end
Loader.GameLoaded = false
function Loader.Load(AssetsData, UIType, CustomUI, Code) 
	local ContentProvider = game:GetService("ContentProvider")
	local text
	local barImg
	local Frame
	local Type
	local DefaultUI = false
	local startTime = os.clock()
	if not AssetsData == nil then
		error("[PreloadService]: AssetsData is missing!")
	else
		DefaultUI = true
		if AssetsData == "Game" then
			Type = "Game"
			AssetsData = {
				game:GetService("HttpService"),
				game.Players.LocalPlayer.PlayerGui,
				game:GetService("Workspace"),
				game:GetService("Players"),
				game:GetService("NetworkClient"),
				game:GetService("ReplicatedFirst"),
				game:GetService("ReplicatedStorage"),
				game:GetService("ServerStorage"),
				game:GetService("StarterPack"),
				game:GetService("StarterPlayer"),
				game:GetService("Teams"),
				game:GetService("SoundService"),
				game:GetService("Chat"),
				game:GetService("LocalizationService"),
				game:GetService("Lighting")
			} 
		end
	end
			if CustomUI == nil then
		local DefaultUI = script.PreloadServiceLoadingUI:Clone()
		DefaultUI.Parent = game.Players.LocalPlayer.PlayerGui
		barImg = DefaultUI.Game.Bar.Progress
		if Type == "Game" then
			if not Settings.LightDefaultUI then
				UIType = "DarkGame"
				text = DefaultUI.Game.LoadingText
			else
				UIType = "LightGame"
				text = DefaultUI.GameLight.LoadingText
			end
		else
				UIType = "DarkOther"
				text = DefaultUI.Other.LoadingText
			else
				UIType = "LightOther"
				text = DefaultUI.OtherLight.LoadingText
			end
		end
	else
		text = CustomUI.LoadingText
		barImg = CustomUI.Bar.Progress
	end
	if UIType == "None" then
		text.Parent.Visible = false
	end
	text.Parent.Visible = true
	text.Text = "Loading.. ["..#AssetsData.."]"
	if not Settings.UseTweens and not CustomUI then
		text.Parent.Bar.LocalScript:Destroy()
	end
	task.wait(Settings.StartDelay)
	local succ, err = pcall(function()
		if CustomUI == nil then
			text.Parent.Bar.LocalScript:Destroy()
			barImg:TweenSizeAndPosition(UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 1, true)
		end
		for i = 1, #AssetsData do
			local startAssetTime = os.clock()
			local Asset = AssetsData[i]
			local Name = tostring(Asset.Name) or ""
			text.Text = "Loading "..Name.." [".. i .. " / "..#AssetsData.."]"
			
			if Asset.Name == "HttpService" then
				text.Text = "Pinging HttpService.."
			end
			
			ContentProvider:PreloadAsync({Asset})
			local TimeLoaded = os.clock() - startAssetTime
			task.wait(Settings.InBetweenAssetsDelay)
			local Progress = i / #AssetsData
			if Settings.UseTweens then
				barImg:TweenSize(UDim2.new(Progress, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true)
			else
				barImg.Size = UDim2.new(Progress, 0, 1, 0)
			end

			if not Asset:IsA("ModuleScript") then
				game.ReplicatedStorage.PSRemotes.ServerCompleted:FireServer(TimeLoaded, Asset.ClassName, Asset.Name,"Other", Asset)
			else
				require(Asset)
				game.ReplicatedStorage.PSRemotes.ServerCompleted:FireServer(TimeLoaded, Asset.ClassName, Asset.Name, "Module", Asset)
			end
			task.wait()
		end
	end)
	if not succ then
		warn("[PreloadService]: Could not preload an item! Error: "..err) 
		text.Text = "Failed to load. Error: "..err..". Please rejoin, and notify the game owner or developer."
		local End = {Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(255, 69, 72)}
		local Info = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2)
		local Tween = game:GetService("TweenService"):Create(barImg, Info, End)
		Tween:Play()
	else
		text.Text = "Finished!"
		local ItemsToTween = {}
		local TextToTween = {}
		local DefautUI = game.Players.LocalPlayer.PlayerGui.PreloadServiceLoadingUI
		local EndTime = os.clock() - startTime
		Print("Successfully loaded in "..math.round(EndTime).." seconds!")
		if DefaultUI then
			if Settings.AutoCloseUI then
				if not Settings.UseTweens then
					game.Players.LocalPlayer.PlayerGui.PreloadServiceLoadingUI:Destroy()
				else
					if UIType == "DarkGame" then
						ItemsToTween = {
							DefautUI.Game,
							DefautUI.Game.Bar,
							DefautUI.Game.Bar.Progress,
						}
						TextToTween = {
							DefautUI.Game.LoadingText,
							DefautUI.Game.MainLabel,
							DefautUI.Game.welcomeMessage,
						}
					elseif UIType == "LightGame" then
						ItemsToTween = {
							DefautUI.GameLight,
							DefautUI.GameLight.Bar,
							DefautUI.GameLight.Bar.Progress
						}
						TextToTween = {
							DefautUI.GameLight.LoadingText,
							DefautUI.GameLight.MainLabel,
							DefautUI.GameLight.welcomeMessage,
						}
					end
					if ItemsToTween ~= nil then
						for i = 1, 100 do
							task.wait(0.001)
							for i, asset in ipairs(ItemsToTween) do
								asset.BackgroundTransparency += 0.01
							end
							for i, asset in ipairs(TextToTween) do
								asset.BackgroundTransparency += 0.01
								asset.TextTransparency += 0.01
							end
						end
					end
					if UIType == "DarkOther" or "LightOther" then
						DefautUI.Other:TweenPosition(UDim2.new(0.328, 0, 2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, true)
						DefautUI.OtherLight:TweenPosition(UDim2.new(0.328, 0, 2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, true)
					end
				end
			end
			DefautUI:Destroy()
		end
		local succ1, err2 = pcall(function() Loader.Completed:FireClient(game.Players.LocalPlayer, EndTime, Code) Loader.Completed:FireServer(EndTime) end)
		if not succ1 then error(err2) return else end

	end
end

function Loader.BindFrame(Player, Frame)
	Print("Binding Frame...")
	local FindFrame = Player.PlayerGui:FindFirstDecendant(Frame.Name)
	if not FindFrame then
		Print('Could not bind frame. Error: Frame does not exist! ')
		return 
	end
	Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		Loader.Load(Frame:GetDecendants(), "None", nil)
	end)
end


function Loader.Print()
	warn("[PreloadService]: Print is an internal function and cannot be used otherwise.")
end

function Loader.FireModule(Module)
	Loader.Load({Module}, "None", nil, "PS_INTERNAL_MODULE")
	Loader.Completed.OnClientEvent:Connect(function(Time,Key)
		if Key == "PS_INTERNAL_MODULE" then
			Module.Fire()
		end
	end)
end

return Loader
