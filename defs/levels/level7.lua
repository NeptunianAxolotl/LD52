
local SPAWN_TIME_MULT = 0.85

local def = {
	humanName = "Widdershins",
	description = [[
Someone tipped off the space police. Don't worry, their missiles only stun.

Fortunately, they blow up when shot, like most things.

To make matters worse, the planet's going backwards. We blame the space police.
]],
	prevLevel = "level6",
	nextLevel = "level8",
	gravity = 22,
	starCount = 900,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 5,
			speedMax = 20,
			orbitMult = 0.6,
			orbitMultRand = 0.4,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.5,
			avoidOrbitOverWrap = true,
			spawnRange = 0.4,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 20) / (count + 7) * (1 - (count + 3) / (count + 50))
			end,
		},
	},
	shipSpawn = {
		{
			timeMin = 20,
			timeRand = 5,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitOtherDirChance = 0.2,
			topBotChance = 0,
			avoidOrbitOverWrap = false,
			spawnRange = 0.7,
			spawnOffset = 0,
			typeName = {"police_slow"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("police")
				local pastCount = GameHandler.CountObject("police_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 5
				end
				return 1 - 0.5 * (count / (count + 2))
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-1100, 0}, 4.5),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = -1,
			age = "stone",
			maxAge = "modern",
			shootRateMult = 1,
			earlyAgeSpeed = 1/Global.EARLY_AGE_SECONDS,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 1/Global.GUY_SECONDS,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
	},
	goal = {
		planet1 = {
			philosopher = 1,
			inventor = 2,
			scientist = 3,
		},
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 160,
		image = "sun",
	},
	asteroids = {
		{
			pos = util.RotateVector({-1000, 0}, 3.2),
			orbitMult = 1.05,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({600, 1450}, 0.7),
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({1200, -400}, 5.4),
			orbitMult = 0.9,
			typeName = "asteroid_big",
		},
		{
			pos = {350, 1450},
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({400, 1200}, -1.5),
			orbitMult = 0.99,
			typeName = "asteroid_med",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
