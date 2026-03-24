-- shared functionalities between the client and server service bag
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OtherAnims = require(ReplicatedStorage.Animations.OtherAnims)
local WeaponsAnims = require(ReplicatedStorage.Animations.WeaponsAnims)

local module = {}

function module.createCharNameIns(char: Model, char_name: string)
	local charNameInst = Instance.new("StringValue")
	charNameInst.Value = char_name
	charNameInst.Parent = char
	charNameInst.Name = "CharName"

	return charNameInst
end

function module:InitCharWeapon(char, char_name, binder)
	local weaponHandler = binder
	if not binder then
		local serviceBag = _G.ServiceBag or _G.ServiceBagClient
		local binderProvider = _G.BinderProvider or _G.BinderProviderClient
		local BinderProvider = serviceBag:GetService(binderProvider)

		local WeaponBinder = BinderProvider:Get("Armed")

		if WeaponBinder then
			weaponHandler = WeaponBinder:Get(char)
		end
	end
	weaponHandler:registryTool(char_name)
	weaponHandler:EquiTool(char_name)
	local instance = char:FindFirstChild("CharName") or module.createCharNameIns(char, char_name)
	instance.Value = char_name
end

function module:InitCharAnim(char, char_name, binder)
	if not WeaponsAnims[char_name] then
		return
	end

	local animHandler = binder
	if not binder then
		local serviceBag = _G.ServiceBag or _G.ServiceBagClient
		local binderProvider = _G.BinderProvider or _G.BinderProviderClient
		local BinderProvider = serviceBag:GetService(binderProvider)

		local AnimationHandler = BinderProvider:Get("AnimationHandler")
		animHandler = AnimationHandler:Get(char)
	end
	animHandler:Restart()
	animHandler:registryAnims(WeaponsAnims[char_name])
	animHandler:AddAnimations(OtherAnims)

	animHandler:LoadAnimation(true, "Equip")
	-- animHandler:PreloadAnims({ "ADash", "SDash", "WDash", "DDash" })
	char:SetAttribute("char_name", char_name)
end

function module:InitChar(char, char_name)
	self:InitCharAnim(char, char_name) -- init anim handler first
	self:InitCharWeapon(char, char_name)
end

function module:GetHumanoid()
	local character = self:GetCharacter()
	return character:WaitForChild("Humanoid")
end

return module
