
local SPAWN_TIME_MULT = 0.95

local def = {
	humanName = "Finely Aged",
	description = [[
This planet was left unsupervised for a bit too long. The handbook advises against this, as it can cause planets to resist harvesting.

Nothing an asteroid or three won't solve.
]],
	prevLevel = "level8",
	nextLevel = "level10",
	gravity = 18,
	starCount = 750,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 50,
			speedMax = 250,
			orbitMult = 0.6,
			orbitMultRand = 0.4,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.5,
			avoidOrbitOverWrap = true,
			spawnRange = 0.4,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 20) / (count + 7) * (1 - (count + 3) / (count + 50))
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
			timeMin = 60,
			timeRand = 30,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitOtherDirChance = 0.2,
			topBotChance = 0,
			avoidOrbitOverWrap = false,
			spawnRange = 0.7,
			spawnOffset = 0,
			typeName = {"police_slow"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("police")
				local pastCount = GameHandler.CountObject("police_total")
				local spaceCount = GameHandler.CountObject("spaceAge")
				if pastCount <= 1 then
					if spaceCount > 0 then
						return 0
					end
					return 100 - pastCount*85
				end
				return 1 - 0.5 * (count / (count + 1))
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-950, 0}, 2.5),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 0.98,
			age = "space",
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
			inventor = 3,
			scientist = 3,
		},
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 180,
		image = "sun",
	},
	asteroids = {
		{
			pos = util.RotateVector({1350, 0}, 3.5),
			orbitMult = 1.05,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({1200, 0}, 1.4),
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({1700, 0}, 3.7),
			orbitMult = 1.05,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({1800, 0}, 0.4),
			orbitMult = 1.2,
			typeName = "asteroid_huge",
		},
		{
			pos = {350, 1450},
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({980, 0}, 2.4),
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
