
local SPAWN_TIME_MULT = 3.5

local def = {
	humanName = "Detritus",
	description = [[
Some joker seeded a planet in the path of an industrial matter dump.  A highly illegal dump, full of smugglers.

Just salvage what you can.  So, ideally, all of it.
]],
	prevLevel = "level14",
	nextLevel = "level16",
	gravity = 60,
	starCount = 980,
	asteroidSpawn = {
		{
			timeMin = 1.5 * SPAWN_TIME_MULT,
			timeRand = 0.8 * SPAWN_TIME_MULT,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 1,
			avoidOrbitOverWrap = true,
			spawnRange = 0.3,
			spawnOffset = -0.16,
			typeName = {
				"asteroid_small", "asteroid_med", "asteroid_small", "asteroid_med", "asteroid_big", "asteroid_big", "asteroid_big","asteroid_med",
				"asteroid_small","asteroid_med", "asteroid_small","asteroid_med", "asteroid_small", "asteroid_big", "asteroid_small", "asteroid_med",
				"asteroid_small", "asteroid_med", "asteroid_med", "asteroid_big", "asteroid_big", "asteroid_big", "asteroid_big", "asteroid_small",
				"asteroid_med", "asteroid_small", "asteroid_med", "asteroid_big", "asteroid_big", "asteroid_big","asteroid_med", "asteroid_small",
				"asteroid_med", "asteroid_small","asteroid_med", "asteroid_small", "asteroid_med", "asteroid_small", "asteroid_med", "asteroid_small",
				"asteroid_med", "asteroid_med", "asteroid_big", "asteroid_big", "asteroid_big", "asteroid_huge", "monolith"
			},
			spawnRateFunc = function ()
				return 20 * (25 / (25 + GameHandler.CountObject("asteroid")))
			end,
		},
	},
	shipSpawn = {
		{
			timeMin = 1.5,
			timeRand = 5,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.3,
			spawnOffset = -0.15,
			typeName = {"smuggler"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				local pastCount = GameHandler.CountObject("smuggler_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 4 -- Spawn quickly first time
				end
				return 1 - 0.6 * (count / (count + 4))
			end,
		},
		{
			timeMin = 8,
			timeRand = 20,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.3,
			spawnOffset = -0.15,
			typeName = {"police"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("police")
				local pastCount = GameHandler.CountObject("police_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 5
				end
				return 1 - 0.6 * (count / (count + 5))
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = {-950, 350},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 0.93,
			age = "stone",
			maxAge = "space",
			shootRateMult = 2,
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
			inventor = 3,
			scientist = 3,
		}
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 220,
		image = "sun",
	},
	asteroids = {
	},
	player = {
		pos = {-300, -500},
		orbitMult = -0.95,
	},
}

return def
