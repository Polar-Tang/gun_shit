local Players = game:GetService("Players")
local require = require(script.Parent.loader).load(script)

local BaseAbility = require("BaseAbility")
local Promise = require("Promise")
local CombatConfig = require("CombatConfig")

local MovementAbility = setmetatable({}, BaseAbility)
MovementAbility.__index = MovementAbility

function MovementAbility.new(config)
	local self = setmetatable(BaseAbility.new(config), MovementAbility)
	self._attacks = {} :: { typeof(Promise.new()) } -- May this be a good resource for creating aoe attacks?
	self._lastAttackID = 0
	self.player = Players:GetPlayerFromCharacter(self.character)

	return self
end

function MovementAbility:SetAttributes()
	local CHAR = self.character
	local HUM = self.humanoid

	CHAR:SetAttribute("Swing", true)

	-- HUM.WalkSpeed = 7
	HUM.JumpHeight = 0
end

function MovementAbility:Execute(params)
	local CHAR = self.character
	if CHAR:GetAttribute("Attacking") or CHAR:GetAttribute("Swing") or CHAR:GetAttribute("IsDefending") then
		return
	end

	if self:GetCD() then
		return
	end
	-- start attack
	self:StartCD()
	--Settin attr
	self:SetAttributes()

	self:_countAttack()

	local selfAny = self :: any
	local animHandler = self._animHandler

	local getAnimName = (params and params.get_anim_name) or selfAny.get_anim_name
	local animName = (getAnimName and getAnimName(params)) or self._animName
	animHandler:LoadAnimation(true, animName)

	local effectFn = (params and params.effect) or selfAny.effect
	if effectFn then
		effectFn(self, params)
	end
end

return MovementAbility
