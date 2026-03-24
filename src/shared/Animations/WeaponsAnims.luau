local Attkcs = {}

local anim_names = {
	
	["FrontDash"] = "rbxassetid://132739372863099",
	["Kafka -BackDash"] = "rbxassetid://85575014339192",
	["DashLeft"] = "rbxassetid://79328523085486",
	["DashRight"] = "rbxassetid://92616275644680",
	
}

export type AttackGroup = {
	[string]: string, -- any key inside groups maps to an animationId string
}

export type Weapon = {
	Attacking: AttackGroup,
	Hit: AttackGroup,
	Sprint: string,
	Equip: string,
	Idle: string,
	UnEquip: string,
}

export type Attkcs = {
	[string]: Weapon,
}
Attkcs["fist"] = {
	["Heavy"] = "rbxassetid://70389048224933",
	["Swing1"] = "rbxassetid://130203779806436",
	["Swing2"] = "rbxassetid://100499038415190",
	["Swing3"] = "rbxassetid://126563645344009",
	["Swing4"] = "rbxassetid://112821950233659",
	["Swing5"] = "rbxassetid://80100527539838",

	["Sprint"] = "rbxassetid://130609866336149",
	["Equip"] = "rbxassetid://91567634616046",
	["Idle"] = "rbxassetid://91567634616046",
	["UnEquip"] = "rbxassetid://76401194937920",
	["Blocking"] = "rbxassetid://109266615151969",
	["GuardBreak"] = "rbxassetid://70952470480164",
}

Attkcs["gun"] = {
	["Heavy"] = "rbxassetid://84447851639470",
	["Swing1"] = "rbxassetid://129734816479678",
	["Swing2"] = "rbxassetid://129734816479678",
	["Swing3"] = "rbxassetid://129734816479678",
	["Swing4"] = "rbxassetid://129734816479678",
	["Swing5"] = "rbxassetid://129734816479678",
	["HeavyHit"] = "rbxassetid://129734816479678",

	["Sprint"] = "rbxassetid://108548036345475",
	["Equip"] = "rbxassetid://74183832229187",
	["Idle"] = "rbxassetid://74183832229187",
	--["UnEquip"] = "rbxassetid://15451005805",
	["Blocking"] = "rbxassetid://119463100691422",
	["GuardBreak"] = "rbxassetid://70952470480164",

	["ADash"] = anim_names["DashLeft"],
	["DDash"] = anim_names["DashRight"],
	["SDash"] = anim_names["Kafka -BackDash"],
	["WDash"] = anim_names["FrontDash"],

}

return Attkcs :: Attkcs
