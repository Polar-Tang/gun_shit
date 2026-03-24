local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AbstractStrategy = require(script.Parent.WeaponBaseClient)
local weaponHelpers = require(script.Parent.weaponHelpers)

local CombatConfig = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Shared.CombatConfig)

local WeaponStats = CombatConfig:getweapon("Fist")

local FistClient = setmetatable({}, AbstractStrategy)
FistClient.__index = FistClient

function FistClient.new(char, serviceBag)
	
	local weapon_stats = table.clone(WeaponStats)

	local self = setmetatable(AbstractStrategy.new(char, serviceBag, weapon_stats), FistClient)
	return self
end

function FistClient:Execute(action, params)
	if not action then
		return
	end
	if not self.attacks[action] then
		return
	end
	weaponHelpers.execute(action, params)
end

return FistClient
