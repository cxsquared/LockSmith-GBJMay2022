import "ecs/world"

local dialoguesystem = World.processingSystem()

dialoguesystem.filter = function(system, entity)
    return entity.dialogue and entity.transform
end

function dialoguesystem:process(e, dt)
    if not e.transform.visible then
        return
    end

    playdate.graphics.setFont(e.dialogue.font)
    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
    playdate.graphics.drawText(e.dialogue.text, e.transform.x, e.transform.y)
end

return dialoguesystem
