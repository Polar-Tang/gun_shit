local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rx = require(ReplicatedStorage.Nevermore.Quenty.rx.Shared.Rx)
local ValueObject = require(ReplicatedStorage.Nevermore.Quenty.valueobject.Shared.ValueObject)

local Mousebutton1Handler = {}
Mousebutton1Handler.__index = Mousebutton1Handler
Mousebutton1Handler.M1PressedValueObject = ValueObject.new(false)    

function Mousebutton1Handler:InputBegan()
    -- Rx
    self.Value = true
end

function Mousebutton1Handler:InputEnded()
    self.Value = false
end

return Mousebutton1Handler