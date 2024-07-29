local settings = {
	WalkSpeed = .5,
	--SkinChanger = true,
	HUDChange = true,
	HasLantern = true
}

local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local players = game:GetService("Players")
local debris = game:GetService("Debris")
local stats = game:GetService("Stats")

local localPlayer = players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local playerModule = require(localPlayer.PlayerScripts.PlayerModule)
local playerControls = playerModule:GetControls()

local rootPart = character:WaitForChild("HumanoidRootPart", math.huge)
local humanoid = character:WaitForChild("Humanoid", math.huge)

local mouse = localPlayer:GetMouse()
local camera = workspace.CurrentCamera
local backpack = localPlayer.Backpack

local enmaU = backpack:FindFirstChild("EnmaU") or character:FindFirstChild("EnmaU")
local lantern = backpack:FindFirstChild("[Lantern]") or character:FindFirstChild("[Lantern]")

local katana = backpack:FindFirstChild("[Katana]") or character:FindFirstChild("[Katana]")
local fist = backpack:FindFirstChild("Fist") or character:FindFirstChild("Fist")
local knife = backpack:FindFirstChild("[Knife]") or character:FindFirstChild("[Knife]")
local molotov = backpack:FindFirstChild("[Molotov]") or character:FindFirstChild("[Molotov]")
local boombox = backpack:FindFirstChild("[Boombox]") or character:FindFirstChild("[Boombox]")

local isEquipped = false
local isRunning = false
local isSurfing = false
local isHovering = false
local onCooldown = false
local gripSpin = false
local canAttack = true

local enmaStomp = nil
local counterStomp = nil
local stopConnection = nil
local speedConnection = nil
local heartbeatLoop = nil
local connections = {}

local surfGyro = nil
local surfVelocity = nil
local surfPosition = nil

if not katana or not knife or not molotov then
	starterGui:SetCore("SendNotification", {
		Title = "EnmaU",
		Text = "Tools Needed | Katana / Knife",
		Icon = "rbxassetid://420885738"
	})

	local oldPos = CFrame.new(rootPart.Position)

	if not katana then
		local headCFrame = workspace.Ignored.Shop.Others["[Katana] - $1200"].Head.CFrame

		repeat
			rootPart.CFrame = headCFrame * CFrame.new(0,3,0)
			fireclickdetector(workspace.Ignored.Shop.Others["[Katana] - $1200"].ClickDetector)

			runService.Heartbeat:Wait()
		until backpack:FindFirstChild("[Katana]") or character:FindFirstChild("[Katana]")

		katana = backpack:FindFirstChild("[Katana]") or character:FindFirstChild("[Katana]")

		if knife then
			rootPart.CFrame = oldPos
			rootPart.AssemblyLinearVelocity = Vector3.new()
		end
	end

	if not knife then
		local headCFrame = workspace.Ignored.Shop.Others["[Knife] - $125"].Head.CFrame

		repeat
			rootPart.CFrame = headCFrame * CFrame.new(0,3,0)
			fireclickdetector(workspace.Ignored.Shop.Others["[Knife] - $125"].ClickDetector)

			runService.Heartbeat:Wait()
		until backpack:FindFirstChild("[Knife]") or character:FindFirstChild("[Knife]")

		knife = backpack:FindFirstChild("[Knife]") or character:FindFirstChild("[Knife]")

		if molotov then
			rootPart.CFrame = oldPos
			rootPart.AssemblyLinearVelocity = Vector3.new()
		end
	end

	if not molotov then
		local headCFrame = workspace.Ignored.Shop.Others["[Molotov] - $850"].Head.CFrame

		repeat
			rootPart.CFrame = headCFrame * CFrame.new(0,3,0)
			fireclickdetector(workspace.Ignored.Shop.Others["[Molotov] - $850"].ClickDetector)

			runService.Heartbeat:Wait()
		until backpack:FindFirstChild("[Molotov]") or character:FindFirstChild("[Molotov]")

		molotov = backpack:FindFirstChild("[Molotov]") or character:FindFirstChild("[Molotov]")

	
		rootPart.CFrame = oldPos
		rootPart.AssemblyLinearVelocity = Vector3.new()
	end

end

if enmaU then
	enmaU:Destroy()
	wait(0.1)
end

enmaU = Instance.new("Tool")
enmaU.Name = "EnmaU"
enmaU.Parent = backpack
enmaU.RequiresHandle = false
enmaU.CanBeDropped = false

starterGui:SetCore("SendNotification",{
	Title = "EnmaU",
	Text = "Credits to Plague, Rewritten by Villain!",
	Icon = "rbxassetid://420885738"
})

local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://4708191566"
local loadIdle = humanoid:LoadAnimation(idleAnim)
loadIdle.Priority = Enum.AnimationPriority.Action2

local idleAnimationTwo = Instance.new("Animation")
idleAnimationTwo.AnimationId = "rbxassetid://16679109994"
local loadIdleTwo = humanoid:LoadAnimation(idleAnimationTwo)
loadIdleTwo.Priority = Enum.AnimationPriority.Action2

local walkAnimation = Instance.new("Animation")
walkAnimation.AnimationId = "rbxassetid://4708193840"
local loadWalk = humanoid:LoadAnimation(walkAnimation)
loadWalk.Priority = Enum.AnimationPriority.Action2

local swordIdleWalkPose = Instance.new("Animation")
swordIdleWalkPose.AnimationId = "rbxassetid://2410679501"
local swordIdle = humanoid:LoadAnimation(swordIdleWalkPose)
swordIdle.Priority = Enum.AnimationPriority.Action3

local runAnimation = Instance.new("Animation")
runAnimation.AnimationId = "rbxassetid://14777024220"
local loadRun = humanoid:LoadAnimation(runAnimation)
loadRun.Priority = Enum.AnimationPriority.Action3

local flyAnimation = Instance.new("Animation")
flyAnimation.AnimationId = "rbxassetid://10714330764"
local loadFly = humanoid:LoadAnimation(flyAnimation)
loadFly.Priority = Enum.AnimationPriority.Action4

local flyAnimationTwo = Instance.new("Animation")
flyAnimationTwo.AnimationId = "rbxassetid://10370351535"
local loadFlyTwo = humanoid:LoadAnimation(flyAnimationTwo)
loadFlyTwo.Priority = Enum.AnimationPriority.Action4

--[[coroutine.wrap(function()
	while true do
		if not katana then
			break
		end

		if settings.SkinChanger and isEquipped then
			local mainRemote = replicatedStorage:WaitForChild("MainRemote")

			local skinIds = {
				"163143622",
				"14543275895"
			}

			for _, skinId in ipairs(skinIds) do
				mainRemote:FireServer("Skin", skinId)

				wait()
			end
		end

		wait()
	end
end)()]]

local function reach()
	pcall(function()
		for _, player in next, players:GetPlayers() do
			if player ~= localPlayer then
				if player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
				end
			end
		end

		knife.Handle.Size = Vector3.new(15,15,15)
		knife.Handle.Transparency = 1
	end)
end

local function noReach()
	pcall(function()
		for _, player in next, players:GetPlayers() do
			if player ~= localPlayer then
				if player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.Size = Vector3.new(5.728994846343994, 4.480000972747803, 3.1827750205993652)
				end
			end
		end

		knife.Handle.Size = Vector3.new(2.195742607116699, 0.4492877125740051, 0.10249516367912292)
		knife.Handle.Transparency = 0
	end)
end

local function normalKnifeGrip()
	knife.Grip = CFrame.new(0.814398646, 0.118087336, 0.0173183531, 0.102999449, -0.994626582, -0.0104389191, 0.100865066, 3.4570694e-06, 0.994899988, -0.989554048, -0.103527039, 0.100323439) * CFrame.Angles(0, 0, 0)
	knife.Parent = character
	knife.Parent = backpack
end
local function chat(input)
	replicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(input, "All")
end

local function playAudio(ID)
	humanoid:UnequipTools()
	boombox.Parent = character

	replicatedStorage.MainRemote:FireServer("Play", ID)
	replicatedStorage.MainRemote:FireServer("Remove")

	boombox.Parent = backpack
	humanoid:EquipTool(enmaU)
end

local function mute()
	humanoid:UnequipTools()
	boombox.Parent = character

	replicatedStorage.MainRemote:FireServer("Stop")
	replicatedStorage.MainRemote:FireServer("Remove")

	boombox.Parent = backpack
	humanoid:EquipTool(enmaU)
end


local function playSFXAudio(ID)
	katana.Parent = backpack

	if settings.HasLantern then
		lantern.Parent = backpack
	end

	boombox.Parent = character

	replicatedStorage.MainRemote:FireServer("Play", ID)
	replicatedStorage.MainRemote:FireServer("Remove")

	boombox.Parent = backpack
	katana.Parent = character

	if settings.HasLantern then
		lantern.Parent = character
	end
end

local function playAnimation(ID, SPEED, TIMEPOS)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. ID

	local loadAnimation = humanoid:LoadAnimation(animation)
	loadAnimation.Priority = Enum.AnimationPriority.Action4
	loadAnimation:Play()
	loadAnimation:AdjustSpeed(SPEED)
	loadAnimation.TimePosition = TIMEPOS

	return loadAnimation
end

local function inputBegan(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then
		return
	end

	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
		if loadIdle.IsPlaying then
			loadIdle:Stop()
		end

		if loadIdleTwo.IsPlaying then
			loadIdleTwo:Stop()
		end

		if isRunning and not loadRun.IsPlaying then
			loadRun:Play()
			loadRun:AdjustSpeed(1.25)

			swordIdle:Play()
			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.23
		end

		if not isRunning and not loadWalk.IsPlaying then
			loadWalk:Play()
			swordIdle:Play()

			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.27
		end
	end
end

local function inputEnded(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then
		return
	end

	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
		if not userInputService:IsKeyDown(Enum.KeyCode.W) and not userInputService:IsKeyDown(Enum.KeyCode.A) and not userInputService:IsKeyDown(Enum.KeyCode.S) and not userInputService:IsKeyDown(Enum.KeyCode.D) then
			if loadWalk.IsPlaying then
				loadWalk:Stop()
			end

			if loadRun.IsPlaying then
				loadRun:Stop()
			end

			loadIdle:Play()
			loadIdleTwo:Play()
			swordIdle:Play()

			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.27
		end
	end
end

local function runningStarted(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		isRunning = true

		if humanoid.MoveDirection.Magnitude > 0 then
			loadRun:Play()
			loadRun:AdjustSpeed(1.25)

			swordIdle:Play()
			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.23
		end
	end
end

local function runningStopped(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		isRunning = false

		if loadRun.IsPlaying then
			loadRun:Stop()
		end

		loadWalk:Play()
		swordIdle:Play()

		swordIdle:AdjustSpeed(0)
		swordIdle.TimePosition = 0.27
	end
end

local function nearestCharacter()
	local closestCharacter = nil
	local currentDistance = math.huge

	for _, char in next, workspace:GetDescendants() do
		if char:IsA("Model") and char ~= character then
			if char:FindFirstChild("HumanoidRootPart") then
				if char:FindFirstChild("I_LOADED_I") then
					local loaded = char:FindFirstChild("I_LOADED_I")
					local ragdoll = loaded:FindFirstChild("Ragdoll")

					if ragdoll then
						if not ragdoll.Value then
							local playerChar = char
							local playerRoot = playerChar.PrimaryPart

							local rootPosition = playerRoot.Position
							local onScreenPosition, isVisible = camera:WorldToScreenPoint(rootPosition)

							if isVisible then
								local mousePosition = Vector2.new(mouse.X, mouse.Y)
								local magnitude = (Vector2.new(onScreenPosition.X, onScreenPosition.Y) - mousePosition).Magnitude

								if magnitude < currentDistance then
									closestCharacter = char
									currentDistance = magnitude
								end
							end
						end
					end
				end
			end
		end
	end

	return closestCharacter
end

local function charInfront()
	local characterInfront = nil

	for _, char in next, workspace:GetDescendants() do
		if char:IsA("Model") and char ~= character then
			if char:FindFirstChild("HumanoidRootPart") then
				if char:FindFirstChild("I_LOADED_I") then
					local loaded = char:FindFirstChild("I_LOADED_I")
					local ragdoll = loaded:FindFirstChild("Ragdoll")

					if ragdoll then
						if not ragdoll.Value then
							local playerChar = char
							local playerRoot = playerChar.PrimaryPart

							local charUnit = (playerRoot.Position - rootPart.Position).Unit
							local charMag = (playerRoot.Position - rootPart.Position).Magnitude
							local charLook = rootPart.CFrame.LookVector

							local dotProduct = charUnit:Dot(charLook)

							if dotProduct > .85 and dotProduct < 1 and charMag <= 35 then
								characterInfront = char
							end
						end
					end
				end
			end
		end
	end

	return characterInfront
end

local function charInTarget()
	local closestCharacter = nil
	local currentDistance = math.huge

	for _, player in next, game.Players:GetPlayers() do
		if player ~= localPlayer then
			if player.Character then
				if player.Character:FindFirstChildWhichIsA("Humanoid") and player.Character:FindFirstChild("I_LOADED_I") then
					local loaded = player.Character:FindFirstChild("I_LOADED_I")

					if loaded then
						local ragdoll = loaded:FindFirstChild("Ragdoll")

						if ragdoll then
							if not ragdoll.Value then
								local playerChar = player.Character
								local playerRoot = playerChar.PrimaryPart

								local rootPosition = playerRoot.Position
								local onScreenPosition, isVisible = camera:WorldToScreenPoint(rootPosition)

								if isVisible then
									local mousePosition = Vector2.new(mouse.X, mouse.Y)
									local magnitude = (Vector2.new(onScreenPosition.X, onScreenPosition.Y) - mousePosition).Magnitude

									if magnitude < currentDistance then
										closestCharacter = player.Character
										currentDistance = magnitude
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return closestCharacter
end

local function getPrediction(targetRoot, targetHumanoid)
	for i=1, 30 do
		if not targetRoot or not targetHumanoid then
			return
		end

		local hipHeight = targetHumanoid.HipHeight * math.sin(i/2)

		if targetHumanoid.MoveDirection.Magnitude == 0 then
			return CFrame.new(targetRoot.Position) * CFrame.new(0, 3.5, 0)
		else
			local pingValue = stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			local walkSpeed = pingValue / 60 + targetHumanoid.WalkSpeed * math.sin(i/4)
			local moveDir = targetHumanoid.MoveDirection

			return CFrame.new(targetRoot.Position + Vector3.new((moveDir.X + .01) * walkSpeed, hipHeight, (moveDir.Z + .01) * walkSpeed))
		end
	end
end

local currentCharacter = nil
local breakTime = false

local function getGrip(arm)
	local cf = getPrediction(currentCharacter.HumanoidRootPart, currentCharacter.Humanoid)

	return arm:toObjectSpace(cf):Inverse()
end

local function teleportGrip(toolName)
	while task.wait(0.0175) do
		if breakTime or not onCooldown then
			break
		end

		local rightArmCFrame = localPlayer.Character["RightHand"].CFrame * CFrame.new(0, -1 ,0, 1, 0, 0, 0, 0, 1, 0, -1, 0)

		if currentCharacter then
			pcall(function()
				local grip = getGrip(rightArmCFrame)

				localPlayer.Character:WaitForChild(toolName).Grip = grip

				localPlayer.Character[toolName].Parent = localPlayer.Backpack
				localPlayer.Backpack[toolName].Parent = localPlayer.Character
			end)
		end
	end

	normalKnifeGrip()
end

local function useFistsHeavy()
	fist.Parent = character
	fist:Activate()

	fist.Parent = backpack
end

local function useKnifeHeavy()
	knife.Parent = character
	knife:Activate()

	knife.Parent = backpack
	task.wait(1.35)

	knife.Parent = character
	task.wait(1.10)

	knife.Parent = backpack
end

local function useFists()
	fist.Parent = character

	fist:Activate()
	fist:Deactivate()

	fist.Parent = backpack
end

local function useKnife()
	local oldGrip = knife.Grip

	knife.Grip = CFrame.new(-1.25, 0, 0) * CFrame.Angles(2, 46, 0)
	knife.Parent = character

	knife:Activate()
	knife:Deactivate()

	task.wait(.5)

	knife.Parent = backpack
	knife.Grip = oldGrip
end

local function normalHoldGrip()
	katana.Grip = CFrame.new(0,0,-0.10) * CFrame.Angles(math.rad(-85), math.rad(0), 0)
	katana.Parent = backpack
	katana.Parent = character
end

local function backwardsHoldGrip()
	katana.Grip = CFrame.new(0, 0, -0.25) * CFrame.Angles(math.rad(90), math.rad(180), math.rad(0))
	katana.Parent = backpack
	katana.Parent = character
end

local function spinGrip()
	gripSpin = true

	coroutine.wrap(function()
		while gripSpin do
			for i = 0, 10 do
				if not gripSpin then
					break
				end

				katana.Grip = CFrame.new(0,0,-0.10) * CFrame.Angles(math.rad(-85), math.rad(0), i)
				task.wait()
			end
		end
	end)()

	coroutine.wrap(function()
		while gripSpin do
			katana.Parent = backpack
			katana.Parent = character
            task.wait(0.03)
		end
	end)()

end

local function endSpinGrip()
	gripSpin = false
	task.wait(.5)

	katana.Parent = backpack
	katana.Parent = character
end

local function spinGripOnce(SPEED, DELAYTIME)
	gripSpin = true

	coroutine.wrap(function()
		while gripSpin do
			for i = 0, 25, SPEED do
				if not gripSpin then
					break
				end
				
				katana.Grip = CFrame.new(0,0,-0.10) * CFrame.Angles(math.rad(-85), math.rad(0), i)
				starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
				task.wait()
			end
		end
	end)()

    coroutine.wrap(function()
		while gripSpin do
			katana.Parent = backpack
			katana.Parent = character
            task.wait(0.03)
		end
	end)()

	task.wait(DELAYTIME)
	gripSpin = false
	normalHoldGrip()
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end

local function flyGrip()
	katana.Grip = CFrame.new(-5.60, 1.92, -1.50) * CFrame.Angles(0, math.rad(100), math.rad(90))
	katana.Parent = backpack
	katana.Parent = character
end

local function flyGripTwo()
	katana.Grip = CFrame.new(-0.20, 0.10, -1.80) * CFrame.Angles(1.25, math.rad(-94), 2.33)
	katana.Parent = backpack
	katana.Parent = character
end

local function Roll()
	local animation = playAnimation(14776851977, 2, 0)
	--playAudio(7346580257)

	local bodyVelocity = Instance.new("BodyVelocity", rootPart)
	bodyVelocity.Name = "N/A_S"
	bodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
	bodyVelocity.P = 1250
	bodyVelocity.Velocity = rootPart.CFrame.LookVector * 150 + Vector3.new(0, 20, 0)

	animation.Stopped:Connect(function()
		if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
			if loadIdle.IsPlaying then
				loadIdle:Stop()
			end

			if loadIdleTwo.IsPlaying then
				loadIdleTwo:Stop()
			end

			if isRunning and not loadRun.IsPlaying then
				loadRun:Play()
				loadRun:AdjustSpeed(1.25)

				swordIdle:Play()
				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.23
			end

			if not isRunning and not loadWalk.IsPlaying then
				loadWalk:Play()
				swordIdle:Play()

				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.27
			end
		else
			if loadWalk.IsPlaying then
				loadWalk:Stop()
			end

			if loadRun.IsPlaying then
				loadRun:Stop()
			end

			loadIdle:Play()
			loadIdleTwo:Play()
			swordIdle:Play()

			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.27
		end
	end)

	debris:AddItem(bodyVelocity, .1)
end

local function M1()
	if not onCooldown then
		onCooldown = true

		if stopConnection and stopConnection.Connected then
			stopConnection:Disconnect()
		end

		normalKnifeGrip()

		local stopped = false

		stopConnection = runService.PreAnimation:Connect(function()
			for _, track in next, humanoid:GetPlayingAnimationTracks() do
				if track and track.Animation and track.Animation.AnimationId == "rbxassetid://14776835565" then
					track:Stop()
					stopped = true
					stopConnection:Disconnect()
				end
			end
		end)

		coroutine.wrap(function()
			repeat
				task.wait(0)
			until stopped

			local swing = playAnimation(14776835565, 0.90, 0)

			task.wait(.7)
			swing:Stop()

			swing = playAnimation(14776835565, 2, .70)
		end)()

		coroutine.wrap(function()
			katana:Activate()
			katana:Deactivate()
		end)()

		coroutine.wrap(function()
			for i=1, 2 do
				useKnife()

				repeat
					wait()
				until not character["I_LOADED_I"].Attacking.Value
			end
		end)()

		coroutine.wrap(function()
			for i=1, 2 do
				useFists()

				repeat
					wait()
				until not character["I_LOADED_I"].Attacking.Value
			end

			if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
				if loadIdle.IsPlaying then
					loadIdle:Stop()
				end

				if loadIdleTwo.IsPlaying then
					loadIdleTwo:Stop()
				end

				if isRunning and not loadRun.IsPlaying then
					loadRun:Play()
					loadRun:AdjustSpeed(1.25)

					swordIdle:Play()
					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.23
				end

				if not isRunning and not loadWalk.IsPlaying then
					loadWalk:Play()
					swordIdle:Play()

					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.27
				end
			else
				if loadWalk.IsPlaying then
					loadWalk:Stop()
				end

				if loadRun.IsPlaying then
					loadRun:Stop()
				end

				loadIdle:Play()
				loadIdleTwo:Play()
				swordIdle:Play()

				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.27
			end
		end)()

		task.wait(2.30)

		onCooldown = false
		stopped = false
	end
end

local function M1Combo()
	if not onCooldown then
		onCooldown = true

		normalKnifeGrip()

		coroutine.wrap(function()
			playAudio(405593386)
			task.wait(2.58)

			playAudio(405596045)
			backwardsHoldGrip()
		end)()

		coroutine.wrap(function()
			spinGrip()
			task.wait(1.50)

			endSpinGrip()
		end)()

		coroutine.wrap(function()
			local animation = playAnimation(15609333208, 0.1, 3)
			task.wait(1.50)

			animation:Stop()
		end)()

		coroutine.wrap(function()
			katana:Activate()
			useFistsHeavy()
			task.wait(1.50)

			local animation = playAnimation(15609333208, 2, 3)
			task.wait(.8)

			animation:Stop()
			backwardsHoldGrip()

			animation = playAnimation(16853374695, 0.6, 0)
			task.wait(1)

			animation:Stop()
			normalHoldGrip()
		end)()

		coroutine.wrap(function()
			task.wait(.25)

			useKnifeHeavy()

			if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
				if loadIdle.IsPlaying then
					loadIdle:Stop()
				end

				if loadIdleTwo.IsPlaying then
					loadIdleTwo:Stop()
				end

				if isRunning and not loadRun.IsPlaying then
					loadRun:Play()
					loadRun:AdjustSpeed(1.25)

					swordIdle:Play()
					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.23
				end

				if not isRunning and not loadWalk.IsPlaying then
					loadWalk:Play()
					swordIdle:Play()

					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.27
				end
			else
				if loadWalk.IsPlaying then
					loadWalk:Stop()
				end

				if loadRun.IsPlaying then
					loadRun:Stop()
				end

				loadIdle:Play()
				loadIdleTwo:Play()
				swordIdle:Play()

				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.27
			end
		end)()

		task.wait(5)
		onCooldown = false
	end
end

local function Romedia()
	if not onCooldown then
		onCooldown = true
		currentCharacter = charInfront()

		if not currentCharacter or not currentCharacter:FindFirstChildWhichIsA("Humanoid") then
			onCooldown = false

			return
		end

		coroutine.wrap(function()
			playAudio(160212718)
			backwardsHoldGrip()

			task.wait(2)

			playAudio(5989940988)
			backwardsHoldGrip()
		end)()

		coroutine.wrap(function()
			local animation = playAnimation(16853374695, 0, 0)
			task.wait(.35)

			knife.Parent = character
			knife:Activate()
			knife.Parent = backpack
			task.wait(.65)

			knife.Parent = character

			task.spawn(function()
				breakTime = false

				teleportGrip("[Knife]")
			end)

			task.wait(3)
			breakTime = true
			animation:Stop()
			normalHoldGrip()

			if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
				if loadIdle.IsPlaying then
					loadIdle:Stop()
				end

				if loadIdleTwo.IsPlaying then
					loadIdleTwo:Stop()
				end

				if isRunning and not loadRun.IsPlaying then
					loadRun:Play()
					loadRun:AdjustSpeed(1.25)

					swordIdle:Play()
					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.23
				end

				if not isRunning and not loadWalk.IsPlaying then
					loadWalk:Play()
					swordIdle:Play()

					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.27
				end
			else
				if loadWalk.IsPlaying then
					loadWalk:Stop()
				end

				if loadRun.IsPlaying then
					loadRun:Stop()
				end

				loadIdle:Play()
				loadIdleTwo:Play()
				swordIdle:Play()

				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.27
			end
		end)()

		task.wait(4)
		onCooldown = false
	end
end

local function HuntingDragon()
	if not onCooldown then
		onCooldown = true

		local bodyVelocity = nil
		local enabled = true

		normalKnifeGrip()

		coroutine.wrap(function()
			task.wait(1.5)

			bodyVelocity = Instance.new("BodyVelocity", rootPart)
			bodyVelocity.MaxForce = Vector3.new(9999, 0, 9999)

			while enabled do
				task.wait(0)
				bodyVelocity.Velocity = rootPart.CFrame.lookVector * 200
			end
		end)()

		coroutine.wrap(function()
			playAudio(8845780263)
			task.wait(1)
			mute()

			playAudio(4973938323)
			task.wait(2.30)
			mute()
		end)()

		coroutine.wrap(function()
			local animation = playAnimation(15875438573, 1, 0)
			task.wait(1)
			animation:Stop()

			playAnimation(15875361013, 0.80, 0)
		end)()

		coroutine.wrap(function()
			katana:Activate()
			task.wait(.1)

			useFistsHeavy()
		end)()

		coroutine.wrap(function()
			task.wait(.2)

			local oldGrip = knife.Grip

			knife.Grip = CFrame.new(-1.25, 0, 0) * CFrame.Angles(2, 46, 0)
			knife.Parent = character
			knife:Activate()
			task.wait(1)

			knife.Parent = character
			task.wait(1.30)
			knife.Parent = backpack
			knife.Grip = oldGrip
		end)()

		wait(2.30)
		enabled = false
		debris:AddItem(bodyVelocity, 0)

		task.wait(2)
		onCooldown = false
	end
end

local function EnmaBlitz()
	if not onCooldown then
		onCooldown = true

		local closestCharacter = nearestCharacter()

		if not closestCharacter or not closestCharacter:FindFirstChildWhichIsA("Humanoid") then
			onCooldown = false

			return
		end

		local targetHumanoid = closestCharacter:FindFirstChildWhichIsA("Humanoid")
		local targetRoot = closestCharacter:FindFirstChild("HumanoidRootPart")
		local oldCFrame = rootPart.CFrame

		local teleportEnabled = true

		coroutine.wrap(function()
			katana:Activate()
			task.wait(1.55)

			repeat
				rootPart.CFrame = getPrediction(targetRoot, targetHumanoid)
				runService.RenderStepped:Wait()
			until not teleportEnabled
		end)()

		coroutine.wrap(function()
			useFistsHeavy()
		end)()

		coroutine.wrap(function()
			task.wait(1.5)

			local animation = playAnimation(14776835565, 1, 0)
			task.wait(.6)

			animation:Stop()

			if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
				if loadIdle.IsPlaying then
					loadIdle:Stop()
				end

				if loadIdleTwo.IsPlaying then
					loadIdleTwo:Stop()
				end

				if isRunning and not loadRun.IsPlaying then
					loadRun:Play()
					loadRun:AdjustSpeed(1.25)

					swordIdle:Play()
					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.23
				end

				if not isRunning and not loadWalk.IsPlaying then
					loadWalk:Play()
					swordIdle:Play()

					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.27
				end
			else
				if loadWalk.IsPlaying then
					loadWalk:Stop()
				end

				if loadRun.IsPlaying then
					loadRun:Stop()
				end

				loadIdle:Play()
				loadIdleTwo:Play()
				swordIdle:Play()

				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.27
			end
		end)()

		task.wait(1.90)
		teleportEnabled = false
		rootPart.CFrame = oldCFrame

		task.wait(3)
		onCooldown = false
	end
end

local function Blink()
	if not onCooldown then
		onCooldown = true

		local closestCharacter = nearestCharacter()

		if not closestCharacter or not closestCharacter:FindFirstChildWhichIsA("Humanoid") then
			onCooldown = false

			return
		end

		local targetRoot = closestCharacter:FindFirstChild("HumanoidRootPart")
		local enabled = false
		local endLoop = false

		coroutine.wrap(function()
			playAudio(7288361610)
			task.wait(1.90)

			for i = 1,6 do
				task.wait(.12)
				playAudio(5989944913)
			end

			task.wait(.15)
			playAudio(5989940114)
		end)()

		coroutine.wrap(function()
			local animation = playAnimation(15609333208, 1, 1)
			task.wait(2)
			animation:Stop()

			animation = playAnimation(15609333208, 1.90, 3)
			task.wait(1.10)
			animation:Stop()

			animation = playAnimation(14776851977, 0, 1)
			task.wait(2)
			animation:Stop()
		end)()

		coroutine.wrap(function()
			enabled = true
			task.wait(2)

			coroutine.wrap(function()
				while enabled do
					if endLoop then
						break
					end

					rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 10)
					runService.Heartbeat:Wait()
				end
			end)()

			task.wait(1)
			enabled = false

			task.wait(.1)
			enabled = true

			coroutine.wrap(function()
				while enabled do
					if endLoop then
						break
					end

					rootPart.CFrame = targetRoot.CFrame * CFrame.new(0,0,-32)
					task.wait(0)
				end
			end)()

			task.wait(2)
			enabled = false
			endLoop = true
		end)()

		coroutine.wrap(function()
			task.wait(3.05)

			katana.Grip = CFrame.new(-4.50, -5, -36) * CFrame.Angles(0, math.rad(60), math.rad(-20))
			katana.Parent = backpack
			katana.Parent = character
			task.wait(2)

			normalHoldGrip()
		end)()

		coroutine.wrap(function()
			spinGripOnce(0.10, 1)
		end)()

		coroutine.wrap(function()
			task.wait(1.8)

			katana:Activate()

			rootPart.AssemblyLinearVelocity = Vector3.new()

			if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
				if loadIdle.IsPlaying then
					loadIdle:Stop()
				end

				if loadIdleTwo.IsPlaying then
					loadIdleTwo:Stop()
				end

				if isRunning and not loadRun.IsPlaying then
					loadRun:Play()
					loadRun:AdjustSpeed(1.25)

					swordIdle:Play()
					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.23
				end

				if not isRunning and not loadWalk.IsPlaying then
					loadWalk:Play()
					swordIdle:Play()

					swordIdle:AdjustSpeed(0)
					swordIdle.TimePosition = 0.27
				end
			else
				if loadWalk.IsPlaying then
					loadWalk:Stop()
				end

				if loadRun.IsPlaying then
					loadRun:Stop()
				end

				loadIdle:Play()
				loadIdleTwo:Play()
				swordIdle:Play()

				swordIdle:AdjustSpeed(0)
				swordIdle.TimePosition = 0.27
			end
		end)()

		task.wait(6)
		onCooldown = false
	end
end

local function Counter()
	local counterTarget = nil
	local startTick = tick()

	connections = {}

	onCooldown = true

	normalKnifeGrip()

	task.spawn(function()
		chat("Without a trace..")
		local anim = playAnimation(16782477765, 0.40, 0)
		wait(5)
		anim:Stop()
	end)

	task.spawn(function()
		repeat task.wait(0) until tick() > startTick + 5

		for _, connection in next, connections do
			if connection.Connected then
				connection:Disconnect()
			end
		end
	end)

	task.spawn(function()
		for _, char in next, workspace:GetDescendants() do
			if char:IsA("Model") and char ~= character then
				if char:FindFirstChild("HumanoidRootPart") then
					if char:FindFirstChild("I_LOADED_I") then
						local loaded = char:FindFirstChild("I_LOADED_I")
						local ragdoll = loaded:FindFirstChild("Ragdoll")

						if ragdoll then
							if not ragdoll.Value then
								if loaded:FindFirstChild("Attacking") then
									local attacking = loaded:FindFirstChild("Attacking")

									local connection1 = attacking:GetPropertyChangedSignal("Value"):Connect(function()
										if (char.PrimaryPart.Position - rootPart.Position).Magnitude <= 10 then
											task.spawn(function()
												replicatedStorage.MainRemote:FireServer("Block", false)

												wait(1)

												replicatedStorage.MainRemote:FireServer("Block", true)
											end)

											counterTarget = char
										end
									end)


									local connection2 = char.ChildAdded:Connect(function(child)
										if child:IsA("Highlight") then
											if (char.PrimaryPart.Position - rootPart.Position).Magnitude <= 3 then
												task.spawn(function()
													replicatedStorage.MainRemote:FireServer("Block", false)

													wait(.25)

													replicatedStorage.MainRemote:FireServer("Block", true)
												end)

												counterTarget = char
											end
										end
									end)

									table.insert(connections, connection1)
									table.insert(connections, connection2)
								end
							end
						end
					end
				end
			end
		end
	end)

	task.spawn(function()
		for _, char in next, workspace:GetDescendants() do
			if char:IsA("Model") and char ~= character then
				if char:FindFirstChild("HumanoidRootPart") then
					if char:FindFirstChild("I_LOADED_I") then
						local loaded = char:FindFirstChild("I_LOADED_I")
						local ragdoll = loaded:FindFirstChild("Ragdoll")

						if ragdoll then
							if not ragdoll.Value then
								if loaded:FindFirstChild("MousePos") then
									local mousepos = loaded:FindFirstChild("MousePos")

									local connection = mousepos:GetPropertyChangedSignal("Value"):Connect(function()
										if (mousepos.Value - rootPart.Position).Magnitude <= 5 then
											counterTarget = char
										end
									end)

									table.insert(connections, connection)
								end
							end
						end
					end
				end
			end
		end
	end)

	repeat task.wait(0) until counterTarget ~= nil

	for _, connection in next, connections do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	local targetTorso = counterTarget:FindFirstChild("UpperTorso")
	local loaded = counterTarget:FindFirstChild("I_LOADED_I")
	local tickTwo = nil
	local anim = nil
	local oldCFrame = rootPart.CFrame

	task.spawn(function()
		for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
			if v.Animation.AnimationId == "rbxassetid://16782477765" then
				v:Stop()
			end
		end

		anim = playAnimation(14775812675, 1, 2.20)
		wait(2)
		anim:Stop()

		tickTwo = tick()
		anim = playAnimation(14775812675, 1, 2.20)

		task.spawn(function()
			useKnifeHeavy()
		end)

		wait(1.35)
		anim:AdjustSpeed(0)
		wait(.35)
		anim:Stop()

		breakTime = false

		task.spawn(function()
			currentCharacter = counterTarget

			teleportGrip("[Knife]")
		end)
	end)

	task.spawn(function()
		rootPart.CFrame = CFrame.new(2681, 321, 1037)
	end)

	task.spawn(function()
		repeat task.wait(0) until tickTwo ~= nil
		repeat task.wait(0) until loaded["K.O"].Value or tick() > tickTwo + 3

		breakTime = true

		if tick() > tickTwo + 3 then
			rootPart.CFrame = oldCFrame

			return
		end

		chat("End Of Days..")

		if enmaStomp then
			enmaStomp:Disconnect()
		end

		counterStomp = replicatedStorage.MainRemote.OnClientEvent:Connect(function(...)
			local tabl = {...}
		
			if tabl[1] == "FX_KILL" and tabl[4] == localPlayer then
				local targetHead = tabl[3].Parent.Head
				local targetRoot = tabl[3].Parent.HumanoidRootPart
				local targetTorso = tabl[3].Parent.UpperTorso

				coroutine.wrap(function()
					rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
					wait(0.70)
					local BP = Instance.new("BodyPosition", rootPart)
					BP.Name = "N/A_S"
					BP.MaxForce = Vector3.new(99999, 99999, 99999)
					BP.P = 5000
					BP.D = 500
					BP.Position = rootPart.CFrame * CFrame.new(0,0,30).Position
					debris:AddItem(BP, 2)
				end)()

				coroutine.wrap(function()
					local kickAnim = playAnimation(14776645699, 1.70, 0.35)
					wait(0.50)
					kickAnim:Stop()
				
					local glideBack = playAnimation(14777141114, 1, 0)
					wait(0.40)
					glideBack:Stop()
				
					local katanaPoseEquip = playAnimation(14776833372, 1, 0)
					local katanaPose = playAnimation(2524329075, 0, 0.3)
					wait(0.60)
					local dashFoward = playAnimation(14777142996, 1, 0)
					wait(0.40)
					dashFoward:Stop()
					katanaPoseEquip:Stop()
					katanaPose:Stop()
				
					local katanaCombo = playAnimation(14776835565, 3, 0)
					wait(1)
					katanaCombo:Stop()
				
					local beforeSheath = playAnimation(16747938666, 1, 0)
					wait(0.50)
					beforeSheath:Stop()
				
					local sheath = playAnimation(16853374695, 0, 0)
					wait(1)
					sheath:Stop()
				end)()
		
				if targetHead and not targetHead.Anchored then
					local BP = Instance.new("BodyPosition", targetTorso)
					BP.Name = "N/A_S"
					BP.MaxForce = Vector3.new(99999, 99999, 99999)
					BP.P = 100
					BP.D = 50
					BP.Position = targetRoot.CFrame * CFrame.new(0, 40, 0).Position
					debris:AddItem(BP, 1)
					wait(1.90)

					local BP = Instance.new("BodyPosition", targetTorso)
					BP.Name = "N/A_S"
					BP.MaxForce = Vector3.new(99999, 99999, 99999)
					BP.P = 2500
					BP.D = 500
					BP.Position = targetRoot.CFrame * CFrame.new(0, -35, 0).Position
				end

			end

		end)
		
		if not counterTarget:FindFirstChild("DEBUG_DEAD") then
			repeat
				rootPart.CFrame = CFrame.new(Vector3.new(targetTorso.Position.X, targetTorso.Position.Y, targetTorso.Position.Z)) * CFrame.new(0, 3, 0)
				replicatedStorage.MainRemote:FireServer("Stomp")
				runService.Heartbeat:Wait()
			until counterTarget:FindFirstChild("DEBUG_DEAD")
		end

		wait(5)
		counterStomp:Disconnect()
		humanoid:UnequipTools()
		humanoid:EquipTool(enmaU)
		onCooldown = false
	end)
end

local circleGripEnabled = false
local mouseGripEnabled = false
local gripRequipping = false
local currentAngle = 0
local currentVal = 0

local function tweenProp(target, properties, speed)
	local tweenInfo = TweenInfo.new(speed)
	local tween = tweenService:Create(target, tweenInfo, properties)
	tween:Play()
	tween.Completed:Wait()
end

local function Bankai()
	circleGripEnabled = not circleGripEnabled
	gripRequipping = not gripRequipping

	katana.Parent = backpack
	katana.Parent = character

	coroutine.wrap(function()
		if circleGripEnabled then
			task.wait(.1)
			local bankaiAnim = playAnimation(16747938666, 0.40, 0)
			wait(1)
			bankaiAnim:AdjustSpeed(0)
			wait(3.25)
			bankaiAnim:Stop()
		end
	end)()

	coroutine.wrap(function()
		if circleGripEnabled then
			playAudio(16737998879)
		end
	end)()

	coroutine.wrap(function()
		if circleGripEnabled then
			gripRequipping = true
	
			coroutine.wrap(function()
				while gripRequipping do	
					task.wait(0.03)
					katana.Parent = backpack
					katana.Parent = character
				end
			end)()
	
			wait(3.25)
			
			gripRequipping = false
		end
	end)()

	coroutine.wrap(function()
		if circleGripEnabled then
			katana.Grip = CFrame.new(0,0,-0.10) * CFrame.Angles(math.rad(-80), math.rad(0), 0)
				tweenProp(katana, {Grip = CFrame.new(0, 0, -0.15) * CFrame.Angles(math.rad(55), math.rad(210), math.rad(0))}, 1)
			wait(1)
				tweenProp(katana, {Grip = CFrame.new(0, 0, 10) * CFrame.Angles(math.rad(55), math.rad(210), math.rad(0))}, 2.25)
			katana.Grip = CFrame.new(0,0,-0.10) * CFrame.Angles(math.rad(-80), math.rad(0), 0)
			katana.Parent = backpack
			katana.Parent = character
		end
	end)()

	coroutine.wrap(function()
		if circleGripEnabled then
			wait(1)
			molotov.Grip = CFrame.new(0, 5.65, -0.25) * CFrame.Angles(math.rad(30), math.rad(35), math.rad(2))
			molotov.Parent = backpack
			molotov.Parent = character
			wait(3)
			molotov.Parent = backpack
			molotov.Grip = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))
		end
	end)()

	wait(4)

	if circleGripEnabled then
		task.spawn(function()
			repeat task.wait(0) knife.Parent = character until knife.Parent == character

			while task.wait(0.03) do
				if not circleGripEnabled then
					break
				end

				currentAngle = (currentAngle + 0.05 * math.pi) % (2 * math.pi)
				currentVal = currentVal + 90

				local rightArmCFrame = localPlayer.Character["RightHand"].CFrame * CFrame.new(0, -1 ,0, 1, 0, 0, 0, 0, 1, 0, -1, 0)

				local spinGrip = rightArmCFrame:toObjectSpace(localPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(math.cos(currentAngle) * 30, 0, math.sin(currentAngle) * 30)):Inverse()
				local mouseGrip
				
				if mouseGripEnabled then
					local nearestCharacter = charInTarget()
					swordIdle:Stop()
						
					if nearestCharacter then
						local cf = getPrediction(nearestCharacter.HumanoidRootPart, nearestCharacter.Humanoid)
						mouseGrip = rightArmCFrame:toObjectSpace(cf * CFrame.Angles(math.rad(90), math.rad(180), math.rad(0))):Inverse()
					end
				end
				
				if mouseGripEnabled then
					localPlayer.Character["[Katana]"].Parent = localPlayer.Backpack
					localPlayer.Backpack["[Katana]"].Parent = localPlayer.Character
				end

				if mouseGripEnabled and mouseGrip then
					localPlayer.Character:WaitForChild("[Katana]").Grip = mouseGrip
				end

				katana:Activate()
				katana:Deactivate()

				localPlayer.Character:WaitForChild("[Knife]").Grip = spinGrip

				if mouseGripEnabled then
					localPlayer.Character["[Katana]"].Parent = localPlayer.Backpack
					localPlayer.Backpack["[Katana]"].Parent = localPlayer.Character
				end

				localPlayer.Character["[Knife]"].Parent = localPlayer.Backpack
				localPlayer.Backpack["[Knife]"].Parent = localPlayer.Character
			end
			
			normalKnifeGrip()
		end)
	else
		normalHoldGrip()
	end
end

local function stompImpactFrames(delay)
	local timeBetween = delay

	local impact = Instance.new("ScreenGui")
	local frames = Instance.new("Frame")
	local one = Instance.new("ImageLabel")
	local two = Instance.new("ImageLabel")
	local three = Instance.new("ImageLabel")
	local four = Instance.new("ImageLabel")

	impact.Name = "impact"
	impact.Parent = localPlayer:WaitForChild("PlayerGui")

	frames.Name = "frames"
	frames.Parent = impact
	frames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frames.Position = UDim2.new(0, 0, -0.100000001, 0)
	frames.Size = UDim2.new(1.10000002, 0, 1.20000005, 0)
	frames.Visible = false

	one.Name = "one"
	one.Parent = frames
	one.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	one.BackgroundTransparency = 1.000
	one.Position = UDim2.new(0.00100000005, 0, 0.0500000007, 0)
	one.Size = UDim2.new(1, 0, 1, 0)
	one.Visible = false
	one.Image = "http://www.roblox.com/asset/?id=17323032347"

	two.Name = "two"
	two.Parent = frames
	two.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	two.BackgroundTransparency = 1.000
	two.Position = UDim2.new(0.00100000005, 0, 0.0500000007, 0)
	two.Size = UDim2.new(1, 0, 1, 0)
	two.Visible = false
	two.Image = "http://www.roblox.com/asset/?id=17323033445"

	three.Name = "three"
	three.Parent = frames
	three.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	three.BackgroundTransparency = 1.000
	three.Position = UDim2.new(0.00100000005, 0, 0.0500000007, 0)
	three.Size = UDim2.new(1, 0, 1, 0)
	three.Visible = false
	three.Image = "http://www.roblox.com/asset/?id=17323034767"

	four.Name = "four"
	four.Parent = frames
	four.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	four.BackgroundTransparency = 1.000
	four.Position = UDim2.new(0.00100000005, 0, 0.0500000007, 0)
	four.Size = UDim2.new(1, 0, 1, 0)
	four.Visible = false
	four.Image = "http://www.roblox.com/asset/?id=17323035755"

	frames.Visible = true
	one.Visible = true
	wait(timeBetween)
	one.Visible = false
	two.Visible = true
	wait(timeBetween)
	two.Visible = false
	three.Visible = true
	wait(timeBetween)
	three.Visible = false
	four.Visible = true
	wait(timeBetween)
	four.Visible = false

	impact:Destroy()
end

userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then
		return
	end

	if input.KeyCode == Enum.KeyCode.C and canAttack then
		Roll()
	elseif input.KeyCode == Enum.KeyCode.R and canAttack then
		M1()
	elseif input.KeyCode == Enum.KeyCode.T and canAttack then
		M1Combo()
	elseif input.KeyCode == Enum.KeyCode.V and canAttack then
		Romedia()
	elseif input.KeyCode == Enum.KeyCode.B and canAttack then
		HuntingDragon()
	elseif input.KeyCode == Enum.KeyCode.H and canAttack then
		EnmaBlitz()
	elseif input.KeyCode == Enum.KeyCode.J and canAttack then
		Blink()
	elseif input.KeyCode == Enum.KeyCode.P and canAttack then
		Counter()
	elseif input.KeyCode == Enum.KeyCode.U and canAttack then
		Bankai()
	elseif input.KeyCode == Enum.KeyCode.X then
		if not isHovering then
			isHovering = true
			canAttack = false

			local randomAnim = math.random(1, 2)

			if randomAnim == 1 then
				loadFly:Play()
				loadFly:AdjustSpeed(0)
				loadFly.TimePosition = 4

				flyGrip()

				if settings.HasLantern then
					lantern.Grip = CFrame.new(-5.60, 2, 1.90) * CFrame.Angles(math.rad(90), math.rad(100), math.rad(90))
					lantern.Parent = backpack
					lantern.Parent = character
				end
			else
				loadFlyTwo:Play()
				loadFlyTwo:AdjustSpeed(0)
				loadFlyTwo.TimePosition = 1

				flyGripTwo()

				if settings.HasLantern then
					lantern.Grip = CFrame.new(0.2, 2, 0.25) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-30))
					lantern.Parent = backpack
					lantern.Parent = character
				end
			end

			humanoid.PlatformStand = true
			humanoid.AutoRotate = false

			surfGyro = Instance.new("BodyGyro")
			surfGyro.Name = "N/A_S"
			surfGyro.Parent = rootPart
			surfGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

			surfPosition = Instance.new("BodyPosition")
			surfPosition.Name = "N/A_S"
			surfPosition.Parent = rootPart
			surfPosition.MaxForce = Vector3.new(60000, 60000, 60000)
			surfPosition.Position = rootPart.CFrame.Position

			while true do
				if not isHovering and not isSurfing then
					break
				end

				if isHovering then
					surfGyro.CFrame = camera.CFrame
					runService.Heartbeat:Wait()
				end

				runService.Heartbeat:Wait()
			end
		else
			isHovering = false
			canAttack = true

			humanoid.PlatformStand = false
			humanoid.AutoRotate = true

			if loadFly.IsPlaying then
				loadFly:Stop()
			end

			if loadFlyTwo.IsPlaying then
				loadFlyTwo:Stop()
			end

			normalHoldGrip()

			if settings.HasLantern then
				lantern.Parent = backpack
			end

			if rootPart:FindFirstChildWhichIsA("BodyVelocity") then
				rootPart:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end

			if rootPart:FindFirstChildWhichIsA("BodyPosition") then
				rootPart:FindFirstChildWhichIsA("BodyPosition"):Destroy()
			end

			if rootPart:FindFirstChildWhichIsA("BodyGyro") then
				rootPart:FindFirstChildWhichIsA("BodyGyro"):Destroy()
			end
		end
	elseif input.KeyCode == Enum.KeyCode.W and isHovering then
		isSurfing = true

		if surfPosition ~= nil then
			surfPosition:Destroy()
			surfPosition = nil
		end

		coroutine.wrap(function()
			playSFXAudio(2741718865)
		end)()

		if not rootPart:FindFirstChildWhichIsA("BodyVelocity") then
			surfVelocity = Instance.new("BodyVelocity")
			surfVelocity.Name = "N/A_S"
			surfVelocity.Parent = rootPart
			surfVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

			while true do
				if not isSurfing and isHovering or not surfVelocity then
					break
				end

				if isSurfing then
					surfVelocity.Velocity = camera.CFrame.LookVector * 100
				end

				runService.Heartbeat:Wait()
			end
		end
	end
end)

userInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent or not isEquipped then
		return
	end

	if input.KeyCode == Enum.KeyCode.W then
		if isSurfing and isHovering then
			isSurfing = false
			canAttack = false

			if surfVelocity ~= nil then
				surfVelocity:Destroy()
				surfVelocity = nil
			end

			if not rootPart:FindFirstChildWhichIsA("BodyPosition") then
				surfPosition = Instance.new("BodyPosition")
				surfPosition.Name = "N/A_S"
				surfPosition.Parent = rootPart
				surfPosition.MaxForce = Vector3.new(60000, 60000, 60000)
				surfPosition.Position = rootPart.CFrame.Position
			end
		end
	end
end)

speedConnection = runService.Heartbeat:Connect(function()
	if not katana then
		isEquipped = false

		speedConnection:Disconnect()
	end

	if isEquipped then
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

		if isRunning then
			if humanoid.MoveDirection.Magnitude > 0 then
				rootPart.CFrame = rootPart.CFrame + humanoid.MoveDirection * settings.WalkSpeed
			end
		end
	end
end)

humanoid.Died:Connect(function()
	isEquipped = false

	if speedConnection and speedConnection.Connected then
		speedConnection:Disconnect()
	end

	if stopConnection and stopConnection.Connected then
		stopConnection:Disconnect()
	end
end)

 mouse.Button1Down:Connect(function()
	if circleGripEnabled then
		repeat task.wait(0) katana.Parent = localPlayer.Character until katana.Parent == localPlayer.Character
		
		katana.Handle.CanCollide = false

		mouseGripEnabled = true
	end
end)

mouse.Button1Up:Connect(function()
	if circleGripEnabled then
		mouseGripEnabled = false

		normalHoldGrip()
	end
end)

userInputService.InputBegan:Connect(inputBegan)
userInputService.InputBegan:Connect(runningStarted)

userInputService.InputEnded:Connect(inputEnded)
userInputService.InputEnded:Connect(runningStopped)

enmaU.Equipped:Connect(function()
	katana.ManualActivationOnly = true
	knife.ManualActivationOnly = true
	fist.ManualActivationOnly = true
	molotov.ManualActivationOnly = true
	normalHoldGrip()

	isEquipped = true
	katana.Parent = character

	if userInputService:IsKeyDown(Enum.KeyCode.W) or userInputService:IsKeyDown(Enum.KeyCode.S) or userInputService:IsKeyDown(Enum.KeyCode.A) or userInputService:IsKeyDown(Enum.KeyCode.D) then
		if loadIdle.IsPlaying then
			loadIdle:Stop()
		end

		if loadIdleTwo.IsPlaying then
			loadIdleTwo:Stop()
		end

		if isRunning and not loadRun.IsPlaying then
			loadRun:Play()
			loadRun:AdjustSpeed(1.25)

			swordIdle:Play()
			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.23
		end

		if not isRunning and not loadWalk.IsPlaying then
			loadWalk:Play()
			swordIdle:Play()

			swordIdle:AdjustSpeed(0)
			swordIdle.TimePosition = 0.27
		end
	else
		if loadWalk.IsPlaying then
			loadWalk:Stop()
		end

		if loadRun.IsPlaying then
			loadRun:Stop()
		end

		loadIdle:Play()
		loadIdleTwo:Play()
		swordIdle:Play()

		swordIdle:AdjustSpeed(0)
		swordIdle.TimePosition = 0.27
	end

	if settings.HUDChange then
		localPlayer.PlayerGui.MainScreenGui.HUD.HUD1.TextLabel.Text = "Mana"

		coroutine.wrap(function()
			local tweenInfo = TweenInfo.new(.5)

			local tween = tweenService:Create(localPlayer.PlayerGui.MainScreenGui.HUD.HUD1.Percentage, tweenInfo, {BackgroundColor3 = Color3.fromRGB(85, 0, 127)})
			tween:Play()
		end)()

		coroutine.wrap(function()
			local tweenInfo = TweenInfo.new(.5)

			local tween = tweenService:Create(localPlayer.PlayerGui.MainScreenGui.HUD.HUD1.Picture.Image, tweenInfo, {ImageColor3 = Color3.fromRGB(85, 0, 127)})
			tween:Play()
		end)()
	end

	reach()

	enmaStomp = replicatedStorage.MainRemote.OnClientEvent:Connect(function(...)
		local tabl = {...}

		if tabl[1] == "FX_KILL" and tabl[4] == localPlayer then
			local targetHead = tabl[3].Parent.Head

			if targetHead and not targetHead.Anchored then
				local heartbeat
				local isColliding = false

				coroutine.wrap(function()
					camera.CameraType = Enum.CameraType.Scriptable

					local tween = tweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {CFrame = CFrame.new(rootPart.CFrame * CFrame.new(15,3,0).Position, rootPart.Position)})
					tween:Play()
					tween.Completed:Wait()

					local heartbeat = runService.Heartbeat:Connect(function()
						tween = tweenService:Create(camera, TweenInfo.new(0.01, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {CFrame = CFrame.new(rootPart.CFrame * CFrame.new(15,3,0).Position, rootPart.Position)})
						tween:Play()
						tween.Completed:Wait()
					end)

					wait(2.45)
					heartbeat:Disconnect()
					camera.CameraType = Enum.CameraType.Custom
				end)()

				coroutine.wrap(function()
					wait(1.80)
					task.spawn(function()
						while task.wait(0) do
							if isColliding then
								break
							end

							for _, part in pairs(tabl[3].Parent:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") and not part.Anchored then
									part.CanCollide = false
								end
							end
						end

						for _, part in pairs(tabl[3].Parent:GetDescendants()) do
							if part:IsA("BasePart") or part:IsA("MeshPart") and not part.Anchored then
								part.CanCollide = true
							end
						end
					end)
					wait(1)
					isColliding = true
				end)()

				coroutine.wrap(function()
					local anim = playAnimation(15609333208, 1, 1)
					wait(1.48)
					anim:Stop()
					anim = playAnimation(14777200153,1.35,0.20)
					wait(.40)
					anim:Stop()
					anim = playAnimation(14775812675,1.45,1.30)
					wait(0.90)
					anim:AdjustSpeed(0.25)
					wait(0.40)
					anim:Stop()
					anim = playAnimation(14776978575,2,0)
					wait(0.50)
					anim:AdjustSpeed(0.25)
				end)()

				coroutine.wrap(function()
					playAudio(1244506786)
					wait(1.60)
					playAudio(5989945551)
					wait(0.20)
					playAudio(134012322)
					wait(1.2)
					playAudio(7119101794)
				end)()

				coroutine.wrap(function()
					wait(1.80)
					local bodyPosition = Instance.new("BodyPosition")
					bodyPosition.Name = "N/A_S"
					bodyPosition.Parent = targetHead
					bodyPosition.MaxForce = Vector3.new(99999, 99999, 99999)
					bodyPosition.P = 100000

					local bodyGyro = Instance.new("BodyGyro")
					bodyGyro.Name = "N/A_S"
					bodyGyro.Parent = targetHead
					bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
					bodyGyro.P = 40000
					bodyGyro.CFrame = rootPart.CFrame * CFrame.new(0, 0, 0)

					heartbeat = runService.Heartbeat:Connect(function()
						if not targetHead or not targetHead:FindFirstChildWhichIsA("BodyPosition") then
							heartbeat:Disconnect()
						end
						bodyPosition.Position = katana.Blade.CFrame * CFrame.new(0, 0, -2).Position
					end)

					wait(0.80)
					heartbeat:Disconnect()
					bodyPosition:Destroy()

					bodyPosition = Instance.new("BodyPosition")
					bodyPosition.Parent = targetHead
					bodyPosition.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
					bodyPosition.P = 10000
					bodyPosition.D = 500
					bodyPosition.Position = rootPart.CFrame * CFrame.new(0, 30, -87).Position
					wait(.80)
					bodyPosition:Destroy()

					bodyPosition = Instance.new("BodyPosition")
					bodyPosition.Parent = targetHead
					bodyPosition.MaxForce = Vector3.new(999999,999999,999999)
					bodyPosition.P = 150
					bodyPosition.D = 50
					bodyPosition.Position =  rootPart.CFrame * CFrame.new(0, -80, -40).Position

					debris:AddItem(bodyPosition, 0.10)
				end)()

				coroutine.wrap(function()
					rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, 4)
					wait(2.7)
					rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 30, -82)
					task.wait()

					local anchorBP = Instance.new("BodyPosition", rootPart)
					anchorBP.Name = "N/A_S"
					anchorBP.MaxForce = Vector3.new(90000, 90000, 90000)
					anchorBP.Position = rootPart.CFrame * CFrame.new(0, 0, 0).Position

					local anchorBG = Instance.new("BodyGyro", rootPart)
					anchorBG.Name = "N/A_S"
					anchorBG.MaxTorque = Vector3.new(30000, 30000, 30000)
					anchorBG.P = anchorBG.P * 5

					debris:AddItem(anchorBP, 1.2)
					debris:AddItem(anchorBG, 1.2)

					heartbeat = runService.Heartbeat:Connect(function()
						anchorBG.CFrame = CFrame.lookAt(rootPart.Position, targetHead.Position)
					end)
				end)()

				coroutine.wrap(function()
					wait(3.15)
					stompImpactFrames(.05)
				end)()

				playerControls:Disable()
				humanoid.AutoRotate = false
				wait(4)
				playerControls:Enable()
				humanoid.AutoRotate = true
			end
		end
	end)

	while enmaU and isEquipped do
		if not katana then
			break
		end

		task.wait()

		pcall(function()
			for _, child in next, character["I_LOADED_I"]:GetChildren() do
				if child.Name == "Cooldown" then
					if child:IsA("NumberValue") or child:IsA("StringValue") then
						child:Destroy()
					end
				end
			end

			local stunned = character:FindFirstChild("Stunned")

			if stunned ~= nil then
				stunned:Destroy()
			end
		end)
	end
end)

enmaU.Unequipped:Connect(function()
	katana.ManualActivationOnly = false
	knife.ManualActivationOnly = false
	fist.ManualActivationOnly = false
	molotov.ManualActivationOnly = false
	
	isEquipped = false
	katana.Parent = backpack

	loadIdle:Stop()
	loadIdleTwo:Stop()
	swordIdle:Stop()

	loadWalk:Stop()
	loadRun:Stop()

	if settings.HUDChange then
		localPlayer.PlayerGui.MainScreenGui.HUD.HUD1.TextLabel.Text = "Energy"

		coroutine.wrap(function()
			local tweenInfo = TweenInfo.new(.5)

			local tween = tweenService:Create(localPlayer.PlayerGui.MainScreenGui.HUD.HUD1.Percentage, tweenInfo, {BackgroundColor3 = Color3.fromRGB(182, 182, 9)})
			tween:Play()
		end)()

		coroutine.wrap(function()
			local tweenInfo = TweenInfo.new(.5)

			local tween = tweenService:Create(localPlayer.PlayerGui.MainScreenGui.HUD.HUD1.Picture.Image, tweenInfo, {ImageColor3 = Color3.fromRGB(236, 231, 85)})
			tween:Play()
		end)()
	end

	noReach()

	for _, connection in next, connections do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	if heartbeatLoop and heartbeatLoop.Connected then
		heartbeatLoop:Disconnect()
	end

	if enmaStomp and enmaStomp.Connected then
		enmaStomp:Disconnect()
	end
end)