-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Motor6D references (adjust paths to your rig)
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
-- local head = character:WaitForChild("Head")

local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local torso = character:WaitForChild("Torso")
-- local leftArm = character:WaitForChild("Left Arm") -- or UpperArm for R15
-- local rightArm = character:WaitForChild("Right Arm")

local neck: Motor6D = torso:WaitForChild("Neck") -- Motor6D in Head
local leftShoulder: Motor6D = torso:WaitForChild("Left Shoulder")
local rightShoulder: Motor6D = torso:WaitForChild("Right Shoulder")

-- Store the ORIGINAL C0 values so we apply look-at on TOP of them
-- These are the rest-pose offsets the rig defines
local neckC0Base: CFrame = neck.C0

local RC1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)

local LC1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

local Mouse = Players.LocalPlayer:GetMouse()

RunService.RenderStepped:Connect(function(dt)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local Kek = CFrame.Angles(0, 0, math.asin(Mouse.Origin.LookVector.Y))
	rightShoulder.C1 = RC1 * Kek:inverse()
	leftShoulder.C1 = LC1 * Kek

	neck.C0 = neckC0Base * CFrame.Angles(math.asin(Mouse.Origin.lookVector.Y), 0, 0):inverse()
	humanoidRootPart.CFrame = CFrame.lookAt(
		humanoidRootPart.Position,
		Vector3.new(Mouse.Hit.Position.X, humanoidRootPart.Position.Y, Mouse.Hit.Position.Z),
		humanoidRootPart.CFrame.UpVector
	)
end)
return {}
