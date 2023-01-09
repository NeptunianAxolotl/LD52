
local SPAWN_TIME_MULT = 1.3

local def = {
	humanName = "Competition",
	description = [[
There is a smuggler
]],
	prevLevel = "level2",
	nextLevel = "level4",
	gravity = 18,
	starCount = 1200,
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
				return (count + 12) / (count + 3) * (1 - (count + 3) / (count + 15))
			end,
		},
	},
	shipSpawn = {
		{
			timeMin = 20,
			timeRand = 5,
			speedMin = 0,
			speedMax = 20,
			orbitMult = 0.8,
			orbitMultRand = 0.1,
			orbitOtherDirChance = 0.2,
			topBotChance = 0,
			avoidOrbitOverWrap = false,
			spawnRange = 0.9,
			spawnOffset = 0,
			typeName = {"smuggler_slow"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				local pastCount = GameHandler.CountObject("smuggler_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					if techCount == 1 then
						return 4 -- Spawn quickly first time
					end
				end
				if count == 0 then
					return 1 * (1 + techCount*0.5)
				elseif count == 1 then
					return 0.2 * (1 + techCount*0.5)
				end
				return 0
			end,
		},
	},
	planets = {
		{
			name = "planet1",
			pos = util.RotateVector({-1250, 0}, 1),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.5,
			orbitMult = 0.9,
			age = "bronze",
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
			philosopher = 3,
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
			pos = {1000, -700},
			orbitMult = 0.8,
			orbitAngle = 0.38,
			typeName = "asteroid_big",
		},
		{
			pos = {1200, 500},
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {-600, -700},
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
