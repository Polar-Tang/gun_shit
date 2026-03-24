local RS = game:GetService("ReplicatedStorage")
local Roact = require(RS.Roact)

local src = script.Parent.src
local MainAppUI = require(src.MainApp)
-- local ctx = src.Context

local Players = game:GetService("Players")

local App = Roact.Component:extend("App")

function App:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
	}, {
		-- PromptProvider = Roact.createElement(PromptProvider, {}, {
		AppUI = Roact.createElement(MainAppUI),
		-- }),
	})
end

-- Ensure LocalPlayer and PlayerGui are available before mounting (LocalPlayer can be nil if this runs too early)
local player = Players.LocalPlayer
if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer

	local characterReplacedBool = player.Character:WaitForChild("CharacterReplaced")
	print(characterReplacedBool)
end
local PlayerGui = player:WaitForChild("PlayerGui")

Roact.mount(Roact.createElement(App), PlayerGui, "UI")

return App
