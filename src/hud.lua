local hud = {}

function drawCenteredText(rectWidth, rectHeight, text)
	local font = love.graphics.getFont()
	local textWidth = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print({{255, 255, 0}, text}, rectWidth/2, rectHeight/10, 0, 1, 1, textWidth/2, textHeight/2)
end

function hud:new()
    self.healthWidth = love.graphics.getWidth() / 3
    self.healthHeight = love.graphics.getHeight() / 20
    self.healthY = love.graphics.getHeight() / 10 - self.healthHeight / 2
    self.round_timer = 60
    return self
end

function hud:update(round_timer)
    self.round_timer = round_timer
end

function hud:draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 10, self.healthY, self.healthWidth, self.healthHeight)
    love.graphics.setColor(1, 1, 1)
    drawCenteredText(love.graphics.getWidth(), love.graphics.getHeight(), math.floor(self.round_timer))
end

return hud
