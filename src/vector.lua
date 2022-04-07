local class = require("class")
local Vector = class:derive("Vector")

function Vector:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

return Vector