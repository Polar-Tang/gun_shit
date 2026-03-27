local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
-- local _ = require(ReplicatedStorage.Animations.handHeadCamera)
local CameraState = require(ReplicatedStorage.Nevermore.Quenty.camera.Client.CameraState)
local CameraHandlerBase = require(script.Parent.CameraHandlerBase)

local ThirdPersonCamera = setmetatable({}, CameraHandlerBase)
ThirdPersonCamera.__index = ThirdPersonCamera

function ThirdPersonCamera.new(cameraStackService, config)
	local self = setmetatable(CameraHandlerBase.new(), ThirdPersonCamera)

	self._config = config
	self._cameraStackService = cameraStackService

	-- This is your owned slot on the stack
	self._key = HttpService:GenerateGUID(false)
	self._cameraState = CameraState.new(Workspace.CurrentCamera)
	-- self._cameraState.CameraFrame = QFrame.
	-- Push it; store cleanup
	self._removeFromStack = cameraStackService:Add(self._cameraState)

	RunService:BindToRenderStep("ThirdPersonShooter" .. self._key, Enum.RenderPriority.Camera.Value, function(delta)
		local baseCFrame = Workspace.CurrentCamera.CFrame

		local offset = baseCFrame:VectorToWorldSpace(self._config.CAMERA_OFFSET)

		self._cameraState.CFrame = self._cframe
			or CFrame.new(baseCFrame.Position + offset) * (baseCFrame - baseCFrame.Position) -- preserve rotation
	end)

	return self
end

function ThirdPersonCamera:GetCurrentCFrame(baseCFrame: CFrame)
	return self._cameraState.CFrame
end

function ThirdPersonCamera:Destroy()
	self._removeFromStack() -- pops the slot off the stack cleanly
end

return ThirdPersonCamera
