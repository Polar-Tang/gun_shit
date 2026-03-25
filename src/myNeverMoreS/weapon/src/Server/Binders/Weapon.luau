--Services
-- The weapon context strategy
-- local SoundService = game:GetService("SoundService")
-- local SoundFolder = SoundService.SFX
-- local WeaponSoundFolder = SoundFolder.Weapons
local Debris = game:GetService("Debris")
local require = require(script.Parent.loader).load(script)
local EffectService = require("EffectService")
local Maid = require("Maid")
local MovementLock = require("MovementLock")
local PromiseRegistry = require("PromiseRegistry")
local WeaponDefenseSystem = require("WeaponDefenseSystem")

local BaseObject = require("BaseObject")
local Weapon = {}
Weapon.__index = Weapon

local Strategies = {
	fist = require("Fist"),
	["gun"] = require("Gun"),
	["ak-47"] = require("Ak_47"),
}

function Weapon.new(char: Model, serviceBag)
	local self = setmetatable(BaseObject.new(char), Weapon)
	self._maid = Maid.new()
	self.Char = char
	self._weapon = nil
	self._serviceBag = serviceBag
	self.Humanoid = char:WaitForChild("Humanoid")

	self._hitboxPromiseRegistry = PromiseRegistry.new()

	self._character_state = MovementLock.new(char, serviceBag)
	-- self._maid:GiveTask(self._character_state)

	self._weaponDefense = WeaponDefenseSystem.new(self)
	-- self._maid:GiveTask(self._weaponDefense)

	self._defenseChain = {}
	self._contexts = {} -- TO handle this in the same main class is bad practice

	if self.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		self.armName = "RightLowerArm"
		self.torso = self.Char:FindFirstChild("UpperTorso")
	else
		self.armName = "Right Arm"
		self.torso = self.Char:FindFirstChild("Torso")
	end
	return self
end

function Weapon:Execute(action, params)
	self._weapon:Execute(action, params)
end

function Weapon:RegisterAttackEffect(attackId, ctx)
	self._contexts[attackId] = ctx
end

function Weapon:GetAttackEffect(attackId)
	return self._contexts[attackId]
end

function Weapon:TakeHit(context)
	context.anchorState = self._character_state
	-- all the effect that the ability can cause happens here
	EffectService:Apply(context)
end

function Weapon:increaseDmgCount(increase)
	assert(typeof(increase) == "number", "increase value must be a number")
	self._weapon:_increaseDmgCount(increase)
end

function Weapon:OnIncomingAttack(hitData) -- The attack send hitData to the defender and calls Weapon which is a binder for the defender, the defender checks if there's already a defense mechanism still active by calling Weapon:OnIncomingAttack(hitData)
	task.spawn(function()
		self._weaponDefense:ProcessAttack(hitData)
	end)
end

function Weapon:GetStrategy()
	return self._weapon
end

function Weapon:SetActiveDefense(ctx)
	-- TODO: maybe this should be handle by the current strategy
	self._weaponDefense:SetActiveDefense(ctx)
end

function Weapon:ClearActiveDefense(priority)
	self._weaponDefense:DeactivateDefense(priority)
end

function Weapon:EquiTool(toolName)
	if not toolName or typeof(toolName) ~= "string" then
		print("invalid toolname ", toolName)
		return
	end
	if not Strategies[toolName] then
		print("There's no such strategy as " .. toolName)
		return
	end
	self.tool_name = toolName
	self._weapon = Strategies[toolName].new(self.Char, self._serviceBag)
	if self._weapon and self._weapon.Init then
		self._weapon:Init()
	end
	local arm = self.Char:FindFirstChild(self.armName)
	if not arm then
		warn(string.format("The %s should has a %s", self.Char.Name, self.armName))
		return
	end
end

function Weapon:UnequiTool()
	if not self.tool then
		warn("No tool equiped")
		return
	end

	local arm = self.Char:FindFirstChild(self.armName)
	arm:FindFirstChild("ToolGrip"):Destroy()

	local UnEquipSound = self.Folder:WaitForChild("UnEquip"):Clone()
	UnEquipSound.Parent = self.Char:WaitForChild("HumanoidRootPart")
	UnEquipSound:Play()
	Debris:AddItem(UnEquipSound, 1)
	self._weapon:UnEquip()
	print("Unequiping")
	debug.traceback()
end

function Weapon:GetAction(action)
	return self._weapon:GetAction(action)
end

function Weapon:registryTool(toolName)
	self.tool_name = toolName
end

-- If the sound thing causes issue we move it to a facade
function Weapon:PlaySound(lifeTime: number?, nameSound: string)
	local dur = lifeTime or 2
	local Sound = self.Folder[nameSound]:Clone()
	Sound.Parent = self.Char:WaitForChild("HumanoidRootPart")
	Sound:Play()
	Debris:AddItem(Sound, dur)
end

function Weapon:PlaySwingSound(lifeTime: number?)
	print("Do you meant to use PlaySound ", debug.traceback())
	local dur = lifeTime or 1
	local SwordSwingSound = self.Folder:WaitForChild("Swing"):Clone()
	SwordSwingSound.Parent = self.Char:WaitForChild("HumanoidRootPart")
	SwordSwingSound:Play()
	Debris:AddItem(SwordSwingSound, dur)
end

function Weapon:PlayHeavySound(lifeTime: number?)
	print("Do you meant to use PlaySound ", debug.traceback())
	return
end

-- ✅ Public method to resolve hitbox promises
function Weapon:ResolveHitboxPromise(attackID, hitTargets, hitPart)
	return self._hitboxPromiseRegistry:Resolve(attackID, hitTargets, hitPart)
end

function Weapon:AddHitToPromise(attackID, hitTarget, hitPart)
	return self._hitboxPromiseRegistry:AddHit(attackID, hitTarget, hitPart)
end

function Weapon:RejectHitboxPromise(attackID, ...)
	return self._hitboxPromiseRegistry:Reject(attackID, ...)
end

-- ✅ Public method to register hitbox promises
function Weapon:RegisterHitboxPromise(data)
	self._hitboxPromiseRegistry:Register(data)
end

-- ✅ Cancel all promises when unequipping/destroying
function Weapon:Destroy()
	self._hitboxPromiseRegistry:CancelAll()
	-- ... rest of cleanup
end

return Weapon
