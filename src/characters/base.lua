CharacterMoveConfig = {}

function CharacterMoveConfig:new(
    o,
    duration,
    endOfLoop,
    canInterrupt,
    dx,
    sound,
    gridArgs
)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.duration = duration
    o.endOfLoop = endOfLoop
    o.canInterrupt = canInterrupt
    o.dx = dx
    o.sound = sound
    o.gridArgs = gridArgs
    return o
end

Character = {

}

function Character:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Character:idle()
    error("Not implemented")
end

FK = Character:new()
-- FK:idle()

cfg = CharacterMoveConfig:new({}, 1, 1, 1, 1, 1, 1)
print(cfg.duration)
cfg2 = CharacterMoveConfig:new({}, 2, 1, 1, 1, 1, 1)
print(cfg.duration)