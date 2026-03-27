local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CameraState = require(ReplicatedStorage.Nevermore.Quenty.camera.Client.CameraState)
local CameraHandlerBase = require(script.Parent.CameraHandlerBase)

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local ThirdPersonCamera = setmetatable({}, CameraHandlerBase)
ThirdPersonCamera.__index = ThirdPersonCamera

function ThirdPersonCamera.new(cameraStackService, config)
	local self = setmetatable(CameraHandlerBase.new(), ThirdPersonCamera)

	self._config = config
	self._cameraStackService = cameraStackService
	self._key = HttpService:GenerateGUID(false)
	self._cameraState = CameraState.new(Workspace.CurrentCamera)
	self._removeFromStack = cameraStackService:Add(self._cameraState)

	self._cframe = nil
	self._recoil = Vector2.new()
	self._zoom = 0
	self._hasToRecoil = false

	self._lerpTimer = 0
	self._isLerping = false
	self._timeToLerp = 0
	self._goalLerp = CFrame.new()

	RunService:BindToRenderStep("ThirdPersonShooter" .. self._key, Enum.RenderPriority.Camera.Value, function(delta)
		local baseCFrame = Workspace.CurrentCamera.CFrame
		local offset = baseCFrame:VectorToWorldSpace(self._config.CAMERA_OFFSET)

		local desired = CFrame.new(baseCFrame.Position + offset) * (baseCFrame - baseCFrame.Position)

		if self._hasToRecoil then
			self:_recoiling(delta, desired)
		elseif self._isLerping then
			self._lerpTimer += delta
			local t = math.clamp(self._lerpTimer / self._timeToLerp, 0, 1)

			local goalRotation = self._goalLerp.Rotation
			local updatedGoal = CFrame.new(baseCFrame.Position + offset) * goalRotation

			self._cameraState.CFrame = desired:Lerp(updatedGoal, t)

			--
			self._cameraState.CFrame = desired:Lerp(updatedGoal, t)

			if t >= self._timeToLerp then
				self._lerpTimer = 0

				self._isLerping = false
			end
		else
			self._cameraState.CFrame = desired
		end
	end)

	return self
end

function ThirdPersonCamera:LerpCamera(targetCFrame, timeToLerp)
	self._goalLerp = targetCFrame
	self._timeToLerp = timeToLerp
	self._isLerping = true
end

function ThirdPersonCamera:StopLerpCamera(targetCFrame, timeToLerp)
	self._lerpTimer = 0
	self._isLerping = false
end

function ThirdPersonCamera:SetCframe(Cf: CFrame?)
	self._cframe = Cf
end

function ThirdPersonCamera:GetCurrentCFrame(baseCFrame: CFrame?): CFrame
	if baseCFrame then
		return baseCFrame
	end
	return self._cameraState.CFrame
end

function ThirdPersonCamera:recoil(recoilAmount: Vector2)
	self._hasToRecoil = true
	self._recoil += recoilAmount
	self._zoom = 1
end

function ThirdPersonCamera:_recoiling(dt: number, currentCFrame: CFrame)
	local recoilFinal = currentCFrame * CFrame.Angles(self._recoil.Y * dt, self._recoil.X * dt, 0)
	self._cameraState.CFrame = recoilFinal

	self._recoil = self._recoil:Lerp(Vector2.zero, math.min(dt * 10, 1))
	self._zoom = lerp(self._zoom, 0, math.min(dt * 10, 1))

	if self._recoil.Magnitude < 0.001 then
		self._recoil = Vector2.new()
		self._hasToRecoil = false
	end
end

function ThirdPersonCamera:Destroy()
	self._removeFromStack()
end

return ThirdPersonCamera
