local Sprite = require "src/sprite"

local StageBase = Sprite:derive("StageBase")

function StageBase:new(ss_path, ss_cols, ss_rows)
    StageBase.super.new(self, ss_path, ss_cols, ss_rows)
    self.stage_sx = (love.graphics.getWidth() + 10) / (self.sprite_sheet:getWidth() / ss_cols)
    self.stage_sy = (love.graphics.getHeight() + 10) / (self.sprite_sheet:getHeight() / ss_rows)
end

function StageBase:draw()
    StageBase.super.draw(self, -5, -5, 0, self.stage_sx, self.stage_sy)
end

return StageBase
