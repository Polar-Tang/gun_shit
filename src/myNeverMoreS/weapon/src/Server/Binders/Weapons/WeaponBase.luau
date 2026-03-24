local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RangeAttack = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Server.Abilities.RangeAttack)
local weaponTypes = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Shared.types.weaponTypes)
local Table = require(ReplicatedStorage.Nevermore.Quenty.table.Shared.Table)

-- WeaponBase.lua
local require = require(script.Parent.loader).load(script)
local Maid = require("Maid")

local AttackBaseAbility = require("AttackBaseAbility")
local DefenseBaseAbility = require("DefenseBaseAbility")
local MovementAbility = require("MovementAbility")

local WeaponBase = {}
WeaponBase.__index = WeaponBase

type AbilityTable = { [string]: any }

type WeaponBase = {
	char: Model,
	_serviceBag: any,
	_weapon: any,
	maid: any,
	weapon_name: string,
	weapon_stats: any,
	attacks: AbilityTable,
	skills: AbilityTable,
	_initialized: boolean,
	Init: (self: WeaponBase) -> (),
	createAbilitiesFromKey: (self: WeaponBase, attacks: AbilityTable) -> AbilityTable,
	Execute: (self: WeaponBase, action: EnumItem | { Name: string }, params: any) -> (),
}

type weaponStats = {
	damage: number,
	heavy_damage: number,
	block_reset_time: number,
	parry_time: number,
	walk_speed_normal: number,
	walk_speed_blocking: number,
	stun_time: number,
	run_speed: number,
}

function WeaponBase.new(char: Model, serviceBag, data): WeaponBase
	local self = setmetatable(data, WeaponBase)
	self.character = char
	self._serviceBag = serviceBag

	-- self.attacks = {}
	-- Table.deepOverwrite(self.attacks, data.attacks)

	self._maid = Maid.new()

	local fck_tool: Tool = self.character:FindFirstChildWhichIsA("Tool")

	fck_tool:SetAttribute("_ammo", self.weapon_stats._ammo)
	self.tool = fck_tool
	self._initialized = false

	return self
end
function WeaponBase:Init()
	self.attacks = self:createAbilitiesFromKey("attacks")
	self.skills = self:createAbilitiesFromKey("skills")
	self._initialized = true
end

function WeaponBase:_increaseDmgCount(dmg)
	if self.isTransformed then
		return
	end
	self._dmgCount += dmg
end

function WeaponBase:_resetDmgCount()
	local countDamage = ReplicatedStorage.RemoteEvents.countDamage
	self._dmgCount = 0

	local char_player = Players:GetPlayerFromWeapon(self.Weapon)
	countDamage:FireClient(char_player, 0)
end

function WeaponBase:_setIsTransformed(value: boolean)
	self.isTransformed = value
	self.Weapon:SetAttribute("IsTransformed", value)

	if self.Weapon:GetAttribute("char_name") == "utlimate_" .. self.char_name then
		self.Weapon:SetAttribute("char_name", self.char_name)
	elseif self.Weapon:GetAttribute("char_name") == self.char_name then
		self.Weapon:SetAttribute("char_name", "utlimate_" .. self.char_name)
	end
end

function WeaponBase:createAbilitiesFromKey(key)
	-- HERE
	local fucking_data = self[key]
	

	local attackData = assert(fucking_data, "no key registered")
	print("self._initialized  ", self._initialized )
	return self:_createAbilities(attackData)
end


function WeaponBase:_createAbilities(attacks)
	-- attacks of type Attack and maybe Movement in the future
	local newAttacks = {}
	for _, spec in pairs(attacks) do
		local config = table.clone(spec.config)
		local externalMethods = table.clone(spec)
		config.character = self.character
		config._serviceBag = self._serviceBag

		config.tool = self.tool

		local skill
		if config.type == "Defense" then
			skill = DefenseBaseAbility.new(config)
		elseif config.type == "Attack" then
			skill = AttackBaseAbility.new(config)
		elseif config.type == "Others" then
			skill = MovementAbility.new(config)
		elseif config.type == "Range" then
			skill = RangeAttack.new(config)
		else
			print("unknown ability ", spec)
			continue
		end
		local key = config.keyCode and config.keyCode.Name or config.key and config.key.Name
		assert(key, "abilty has no key ", config)
		assert(typeof(key) == "string", "'key'", key, "is not string")
		assert(attacks[key], key .. " is not present in the attacks ", attacks)

		-- attach spec methods/constants on the ability instance for direct dispatch
		skill.spec = externalMethods
		for methodName, methodValue in pairs(externalMethods) do
			if methodName ~= "config" and typeof(methodValue) == "function" then
				skill[methodName] = methodValue
			end
		end

		skill:Init(externalMethods)
		self._maid:GiveTask(skill)
		newAttacks[key] = skill

	end
	return newAttacks
end

function WeaponBase.Start(self)
	self:_resetDmgCount()

	self:_createAbilities()
end

function WeaponBase:Destroy()
	self._maid:DoCleaning()
	setmetatable(self, nil)
end

function WeaponBase:Execute(action: EnumItem | { Name: string }, params)
	if not action.Name then
		return
	end

	local key = action.Name

	local command = self.attacks[key] or self.skills[key]
	if not command then
		return
	end

	-- `command` already carries its spec via createAbilitiesFromKey
	command:Execute(params)
end

function WeaponBase:GetAction(action: string)
	return self.attacks[action]
end
--

function WeaponBase:UnEquip()
	self._maid:DoCleaning()
	return self:Destroy()
end

-- This will loop abilities, setting new ones based on the weapon type
--[[function Weapon:Start(weaponAbilities: {[string]})
	for keyCode, abilityName in pairs(weaponAbilities) do
		local abilityClass = assert(ALL_ABILITIES[abilityName], "Ability "..abilityName.." not found")
		self[keyCode] = abilityClass.new({
			name = abilityName,
		})
	end
end
]]
return WeaponBase
