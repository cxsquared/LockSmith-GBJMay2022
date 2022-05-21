import "ecs/world"

local drawSystem = World.processingSystem()

drawSystem.filter = function(system, entity)
    return entity.image and entity.transform
end

function drawSystem:process(e, dt)
    if not e.transform.visible then
        return
    end

    if e.transform.center then
        local width, height = e.image:getSize()
        e.transform.x = 400 / 2 - width / 2
        e.transform.y = 240 / 2 - height / 2
    end

    if e.transform.rotation then
        e.image:drawRotated(199, 123, e.transform.rotation)
    elseif e.transform.a and e.transform.d then
        e.image:drawFaded(e.transform.x, e.transform.y, e.transform.a, e.transform.d)
    else
        e.image:draw(e.transform.x, e.transform.y)
    end
end

return drawSystem
