
local SPAWN_TIME_MULT = 2.5

local def = {
	humanName = "Whirlpool",
	description = [[
If this star sucked any harder, it might just pull the planet apart.

It looks like someone dropped a whole asteroid belt in here, too.
]],
	prevLevel = "level9",
	nextLevel = "level11",
	gravity = 50,
	starCount = 1150,
	asteroidSpawn = {
		{
			timeMin = 1.5 * SPAWN_TIME_MULT,
			timeRand = 0.8 * SPAWN_TIME_MULT,
			speedMin = 0,
			speedMax = 10,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 1,
			avoidOrbitOverWrap = true,
			forceTop = true,
			spawnRange = 0.3,
			spawnOffset = -0.15,
			typeName = {"asteroid_med", "asteroid_med", "asteroid_med", "asteroid_big"},
		},
		{
			timeMin = 1.5 * SPAWN_TIME_MULT,
			timeRand = 0.8 * SPAWN_TIME_MULT,
			speedMin = 0,
			speedMax = 10,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 1,
			avoidOrbitOverWrap = true,
			forceBottom = true,
			spawnRange = 0.3,
			spawnOffset = 0.15,
			typeName = {"asteroid_med", "asteroid_med", "asteroid_med", "asteroid_big"},
		},
		{
			timeMin = 3 * SPAWN_TIME_MULT,
			timeRand = 1 * SPAWN_TIME_MULT,
			speedMin = 0,
			speedMax = 10,
			orbitMult = 0.4,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			avoidOrbitOverWrap = true,
			forceLeft = true,
			spawnRange = 0.3,
			spawnOffset = -0.15,
			typeName = {"asteroid_med", "asteroid_med", "asteroid_med", "asteroid_big"},
		},
		{
			timeMin = 3 * SPAWN_TIME_MULT,
			timeRand = 1 * SPAWN_TIME_MULT,
			speedMin = 0,
			speedMax = 10,
			orbitMult = 0.4,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			avoidOrbitOverWrap = true,
			forceRight = true,
			spawnRange = 0.3,
			spawnOffset = 0.15,
			typeName = {"asteroid_med", "asteroid_med", "asteroid_med", "asteroid_big"},
		},
		{
			timeMin = 70,
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
			timeMin = 50,
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
				if pastCount == 0 then
					return 1
				end
				if count == 0 then
					return 1
				elseif count == 1 then
					return 0.5
				end
				return 0.2
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-900, 0}, 2.5),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 0.98,
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
			philosopher = 2,
			inventor = 3,
			scientist = 2,
		},
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 200,
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
