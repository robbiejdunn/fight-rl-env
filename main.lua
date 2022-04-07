local anim8 = require "anim8"
local tick = require "src/tick"
local waterfall_stage = require "src/stages/waterfall"

local image, animation
local inputBuffer = {}
local player = {
    direction = 1,
    x = love.graphics:getWidth() / 2 - 900,
    y = 430
}
local roundTimer = 60
local hud
local currentMoveTimer = 0
local currentMoveSounds
local playerTwo = {
    direction = 0,
    x = 500,
    y = 500
}

function love.load()
    tick.framerate = 60
    tick.rate = 1 / 60

    -- load font
    font = love.graphics.setNewFont("assets/FutilePro.ttf", 70)
    loadBGM()
    loadStageSounds()
    image = love.graphics.newImage("assets/spritesheet.png")
    player.direction = 1
    -- player:initAnimations()
    player:initAnimations()
    playerTwo:initAnimations()
    local hudClass = require("src/hud")
    hud = hudClass:new()
end

function loadBGM()
    bgm = love.audio.newSource("assets/sounds/chee-zee-jungle-by-kevin-macleod-from-filmmusic-io.mp3", "stream")
    bgm:setLooping(true)
    bgm:play()
end

function loadStageSounds()
    waterfall = love.audio.newSource("assets/sounds/vlc-record-2022-04-06-15h38m19s-zapsplat_nature_forest_ambience_waterfall_close_by_birds.mp3-.mp3", "stream")
    waterfall:setLooping(true)
    waterfall:setVolume(0.2)
    waterfall:play()
end

function player:addAnimation(
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

function animationLoopHandler()
    player.state = "idle"
    player:updateAnimation()
end

function player:initAnimations()
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
        if animCfg.blockingAction then eol = animationLoopHandler end
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
    waterfall_stage:update(dt)
    -- update timers
    currentMoveTimer = currentMoveTimer + dt
    roundTimer = roundTimer - dt

    hud:update(roundTimer)

    -- player one updates
    player:getInput()
    player:updateAnimation()
    player.animation:update(dt)

    -- player two updates
    playerTwo.animation:update(dt)
end

function move(dx, dy)
    player.x = player.x + (dx * 1.8)
    player.y = player.y + dy
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
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

function player:getInput()
    if self.states[self.state].can_act then
        local dx = 0
        local dy = 0
        if love.keyboard.isDown("v") then
            player.state = "defend"
        elseif love.keyboard.isDown("d") then
            dx = 1
            player.state = "run"
        elseif love.keyboard.isDown("a") then
            dx = -0.5
            player.state = "run"
        else
            player.state = "idle"
        end
        move(dx, dy)
    end
end

function player:updateAnimation()
    if not self.animations[self.state] then return end
    self.last_state = self.current_state
    self.current_state = self.state
    self.last_direction = self.current_direction
    self.current_direction = self.direction

    if self.states[self.state].dx_per_frame then
        move(self.states[self.state].dx_per_frame, 0)
    end

    if currentMoveSounds and #currentMoveSounds > 0 then
        if currentMoveTimer >= currentMoveSounds[#currentMoveSounds]["time"] then
            if currentMoveSounds[#currentMoveSounds]["audio"]:isPlaying() then
                currentMoveSounds[#currentMoveSounds]["audio"]:stop()
            end
            
            currentMoveSounds[#currentMoveSounds]["audio"]:play()
            table.remove(currentMoveSounds)
        end
    end

    if self.last_state == self.current_state and self.last_direction == self.current_direction then return end

    if self.direction > 0 then
        self.animation = self.animations[self.state].anim_right
    elseif self.direction < 0 then
        self.animation = self.animations[self.state].anim_left
    end
end

function love.draw()
    waterfall_stage:draw()

    -- drawHUD()
    hud:draw()
    
    love.graphics.setBackgroundColor(1, 0, 0, 0.7)
    player.animation:draw(player.spriteSheet, player.x, player.y, 0, 4, 4)
    love.graphics.setColor(1, 0, 0, 0.7)
    playerTwo.animation:draw(image, playerTwo.x, playerTwo.y, 0, 4, 4)
    love.graphics.setColor(1, 1, 1)
end
