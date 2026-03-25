local UserInputSer: UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local weaponTypes = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Shared.types.weaponTypes)

-- constants
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
char:WaitForChild("Humanoid")
--print("char ", char)

local isCD = false
-- FUCK DRY
local function GCD(secs: number)
	isCD = true
	task.delay(secs, function()
		isCD = false
	end)
end

local InputManager = {}

InputManager.Bindings = {
	[Enum.KeyCode.Q] = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Client.Abilities.Slide.Slide),
}

local player = Players.LocalPlayer
local BinderProviderInitialized
local WeaponBinderStarted
local weapon: weaponTypes.WeaponContext
-- Init
do
	m1Hold = Instance.new("BoolValue")
	m1Hold.Name = "m1Hold"
	m1Hold.Value = false
	m1Hold.Parent = plr
end

UserInputSer.InputBegan:Connect(function(input: InputObject, IsTyping)
	if IsTyping then
		return
	end

	-- Prefer lookup by KeyCode, but fall back to UserInputType for mouse/touch events
	-- Unelegant way for knowing whether the player is kept
	-- if not (input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.S or or input.KeyCode == Enum.KeyCode.A) then
	-- 	_G.hasPressedM1 = true
	-- end
	-- For the moment let's imagine that all the damn characters same the daches execute
	--/src/client/Character/InputManager.client.luau
	if UserInputSer:IsKeyDown(Enum.KeyCode.Q) then
		local command = InputManager.Bindings[Enum.KeyCode.Q]
		if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.D then
			if not command.Check() then
				return
			end
			command.Execute(input.KeyCode)
		end

		task.delay(0.3, function()
			if UserInputSer:IsKeyDown(Enum.KeyCode.Q) then
				command.Execute(Enum.KeyCode.W)
			else
			end
		end)
	elseif not InputManager.Bindings[input.KeyCode] then
		-- Proxy the ability to the weapon context
		if not _G.BinderProvider then
			return
		end
		if not BinderProviderInitialized then
			BinderProviderInitialized = _G.ServiceBag:GetService(_G.BinderProvider)
		end
		if not WeaponBinderStarted then
			WeaponBinderStarted = BinderProviderInitialized:Get("Armed") -- here's the character strategy context
		end
		if not weapon then
			weapon = WeaponBinderStarted:Get(player.Character)
			_G.PlayerWeaponBinder = weapon
		end
		if not weapon:GetStrategy() then
			return
		end
		local command = input.KeyCode
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			m1Hold.Value = true
			command = input.UserInputType
		end
		weapon:Execute(command)
	end
end)
UserInputSer.InputEnded:Connect(function(input, isTyping)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		m1Hold.Value = false
	end
	-- Match how InputBegan resolves bindings: KeyCode first, then UserInputType (for mouse/touch)

	-- if input.KeyCode == Enum.KeyCode.F and attckChck() and not isBlocking then
	-- 	if command and command.Kill then
	-- 		command.Kill()
	-- 	end
	-- 	swingEvent:FireServer(Enum.KeyCode.F)
	-- elseif input.KeyCode == Enum.KeyCode.W and command and command.Check and command.Check() then
	-- 	-- command.Kill()
	-- end
	-- 	-- command.Kill()
	-- end
end)

--print("run")
--

---------------------------------MOBILE------------------------------------

if UserInputSer.TouchEnabled then
	local MobileButtons = plr.PlayerGui:WaitForChild("MobileButtons"):WaitForChild("MobileButtons2")
	MobileButtons.Visible = true

	--StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
	--[[
	MobileButtons.Dash.Activated:Connect(function()		
		if Dash.Check then
			Dashing()
		end		
	end)
	
	
	local MobileButtons1 = plr.PlayerGui:WaitForChild("MobileButtons"):WaitForChild("MobileButtons")
	MobileButtons1.Visible = true
	local MobileButtons2 = plr.PlayerGui:WaitForChild("MobileButtons"):WaitForChild("MobileButtons2")
	MobileButtons2.Visible = true

	

	MobileButtons2.Swing.Activated:Connect(function()
		if char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" then
			lastMouseButton1Pressed = tick()
			swingEvent:FireServer("none",char:FindFirstChildWhichIsA("Tool").Name)
		end	
	end)

	MobileButtons1.Feint.Activated:Connect(function() --if you delete the feint stuff also delete this
		if char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" then
			FeintFunction()
		end
	end)

	MobileButtons1.Heavy.Activated:Connect(function() --if you delete the feint stuff also delete this
		HeavyFunction()
	end)

	-- THE BLOCKING
	if uis.TouchEnabled then
	plr.PlayerGui:WaitForChild("MobileButtons"):WaitForChild("MobileButtons").Visible = true

	char:WaitForChild("Humanoid").AutoJumpEnabled = false --auto jump is annoying for mobile

	blockingUi.MainFrame.Position = UDim2.new(0.35,0,0.75,0)

	plr.PlayerGui:WaitForChild("MobileButtons"):WaitForChild("MobileButtons").Block.Activated:Connect(function()
		local Stunned = char:GetAttribute("Stunned")
		if not debounce and char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" and not char:GetAttribute("IsBlocking") then
			startBlocking()
		elseif not Stunned and char:GetAttribute("IsBlocking") then
			stopBlocking()
		end
	end)

end

	---------------- S--printING
	if uis.TouchEnabled then
	local MobileButtons = plr.PlayerGui:WaitForChild("MobileButtons"):WaitForChild("MobileButtons2")

	MobileButtons.S--print.Activated:Connect(function()		
		shiftToS--print()
	end)
end	

	]]

	---------------------------------MOBILE------------------------------------
end
