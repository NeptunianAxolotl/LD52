
local SPAWN_TIME_MULT = 1

local def = {
	humanName = "Sophistication",
	description = [[
Different types of people come from different ages.

Great minds in an age help progress greatly.
]],
	prevLevel = "level1",
	nextLevel = "level3",
	gravity = 20,
	starCount = 1200,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 10,
			speedMax = 35,
			orbitMult = 0.7,
			orbitMultRand = 0.3,
			orbitOtherDirChance = 0.3,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.6,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 12) / (count + 3) * (1 - (count + 3) / (count + 15))
			end,
		},
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-500, 0}, -1),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.18,
			age = "stone",
			maxAge = "invention",
			shootRateMult = 1,
			earlyAgeSpeed = 1/12,
			lateAgeSpeed = 1/50,
			guySpeed = 1/12,
			guyGap = 0,
			guyAgeBoost = 6,
			fillLastAge = false,
		},
	},
	goal = {
		planet1 = {
			philosopher = 2,
			inventor = 2
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
			typeName = "asteroid_big",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
