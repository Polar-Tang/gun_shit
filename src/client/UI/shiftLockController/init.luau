--[[

	@ Name: SmoothShiftLock
	@ Author: rixtys
	@ Version: 1.1.0
	
	@ Desc: Smooth shift lock module that adds smoothness to the Roblox's shift lock
	│ @ for this to work, disable the default Roblox's shift lock
	│ @ game.StarterPlayer.EnableMouseLockOption = false
	│ @ and start the custom shift lock module with
	└ @ SmoothShiftLock:Init()
	
	@ Methods = {
		SmoothShiftLock:Init()
		Initializes the module. (Should be done on client and only once)
		
		SmoothShiftLock:IsEnabled()
		Gets ShiftLock's enabled state
		
		module.ToggleShiftLock:Fire(boolean)
		Toogles ShiftLock. (Automatically bind to SHIFT_LOCK_KEYBINDS on initialization)
		
		module.EditConfig:Fire(configName, value)
		Edits the ShiftLock's config. (Line 51)
	}

--]]
game.StarterPlayer.EnableMouseLockOption = false

local SmoothShiftLock = {}
SmoothShiftLock.__index = SmoothShiftLock

-- [[ Variables ]]:

--// Services and requires
local Players = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local Spring = require(ReplicatedStorage.Nevermore.Quenty.spring.Shared.Spring)

local _ = require(script.handHeadCamera)
--// Instances
local LocalPlayer = Players.LocalPlayer

--// Bindables
local events = RS.RemoteEvents
local ToggleEvent: RemoteEvent = events.ToggleShiftLock
local EditConfig: RemoteEvent = events.EditConfig
-- TODO: disable shift lock from roblox
--// Configuration
local config = {
	["CHARACTER_SMOOTH_ROTATION"] = true, --// If your character should rotate smoothly or not
	["MANUALLY_TOGGLEABLE"] = true, --// If the shift lock an be toggled manually by player
	["CHARACTER_ROTATION_SPEED"] = 3, --// How quickly character rotates smoothly
	["TRANSITION_SPRING_DAMPER"] = 0.7, --// Camera transition spring damper, test it out to see what works for you
	["CAMERA_TRANSITION_IN_SPEED"] = 10, --// How quickly locked camera moves to offset position
	["CAMERA_TRANSITION_OUT_SPEED"] = 14, --// How quickly locked camera moves back from offset position
	["LOCKED_CAMERA_OFFSET"] = Vector3.new(0, 1.25, 0), --// Locked camera offset
	--["LOCKED_CAMERA_OFFSET"]        = Vector3.new(1.75, 0.25, 0), --// Locked camera offset
	--// Locked mouse icon
	["LOCKED_MOUSE_ICON"] = "rbxasset://textures/ui/Controls/xboxRSDirectional.png",
	--// Shift lock keybinds
	["SHIFT_LOCK_KEYBINDS"] = { Enum.KeyCode.LeftShift },
	["CAMERA_OFFSET"] = Vector3.new(1.5, -1, 0), -- X = right, Y = up, Z = forward
}

local ENABLED = false

--// Setup
local maid = Maid.new()

-- [[ Functions ]]:

--// Setup smooth shift lock on client (Run once and on a LocalScript)
function SmoothShiftLock.new()
	local self = setmetatable({}, SmoothShiftLock)

	self:CharacterAdded()
	return self
end

--// Character added event function
function SmoothShiftLock:CharacterAdded()
	--// Instances
	self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	self.RootPart = self.Character:WaitForChild("HumanoidRootPart")
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.Head = self.Character:WaitForChild("Head")
	--// Other
	self.Camera = WorkspaceService.CurrentCamera
	--// Setup
	self.connectionsMaid = Maid.new()
	self.camOffsetSpring = Spring.new(Vector3.new(0, 0, 0))
	self.camOffsetSpring.Damper = config.TRANSITION_SPRING_DAMPER

	--// Bind keybinds
	self.connectionsMaid:GiveTask(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or not config.MANUALLY_TOGGLEABLE then
			return
		end
		for _, keyBind in pairs(config.SHIFT_LOCK_KEYBINDS) do
			if (input.KeyCode == keyBind) and (self.Humanoid and self.Humanoid.Health ~= 0) then
				self:ToggleShiftLock(not ENABLED)
			end
		end
	end))

	--// Update camera offset
	self.connectionsMaid:GiveTask(RunService.RenderStepped:Connect(function()
		if self.Head.LocalTransparencyModifier > 0.6 then
			return
		end

		local camCF = self.Camera.CoordinateFrame
		local distance = (self.Head.Position - camCF.Position).magnitude
		--// Camera offset
		if distance > 1 then
			self.Camera.CFrame = (self.Camera.CFrame * CFrame.new(self.camOffsetSpring.Position))

			if ENABLED and (UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter) then
				self:SetMouseState(ENABLED)
			end
		end
	end))

	--// Bindables
	self.connectionsMaid:GiveTask(ToggleEvent.OnClientEvent:Connect(function(toggle: boolean)
		if self.Humanoid and self.Humanoid.Health ~= 0 then
			self:ToggleShiftLock(toggle)
		end
	end))

	self.connectionsMaid:GiveTask(EditConfig.OnClientEvent:Connect(function(toChange, value)
		if config[toChange] ~= nil then
			config[toChange] = value
		end
	end))

	--// On death
	self.connectionsMaid:GiveTask(self.Humanoid.Died:Connect(function()
		self:CharacterDiedOrRemoved()
		return
	end))

	--// On character removing
	self.connectionsMaid:GiveTask(LocalPlayer.CharacterRemoving:Connect(function()
		self:CharacterDiedOrRemoved()
		return
	end))

	return self
end

--// Stop shiftlock upon character death or removal
function SmoothShiftLock:CharacterDiedOrRemoved()
	self:ToggleShiftLock(false)

	if self.connectionsMaid ~= nil then
		self.connectionsMaid:Destroy()
	end

	maid:DoCleaning()
end

--// Return shiftlock enabled state
function SmoothShiftLock:IsEnabled(): boolean
	return ENABLED
end

--// Set Enum.MouseBehavior to LockCenter or Default depending on shiftlock enabled
function SmoothShiftLock:SetMouseState(enable: boolean)
	UserInputService.MouseBehavior = (enable and Enum.MouseBehavior.LockCenter) or Enum.MouseBehavior.Default
end

--// Change mouse icon depending on shiftlock enabled
function SmoothShiftLock:SetMouseIcon(enable: boolean)
	UserInputService.MouseIcon = (enable and config.LOCKED_MOUSE_ICON :: string) or ""
end

--// Tween locked camera offset position
function SmoothShiftLock:TransitionLockOffset(enable: boolean)
	if enable then
		self.camOffsetSpring.Speed = config.CAMERA_TRANSITION_IN_SPEED
		self.camOffsetSpring.Target = config.LOCKED_CAMERA_OFFSET
	else
		self.camOffsetSpring.Speed = config.CAMERA_TRANSITION_OUT_SPEED
		self.camOffsetSpring.Target = Vector3.new(0, 0, 0)
	end
end

--// Toggle shift lock
function SmoothShiftLock:ToggleShiftLock(enable: boolean)
	assert(typeof(enable) == typeof(false), "Enable value is not a boolean.")
	ENABLED = enable

	self:SetMouseState(ENABLED)
	self:SetMouseIcon(ENABLED)
	self:TransitionLockOffset(ENABLED)

	--// Start
	if ENABLED then
		maid:GiveTask(RunService.RenderStepped:Connect(function(delta)
			if self.Humanoid and self.RootPart then
				self.Humanoid.AutoRotate = not ENABLED
			end

			--// Rotate character
			if ENABLED and not self.Character:GetAttribute("Stunned") then
				if not self.Humanoid.Sit and config.CHARACTER_SMOOTH_ROTATION then
					local _x, y, _z = self.Camera.CFrame:ToOrientation()
					self.RootPart.CFrame = self.RootPart.CFrame:Lerp(
						CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0),
						delta * 5 * config.CHARACTER_ROTATION_SPEED
					)
				elseif not self.Humanoid.Sit then
					local _x, y, _z = self.Camera.CFrame:ToOrientation()
					self.RootPart.CFrame = CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0)
				end

				--// Apply over-the-shoulder offset
				local offsetInWorld = self.Camera.CFrame:VectorToWorldSpace(config.CAMERA_OFFSET)
				self.Camera.CFrame = self.Camera.CFrame + offsetInWorld
			end

			--// Stop
			if not ENABLED then
				maid:Destroy()
			end
		end))
	end

	return self
end

return SmoothShiftLock
