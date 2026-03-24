--||Services||--
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--||Helper||--

--||Event||--
local SwingEvent = RS.RemoteEvents.Swing

--||Player||--
local plr = game:GetService("Players").LocalPlayer
local _char = plr.Character

--||Other||--
local DashDebounce = false
local IsSliding = false
local Cooldown = 1
--||Animations||--
local _AnimationClient = require(ReplicatedStorage.Animations.Utils.AnimationClient)

local _dir
local _camYaw
--||Dash VFX||--

------------------------------------------------------------------------------------------------------------------
local Dash = {}

local _g_dir = Vector3.zero
local CurrentButton = ""
local dash_thing = {
	["WButton"] = "WDash",
	["SButton"] = "SDash",
	
}

function Dash.getDashDirection(KeyCode)
	local dir = Vector3.zero

	local camera = workspace.CurrentCamera

	-- camera basis
	local camCF = camera.CFrame

	-- flatten to XZ plane
	local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit

	-- Only allow W (forward) and S (backward) directions for slide
	if KeyCode == Enum.KeyCode.W then
		CurrentButton = "WButton"
		dir += forward
	elseif KeyCode == Enum.KeyCode.S then
		CurrentButton = "SButton"
		dir -= forward
	else
		-- For slide, only W and S are allowed, ignore A and D
		return nil
	end

	if dir.Magnitude == 0 then
		return nil -- no direction held
	end

	--local _, camYaw, _ = camCF:ToOrientation()
	local look = camCF.LookVector
	local camYaw = math.atan2(-look.X, -look.Z)

	-- Slide only supports forward/backward, so we don't need the camera flip logic for A/D
	return {
		dir = dir.Unit,
		camYaw = camYaw,
	}
end

function Dash.Execute(KeyCode)
    if not _G.PlayerWeaponBinder then 
        return
    end

    -- Allow cancelling an active slide by pressing Q
	if IsSliding then
		IsSliding = false
		SwingEvent:FireServer({Name = "CancelSlide"}, {})
		return
	end

	local dashDir = Dash.getDashDirection(KeyCode)
	if not dashDir then
		return
	end

    _G.PlayerWeaponBinder:Execute(KeyCode, { Name = "WDash" } )

	DashDebounce = true
	IsSliding = true

	
	task.delay(Cooldown, function()
		DashDebounce = false
		IsSliding = false
	end)
end

function Dash.Check()
	-- return CheckingForValues(char, DashDebounce)
	return not DashDebounce and UIS:IsKeyDown(Enum.KeyCode.Q)
end

return Dash