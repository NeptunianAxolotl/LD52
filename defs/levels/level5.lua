
local SPAWN_TIME_MULT = 0.7

local def = {
	humanName = "Cooperation",
	description = [[
The Gorlaxians have an undeveloped planet in their system and have agreed to look the other way.

They can take care of themselves.
]],
	prevLevel = "level4",
	nextLevel = "level6",
	gravity = 18,
	starCount = 860,
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
				return (count + 20) / (count + 5)
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
			humanName = "Gorlax II",
			pos = util.RotateVector({-1400, 0}, 1),
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
			pos = util.RotateVector({-900, 0}, 3),
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0,
			orbitMult = 0.95,
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
		planet2 = {
			philosopher = 3,
			inventor = 2,
			scientist = 1
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
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -1.2,
	},
}

return def
