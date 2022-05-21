local snd = playdate.sound

SoundManager = {}

SoundManager.kPinUnlock = 'pinunlock'
SoundManager.kReset = 'reset'
SoundManager.kUnlocked = 'unlocked'
SoundManager.kRotate = 'rotate'

local sounds = {}

for _, v in pairs(SoundManager) do
    sounds[v] = snd.sampleplayer.new('sounds/' .. v)
end

SoundManager.sounds = sounds

function SoundManager:playSound(name)
    self.sounds[name]:play(1)
end

function SoundManager:stopSound(name)
    self.sounds[name]:stop()
end

function SoundManager:updateRotate(isRotating)
    if isRotating and not self.sounds[SoundManager.kRotate]:isPlaying() then
        self.sounds[SoundManager.kRotate]:play()
    elseif isRotating then
        self.sounds[SoundManager.kRotate]:setVolume(1)
    else
        self.sounds[SoundManager.kRotate]:setVolume(0)
    end
end
