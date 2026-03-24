--Services
-- The weapon context strategy
-- local SoundService = game:GetService("SoundService")
-- local SoundFolder = SoundService.SFX
-- local WeaponSoundFolder = SoundFolder.Weapons
local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local Weapon = {}
Weapon.__index = Weapon

local Strategies = {
	fist = require("FistClient"),
	["gun"] = require("GunClient"),
}

function Weapon.new(char: Model, serviceBag)
	local self = setmetatable(BaseObject.new(char), Weapon)
	self.Char = char
	self._weapon = nil
	self._serviceBag = serviceBag
	self.Humanoid = char:WaitForChild("Humanoid")

	return self
end

function Weapon:Execute(action, params)
	--print("successfully execute action ", action)
	self._weapon:Execute(action, params)
end

-- Method for registering an strategy
function Weapon:EquiTool(toolName)
	if not toolName or typeof(toolName) ~= "string" then
		warn("invalid weapo ", toolName)
		return
	end
	if not Strategies[toolName] then
		warn("Weapon " .. toolName .. " not found")
		return
	end
	self.tool_name = toolName
	self._weapon = Strategies[toolName].new(self.Char, self._serviceBag)
	if self._weapon and self._weapon.Init then
		self._weapon:Init()
	end
end

function Weapon:GetStrategy()
	return self._weapon
end

function Weapon:registryTool(toolName)
	self.tool_name = toolName
end
-- ✅ Cancel all promises when unequipping/destroying
function Weapon:Destroy()
	-- TODO: clean up the bindable events created
end

return Weapon
