local OtherAnims = {}

export type Dash = {
	ADash: string,
	DDash: string,
	SDash: string,
	WDash: string,
}

export type OtherAnims = {
	Dash: Dash,
	Extra: string,
	-- default_r6: string,
	-- default :
}

local otherAnims: OtherAnims = {
	Dash = {
		["ADash"] = "rbxassetid://122305201667449",
		["DDash"] = "rbxassetid://115451998547335",
		["SDash"] = "rbxassetid://133339970955472",
		["WDash"] = "rbxassetid://126359086132557",
	},
	Extra = "some value",
	-- TODO: load this animations through :registryAnims, to the npc. Also fill it with the same animations filds as the Player.Character.Animate
	["default_r6"] = {
		walk = "rbxassetid://134585533297642",
	},
	-- TODO: fill it with Player.Character.Animate 
	["default"] = {
		walk = "",
	}
}

return otherAnims
