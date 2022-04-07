local class = require("src/class")
local anim8 = require("../anim8Custom") 

local Sprite = class:derive("Sprite")

function Sprite:new(ss_path, ss_cols, ss_rows)
    self.sprite_sheet = love.graphics.newImage(ss_path)
    self.grid = anim8.newGrid(
        self.sprite_sheet:getWidth() / ss_cols,
        self.sprite_sheet:getHeight() / ss_rows,
        self.sprite_sheet:getDimensions()
    )
    self.animations = {}
    self.current_anim = nil
end

function Sprite:newAnimation(name, duration, ...)
    self.animations[name] = anim8.newAnimation(self.grid(...), duration)
end

function Sprite:update(dt)
    self.animations[self.current_anim]:update(dt)
end

function Sprite:draw(x, y, r, sx, sy)
    self.animations[self.current_anim]:draw(self.sprite_sheet, x, y, r, sx, sy)
end

return Sprite