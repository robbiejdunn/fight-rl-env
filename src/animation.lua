local class = require("class")
local Vector = require("vector")
local Animation = class:derive("Animation")

function Animation:new(offset_x, offset_y, width, height, num_frames, fps)
    self.fps = fps
    self.timer = 1 / self.fps
    self.frame = 1
    self.num_frames = num_frames
    self.start_offset = Vector(offset_x, offset_y)
    self.size = Vector(width, height)
end

function Animation:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.timer = 1 / self.fps
        self.frame = self.frame + 1
        if self.frame > self.num_frames then
            self.frame = 1
        end
        self.offset.x = self.size.x * self.frame
    end
end

return Animation
