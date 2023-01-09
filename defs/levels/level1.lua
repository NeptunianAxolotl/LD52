
local SPAWN_TIME_MULT = 1

local def = {
	humanName = "A Lively Debate",
	description = [[
Protect the planet and harvest the people.  Watch out for the asteroids!

The quota has gone up.  The buyer wants two philosophers this time, so he can watch them argue with each other.
]],
	nextLevel = "level2",
	prevLevel = "level0_a",
	gravity = 15,
	starCount = 750,
	asteroidSpawn = {
		{
			timeMin = 10 * SPAWN_TIME_MULT,
			timeRand = 5 * SPAWN_TIME_MULT,
			speedMin = 2,
			speedMax = 6,
			orbitMult = 0.5,
			orbitMultRand = 0.2,
			orbitOtherDirChance = 0,
			topBotChance = 0,
			avoidOrbitOverWrap = true,
			spawnRange = 0.5,
			typeName = {"asteroid_big", "asteroid_med", "asteroid_med"},
			spawnRateFunc = function ()
				local count = GameHandler.CountObject("asteroid")
				if count < 2 then
					return 4
				end
				return ((count + 9) / (count + 3)) * (1 - (count + 3) / (count + 20))
			end,
		},
	},
	shipSpawn = {
	},
	planets = {
		{
			name = "planet1",
			pos = {-1000, 0},
			radius = Global.PLANET_RADIUS,
			density = 150,
			ageProgress = 0.15,
			age = "stone",
			maxAge = "classical",
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
			philosopher = 2
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
			-- Designed to hit the planet early
			pos = util.RotateVector({-1000, 0}, 2.5),
			orbitMult = -1.005,
			typeName = "asteroid_med",
		},
		{
			-- Designed to hit the planet in the middle
			pos = util.RotateVector({600, 1450}, 0.98),
			orbitMult = 0.95,
			orbitAngle = -0.2,
			typeName = "asteroid_med",
		},
		{
			-- Designed to hit the planet in the classical age
			pos = util.RotateVector({1200, -400}, 2.2),
			orbitMult = 0.7,
			orbitAngle = -0.2,
			typeName = "asteroid_big",
		},
		{
			-- Harmless, taget practice
			pos = {350, 1450},
			orbitMult = 0.98,
			typeName = "asteroid_big",
		},
		{
			-- Harmless, taget practice
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
