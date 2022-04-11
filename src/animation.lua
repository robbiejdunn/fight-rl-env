local class = require("class")
local Vector = require("vector")
local Animation = class:derive("Animation")

function Animation:new(grid, duration, ...)
    self.anim = anim8.newAnimation(g(...), duration)
    self.timer = 1 / self.fps
    self.frame = 1
    self.num_frames = num_frames
    self.size = Vector(width, height)
end

function Animation:update(dt)
    self.anim:update(dt)
end

return Animation
