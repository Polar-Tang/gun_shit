local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CameraRecoiler = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Client.utils.CameraRecoiler)
local CooldownController = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Server.Utils.CooldownController)
local EffectTypes = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Server.Utils.EffectTypes)
local BaseAbility = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Shared.Abilities.BaseAbility)
local castRays = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Shared.utils.castRays)
local drawRayResults = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Shared.utils.drawRayResults)
local getRayDirections = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Shared.utils.getRayDirections)
local weaponTypes = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Server.types.weaponTypes)

local CombatConfig = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Shared.CombatConfig)

export type AttackDistanceAbilityType = weaponTypes.AttackDistanceAbilityCLient
export type construnctor = weaponTypes.BaseAbilityConstructor
export type hitDetection = weaponTypes.hitDetection
export type HitEffectContract = EffectTypes.HitEffectContract

local AttackDistanceAbility = setmetatable({}, BaseAbility)
AttackDistanceAbility.__index = AttackDistanceAbility

function AttackDistanceAbility.new(config: construnctor)
	local self = setmetatable(BaseAbility.new(config), AttackDistanceAbility)
	self._lastAttackID = 0

	self.ammo = 0
	self.attackType = config.attackType
	self.player = Players:GetPlayerFromCharacter(self.character)

	self._lastShotTimestamp = 0
	self._recoilRestoreCFrame = nil
	self._recoilTimeoutThreshold = 0.01
	self._recoilCooldownController = CooldownController.new(self.character, self._serviceBag)
	self._recoilResetConnection = nil

	self.attackRow = 0

	self._playerMoved = false
	self._lastPlayerCFrame = nil

	self._inputConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self._playerMoved = true
			self._lastPlayerCFrame = Workspace.CurrentCamera.CFrame
		end
		self._currentTween:Stop()
	end)
	self._maid:GiveTask(self._inputConnection)

	self:_setupContinuousFireObservable()

	return self :: AttackDistanceAbilityType
end

function AttackDistanceAbility._resolveWeaponGrip(
	self: AttackDistanceAbilityType,
	strategyName: string,
	methodName: string,
	model: Model
)
	local weaponStats = CombatConfig:getweapon(strategyName)
	local fn = weaponStats[methodName]

	assert(typeof(fn) == "function", "Invalid weapon grip method")

	return fn(model)
end

function AttackDistanceAbility._setupContinuousFireObservable(self: AttackDistanceAbilityType)
	local bool: BoolValue = Players.LocalPlayer:FindFirstChild("m1Hold")

	local m1Con: RBXScriptConnection
	m1Con = bool.Changed:Connect(function()
		if not bool.Value then
			return
		end

		local thread
		thread = function()
			task.delay(self._cooldown, function()
				-- bool val may change while the task is schedule
				if not bool.Value then
					return
				end
				self:Execute()
				thread()
			end)
		end

		thread()
	end)
	self._maid:GiveTask(m1Con)
end

function AttackDistanceAbility._isContinuousShot(self: AttackDistanceAbilityType, timestamp: number)
	local last = self._lastShotTimestamp
	local threshold = 0.1
	local cooldown = self._cooldown
	return last > 0 and timestamp - last <= (cooldown + threshold)
end

function AttackDistanceAbility._restoreRecoil(self: AttackDistanceAbilityType)
	print("asd")
	-- really need to find out a way for coexisting the tween cameras and the camera override
	local camera = Workspace.CurrentCamera
	if camera and self._recoilRestoreCFrame then
		local tweenInfo = TweenInfo.new(
			0.2, -- duration (tweak this)
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(camera, tweenInfo, {
			CFrame = self._recoilRestoreCFrame,
		})
		self._currentTween = tween
		tween:Play()
	end

	self._recoilRestoreCFrame = nil

	if self._recoilResetConnection then
		self._recoilResetConnection:Disconnect()
		self._recoilResetConnection = nil
	end
	local controller = self._recoilCooldownController:getCD()
	if controller then
		-- reset optional controller to let next shooting cycle recreate
		-- controller cancellation performed by its own model end state
	end
end

function AttackDistanceAbility._createRecoilStrike(self: AttackDistanceAbilityType)
	self._recoilCooldownController:init(self._cooldown + 0.15)
	task.defer(function()
		local c = self._recoilCooldownController:getCD()
		if not c then
			return
		end
		if self._recoilResetConnection then
			self._recoilResetConnection:Disconnect()
		end
		self._recoilResetConnection = c.Done:Connect(function()
			self:_restoreRecoil()
		end)
		-- self._maid:GiveTask(self._recoilCooldownController)
	end)
end

function AttackDistanceAbility._scheduleRecoilReset(self: AttackDistanceAbilityType)
	local controller = self._recoilCooldownController:getCD()
	if not controller then
		self:_createRecoilStrike()
	else
		if self._cooldown == 3 then
			print()
		end
		self._recoilCooldownController:ResetTo(self._cooldown + 0.1)
	end
end

function AttackDistanceAbility.SetAttributes(self: AttackDistanceAbilityType)
	local CHAR = self.character
	local HUM = self.humanoid

	CHAR:SetAttribute("Attacking", true)
	CHAR:SetAttribute("Swing", true)

	HUM.WalkSpeed = 7
	HUM.JumpHeight = 0
end

function AttackDistanceAbility.UnsetAttributes(self: AttackDistanceAbilityType)
	local CHAR = self.character
	local HUM = self.humanoid

	CHAR:SetAttribute("Attacking", false)
	CHAR:SetAttribute("Swing", false)

	HUM.WalkSpeed = 16
	HUM.JumpHeight = 6.5
end

function AttackDistanceAbility._shot(self: AttackDistanceAbilityType)
	local spread = self.weapon_stats.spread
	local raysPerShot = self.weapon_stats.raysPerShot
	local range = self.weapon_stats.range
	local rayRadius = self.weapon_stats.rayRadius

	local now = Workspace:GetServerTimeNow()

	if not self:_isContinuousShot(now) then
		self:_createRecoilStrike()
		self.attackRow = 1
	else
		self.attackRow += 1
		self:_scheduleRecoilReset()
	end
	self._lastShotTimestamp = now

	self:recoil()

	-- Update restore point if player moved camera during shot
	if self._playerMoved then
		self._recoilRestoreCFrame = self._lastPlayerCFrame
		self._playerMoved = false
	end

	self.ammo -= 1

	-- self.guiController:setAmmo(self.ammo)

	local origin = Workspace.CurrentCamera.CFrame

	local rayDirections = getRayDirections(origin, raysPerShot, math.rad(spread), now)
	for index, direction in rayDirections do
		rayDirections[index] = direction * range
	end

	local rayResults = castRays(self.player, origin.Position, rayDirections, rayRadius)

	-- Rather than passing the entire table of rayResults to the server, we'll pass the shot origin and a list of tagged humanoids.
	-- The server will then recalculate the ray directions from the origin and validate the tagged humanoids.
	-- Strings are used for the indices since non-contiguous arrays do not get passed over the network correctly.
	-- (This may be non-contiguous in the case of firing a shotgun, where not all of the rays hit a target)
	local tagged = {}
	for index, rayResult in rayResults do
		if rayResult.taggedHumanoid then
			tagged[tostring(index)] = {
				Humanoid = rayResult.taggedHumanoid,
				limb = rayResult.limb,
			}
		end
	end

	ReplicatedStorage.RemoteEvents.Swing:FireServer(
		Enum.UserInputType.MouseButton1,
		{ timestamp = now, tagged = tagged, origin = origin }
	)

	drawRayResults(assert(self._tool.PrimaryPart, " tool must have a primary part").Position, rayResults)
end

local random = Random.new()
function AttackDistanceAbility.recoil(self: AttackDistanceAbilityType)
	local recoilMin = self.weapon_stats.recoilMin
	local recoilMax = self.weapon_stats.recoilMax

	local xDif = recoilMax.X - recoilMin.X
	local yDif = recoilMax.Y - recoilMin.Y
	local x = recoilMin.X + random:NextNumber() * xDif
	local y = recoilMin.Y + random:NextNumber() * yDif

	local recoil = Vector2.new(math.rad(-x), math.rad(y))

	CameraRecoiler.recoil(recoil)
end

function AttackDistanceAbility.Execute(self: AttackDistanceAbilityType, params)
	local CHAR = self.character
	local frontenShit = params

	if not self.special_attack then
		if CHAR:GetAttribute("Attacking") or CHAR:GetAttribute("Swing") or CHAR:GetAttribute("IsDefending") then
			return
		end
	end

	if self:GetCD() then
		return
	end
	-- start attack
	self:StartCD()

	local preAnimFx = (params and params.preAnimFx) or self.preAnimFx
	if preAnimFx then
		preAnimFx(self, frontenShit)
	end

	-- local animHandler = self._animHandler
	-- local getAnimName = (params and params.get_anim_name) or self.get_anim_name
	-- local animName = (getAnimName and getAnimName(self)) or self._animName

	-- local hit_effect_data = self.hit_effect_data -- remember to use this as an attribute

	self:_shot()

	local postAnim = (params and params.post_anim) or self.post_anim
	if postAnim then
		postAnim(self)
	end
end

return AttackDistanceAbility
