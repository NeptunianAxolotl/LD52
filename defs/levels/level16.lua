
local SPAWN_TIME_MULT = 0.35

local def = {
	humanName = "Imperial Seat",
	description = [[
This system looks familiar...but it appears on the harvester register. It must just be a bit overripe, right?

Something tells me we won't have to worry about retirement after this.
]],
	nextLevel = "level17",
	prevLevel = "level15",
	gravity = 28,
	starCount = 2500,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 50,
			speedMax = 250,
			orbitMult = 0.6,
			orbitMultRand = 0.4,
			orbitOtherDirChance = 0.2,
			topBotChance = 0.2,
			avoidOrbitOverWrap = true,
			spawnRange = 0.9,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 20) / (count + 7) * (1 - (count + 3) / (count + 50))
			end,
		},
		{
			timeMin = 70 * SPAWN_TIME_MULT,
			timeRand = 45 * SPAWN_TIME_MULT,
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
			timeMin = 8,
			timeRand = 20,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.5,
			typeName = {"smuggler", "smuggler_slow"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				return 1 - 0.6 * (count / (count + 4))
			end,
		},
		{
			timeMin = 4,
			timeRand = 7,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitMultBothDirections = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.5,
			typeName = {"police", "police", "police_slow"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("police")
				local pastCount = GameHandler.CountObject("police_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount <= 2 then
					return 5 - pastCount
				end
				return 1 - 0.5 * (count / (count + 4))
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({1420, 0}, 0.2),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0,
			orbitMult = 0.95,
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
		{
			name = "planet2",
			pos = util.RotateVector({-780, 0}, 5.5),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = -0.99,
			age = "modern",
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
			scientist = 4
		},
		planet2 = {
			philosopher = 1,
			inventor = 2,
			scientist = 3,
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
			pos = {800, -500},
			orbitMult = 1.2,
			orbitAngle = 0.1,
			typeName = "asteroid_big",
		},
		{
			pos = {1200, 500},
			orbitMult = 1,
			orbitAngle = 0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {-800, -700},
			orbitMult = 0.9,
			orbitAngle = 0.1,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({-1000, 0}, 1.2),
			orbitMult = 1.05,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({350, 1450}, 0.3),
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({350, 1450}, 2.4),
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({350, 1450}, -1.8),
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({400, 1200}, -4.),
			orbitMult = 0.99,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({400, 1200}, -1.7),
			orbitMult = 0.99,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({400, 1350}, 2),
			orbitMult = 0.99,
			typeName = "asteroid_huge",
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
