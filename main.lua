local anim8 = require "anim8"

local image, animation
local stage, stageAnim
local inputBuffer = {}
local player = {
    direction = 1,
    x = love.graphics:getWidth() / 2,
    y = 500
}
local roundTimer = 60
local currentMoveTimer = 0
local currentMoveSounds
local playerTwo = {
    direction = 0,
    x = 500,
    y = 500
}
local soundIndex

local fireKnight = require("src/characters/fire-knight")

function love.resize (w, h)
	resize (w, h) -- update new translation and scale
end

function resize (w, h) -- update new translation and scale:
	local w1, h1 = window.width, window.height -- target rendering resolution
	local scale = math.min (w/w1, h/h1)
	window.translateX, window.translateY, window.scale = (w-w1*scale)/2, (h-h1*scale)/2, scale
end

function love.load()
	-- resize (width, height) -- update new translation and scale
    -- load font
    font = love.graphics.setNewFont("assets/FutilePro.ttf", 70)
    loadBGM()
    loadStageSounds()
    loadStage()
    image = love.graphics.newImage("assets/spritesheet.png")
    player.direction = 1
    player:initAnimations()
    playerTwo:initAnimations()
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

function loadStage()
    stage = love.graphics.newImage("assets/stages/waterfall.png")
    local g = anim8.newGrid(stage:getWidth() / 2, stage:getHeight() / 4, stage:getDimensions())
    stageAnim = anim8.newAnimation(g("1-2", "1-4"), 0.1)
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
    self.animations = {}
    local g = anim8.newGrid(image:getWidth() / 9, image:getHeight() / 15, image:getDimensions())

    self:addAnimation("1atk", g, 0.075, animationLoopHandler, false, nil, nil, "1-9", 1, "1-2", 2)
    self:addAnimation("2atk", g, 0.075, animationLoopHandler, false, nil, nil, "1-9", 3, "1-3", 4)
    self:addAnimation("idle", g, 0.1, nil, true, nil, nil, "1-8", 10)
    self:addAnimation("run", g, 0.1, nil, true, nil, nil, "5-9", 12, "1-3", 13)
    self:addAnimation("backdash", g, 0.07, animationLoopHandler, false, -0.7, nil, "5-9", 12, "1-3", 13)
    self:addAnimation("defend", g, 0.1, "pauseAtEnd", true, nil, nil, 9, 8, "1-7", 9)
    
    self:addAnimation(
        "spatk",
        g,
        {["1-12"] = 1 / 12, ["13-15"] = 0.4 / 3, ["16-18"] = 0.5 / 3},
        animationLoopHandler,
        false,
        nil,
        {
            {
                ["time"] = 1,
                ["audio"] = love.audio.newSource("assets/sounds/zapsplat_sound_design_whoosh_flames_fire_cinematic_002_62041.mp3", "static")
            },
            {
                ["time"] = 0.7,
                ["audio"] = love.audio.newSource("assets/sounds/soundbits_JustWhoosh3_Swoosh_Rod_Pole_015.mp3", "static")
            },
            {
                ["time"] = 0.7,
                ["audio"] = love.audio.newSource("assets/sounds/zapsplat_human_male_fight_vocalisation_grunt_019_50229.mp3", "static")
            },
            {            
                ["time"] = 0.2,
                ["audio"] = love.audio.newSource("assets/sounds/vlc-record-2022-04-06-22h34m07s-FIRE, BURNING; DIGIFFECTS; Fire Scenes, Fires & Flames-.mp3", "static")
            }
        },
        "4-9", 13, "1-9", 14, "1-3", 15
    )

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
    -- update timers
    currentMoveTimer = currentMoveTimer + dt
    roundTimer = roundTimer - dt

    -- stage updates
    stageAnim:update(dt)

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
        if scancode == "x" then
            player.state = "1atk"
        elseif scancode == "c" then
            player.state = "2atk"
        elseif scancode == "b" then
            player.state = "backdash"
        elseif scancode == "v" then
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
        if love.keyboard.isDown("d") then
            dx = 1
            player.state = "run"
        elseif love.keyboard.isDown("a") then
            player.state = "defend"
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
            -- love.audio.play(currentMoveSounds[#currentMoveSounds]["audio"])
            table.remove(currentMoveSounds)
        end
    end

    -- if self.states[self.state].sound and #self.states[self.state].sound > 0 then
    --     if not soundIndex then soundIndex = 1 end
    --     print(soundIndex)
    --     if soundIndex <= #self.states[self.state].sound and (currentMoveTimer >= self.states[self.state].sound[soundIndex]["time"]) then
    --         love.audio.play(self.states[self.state].sound[soundIndex]["audio"])
    --         soundIndex = soundIndex + 1
    --         -- currentMoveTimer = -100
    --     end
    -- end

    if self.last_state == self.current_state and self.last_direction == self.current_direction then return end

    if self.direction > 0 then
        self.animation = self.animations[self.state].anim_right
    elseif self.direction < 0 then
        self.animation = self.animations[self.state].anim_left
    end
end

function drawCenteredText(rectWidth, rectHeight, text)
	local font = love.graphics.getFont()
	local textWidth = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print({{255, 255, 0}, text}, rectWidth/2, rectHeight/10, 0, 1, 1, textWidth/2, textHeight/2)
end

function drawHUD()
    local healthWidth = love.graphics.getWidth() / 3
    local healthHeight = love.graphics.getHeight() / 20
    local healthY = love.graphics.getHeight() / 10 - healthHeight / 2
    love.graphics.setColor(0, 255, 0)
    local rect = love.graphics.rectangle("fill", love.graphics.getWidth() / 10, healthY, healthWidth, healthHeight)
    love.graphics.setColor(255, 255, 255)
    -- rect.setColor(0, 255, 0)
    -- love.graphics.clear( )
    drawCenteredText(love.graphics.getWidth(), love.graphics.getHeight(), math.floor(roundTimer))
end

function love.draw()
    -- stretch to screen
    local sx = (love.graphics.getWidth() + 10) / (stage:getWidth() / 2)
    local sy = (love.graphics.getHeight() + 10) / (stage:getHeight() / 4)
    -- print(love.graphics.getPixelWidth(), stage:getWidth() / 2)
    stageAnim:draw(stage, -5, -5, 0, sx, sy)

    drawHUD()
    
    -- love.graphics.print({{255, 255, 0}, math.floor(roundTimer)}, 300, 300)
    -- love.graphics.print(math.floor(roundTimer), 300, 300)

    -- writeString("HELLOMOTO", 50, 50)
    -- love.graphics.draw(fontImg, font["A"], 50, 50)
    love.graphics.setBackgroundColor(1, 0, 0, 0.7)
    player.animation:draw(image, player.x, player.y, 0, 4, 4)
    love.graphics.setColor(1, 0, 0, 0.7)
    playerTwo.animation:draw(image, playerTwo.x, playerTwo.y, 0, 4, 4)
    love.graphics.setColor(1, 1, 1)
end