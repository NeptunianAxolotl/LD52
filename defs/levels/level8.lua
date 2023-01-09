
local SPAWN_TIME_MULT = 0.95

local def = {
	humanName = "Counter-System",
	description = [[
Our client wants one Great Mind of each type from both planets. They say the Minds work best in pairs.

We're pretty sure they just like watching culture shock.
]],
	prevLevel = "level7",
	nextLevel = "level9",
	gravity = 22,
	starCount = 900,
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
				return (count + 30) / (count + 7) * (1 - (count + 3) / (count + 50))
			end,
		},
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-800, 0}, 4.5),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.02,
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
		{
			name = "planet2",
			pos = util.RotateVector({-800, 0}, 4.5 + math.pi),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.02,
			age = "bronze",
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
			inventor = 1,
			scientist = 1,
		},
		planet2 = {
			philosopher = 1,
			inventor = 1,
			scientist = 1,
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
			pos = util.RotateVector({-1000, 0}, 2.5),
			orbitMult = 1.05,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({600, 1450}, 0.98),
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({1200, -400}, 2.2),
			orbitMult = 0.7,
			orbitAngle = -0.42,
			typeName = "asteroid_big",
		},
		{
			pos = {350, 1450},
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({400, 1200}, -2.5),
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
