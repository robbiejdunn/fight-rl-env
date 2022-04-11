local SceneBase = require "src/scene/scene_base"

local FightScene = SceneBase:derive("FightScene")

function FightScene:new(stage)
    self.stage = stage
    FightScene.super.new(self)
end

function FightScene:enter()
    self.stage:enter()
end

function FightScene:update(dt)
    self.stage:update(dt)
end

function FightScene:draw()
    self.stage:draw()
    FightScene.super.draw(self)
end

return FightScene
