
local SPAWN_TIME_MULT = 0.8
local ENEMY_TIME_MULT = 0.8

local def = {
	humanName = "Rule of Three",
	description = [[
Some say three is an auspicious number.  We say, let them pay a premium for the philosophers from this system.

Be sure not to let any planet advance too far, at least before being harvested.
]],
	prevLevel = "level13",
	nextLevel = "level15",
	gravity = 25,
	starCount = 860,
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
		{
			timeMin = 60 * SPAWN_TIME_MULT,
			timeRand = 20 * SPAWN_TIME_MULT,
			speedMin = 5,
			speedMax = 20,
			orbitMult = 0.6,
			orbitMultRand = 0.4,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.1,
			avoidOrbitOverWrap = true,
			spawnRange = 0.4,
			typeName = {"asteroid_huge"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 20) / (count + 7) * (1 - (count + 3) / (count + 50))
			end,
		},
	},
	shipSpawn = {
		{
			timeMin = 8 * ENEMY_TIME_MULT,
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
				return 1 - 0.6 * (count / (count + 8))
			end,
		},
		{
			timeMin = 15 * ENEMY_TIME_MULT,
			timeRand = 40 * ENEMY_TIME_MULT,
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
			pos = util.RotateVector({-880, 0}, 3.2),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0,
			orbitMult = 0.95,
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
			name = "planet2",
			pos = util.RotateVector({-880, 0}, 3.2 + math.pi*2/3),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 0.95,
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
			name = "planet3",
			pos = util.RotateVector({-880, 0}, 3.2 - math.pi*2/3),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.25,
			orbitMult = 0.95,
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
			philosopher = 3,
		},
		planet2 = {
			philosopher = 3,
		},
		planet3 = {
			philosopher = 3,
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
			pos = util.RotateVector({-1000, 0}, 8),
			orbitMult = 1.05,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({350, 1450}, 0),
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({350, 1450}, 2.1),
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({350, 1450}, -2.1),
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({400, 1200}, -4.5),
			orbitMult = 0.99,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({400, 1200}, -1.2),
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
