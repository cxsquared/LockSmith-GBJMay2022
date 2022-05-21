class('Unlocked').extends(playdate.graphics.sprite)

local font = playdate.graphics.font.new('images/Nontendo-Light-2x')

function Unlocked:init()

    Unlocked.super.init(self)

    self.font = playdate.graphics.font.new('images/Nontendo-Light-2x')
    self.score = 0

    self:setZIndex(900)
    self:setIgnoresDrawOffset(true)
    self:setCenter(0, 0)
    self:setSize(400, 240)
    self:moveTo(0, 0)
end

function Unlocked:draw()
    playdate.graphics.setFont(self.font)
    playdate.graphics.drawText("U N L O C K E D", 0, 0)
end
