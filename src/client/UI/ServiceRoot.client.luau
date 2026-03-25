--||Services||--
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--||Nevermore Shit||--
---------------------------getting servicebag and loader -----------------------------

local NeverMorePackages = RS.Nevermore
local loader = NeverMorePackages:FindFirstChild("LoaderUtils", true).Parent
local Nevermore = require(loader).bootstrapGame(NeverMorePackages)

local ServiceBag = Nevermore("ServiceBag")
local serviceBag = ServiceBag.new()

---------------------------------
local istTaggedArmed
local isServiceBagInitialized
---------------------------------

--------------------------- Binders -----------------------------
local RagdollServiceClient = serviceBag:GetService(Nevermore("RagdollServiceClient"))
local Cooldown = serviceBag:GetService(Nevermore("CooldownClient"))

-- local BinderProvider = Nevermore("BinderProvider")
local Binder = Nevermore("Binder")
serviceBag:GetService(Nevermore("RagdollServiceClient"))
local WeaponClient = Nevermore("WeaponClient") -- THIS IS NEW
serviceBag:GetService(Nevermore("TimeSyncService"))
local AnimationHandler = Nevermore("AnimationHandler")
local CameraStackService = Nevermore("CameraStackService")
local Binders = {
	["AnimationHandler"] = AnimationHandler,
	["Armed"] = WeaponClient,
}
---------- USE BINDER PORVIDER ----------
local BinderProvider = Nevermore("BinderProvider")

local AttacksBinders = BinderProvider.new("Binders", function(self, serviceBag)
	for tag, contructor in pairs(Binders) do
		self:Add(Binder.new(tag, contructor), serviceBag, "test")
	end
end)
serviceBag:GetService(AttacksBinders)
--------------------------- END Binders -----------------------------
--------------------------- INIT -----------------------------

local shiftLockControllerModule = require(script.Parent.shiftLockController)
local shiftLockController = shiftLockControllerModule.new()
shiftLockController:ToggleShiftLock(true)

serviceBag:Init()
local PlayerBrio = Nevermore("PlayerBrio")

local BinderProviderInitialized = serviceBag:GetService(AttacksBinders)
local characterCtxUtils = require(ReplicatedStorage.Helpers.shared_services.characterCtxUtils)
local CameraRecoiler = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Client.utils.CameraRecoiler)
local FadeText = require(ReplicatedStorage.utils.FadeText)

local player = Players.LocalPlayer
local player_character = player.Character or player.CharacterAdded:Wait()

local WeaponBinderStarted = BinderProviderInitialized:Get("Armed")
WeaponBinderStarted:GetClassAddedSignal():Connect(function(binder)
	local character = binder.Char

	-- If there are more shit that App depends to, we can use a bool instance, and listen to this att, when it's true we require it
	if player_character == character then
		istTaggedArmed = true
	end
end)

local AnimBinder = BinderProviderInitialized:Get("AnimationHandler")
AnimBinder:GetClassAddedSignal():Connect(function(binder)
	local character = binder.Char
	character:SetAttribute("binder-AnimationHandler-charged", true)
	-- replaceCharacter({ name = "shark", character = character })
	-- characterService:InitCharAnim(character, "shark", binder)
end)

-------------------------START SERVICEBAG -----------------------------

serviceBag:Start()

----- ------------------------ START SERVICEBAG -----------------------------
_G.PlayerBrio = PlayerBrio.new() -- use the same instance for everything
_G.ServiceBag = serviceBag
_G.BinderProvider = AttacksBinders
_G.shiftLockController = shiftLockController
isServiceBagInitialized = true
------------- ONCE INITIALIZED -------------

-- Ensures Roact App start after intializing service bag
require(script.Parent.AttckInvockerClient)

-- TODO: find out how to using the player brio and clean up connections once it logs out

-- local humanoid: Humanoid = player_character:WaitForChild("Humanoid")
player_character.ChildAdded:Connect(function(a0: Instance)
	if a0:IsA("Tool") then
		ReplicatedStorage.RemoteEvents.Equipment:FireServer({
			tool = a0,
			has_to_equip = true,
		})
		characterCtxUtils:InitChar(player_character, tostring(a0.Name:lower()))
	end
end)

local whenRequireAppCon
whenRequireAppCon = RunService.Heartbeat:Connect(function(a0: number)
	if istTaggedArmed and isServiceBagInitialized then
		require(script.Parent.App)
		whenRequireAppCon:Disconnect()
	end
end)

ReplicatedStorage.RemoteEvents.countDamage.OnClientEvent:Connect(function(data)
	local dmg = data.dmg
	local textColor = Color3.fromRGB(255, 255, 255)

	FadeText(data.src, dmg, textColor, UDim2.new(6, 0, 4, 0))
end)

-- player_character:GetAttributeChangedSignal("recoil"):Connect(function(recoil: number)
-- 	print("recoild ", recoil)
-- 	CameraRecoiler.recoil(recoil)
-- end)
