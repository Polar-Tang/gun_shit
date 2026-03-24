local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- COMPONENTS
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))

local App = Roact.Component:extend("App")
function App:init()
	self:setState({
		running = true,
	})
end

-- local Context = script.Parent.Context
-- local useContext = require(Context.Utils.useContext)

function App:render()
	return Roact.createFragment({})
end

function App:didMount()
	self.running = true
end

return App
