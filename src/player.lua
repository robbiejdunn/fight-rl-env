local class = require "src/class"
local anim8 = require "anim8"

local Player = class:derive("Player")

function Player:new(
    direction,
    starting_x,
    starting_y
)
    self.direction = direction
    self.x = starting_x
    self.y = starting_y
    self.animations = {}
    self.states = {}
    self.state = nil
    self.animation = nil
    self:initAnimations()
end

function Player:addAnimation(
    state,               -- the name of the state you're to bind this animation to
    g,                   -- grid to extract quads from
    frame_duration,      -- how long each frame lasts
    on_loop,             -- function called every time an animation completes
    can_act,
    dx_per_frame,
    sound,
    ...                  -- the arguments to give anim8 grid()
)
    self.animations[state] = {}
    self.animations[state].anim_right = anim8.newAnimation(g(...), frame_duration, on_loop)
    self.animations[state].anim_left = self.animations[state].anim_right:clone():flipH()
    self.states[state] = {}
    self.states[state].can_act = can_act
    self.states[state].dx_per_frame = dx_per_frame
    self.states[state].sound = sound
end

function Player:animationLoopHandler()
    self.state = "idle"
    self:updateAnimation()
end

function Player:initAnimations()
    local character = require("src/characters/fire-knight")
    self.spriteSheet = character.spriteSheet
    self.animations = {}
    local g = anim8.newGrid(character.ssWidth, character.ssHeight, character.spriteSheet:getDimensions())
    local baseAnimations = {
        "idle",
        "run",
        "defend",
        "1atk",
        "spatk"
    }
    for _, anim in ipairs(baseAnimations) do
        local animCfg = character.animations[anim]
        local eol = animCfg.endOfLoop
        if animCfg.blockingAction then eol = self.animationLoopHandler end
        self:addAnimation(
            anim,
            g,
            animCfg.duration,
            eol,
            animCfg.canInterrupt,
            animCfg.dx,
            animCfg.sound,
            unpack(animCfg.gridArgs)
        )
    end
    self.state = "idle"
    self.animation = self.animations["idle"].anim_right
end

function Player:move(dx, dy)
    self.x = self.x + (dx * 1.8)
    self.y = self.y + dy
end

function Player:updateAnimation()
    if not self.animations[self.state] then return end
    self.last_state = self.current_state
    self.current_state = self.state
    self.last_direction = self.current_direction
    self.current_direction = self.direction

    if self.states[self.state].dx_per_frame then
        self:move(self.states[self.state].dx_per_frame, 0)
    end

    if self.last_state == self.current_state and self.last_direction == self.current_direction then return end

    if self.direction > 0 then
        self.animation = self.animations[self.state].anim_right
    elseif self.direction < 0 then
        self.animation = self.animations[self.state].anim_left
    end
end

return Player
