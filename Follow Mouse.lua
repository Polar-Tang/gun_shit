local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Character = Player.Character
local Torso = Character:WaitForChild("Torso")
local Neck = Torso:WaitForChild("Neck")
local LeftShoulder = Torso:WaitForChild("Left Shoulder")
local RightShoulder = Torso:WaitForChild("Right Shoulder")
local Humanoid = Character:WaitForChild("Humanoid")
Humanoid.AutoRotate = false
local HMR = Character:WaitForChild("HumanoidRootPart")

local Mouse = Player:GetMouse()

local RC0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
local RC1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)

local LC0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local LC1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

local NeckC0 = Neck.C0
local NeckC1 = Neck.C1

-- TODO: find out how to replicate this

game:GetService("RunService").RenderStepped:connect(function()
	local cf = workspace.CurrentCamera.CFrame.LookVector.Y

	local Kek = CFrame.Angles(0, 0, math.asin(Mouse.Origin.LookVector.Y))
	RightShoulder.C1 = RC1 * Kek:inverse()
	LeftShoulder.C1 = LC1 * Kek

	Neck.C0 = NeckC0 * CFrame.Angles(math.asin(Mouse.Origin.lookVector.Y), 0, 0):inverse()
	HMR.CFrame = CFrame.lookAt(
		HMR.Position,
		Vector3.new(Mouse.Hit.Position.X, HMR.Position.Y, Mouse.Hit.Position.Z),
		HMR.CFrame.UpVector
	)
end)
