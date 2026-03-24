--||Service||--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Listen for tools added to the backpack

-- initial backpack tools

local HitboxClass = require(ReplicatedStorage.HitboxClass)
-- Remotes events (i got the code smell to migrate this)
local Events = ReplicatedStorage.RemoteEvents
local HitboxResponseRemote = Events.HitboxResponseRemote

local _ = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

-- This event is called in the server after it has Execute() the ability
HitboxResponseRemote.OnClientEvent:Connect(function(attackInfo)
	local hitboxes = attackInfo.hitboxes
	for _, hitbox in ipairs(hitboxes) do
		local weapon = hitbox.Weapon

		if typeof(weapon) == "table" then
			local pos = weapon.Pos
			local root_hitbox = Instance.new("Part")
			root_hitbox.Transparency = 1
			root_hitbox.Position = pos
			root_hitbox.CanCollide = false
			root_hitbox.Anchored = true
			root_hitbox.Size = hitbox.Size
			root_hitbox.Parent = workspace
			if weapon.CF then
				root_hitbox.CFrame = weapon.CF
			end
			weapon = root_hitbox
			Debris:AddItem(root_hitbox, hitbox.Time)
			-- print(weapon)
		end

		-- Create overlapParams
		local newParmas = OverlapParams.new()
		newParmas.FilterType = Enum.RaycastFilterType.Exclude
		newParmas.FilterDescendantsInstances = { hitbox.Attacker }
		-- TODO: add a strike effect from the data which has strike true or something alike, vfx for tha abilities like m1 or shark frenzy has this att set to true, this create an emit a particle right in weapon.Position
		local newHitbox = HitboxClass.new(hitbox.Shape, {
			root = weapon,
			size = hitbox.Size,
			duration = hitbox.Time,
			interval = 0.05,
			velocityPrediction = true,
			dotProductFilter = {
				dotProduct = 0.1,
				referenceVector = hitbox.referenceVector,
				sourcePosition = hitbox.sourcePosition,
			},
			-- debug = true,
			hitboxId = hitbox.attackID,
			HitMode = hitbox.HitMode,
			overlapParams = newParmas,
		})
		newHitbox.OnHit:Connect(function(character, hitPart)
			-------TEST-------

			HitboxResponseRemote:FireServer({ attackID = attackInfo.attackID, character = character, hitPart = hitPart })
		end)

		newHitbox:Start()
	end
end)

return {}
