
local SPAWN_TIME_MULT = 3
local ENEMY_TIME_MULT = 0.7

local def = {
	humanName = "Confluence",
	description = [[
This system is  ripe for the taking. Unfortunately, this makes it hotly contested.
]],
	prevLevel = "level10",
	nextLevel = "level12",
	gravity = 25,
	starCount = 1900,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 5,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.05,
			avoidOrbitOverWrap = true,
			spawnRange = 0.9,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 30) / (count + 4) * (1 - (count + 3) / (count + 50))
			end,
		},
		{
			timeMin = 50,
			timeRand = 30,
			speedMin = 20,
			speedMax = 70,
			orbitMult = 0.7,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.4,
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
			spawnRange = 0.9,
			spawnOffset = 0,
			typeName = {"smuggler_slow", "smuggler"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				local pastCount = GameHandler.CountObject("smuggler_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 4 -- Spawn quickly first time
				end
				return 1 - 0.6 * (count / (count + 8))
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
			typeName = {"police_slow", "police_slow", "police"},
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
			name = "planet2",
			pos = util.RotateVector({-1150, 0}, 2),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.02,
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
		{
			name = "planet1",
			pos = util.RotateVector({-700, 0}, 4),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.02,
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
			inventor = 1,
			scientist = 2,
		},
		planet2 = {
			philosopher = 2,
			inventor = 1,
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
			pos = util.RotateVector({-1000, 0}, 5),
			orbitMult = 1.05,
			typeName = "asteroid_med",
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
