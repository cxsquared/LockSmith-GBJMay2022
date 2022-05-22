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
            math.random(10, 30),
            math.random(70, 99),
            math.random(0, 20),
            math.random(60, 80),
            math.random(5, 15),
            math.random(50, 99),
        },
        currentPin = 1,
        pinMargin = 3,
        fails = 0,
        unlocked = false,
        totalNumberOfPins = 0
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

local dialogue = {
    dialogue = {
        font = gfx.font.new("images/font-full-circle"),
        text = "This is a test",
    },
    transform = {
        x = 10,
        y = 10,
        visible = false
    }
}

local timTimer = nil

local world = World()

dialogueTimer = nil
function hideDialogue() 
    dialogue.transform.visible = false
end

function startDialogueTimer()
    if dialogueTimer ~= nil then
        dialogueTimer:remove()
    end
    dialogueTimer = playdate.timer.new(4000, hideDialogue)
end

-- Draw System

world:addEntity(lockBackground)
world:addEntity(lockFace)
world:addEntity(tim)
world:addEntity(dialogue)
world:addSystem(import "ecs/drawsystem")
world:addSystem(import "ecs/dialoguesystem")
printTable(world)

local panic = 0

local function updateDialogue(fail)
    if not fail then
        if lockFace.lock.totalNumberOfPins == 1 and lockFace.lock.fails == 0 then
            dialogue.dialogue.text = "Oh that tickles..."
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.totalNumberOfPins > 0 and lockFace.lock.currentPin == 3 and panic == 0 then
            panic += 1
            dialogue.dialogue.text = "Woah there!\nWhat do you\nthink you are doing"
            dialogue.transform.x = 10 
            dialogue.transform.y = 185 
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.currentPin == 4 and panic == 1 then
            panic += 1
            dialogue.dialogue.text = "No I don't think I will\nYou shouldn't see\nwhat's inside"
            dialogue.transform.x = 5 
            dialogue.transform.y = 5 
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.currentPin == 5 and panic == 2 then
            panic += 1
            dialogue.dialogue.text = "Last warning...\nYou aren't ready\nFor what's inside"
            dialogue.transform.x = 5 
            dialogue.transform.y = 5 
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.currentPin == 5 and panic >= 3 then
            panic += 2
            dialogue.dialogue.text = "This is the end"
            dialogue.transform.x = 10 
            dialogue.transform.y = 195 
            dialogue.transform.visible = true
            startDialogueTimer()
        end
    else
        if panic == 3 then
            panic += 1
            dialogue.dialogue.text = "I'm glad you thought better"
            dialogue.transform.x = 1 
            dialogue.transform.y = 1 
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.fails == 1 then
            dialogue.dialogue.text = "huuu, that was close"
            dialogue.transform.x = 235 
            dialogue.transform.y = 5 
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.fails == 3 then
            dialogue.dialogue.text = "Having some trouble?"
            dialogue.transform.x = 5 
            dialogue.transform.y = 210 
            dialogue.transform.visible = true
            startDialogueTimer()
        elseif lockFace.lock.fails == 5 then
            dialogue.dialogue.text = "Gonna be here all day..."
            dialogue.transform.x = 250 
            dialogue.transform.y = 210 
            dialogue.transform.visible = true
            startDialogueTimer()
        end
    end
end

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
                lockFace.lock.totalNumberOfPins += 1
                lockFace.lock.currentPin = currentPin + 1
                updateDialogue(false)
                SoundManager:playSound(SoundManager.kPinUnlock)
            end
        elseif currentPin == 2 then
            if change < 0 and pin >= combination[1] + pinMargin * 2 then
                SoundManager:playSound(SoundManager.kReset)
                lockFace.lock.currentPin = 1
                lockFace.lock.fails += 1
                updateDialogue(true)
            end
            if change > 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                lockFace.lock.totalNumberOfPins += 1
                lockFace.lock.currentPin = currentPin + 1
                updateDialogue(false)
                SoundManager:playSound(SoundManager.kPinUnlock)
                print("Pin 2")
            end
        elseif currentPin == 3 then
            if change > 0 and pin <= combination[2] - pinMargin * 2 then
                SoundManager:playSound(SoundManager.kReset)
                lockFace.lock.currentPin = 1
                lockFace.lock.fails += 1
                updateDialogue(true)
            end
            if change < 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                lockFace.lock.totalNumberOfPins += 1
                lockFace.lock.currentPin = currentPin + 1
                updateDialogue(false)
                SoundManager:playSound(SoundManager.kPinUnlock)
                print("Pin 3")
            end
        elseif currentPin == 4 then
            if change < 0 and pin >= combination[3] + pinMargin * 2 then
                SoundManager:playSound(SoundManager.kReset)
                lockFace.lock.currentPin = 1
                lockFace.lock.fails += 1
                updateDialogue(true)
            end
            if change > 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                lockFace.lock.totalNumberOfPins += 1
                lockFace.lock.currentPin = currentPin + 1
                updateDialogue(false)
                SoundManager:playSound(SoundManager.kPinUnlock)
                print("Pin 4")
            end
        elseif currentPin == 5 then
            if change > 0 and pin <= combination[4] - pinMargin * 2 then
                SoundManager:playSound(SoundManager.kReset)
                lockFace.lock.currentPin = 1
                lockFace.lock.fails += 1
                updateDialogue(true)
            end
            if change < 0 and pin >= combination[currentPin] - pinMargin and pin <= combination[currentPin] + pinMargin then
                lockFace.lock.totalNumberOfPins += 1
                lockFace.lock.unlocked = true
                SoundManager:playSound(SoundManager.kUnlocked)
                timTimer = playdate.timer.new(3000, 0, 1)
                timTimer.updateCallback = function(timer)
                    tim.transform.a = timer.value
                end
                tim.transform.visible = true
                lockFace.transform.visible = false
                lockBackground.transform.visible = false
                lockFace.lock.currentPin += 1 
                dialogue.transform.visible = false
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
