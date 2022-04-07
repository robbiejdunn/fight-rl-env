local StageBase = require("src/stages/stage_base")

local waterfall_stage = StageBase("assets/stages/waterfall.png", 2, 4)

waterfall_stage:newAnimation("loop", 8, "1-2", "1-4")

waterfall_stage.current_anim = "loop"

return waterfall_stage
