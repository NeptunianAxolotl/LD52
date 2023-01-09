
local SPAWN_TIME_MULT = 3.5

local def = {
	humanName = "Slow Primates",
	description = [[
The inhabitants of this system are a bit thick.

Luckily a frieghter of monoliths (sapience guranteed!) just had an "accident" nearby.

Nudge the monoliths onto the planet to help things along.
]],
	prevLevel = "level5",
	nextLevel = "level7",
	gravity = 12,
	starCount = 480,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 5,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.2,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.8,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 10) / (count + 5) * (1 - (count + 3) / (count + 20))
			end,
		},
		{
			timeMin = 10,
			timeRand = 5,
			speedMin = 20,
			speedMax = 75,
			orbitMult = 0.7,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.05,
			avoidOrbitOverWrap = true,
			spawnRange = 0.6,
			typeName = {"monolith"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("monolith")
				return 1 - 0.7 * (count / (count + 6))
			end,
		},
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-1000, 0}, -2),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0,
			orbitMult = 0.99,
			age = "stone",
			maxAge = "modern",
			shootRateMult = 1,
			earlyAgeSpeed = 0/Global.EARLY_AGE_SECONDS,
			lateAgeSpeed = 0/Global.LATE_AGE_SECONDS,
			guySpeed = 1/Global.GUY_SECONDS,
			guyGap = 0,
			guyAgeBoost = 1,
			fillLastAge = false,
		},
	},
	goal = {
		planet1 = {
			philosopher = 2,
			inventor = 2,
			scientist = 2,
		}
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 160,
		image = "sun",
	},
	asteroids = {
		{
			pos = {1100, -500},
			orbitMult = 0.8,
			orbitAngle = 0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {-1400, 300},
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {1500, 200},
			orbitMult = 0.95,
			orbitAngle = -0.05,
			typeName = "monolith",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
