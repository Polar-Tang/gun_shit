local RS = game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = RS.RemoteEvents
local swingEvent = Events.Swing
--||RemoteEvents||--
local Equipment = Events.Equipment

local animations = require(RS.Animations.WeaponsAnims)
local characterCtxUtils = require(ReplicatedStorage.Helpers.shared_services.characterCtxUtils)

--local blockingEvent = Events.Blocking

local serviceBag = _G.ServiceBag

local BinderProvider = serviceBag:GetService(_G.BinderProvider)
local AnimationHandler = BinderProvider:Get("AnimationHandler")
local WeaponBinder = BinderProvider:Get("Armed")
local CombatMediator = {}

function CombatMediator.PlayerAdded(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	char:SetAttribute("Combo", 1)
	char:SetAttribute("Stunned", false)
	char:SetAttribute("Swing", false)
	char:SetAttribute("Attacking", false)
	char:SetAttribute("IsRagdoll", false)
	char:SetAttribute("Iframes", false)
	char:SetAttribute("IsBlocking", false)
	char:SetAttribute("Blocking", 0)
	char:SetAttribute("Parrying", false)
end

local AttckInvoker = script.Parent.AttckInvoker

--||Event for combat||--
local combatServer = require(AttckInvoker)

swingEvent.OnServerEvent:Connect(combatServer.swingEvent)

--||Equipment||--

Equipment.OnServerEvent:Connect(function(player: Player, data)
	local tool = data.tool
	local has_to_equip = data.has_to_equip
	local char: Model = player.Character or player.CharacterAdded:Wait()

	local WeaponHandler = WeaponBinder:Get(char)

	if not has_to_equip then
		-- AnimationClient.UnEquip(char)
		print("not has to equip")
		WeaponHandler:UnequiTool()
		return
	end
	local r6Name = tostring(tool.Name):lower()

	local tool_anims = animations[r6Name]
	characterCtxUtils:InitCharWeapon(char, r6Name)
end)

local HitboxResponseRemote = Events.HitboxResponseRemote

HitboxResponseRemote.OnServerEvent:Connect(function(player, data)
	local attackID = data.attackID
	local hitTargets = data.character
	local hitPart = data.hitPart

	-- Get the attacker's character
	local character = player.Character
	if not character then
		-- warn("[HitboxServer] Player character not found")
		return
	end

	-- Get weapon binder for this character
	local weapon = WeaponBinder:Get(character)
	if not weapon then
		-- warn("[HitboxServer] Weapon not found for", player.Name)
		return
	end

	-- ✅ Route to the correct promise
	weapon:AddHitToPromise(attackID, hitTargets, hitPart)
end)

return CombatMediator
