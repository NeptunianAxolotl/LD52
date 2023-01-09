
local SPAWN_TIME_MULT = 1.4
local ENEMY_TIME_MULT = 2.2

local def = {
	humanName = "Squeeze Past",
	description = [[
Let sleeping giants lie.

The sun is your greatest ally.

Good luck.
]],
	prevLevel = "level12",
	nextLevel = "level14",
	gravity = 32,
	starCount = 980,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 20,
			speedMax = 60,
			orbitMult = 0.8,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.05,
			avoidOrbitOverWrap = true,
			spawnRange = 0.9,
			typeName = {"asteroid_huge"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 30) / (count + 4) * (1 - (count + 3) / (count + 50))
			end,
		},
	},
	shipSpawn = {
		{
			timeMin = 30 * ENEMY_TIME_MULT,
			timeRand = 12 * ENEMY_TIME_MULT,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitOtherDirChance = 0.2,
			topBotChance = 0,
			avoidOrbitOverWrap = false,
			spawnRange = 0.9,
			spawnOffset = 0,
			typeName = {"smuggler"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				local pastCount = GameHandler.CountObject("smuggler_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 4 -- Spawn quickly first time
				end
				return 1 - 0.6 * (count / (count + 6))
			end,
		},
		{
			timeMin = 20 * ENEMY_TIME_MULT,
			timeRand = 5 * ENEMY_TIME_MULT,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitOtherDirChance = 0.2,
			topBotChance = 0,
			avoidOrbitOverWrap = false,
			spawnRange = 0.7,
			spawnOffset = 0,
			typeName = {"police"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("police")
				local pastCount = GameHandler.CountObject("police_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 5
				end
				return 1 - 0.6 * (count / (count + 8))
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-1100, 0}, 0.2),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0,
			orbitMult = 0.72,
			age = "stone",
			maxAge = "space",
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
		radius = 175,
		image = "sun",
	},
	asteroids = {
		{
			pos = util.RotateVector({-1000, 0}, 1),
			orbitMult = 1.05,
			typeName = "asteroid_huge",
		},
		{
			pos = {350, 1450},
			orbitMult = 0.98,
			typeName = "asteroid_huge",
		},
		{
			pos = util.RotateVector({400, 1500}, -4.5),
			orbitMult = 1.4,
			typeName = "asteroid_huge",
		},
		{
			pos = util.RotateVector({400, 700}, -1.2),
			orbitMult = 0.9,
			typeName = "asteroid_huge",
		},
		{
			pos = util.RotateVector({400, 1500}, 1.2),
			orbitMult = 1.4,
			typeName = "asteroid_huge",
		},
		{
			pos = util.RotateVector({1200, 0}, -1.2),
			orbitMult = 0.9,
			typeName = "asteroid_huge",
		},
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
