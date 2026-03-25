local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Shared.CombatConfig)
local AbstractStrategy = require(script.Parent.WeaponBaseClient)

local WeaponStats = CombatConfig:getweapon("ak-47")
local Ak_47Client = setmetatable({}, AbstractStrategy)
Ak_47Client.ClassName = "Ak_47Client"
Ak_47Client.__index = Ak_47Client

function Ak_47Client.new(char, serviceBag)
	local damn_data = table.clone(WeaponStats)

	local self = setmetatable(AbstractStrategy.new(char, serviceBag, damn_data), Ak_47Client)
	return self
end

function Ak_47Client:Execute(action, params)
	if not action then
		return
	end
	if not action.Name then
		return
	end
	if not self.attacks[action.Name] then
		return
	end

	local command

	local checkThTShit = function(key)
		return self[key][action.Name]
	end

	if self.skills[action.Name] then
		command = checkThTShit("skills")
	elseif self.attacks[action.Name] then
		command = checkThTShit("attacks")
	else
		print("Unkown command ", action.Name)
		return
	end

	command:Execute(params)
end

return Ak_47Client
