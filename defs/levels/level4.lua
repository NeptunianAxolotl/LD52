
local SPAWN_TIME_MULT = 1.2

local def = {
	humanName = "Science Victory",
	description = [[
We have a buyer for some more modern thinkers.

Great Minds increase the rate of advancement while they remain on the planet.
]],
	prevLevel = "level3",
	nextLevel = "level5",
	gravity = 25,
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
				return (count + 20) / (count + 7)
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
			typeName = {"smuggler_slow"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("smuggler")
				local pastCount = GameHandler.CountObject("smuggler_total")
				local techCount = GameHandler.CountObject("highTech")
				if pastCount == 0 then
					if techCount == 1 then
						return 1.5
					end
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
			pos = util.RotateVector({-1050, 0}, 4.5),
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
			scientist = 4
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
			pos = {-200, 500},
			orbitMult = 0.8,
			orbitAngle = 0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {500, 200},
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_big",
		},
		{
			pos = {500, -700},
			orbitMult = 0.95,
			orbitAngle = -0.05,
			typeName = "asteroid_big",
		},
		{
			pos = {800, -650},
			orbitMult = 1.1,
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
