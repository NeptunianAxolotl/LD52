
local SPAWN_TIME_MULT = 1.8

local def = {
	humanName = "Passing Through",
	description = [[
Your guess is as good as ours.  Just harvest enough from the planet before whatever happens, happens.

At there are barely any asteroids.
]],
	prevLevel = "level11",
	nextLevel = "level13",
	gravity = 16,
	starCount = 650,
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
			spawnRange = 0.8,
			typeName = {"asteroid_big", "asteroid_big", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				return (count + 30) / (count + 7) * (1 - (count + 3) / (count + 50))
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
			spawnRange = 0.9,
			spawnOffset = 0,
			typeName = {"smuggler"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				local pastCount = GameHandler.CountObject("smuggler_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					return 1.5
				end
				if count == 0 then
					return 1 * (1 + techCount*0.5)
				elseif count == 1 then
					return 0.5 * (1 + techCount*0.5)
				end
				return 0.2
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-1600, 0}, 0.6),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 1.5,
			orbitAngle = -0.2,
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
			inventor = 2,
			scientist = 2,
		},
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 165,
		image = "sun",
	},
	asteroids = {
		{
			pos = util.RotateVector({-1000, 0}, 7.5),
			orbitMult = 1.05,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({600, 1450}, 1.98),
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_med",
		},
		{
			pos = util.RotateVector({1200, -400}, 1.2),
			orbitMult = 0.9,
			orbitAngle = 0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {350, 1450},
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			pos = util.RotateVector({400, 1200}, -5.5),
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
