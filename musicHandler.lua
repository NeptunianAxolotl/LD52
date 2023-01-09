

local SoundHandler = require("soundHandler")
local soundFiles = util.LoadDefDirectory("resources/soundDefs")

local self = {}
local api = {}
local cosmos

local font = love.graphics.newFont(70)

-- First eligible tracks are used as start music
local trackList = {
	'bgm_dead',
	'bgm_stone',
	'bgm_bronze',
	'bgm_iron',
	'bgm_classical',
	'bgm_reneissance',
	'bgm_modern',
	'bgm_space',
}

local currentTrack = {}
local trackRunning = false
local initialDelay = true
local currentTrackRemaining = 1
local trackParity = 1
local playingSounds = {}

function api.StopCurrentTrack(delay)
	currentTrackRemaining = delay or 0
end

function api.SetCurrentTrackFadeTime(fadeTime)
	if trackRunning then
		for i = 1, #currentTrack do
			SoundHandler.SetSoundFade(currentTrack[i].sound, false, 1/fadeTime)
		end
	end
end

function api.Update(dt)
	if self.needDtReset then
		Global.ResetMissingDt()
		self.needDtReset = false
	end
	if initialDelay then
		initialDelay = initialDelay - dt
		if initialDelay < 0 then
			initialDelay = false
			self.needDtReset = true
		else
			return
		end
	end
	local maxTech = GameHandler and GameHandler.GetMaxTech()
	currentTrackRemaining = (currentTrackRemaining or 0) - dt
	if currentTrackRemaining < 0 then
		if cosmos.MusicEnabled() then
			if trackRunning then
				for i = 1, #trackList do
					SoundHandler.StopSound(currentTrack[i])
				end
			end
			trackRunning = true
			currentTrackRemaining = soundFiles[trackList[4]].duration
			for i = 1, #trackList do
				playingSounds[i] = SoundHandler.PlaySound(trackList[i], false, 1, 1, false, false, (i == maxTech and 1) or 0, true)
			end
		elseif trackRunning then
			for i = 1, #trackList do
				SoundHandler.StopSound(trackList[i])
			end
			trackRunning = false
		end
	elseif trackRunning then
		for i = 1, #trackList do
			playingSounds[i].want = ((i == maxTech and 1) or 0)
		end
	end
end

function api.Initialize(newCosmos)
	self = {}
	cosmos = newCosmos
	initialDelay = 0
	for i = 1, #trackList do
		SoundHandler.LoadSound(trackList[i])
	end
end

return api
