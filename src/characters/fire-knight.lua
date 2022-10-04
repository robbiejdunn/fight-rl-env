local spriteSheetFile = "assets/fire-knight/fire_full_SpriteSheet_288x128.png"
local spriteSheet = love.graphics.newImage(spriteSheetFile)

return {
    name = "Fire Knight",
    spriteSheet = spriteSheet,
    ssWidth = 288,
    ssHeight = 128,

    animations = {
        idle = {
            duration = 64,
            totalFrames = 8,
            blockingAction = false,
            endOfLoop = nil,
            canInterrupt = true,
            dx = nil,
            sound = nil,
            gridArgs = {
                "1-8", 1
            }
        },
        run = {
            duration = 8,
            totalFrames = 8,
            blockingAction = false,
            endOfLoop = nil,
            canInterrupt = true,
            dx = nil,
            sound = nil,
            gridArgs = {
                "1-8", 2
            }
        },
        defend = {
            duration = 0.1,
            totalFrames = 8,
            blockingAction = false,
            endOfLoop = "pauseAtEnd",
            canInterrupt = true,
            dx = nil,
            sound = nil,
            gridArgs = {
                "1-8", 11
            }
        },
        ["1atk"] = {
            duration = 11,
            totalFrames = 11,
            blockingAction = true,
            endOfLoop = nil,
            canInterrupt = false,
            dx = nil,
            sound = nil,
            gridArgs = {
                "1-11", 7
            }
        },
        spatk = {
            duration = 60,
            totalFrames = 18,
            blockingAction = true,
            endOfLoop = nil,
            canInterrupt = false,
            dx = nil,
            sound = {
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
            gridArgs = {
                "1-18", 10
            }
        }
    }
}
