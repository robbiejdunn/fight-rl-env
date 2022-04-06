local M = { }

fkBaseAnimations = {
    idle = {
        duration = 0.1,
        endOfLoop = nil,
        canInterrupt = true,
        dx = nil,
        dy = nil,
        gridArgs = {
            "1-8", 10
        }
    }
}

M.fkBaseAnimations = fkBaseAnimations

return M
