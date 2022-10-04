local anim8 = require "anim8"
local tick = require "src/tick"
local waterfall_stage = require "src/stages/waterfall"
local Player = require "src/player"

local image, animation
local inputBuffer = {}
local player = Player(1, love.graphics:getWidth() / 2 - 900, 430)
local roundTimer = 60
local hud
local currentMoveTimer = 0
local currentMoveSounds
local playerTwo = {
    direction = 0,
    x = 500,
    y = 500
}

local FightScene = require "src/scene/fight"
local fs = FightScene(waterfall_stage)

local current_scene = fs

function love.load()
    tick.framerate = 60
    tick.rate = 1 / 60

    -- load font
    font = love.graphics.setNewFont("assets/FutilePro.ttf", 70)

    image = love.graphics.newImage("assets/spritesheet.png")
    playerTwo:initAnimations()
    local hudClass = require("src/hud")
    hud = hudClass:new()
    fs:enter()
end

function animationLoopHandler()
    -- player.state = "idle"
    -- player:updateAnimation()
end

function playerTwo:addAnimation(
    state,               -- the name of the state you're to bind this animation to
    g,                   -- grid to extract quads from
    frame_duration,      -- how long each frame lasts
    on_loop,             -- function called every time an animation completes
    can_act,
    dx_per_frame,
    sound,
    ...                  -- the arguments to give anim8 grid()
)
    if not self.animations then self.animations = {} end
    self.animations[state] = {}
    self.animations[state].anim_right = anim8.newAnimation(g(...), frame_duration, on_loop)
    self.animations[state].anim_left = self.animations[state].anim_right:clone():flipH()
    if not self.states then self.states = {} end
    self.states[state] = {}
    self.states[state].can_act = can_act
    self.states[state].dx_per_frame = dx_per_frame
    self.states[state].sound = sound
end

function playerTwo:initAnimations()
    self.animations = {}
    local g = anim8.newGrid(image:getWidth() / 9, image:getHeight() / 15, image:getDimensions())
    self:addAnimation("idle", g, 0.1, nil, true, nil, nil, "1-8", 10)
    self.state = "idle"
    self.animation = self.animations["idle"].anim_left
end

function love.update(dt)
    current_scene:update(1)
    -- update timers
    currentMoveTimer = currentMoveTimer + dt
    roundTimer = roundTimer - dt

    hud:update(roundTimer)

    -- player one updates
    player:getInput()
    player:updateAnimation()
    player.animation:update(1)

    -- player two updates
    playerTwo.animation:update(dt)
end

function move(dx, dy)
    player.x = player.x + (dx * 1.8)
    player.y = player.y + dy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function love.keypressed(key, scancode, isrepeat)
    if player.states[player.state].can_act then
        if scancode == "h" then
            player.state = "1atk"
        elseif scancode == "j" then
            player.state = "spatk"
            currentMoveTimer = 0
            currentMoveSounds = deepcopy(player.states[player.state].sound)
        end
    end
end

function love.draw()
    current_scene:draw()

    hud:draw()
    
    -- love.graphics.setBackgroundColor(1, 0, 0, 0.7)
    player.animation:draw(player.spriteSheet, player.x, player.y, 0, 4, 4)
    -- love.graphics.setColor(1, 0, 0, 0.7)
    playerTwo.animation:draw(image, playerTwo.x, playerTwo.y, 0, 4, 4)
    -- love.graphics.setColor(1, 1, 1)
end
