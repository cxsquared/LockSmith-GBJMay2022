-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "imports"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

local lockFace = {
    image = gfx.image.new("images/lock_face"),
    transform = {
        x = 0,
        y = 0,
        rotation = 0,
        visible = true,
        center = true
    },
    lock = {
        combination = {
            math.random(0, 99),
            math.random(0, 99),
            math.random(0, 99),
        },
        currentPin = 1,
        pinMargin = 3,
        unlocked = false
    }
}

local lockBackground = {
    image = gfx.image.new("images/lock_bg"),
    transform = {
        x = 0,
        y = 0,
        visible = true,
        center = true
    }
}

local tim = {
    image = gfx.image.new("images/winner"),
    transform = {
        x = 0,
        y = 0,
        a = 0,
        d = gfx.image.kDitherTypeFloydSteinberg,
        visible = false,
        center = true
    },
}

local timTimer = nil

local world = World()

-- Draw System

world:addEntity(lockBackground)
world:addEntity(lockFace)
world:addEntity(tim)
world:addSystem(import "ecs/drawsystem")

-- Input
local crankPos = nil
local myInputHandler = {
    cranked = function(change, acceleratedChange)
        if lockFace.lock.unlocked then
            SoundManager:updateRotate(false)
            return
        end

        crankPos = crankPos + change
        SoundManager:updateRotate(true)
        lockFace.transform.rotation = crankPos
        if crankPos < 0 then
            crankPos = crankPos + 360
        elseif crankPos > 360 then
            crankPos = crankPos - 360
        end

        local pin = mathutils.map(crankPos, 360, 0, 0, 99)
        local currentPin = lockFace.lock.currentPin
        local combination = lockFace.lock.combination
        local pinMargin = lockFace.lock.pinMargin

        if currentPin == 1 then
            if change < 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                print("Pin 1")
                SoundManager:playSound(SoundManager.kPinUnlock)
                lockFace.lock.currentPin = currentPin + 1
            end
        elseif currentPin == 2 then
            if change < 0 and pin >= combination[1] + pinMargin * 2 then
                SoundManager:playSound(SoundManager.kReset)
                lockFace.lock.currentPin = 1
            end
            if change > 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                SoundManager:playSound(SoundManager.kPinUnlock)
                print("Pin 2")
                lockFace.lock.currentPin = currentPin + 1
            end
        elseif currentPin == 3 then
            if change > 0 and pin <= combination[2] - pinMargin * 2 then
                SoundManager:playSound(SoundManager.kReset)
                lockFace.lock.currentPin = 1
            end
            if change < 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                lockFace.lock.unlocked = true
                SoundManager:playSound(SoundManager.kUnlocked)
                timTimer = playdate.timer.new(3000, 0, 1)
                timTimer.updateCallback = function(timer)
                    tim.transform.a = timer.value
                end
                tim.transform.visible = true
                lockFace.transform.visible = false
                lockBackground.transform.visible = false
                lockFace.lock.currentPin = 3
            end
        end
    end
}

playdate.inputHandlers.push(myInputHandler)

function myGameSetUp()
    -- We want an environment displayed behind our sprite.
    -- There are generally two ways to do this:
    -- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
    -- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
    --       and call :setZIndex() with some low number so the background stays behind
    --       your other sprites.

    --
    crankPos = playdate.getCrankPosition()
end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

local lastCrankPos = crankPos
local time = playdate.getCurrentTimeMilliseconds()

function playdate.update()
    gfx.clear(gfx.kColorBlack)
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if playdate.isCrankDocked() or lastCrankPos == playdate.getCrankPosition() then
        SoundManager:updateRotate(false)
    end

    lastCrankPos = playdate.getCrankPosition()

    world:update(playdate.getCurrentTimeMilliseconds() - time)
    time = playdate.getCurrentTimeMilliseconds()
end
