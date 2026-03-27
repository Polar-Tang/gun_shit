local CameraHandlerBase = {}
CameraHandlerBase.__index = CameraHandlerBase

function CameraHandlerBase.new()
	local self = setmetatable({}, CameraHandlerBase)
	self._cframe = nil
	return self
end

function CameraHandlerBase:SetCframe(Cf: CFrame)
	self._cframe = Cf
end

function CameraHandlerBase:Destroy()
	error("Destroy must be implemented by subclass")
end

return CameraHandlerBase
