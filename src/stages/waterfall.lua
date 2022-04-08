local StageBase = require("src/stages/stage_base")

local waterfall_stage = StageBase(
    "assets/stages/waterfall.png",
    2,
    4,
    "assets/sounds/chee-zee-jungle-by-kevin-macleod-from-filmmusic-io.mp3",
    "assets/sounds/vlc-record-2022-04-06-15h38m19s-zapsplat_nature_forest_ambience_waterfall_close_by_birds.mp3-.mp3"
)

waterfall_stage:newAnimation("loop", 8, "1-2", "1-4")

waterfall_stage.current_anim = "loop"

return waterfall_stage
