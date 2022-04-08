local Sprite = require "src/sprite"

local StageBase = Sprite:derive("StageBase")

function StageBase:new(
    ss_path,
    ss_cols,
    ss_rows,
    bgm_source,
    stage_sound_source
)
    StageBase.super.new(self, ss_path, ss_cols, ss_rows)
    self.stage_sx = (love.graphics.getWidth() + 10) / (self.sprite_sheet:getWidth() / ss_cols)
    self.stage_sy = (love.graphics.getHeight() + 10) / (self.sprite_sheet:getHeight() / ss_rows)
    self.bgm = love.audio.newSource(bgm_source, "stream")
    self.bgm:setLooping(true)
    self.stage_sound = love.audio.newSource(stage_sound_source, "stream")
    self.stage_sound:setLooping(true)
    self.stage_sound:setVolume(0.2)
end

function StageBase:draw()
    StageBase.super.draw(self, -5, -5, 0, self.stage_sx, self.stage_sy)
end

function StageBase:enter()
    self:playBGM()
    self:playStageSounds()
end

function StageBase:playBGM()
    self.bgm:play()
end

function StageBase:playStageSounds()
    self.stage_sound:play()
end

return StageBase
