local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RangeAttack = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Server.Abilities.RangeAttack)
local EffectTypes = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Server.Utils.EffectTypes)
local roll_vfx = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Server.Utils.roll_vfx)
local Constanst = require(ReplicatedStorage.Nevermore.Custom.abilities.src.Shared.Constanst)
local Table = require(ReplicatedStorage.Nevermore.Quenty.table.Shared.Table)
local weaponTypes = require(ReplicatedStorage.Nevermore.Custom.weapon.src.Server.types.weaponTypes)

export type BaseAbility = weaponTypes.BaseAbility
export type BaseAbilityConstructor = weaponTypes.BaseAbilityConstructor

export type AttackBaseAbility = weaponTypes.AttackBaseAbility
export type AttackBaseAbilityConstructor = weaponTypes.AttackBaseAbilityConstructor

export type DefenseAbility = weaponTypes.DefenseAbility
export type DefenseAbilityConstructor = weaponTypes.DefenseAbilityConstructor

export type AbilitySpec = {
	config: BaseAbilityConstructor | DefenseAbilityConstructor | AttackBaseAbilityConstructor,
	endFx: ((ctx: BaseAbility) -> ())?,
	special_speed: number?,
	effect: ((ctx: BaseAbility) -> ())?,
}

export type effectHitCtx = EffectTypes.effectHitCtx
export type VFX = EffectTypes.VFX

export type HitboxesResult = {
	hitboxes: { weaponTypes.HitboxConfig },
	vfxs: { VFX }?,
	hit_effect_data: {}?,
}

export type hits = {
	hitPart: BasePart,
	target: Model,
}

export type after_hit_data = {
	vfxs: { VFX },
	hits: hits,
}

export type AttackAbilitySpec = {

	-- execution hooks
	createHitboxes: (ctx: AttackBaseAbility) -> HitboxesResult,
	delay_cb: ((ctx: AttackBaseAbility) -> () -> ())?,
	delay_cb_number: number?,
	custom_init: ((ctx: AttackBaseAbility) -> () -> ())?,
	after_hit: ((ctx: AttackBaseAbility, after_hit_data: after_hit_data) -> ())?,
	post_anim: (ctx: AttackBaseAbility) -> ()?,
	get_anim_name: (ctx: AttackBaseAbility) -> ()?,
} & AbilitySpec

export type DefenseAbilitySpec = {
	_process: (ctx: DefenseAbility, dmgCtx: any) -> (),
	_execute: (ctx: DefenseAbility) -> (),
	_additiona_deactivate: ((ctx: DefenseAbility) -> ())?,
} & AbilitySpec

export type Weapon = {
	attacks: {
		[string]: AttackAbilitySpec | DefenseAbilitySpec | AbilitySpec,
	},
}

local module = {}
local info = {}

local default_end_fx = function(data)
	for i, animName in ipairs(data.animNames) do
		data._animHandler:PreloadAnims({ animName })
		local hitEnd = function(track: AnimationTrack)
			data:resetAtt()
		end

		data._animHandler:OnSignal({
			callback = hitEnd,
			animationName = animName,
			animationEventName = "EndedCon",
		})
	end
end

local end_m1_fx = function(data)
	data:InitCDInst()
	data.character:SetAttribute("Combo", 1)

	for i, animName in ipairs(data.animNames) do
		if data._animHandler then
			data._animHandler:PreloadAnims({ animName })
			local hitEnd = function(track: AnimationTrack)
				if not data.character:GetAttribute("IsBlocking") then
					data.humanoid.WalkSpeed = 14
					data.humanoid.JumpHeight = 6.5
				end

				data.character:SetAttribute("Attacking", false)
				-- data:PlaySound("Swing", 2)
				data.character:SetAttribute("Swing", false)
			end
			data._animHandler:OnSignal({
				callback = hitEnd,
				animationName = animName,
				animationEventName = "EndedCon",
			})
		end
	end
end

--

type dash_movement_arg = {
	hrp: BasePart,
	dir: Vector3,
	time: number,
	distance: number,
}

local function dash_movement(dash_movement_arg: dash_movement_arg)
	-- ALING THE CHARACTER TO THE PLAYER CAMERA ORIENTATION
	local hrp = dash_movement_arg.hrp
	local dashDir = dash_movement_arg.dir
	local timeShit = dash_movement_arg.time
	local distance = dash_movement_arg.distance

	-- testPart({Position = hrp.Position, Size = Vector3.new(50,50,50)})
	local dashSpeed = distance / timeShit
	local endPos = hrp.Position + (dashDir * dashSpeed) * timeShit
	-- local endPos2 = hrp.Position + dashDir * Constants.dashDistance

	local attachmentAlignPos = Instance.new("Attachment")
	attachmentAlignPos.Name = "attachmentDash"
	attachmentAlignPos.Visible = true
	attachmentAlignPos.Parent = hrp

	local alignPos = Instance.new("AlignPosition")
	alignPos.Attachment0 = attachmentAlignPos
	alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPos.MaxForce = math.huge
	alignPos.MaxVelocity = math.huge
	alignPos.Position = endPos
	-- testPart({Position = endPos, Size = Vector3.new(5,5,5)})
	alignPos.Responsiveness = 20
	alignPos.ApplyAtCenterOfMass = true
	alignPos.Parent = hrp
	Debris:AddItem(alignPos, Constanst.dashTime)
	Debris:AddItem(attachmentAlignPos, Constanst.dashTime)
end
-- Sliding
local dash_effect = function(ctx: AttackBaseAbility, frontendShits)
	local dashDir = frontendShits.dir
	local camYaw = frontendShits.camYaw

	do
		if typeof(dashDir) ~= "Vector3" then
			return
		end
		if dashDir.Magnitude < 0.9 or dashDir.Magnitude > 1.1 then
			return
		end

		dashDir = Vector3.new(dashDir.X, 0, dashDir.Z)
		if dashDir.Magnitude == 0 then
			return
		end
		dashDir = dashDir.Unit
	end

	local Character = ctx.character
	local hrp = Character.HumanoidRootPart

	-- if frontendShits.dir == Vector3.new(0, 0, 1) then
	-- 	local endPos = hrp.Position + (dashDir * 20) * 0.3

	-- 	local newCFrame = CFrame.lookAt(hrp.Position, hrp.Position - endPos) * CFrame.Angles(0, math.rad(camYaw), 0)
	-- 	-- CombatUtils.GetCFForCamYaw(hrp.Position, camYaw)
	-- 	hrp.CFrame = newCFrame
	-- else
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, camYaw, 0)
	-- end
	local dash_data = {
		dir = dashDir.Unit,
		hrp = ctx.hrp,
		time = Constanst.dashTime,
		distance = Constanst.dashDistance,
	}
	dash_movement(dash_data)

	--dash_promise(ctx)

	roll_vfx({
		{
			Attacker = ctx.character,
			action = "dash_vfx",
			dashDir = dashDir,
			camYaw = camYaw,
			animName = frontendShits.animName,
			dir = dashDir,
		},
	})
end

SDashKey = { Name = "SDash" }
local Slide = {
	config = {
		animNames = { "SDash" },
		type = "Movement",
		cooldown = 5,
		key = SDashKey,
	},
	get_anim_name = function(frontendShits)
		return frontendShits.dashName
	end,
	effect = dash_effect,
	endFx = default_end_fx,
}

local WDash = table.clone(Slide)
WDaskKey = { Name = "WDash" }
WDash.config = {
	animNames = { "WDash" },
	type = "Movement",
	cooldown = 5,
	key = WDaskKey,
}

-- Weapons

-- Stink Fist

local function create_m1_hitboxes(configData: weaponTypes.HixboxDataConfig)
	return function(ctx, params)
		-- SET THE COMBO ATT
		local char = ctx.character
		local max_combo = 4

		local function getWeapon(): BasePart
			local char = ctx.character
			local combo = char:GetAttribute("Combo")

			-- TODO: the new observer will remove the use of a hardcoded strategy
			if combo % 2 == 0 then
				return ctx:_resolveWeaponGrip("Fist", "getRightGrip", char)
			end

			return ctx:_resolveWeaponGrip("Fist", "getLeftGrip", char)
		end

		local current_combo = char:GetAttribute("Combo")

		local hit_effect = {
			damage = 10,
			attacker = ctx.character,
			stun_time = ctx.stun_time,
			attackId = ctx.attackId,
		}
		if current_combo == max_combo then
			hit_effect.strength = 30
			hit_effect.groundSmash = {
				position = nil,
				amount = 14,
				velocity = 70,
				material = Enum.Material.Slate,
				dust = true,
				shockwave = true,
				sizeRange = Vector2.new(1, 2.5),
				lifetime = 2.5,
			}
		end
		hit_effect.strikes_hit = true

		local weapon = getWeapon()

		local detectionInfo = {
			Time = configData.Time,
			Size = configData.Size,
			CFrame = configData.CFrame,
			HitMode = configData.HitMode,
			Shape = configData.Shape,
			attackId = ctx.attackId,
			strikes_hit = configData.strikes_hit,
			Weapon = weapon,
			referenceVector = ctx.character.PrimaryPart.CFrame.LookVector,
			sourcePosition = ctx.character.PrimaryPart.Position,
			Attacker = ctx.character,
		}

		if params.isTransformed then
			roll_vfx({ {
				action = "waterHit",
				src = weapon,
				Attacker = ctx.character,
			} })
		end
		return {
			hitboxes = { detectionInfo },
			hit_effect_data = hit_effect,
		}
	end
end

local m1 = {
	config = {
		life_time = 1.4,
		keyCode = Enum.UserInputType.MouseButton1,
		animNames = { "Swing1", "Swing2", "Swing3", "Swing4" },
		type = "Attack",
		attackType = "ST",
		cooldown = 0.5,
	},
	get_anim_name = function(ctx)
		local char = ctx.character
		local combo = char:GetAttribute("Combo")

		return "Swing" .. combo
	end,

	preAnimFx = function(ctx)
		local char = ctx.character
		local max_combo = 4
		-- SET THE COMBO ATT
		-- If the last hit was after 3 seconds, reset the combo
		if not ctx._comboController:isCd() then
			-- print("current combo ", char:GetAttribute("Combo"))
			char:SetAttribute("Combo", 1)
			ctx._comboController:init(3)

			return
		end

		ctx._comboController:init(3)

		local combo = char:GetAttribute("Combo")
		if combo >= max_combo then
			char:SetAttribute("Combo", 1)
		else
			char:SetAttribute("Combo", combo + 1)
		end
	end,
	createHitboxes = create_m1_hitboxes({
		Time = 2,
		Size = Vector3.new(5, 5, 5),
		CFrame = Vector3.new(0, 0, 3),
		Shape = "Box",
		HitMode = "Strong",
		strikes_hit = true,
	}),
	endFx = end_m1_fx,
}

local Fist = {
	skills = {},
	attacks = {
		[Enum.UserInputType.MouseButton1.Name] = m1,
	},
	walk_speed_normal = 14,
	walk_speed_blocking = 6,
	walk_speed_counter = 3,
	required_damage = 120,
	getLeftGrip = function(model)
		return model:FindFirstChild("Left Arm")
	end,
	getRightGrip = function(model)
		return model:FindFirstChild("Right Arm")
	end,
	getHead = function(model)
		return model:FindFirstChild("Head")
	end,
	-- run_speed = 18,
}

info["Fist"] = Fist

-- Gun
do
	local ak_47 = table.clone(Fist)

	local ak_stats = {
		_ammo = 10,
		_reloading = false,

		aimAssistCenteringStrength = 0,
		aimAssistFov = 20,
		aimAssistFrictionStrength = 0.5,
		aimAssistRange = 100,
		aimAssistTrackingStrength = 0.5,

		damage = 35,
		fireMode = "Semi",
		magazineSize = 10,
		bulletVelocity = 1000,

		range = 400,
		rateOfFire = 600,
		rayRadius = 0.4,
		raysPerShot = 1,
		maxDistance = 400,

		recoilMax = Vector2.new(5, 20),
		recoilMin = Vector2.new(0, 15),

		reloadTime = 1,
		spread = 2,
		unanchoredImpulseForce = 5,

		viewModel = "Blaster",
	}

	local shot_m1 = table.clone(m1)
	shot_m1.config = {
		life_time = 1.4,
		keyCode = Enum.UserInputType.MouseButton1,
		animNames = { "Swing1", "Swing2", "Swing3", "Swing4" },
		type = "Range",
		attackType = "ST",
		cooldown = 0.4, -- A basic gun can shot
		weapon_stats = table.clone(ak_stats),
	}
	ak_47.weapon_stats = table.clone(ak_stats)
	ak_47.weapon_name = "gun"
	ak_47.attacks = {
		[Enum.UserInputType.MouseButton1.Name] = shot_m1,
	}
	ak_47.skills = {
		["SDash"] = Slide,
		["WDash"] = WDash,
	}
	-- todo finnish this fist with an m1

	info["gun"] = ak_47
end

do
	local ak_47 = table.clone(info["gun"])
	ak_47.weapon_stats = {
		_ammo = 30,
		_reloading = false,

		aimAssistCenteringStrength = 0,
		aimAssistFov = 20,
		aimAssistFrictionStrength = 0.5,
		aimAssistRange = 100,
		aimAssistTrackingStrength = 0.5,

		damage = 10,
		fireMode = "Auto",
		magazineSize = 30,
		range = 1000,
		rateOfFire = 600,
		maxDistance = 600,

		rayRadius = 0.4,
		raysPerShot = 1,

		recoilMax = Vector2.new(2, 7),
		recoilMin = Vector2.new(-2, 5),

		reloadTime = 1.5,
		spread = 2,
		unanchoredImpulseForce = 2,
		viewModel = "Auto Blaster",
	}

	local shot_m1 = table.clone(m1)
	shot_m1.config = {
		life_time = 1.4,
		keyCode = Enum.UserInputType.MouseButton1,
		animNames = { "Swing1", "Swing2", "Swing3", "Swing4" },
		type = "Range",
		attackType = "ST",
		cooldown = 0.1, -- A basic gun can shot
		weapon_stats = table.clone(ak_47.weapon_stats),
	}
	-- Remove all shits about animation for the moment
	shot_m1.endFx = nil
	shot_m1.preAnimFx = nil

	ak_47.attacks = {
		[Enum.UserInputType.MouseButton1.Name] = shot_m1,
	}
	info["ak-47"] = ak_47
end

module.info = Table.errorOnNilIndex(info)

function module:getweapon(WeaponName: string)
	return info[WeaponName]
end

return module
