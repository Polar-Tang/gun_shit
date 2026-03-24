local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MovementAbillity = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Client.Abilities.MovementAbillityClient)
local RangeAttackClient = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Client.Abilities.RangeAttackClient)
local weaponTypes = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Shared.types.weaponTypes)
local Maid = require(ReplicatedStorage.Nevermore.Quenty.maid.Shared.Maid)
local require = require(script.Parent.loader).load(script)
local Signal = require("Signal")
local BaseObject = require("BaseObject")

export type ClientAbilityTable = { [string]: any }
export type WeaponBaseClient = {
	character: Model,
	_serviceBag: any,
	weapon_name: string,
	weapon_stats: any,
	maid: any,
	attacks: ClientAbilityTable,
	skills: ClientAbilityTable,

	Init: (self: WeaponBaseClient) -> (),
	createAbilitiesFromKey: (self: WeaponBaseClient, attacks: ClientAbilityTable) -> ClientAbilityTable,
	Execute: (self: WeaponBaseClient, action: string, params: any) -> (),
}

local AbstractStrategy = {}
AbstractStrategy.__index = AbstractStrategy

function AbstractStrategy.new(char, serviceBag, data)
	local damn_data = table.clone(data)
	local self = setmetatable(damn_data, AbstractStrategy)
	self._maid = Maid.new()
	self.character = char
	self._serviceBag = serviceBag

	self.AbilityExecuted = Signal.new()
	self._maid:GiveTask(self.AbilityExecuted)
	self.weapon_name = data.char_name
	self.weapon_stats = table.clone(data.weapon_stats)
	return self
end

function AbstractStrategy:_createAbilities(attacks)
	-- attacks of type Attack and maybe Movement in the future
	local newAttacks = {}

	for _, spec in pairs(attacks) do
		local config = table.clone(spec.config)
		local externalMethods = table.clone(spec)
		config.character = self.character
		config._serviceBag = self._serviceBag
		local tool = self.character:FindFirstChildWhichIsA("Tool")
		config.tool = tool

		local skill
		if config.type == "Range" then
			skill = RangeAttackClient.new(config)
		elseif config.type == "Movement" then
			skill = MovementAbillity.new(config)
		else
			print("unknown ability ", spec)
			continue
		end
		local key = config.keyCode and config.keyCode.Name or config.key and config.key.Name
		assert(key, "abilty has no key ", config)
		assert(typeof(key) == "string", "'key'", key, "is not string")

		assert(attacks[key] or self.skills[key], key .. " is not present in 'attacks' or 'skills'")
		-- attach spec methods directly to the ability instance for OOP style
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

function AbstractStrategy:createAbilitiesFromKey(key: string)
	local abilitySet = assert(self[key], "no key registered: " .. key)
	return self:_createAbilities(abilitySet)
end

function AbstractStrategy:Init()
	self.attacks = self:createAbilitiesFromKey("attacks")
	self.skills = self:createAbilitiesFromKey("skills")
	return self
end

function AbstractStrategy:Start()
	self:_resetDmgCount()

end

function AbstractStrategy:Destroy()
	self.ActionRequested:Destroy()
end

return AbstractStrategy
