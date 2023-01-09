
local SPAWN_TIME_MULT = 1

local def = {
	humanName = "Sophistication",
	description = [[
Different types of people come from different ages.

Great minds in an age help civilizations grow significantly faster.

However, they also cause stagnation at the end of an age, and must be removed to allow the planet to progress.

You can hit the planet with things to revert progress.
]],
	prevLevel = "level1",
	nextLevel = "level3",
	gravity = 16,
	starCount = 850,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 20,
			speedMax = 70,
			orbitMult = 0.6,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.3,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.6,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 18) / (count + 3) * (1 - (count + 3) / (count + 20))
			end,
		},
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-480, 0}, -1),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.18,
			age = "stone",
			maxAge = "invention",
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
			philosopher = 2,
			inventor = 1
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
			pos = {1200, -400},
			orbitMult = 0.75,
			orbitAngle = -0.38,
			typeName = "asteroid_big",
		},
		{
			pos = {1000, 700},
			orbitMult = -0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {-800, -700},
			orbitMult = 0.95,
			orbitAngle = -0.05,
			typeName = "asteroid_huge",
		},
		{
			-- Harmless, taget practice
			pos = util.RotateVector({400, 1300}, -0.5),
			orbitMult = 0.98,
			typeName = "asteroid_med",
		},
		{
			-- Harmless, taget practice
			pos = {-1400, 300},
			orbitMult = 1.05,
			typeName = "asteroid_big",
		},
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
