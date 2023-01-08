
local SPAWN_TIME_MULT = 1.8

local def = {
	name = "Drain Circling",
	nextLevel = "level1",
	gravity = 100,
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
			spawnOffset = -0.15,
			typeName = "asteroid_med",
		},
	},
	shipSpawn = {
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
			spawnOffset = -0.15,
			typeName = "smuggler",
		},
	},
	planets = {
		{
			pos = {-1000, 0},
			radius = 95,
			density = 150,
			age = "classical",
			maxAge = "space",
			shootRateMult = 2,
			ageSpeed = 1/4,
			guySpeed = 1/2,
			guyGap = 0,
			guyAgeBoost = 1.5,
			fillLastAge = false,
		},
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 200,
		image = "sun",
	},
	asteroids = {
		{
			pos = {1000, 0},
			orbitMult = -1,
			typeName = "asteroid_big",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -0.95,
	},
}

return def
