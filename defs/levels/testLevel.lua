
local SPAWN_TIME_MULT = 1.8

local def = {
	humanName = "Test Level",
	description = [[
etBody Returns the body the fixture is attached to. Added since 0.8.0 
Fixture BoundingBox Returns the points of the fixture bounding box. Added since 0.8.0 
Fixture Category Returns the categories the fixture belongs to. Added since 0.8.0 
Fixture Category Returns the categories the fixture belongs to. Added
]],
	nextLevel = "level1",
	gravity = 100,
	starCount = 1200,
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
			typeName = {"asteroid_med", "asteroid_med", "asteroid_med", "asteroid_big", "monolith"},
			spawnRateFunc = function ()
				return 20 * (20 / (20 + GameHandler.CountObject("asteroid")))
			end,
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
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.3,
			spawnOffset = -0.15,
			typeName = {"smuggler_slow"},
		},
		{
			timeMin = 1.5 * SPAWN_TIME_MULT,
			timeRand = 0.8 * SPAWN_TIME_MULT,
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
		},
	},
	planets = {
		{
			name = "Planet 1",
			humanName = "FORCED",
			forcePlanetType = "planet1",
			pos = {-1000, 0},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			age = "stone",
			maxAge = "space",
			shootRateMult = 2,
			earlyAgeSpeed = 1/10,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 1/2,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
		{
			name = "Saphirre",
			pos = {0, -1000},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			age = "classical",
			maxAge = "space",
			shootRateMult = 2,
			earlyAgeSpeed = 1/10,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 1/2,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
		{
			name = "Saphirre 2",
			pos = {300, -1000},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			age = "classical",
			maxAge = "space",
			shootRateMult = 2,
			earlyAgeSpeed = 1/10,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 1/2,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
		{
			name = "Saphirre 3",
			pos = {-300, -1000},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			age = "classical",
			maxAge = "space",
			shootRateMult = 2,
			earlyAgeSpeed = 1/10,
			lateAgeSpeed = 1/Global.LATE_AGE_SECONDS,
			guySpeed = 1/2,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
	},
	goal = {
		["Planet 1"] = {
			philosopher = 6,
			inventor = 6,
			scientist = 6,
		},
		["Saphirre"] = {
			philosopher = 6,
			inventor = 6,
			scientist = 6,
		},
		["Saphirre 2"] = {
			philosopher = 6,
			inventor = 6,
			scientist = 6,
		},
		["Saphirre 3"] = {
			philosopher = 6,
			inventor = 6,
			scientist = 6,
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
			typeName = "asteroid_huge",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -0.95,
	},
}

return def
